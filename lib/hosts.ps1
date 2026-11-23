# Managed block in the Windows hosts file.
# Only the block between the two markers is ever touched.

$HostsFile = Join-Path $env:SystemRoot 'System32\drivers\etc\hosts'
$HostsMarkerStart = '# WampDeck - start (managed block, do not edit)'
$HostsMarkerEnd = '# WampDeck - end'

function Get-RequiredHosts {
    $entries = New-Object System.Collections.Generic.List[string]
    $seen = @{}
    foreach ($project in @(Get-ProjectList)) {
        foreach ($name in @($project.Hosts)) {
            if (-not $name) { continue }
            if (-not $seen.ContainsKey($name)) {
                $seen[$name] = $true
                $entries.Add("127.0.0.1`t$name")
            }
        }
    }
    return $entries
}

function Get-HostsManagedBlock {
    $entries = @(Get-RequiredHosts)
    if ($entries.Count -eq 0) { return '' }
    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add($HostsMarkerStart)
    foreach ($entry in $entries) { $lines.Add($entry) }
    $lines.Add($HostsMarkerEnd)
    return ($lines -join "`r`n")
}

function Remove-HostsManagedBlock {
    param([string]$Content)
    $pattern = '(?s)\r?\n?' + [regex]::Escape($HostsMarkerStart) + '.*?' + [regex]::Escape($HostsMarkerEnd) + '\r?\n?'
    return ([regex]::Replace($Content, $pattern, "`r`n"))
}

function Get-HostsContent {
    if (-not (Test-Path $HostsFile)) { return '' }
    return [System.IO.File]::ReadAllText($HostsFile)
}

function Sync-HostsFile {
    param([switch]$Force)

    if (-not (Test-Admin)) {
        throw 'Writing the hosts file needs administrator rights. Use Invoke-HostsSyncElevated.'
    }

    $current = Get-HostsContent
    $cleaned = (Remove-HostsManagedBlock -Content $current).TrimEnd()
    $block = Get-HostsManagedBlock

    if ($block) {
        $updated = if ($cleaned) { $cleaned + "`r`n`r`n" + $block + "`r`n" } else { $block + "`r`n" }
    } else {
        $updated = if ($cleaned) { $cleaned + "`r`n" } else { '' }
    }

    if (-not $Force -and $updated -eq $current) { return $true }

    try {
        [System.IO.File]::WriteAllText($HostsFile, $updated, [System.Text.Encoding]::ASCII)
        return $true
    } catch {
        throw "Could not write $HostsFile - $($_.Exception.Message)"
    }
}

function Invoke-HostsSyncElevated {
    if (Test-Admin) {
        Sync-HostsFile -Force
        return $true
    }

    Ensure-Dir $TmpDir
    $script = Join-Path $TmpDir 'sync-hosts.ps1'
    $configPath = Join-Path $Root 'config.ps1'
    $commonPath = Join-Path $Root 'lib\common.ps1'
    $modulePath = Join-Path $Root 'lib\hosts.ps1'

    $content = @"
`$ErrorActionPreference = 'Stop'
. '$configPath'
. '$commonPath'
. '$modulePath'
Sync-HostsFile -Force
"@
    Set-Content -Path $script -Value $content -Encoding ASCII

    try {
        $process = Start-Process -FilePath 'powershell.exe' `
            -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$script`"") `
            -Verb RunAs -WindowStyle Hidden -Wait -PassThru
        return ($process.ExitCode -eq 0)
    } catch {
        return $false
    } finally {
        Remove-Item $script -Force -ErrorAction SilentlyContinue
    }
}

function Get-HostsStatus {
    $content = Get-HostsContent
    $required = @(Get-RequiredHosts)
    $present = New-Object System.Collections.Generic.List[string]
    $missing = New-Object System.Collections.Generic.List[string]

    $lines = @($content -split "`r?`n" | ForEach-Object { $_.Trim() })
    foreach ($entry in $required) {
        $hostName = ($entry -split "`t")[1]
        $found = $false
        foreach ($line in $lines) {
            if ($line -match "^\s*127\.0\.0\.1\s+$([regex]::Escape($hostName))\s*$") {
                $found = $true
                break
            }
        }
        if ($found) { $present.Add($hostName) } else { $missing.Add($hostName) }
    }

    $managed = @()
    $match = [regex]::Match($content, '(?s)' + [regex]::Escape($HostsMarkerStart) + '(.*?)' + [regex]::Escape($HostsMarkerEnd))
    if ($match.Success -and $match.Groups[1].Value.Trim()) {
        $managed = @($match.Groups[1].Value.Trim() -split "`r?`n")
    }

    return [pscustomobject]@{
        File       = $HostsFile
        IsAdmin    = (Test-Admin)
        Required   = $required.Count
        Present    = $present.Count
        Missing    = @($missing)
        Synced     = ($missing.Count -eq 0)
        HasBlock   = $match.Success
        BlockLines = $managed
    }
}
