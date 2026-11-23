# Free public updater.
#
# Uses only GitHub's public release API. No paid service, no licence key, and
# no silent install: the installer is downloaded, checksum-verified, and then
# launched so the user stays in control of the UAC prompt and the wizard.

$script:WampDeckUpdateRepo = 'oryxindia/wampdeck'

function Get-WampDeckReleaseInfo {
    param([string]$Repo = $script:WampDeckUpdateRepo)

    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $release = Invoke-RestMethod `
            -Uri "https://api.github.com/repos/$Repo/releases/latest" `
            -Headers @{ 'User-Agent' = 'WampDeck-Updater'; Accept = 'application/vnd.github+json' } `
            -TimeoutSec 30 -ErrorAction Stop
        return $release
    } catch {
        throw "Could not check for updates: $($_.Exception.Message)"
    }
}

function ConvertTo-WampDeckVersionNumber {
    param([string]$Version)
    if (-not $Version) { return $null }
    $text = ([string]$Version).Trim() -replace '^v', ''
    $numeric = ($text -split '-')[0]
    try { return [version]$numeric } catch { return $null }
}

function Get-WampDeckPreRelease {
    param([string]$Version)
    $text = ([string]$Version).Trim() -replace '^v', ''
    if ($text -match '-([A-Za-z]+)\.?(\d*)') {
        return [pscustomobject]@{
            Label  = $Matches[1].ToLowerInvariant()
            Number = $(if ($Matches[2]) { [int]$Matches[2] } else { 0 })
        }
    }
    return $null
}

function Test-WampDeckUpdateAvailable {
    param([string]$Current, [string]$Latest)

    $a = ConvertTo-WampDeckVersionNumber -Version $Current
    $b = ConvertTo-WampDeckVersionNumber -Version $Latest
    if (-not $a -or -not $b) { return $false }

    if ($b -gt $a) { return $true }
    if ($b -lt $a) { return $false }

    # Same numeric version: a stable release is newer than any pre-release,
    # and a later beta is newer than an earlier one.
    $preA = Get-WampDeckPreRelease -Version $Current
    $preB = Get-WampDeckPreRelease -Version $Latest
    if ($preA -and -not $preB) { return $true }
    if ($preB -and -not $preA) { return $false }
    if ($preA -and $preB) { return ($preB.Number -gt $preA.Number) }
    return $false
}

function Invoke-WampDeckUpdate {
    param(
        [switch]$Check,
        [switch]$Yes,
        [string]$Repo = $script:WampDeckUpdateRepo
    )

    $release = Get-WampDeckReleaseInfo -Repo $Repo
    $latest = ([string]$release.tag_name).Trim() -replace '^v', ''
    $current = [string]$WampDeckVersion
    $newer = Test-WampDeckUpdateAvailable -Current $current -Latest $latest

    Write-Host ''
    Write-Host "  WampDeck update" -ForegroundColor Cyan
    Write-Host "    installed : $current" -ForegroundColor DarkGray
    Write-Host "    latest    : $latest" -ForegroundColor DarkGray
    Write-Host "    release   : $($release.html_url)" -ForegroundColor DarkGray
    Write-Host ''

    if ($Check) {
        Write-Host $(if ($newer) { '  A newer free release is available.' } else { '  You are up to date.' }) -ForegroundColor $(if ($newer) { 'Yellow' } else { 'Green' })
        Write-Host ''
        return 0
    }

    if (-not $newer) {
        Write-Host '  You are up to date.' -ForegroundColor Green
        Write-Host ''
        return 0
    }

    $asset = @($release.assets | Where-Object { $_.name -eq 'WampDeck-Setup.exe' } | Select-Object -First 1)
    $sums = @($release.assets | Where-Object { $_.name -eq 'SHA256SUMS.txt' } | Select-Object -First 1)
    if ($asset.Count -eq 0 -or $sums.Count -eq 0) {
        throw 'The release is missing WampDeck-Setup.exe or SHA256SUMS.txt.'
    }

    if (-not $Yes) {
        try { $answer = Read-Host '  Download and verify the update? (yes/no)' }
        catch { $answer = '' }
        if ($answer -notmatch '^(y|yes)$') {
            Write-Host '  Cancelled.' -ForegroundColor DarkGray
            Write-Host ''
            return 0
        }
    }

    $destDir = Join-Path $TmpDir 'update'
    Ensure-Dir $destDir
    $exePath = Join-Path $destDir 'WampDeck-Setup.exe'
    $sumPath = Join-Path $destDir 'SHA256SUMS.txt'

    Write-Host '  Downloading SHA256SUMS.txt ...' -ForegroundColor DarkGray
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $sums[0].browser_download_url -OutFile $sumPath -TimeoutSec 120 -UseBasicParsing -ErrorAction Stop

    Write-Host '  Downloading installer (about 425 MB) ...' -ForegroundColor DarkGray
    Invoke-WebRequest -Uri $asset[0].browser_download_url -OutFile $exePath -TimeoutSec 1800 -UseBasicParsing -ErrorAction Stop

    $expected = $null
    foreach ($line in @(Get-Content -Path $sumPath -ErrorAction SilentlyContinue)) {
        if ($line -match '(^|\s)([a-f0-9]{64})\s+WampDeck-Setup\.exe\s*$') {
            $expected = $Matches[2].ToLowerInvariant()
            break
        }
    }
    if (-not $expected) { throw 'SHA256SUMS.txt has no installer checksum.' }

    $actual = (Get-FileHash -Path $exePath -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actual -ne $expected) {
        Remove-Item $exePath -Force -ErrorAction SilentlyContinue
        throw "Checksum mismatch. The download was deleted; please try again."
    }
    Write-Host '  Checksum verified.' -ForegroundColor Green
    Write-Host "  Saved to $exePath" -ForegroundColor DarkGray
    Write-Host '  Launching the installer - approve UAC and keep C:\WampDeck.' -ForegroundColor White
    Start-Process -FilePath $exePath -ErrorAction Stop
    Write-Host ''
    return 0
}
