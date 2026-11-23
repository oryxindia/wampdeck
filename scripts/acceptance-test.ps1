# WampDeck acceptance test.
#
# Read-only smoke test for an installed WampDeck. It checks the layout,
# CLI, stack state, PHP workers, supervisor, MySQL, HTTP responses and
# (optionally) that project folders survived an upgrade untouched.
#
# Usage:
#   .\scripts\acceptance-test.cmd
#   .\scripts\acceptance-test.cmd -Root D:\WampDeck -ExpectedVersion 2.0.0-beta.2
#   .\scripts\acceptance-test.cmd -Projects blog,edupro -CaptureBaseline C:\acceptance\before.json
#   .\scripts\acceptance-test.cmd -Projects blog,edupro -Baseline C:\acceptance\before.json -Deep
#
# Exit codes: 0 pass, 1 failure or unaccepted warning, 2 bad arguments.

[CmdletBinding()]
param(
    [string]$Root = '',
    [string]$ExpectedVersion = '2.0.0-beta.2',
    [string[]]$Urls = @(),
    [string[]]$Projects = @(),
    [string]$CaptureBaseline = '',
    [string]$Baseline = '',
    [string]$ReportPath = '',
    [switch]$AllowWarnings,
    [switch]$SkipHttp,
    [switch]$SkipMysql,
    [switch]$Deep
)

$ErrorActionPreference = 'Stop'
$script:Checks = New-Object System.Collections.Generic.List[object]

function Write-Section {
    param([string]$Text)
    Write-Host ''
    Write-Host "  $Text" -ForegroundColor Cyan
}

function Add-Check {
    param(
        [string]$Id,
        [string]$Title,
        [ValidateSet('pass', 'warn', 'fail', 'skip')][string]$Status,
        [string]$Detail = ''
    )

    $check = [pscustomobject]@{
        id     = $Id
        title  = $Title
        status = $Status
        detail = $Detail
    }
    $script:Checks.Add($check)

    $tag = switch ($Status) {
        'pass' { '[PASS]' }
        'warn' { '[WARN]' }
        'fail' { '[FAIL]' }
        'skip' { '[SKIP]' }
    }
    $color = switch ($Status) {
        'pass' { 'Green' }
        'warn' { 'Yellow' }
        'fail' { 'Red' }
        'skip' { 'DarkGray' }
    }
    Write-Host ("  {0} {1,-28} {2}" -f $tag, $Id, $Title) -ForegroundColor $color
    if ($Detail) {
        Write-Host ("         {0}" -f $Detail) -ForegroundColor DarkGray
    }
}

function Resolve-WampDeckRoot {
    param([string]$Requested)

    if ($Requested) {
        $resolved = (Resolve-Path -LiteralPath $Requested -ErrorAction Stop).Path
        return $resolved.TrimEnd("\")
    }

    # Prefer the standard install. This lets the source-tree copy test the
    # installed product without passing -Root every time.
    if (Test-Path "C:\WampDeck\config.ps1") { return "C:\WampDeck" }

    $scriptDir = Split-Path -Parent $PSScriptRoot
    if (Test-Path (Join-Path $scriptDir "config.ps1")) { return $scriptDir }

    throw "WampDeck was not found. Pass -Root <install folder>."
}

function Invoke-Cli {
    param([string[]]$Arguments)

    $exe = Join-Path $script:Root 'wampdeck.cmd'
    if (-not (Test-Path $exe)) { throw "Missing $exe" }

    $output = @(& $exe @Arguments 2>&1)
    $code = $LASTEXITCODE
    $lines = @($output | ForEach-Object { "$_" })
    return [pscustomobject]@{
        ExitCode = $code
        Lines    = $lines
        Text     = ($lines -join "`n")
    }
}

function Convert-CliJson {
    param($Result, [string]$Command)

    if (-not $Result.Text.Trim()) {
        throw "$Command returned no output (exit $($Result.ExitCode))."
    }
    try {
        return ($Result.Text | ConvertFrom-Json -ErrorAction Stop)
    } catch {
        $preview = $Result.Text
        if ($preview.Length -gt 500) { $preview = $preview.Substring(0, 500) + '...' }
        throw "$Command did not return valid JSON (exit $($Result.ExitCode)): $preview"
    }
}

function Get-HttpCode {
    param(
        [string]$Url,
        [int]$TimeoutSeconds = 30
    )

    $request = [System.Net.HttpWebRequest]::Create($Url)
    $request.Proxy = $null
    $request.Timeout = $TimeoutSeconds * 1000
    $request.ReadWriteTimeout = $TimeoutSeconds * 1000
    $request.AllowAutoRedirect = $true
    $request.UserAgent = 'WampDeck-Acceptance/1.0'
    try {
        $response = $request.GetResponse()
        $code = [int]$response.StatusCode
        $response.Close()
        return $code
    } catch [System.Net.WebException] {
        if ($_.Exception.Response) {
            return [int]$_.Exception.Response.StatusCode
        }
        if ($_.Exception.Status -eq [System.Net.WebExceptionStatus]::Timeout) {
            throw "timed out after ${TimeoutSeconds}s"
        }
        # A refused or reset connection carries no InnerException, and throwing
        # its null message surfaces as a bare "ScriptHalted" in the report.
        $message = if ($_.Exception.InnerException) { $_.Exception.InnerException.Message } else { $_.Exception.Message }
        throw $message
    } finally {
        $request.Abort()
    }
}

function Get-FileSha256 {
    param([string]$Path)

    # .NET streaming is much faster than one Get-FileHash cmdlet per file.
    $share = [IO.FileShare]::ReadWrite -bor [IO.FileShare]::Delete
    $stream = [IO.File]::Open($Path, [IO.FileMode]::Open, [IO.FileAccess]::Read, $share)
    $sha = [Security.Cryptography.SHA256]::Create()
    try {
        return [BitConverter]::ToString($sha.ComputeHash($stream)).Replace("-", "")
    } finally {
        $sha.Dispose()
        $stream.Dispose()
    }
}

function Get-ProjectDirectories {
    param([string[]]$Names, [string]$RootPath)

    # powershell.exe -File binds "blog,edupro" as one string, so split it here.
    $expanded = @()
    foreach ($name in @($Names)) {
        foreach ($part in ($name -split ",")) {
            $trimmed = $part.Trim()
            if ($trimmed) { $expanded += $trimmed }
        }
    }

    $www = Join-Path $RootPath "www"
    if ($expanded.Count -gt 0) {
        foreach ($name in $expanded) {
            $dir = Join-Path $www $name
            if (-not (Test-Path -LiteralPath $dir -PathType Container)) {
                throw "Project folder not found: $dir"
            }
            [pscustomobject]@{ Name = $name; Path = $dir }
        }
        return
    }

    foreach ($dir in @(Get-ChildItem -LiteralPath $www -Directory -ErrorAction SilentlyContinue | Sort-Object Name)) {
        if ($dir.Name -in @("panel", "demo")) { continue }
        [pscustomobject]@{ Name = $dir.Name; Path = $dir.FullName }
    }
}

function Get-TreeFingerprint {
    param([string]$Path, [bool]$HashContent)

    $full = (Resolve-Path -LiteralPath $Path).Path.TrimEnd('\')
    $files = @(Get-ChildItem -LiteralPath $full -Recurse -File -Force -ErrorAction SilentlyContinue)
    $lines = New-Object System.Collections.Generic.List[string]
    $bytes = 0L

    foreach ($file in $files) {
        $bytes += $file.Length
        $line = '{0}|{1}|{2}' -f $file.FullName.Substring($full.Length), $file.Length, $file.LastWriteTimeUtc.Ticks
        if ($HashContent) {
            $line += '|' + (Get-FileSha256 -Path $file.FullName)
        }
        $lines.Add($line)
    }
    $lines.Sort()

    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $payload = [System.Text.Encoding]::UTF8.GetBytes(($lines -join "`n"))
        $digest = [System.BitConverter]::ToString($sha.ComputeHash($payload)).Replace('-', '')
    } finally {
        $sha.Dispose()
    }

    return [pscustomobject]@{
        path   = $full
        files  = $files.Count
        bytes  = $bytes
        digest = $digest
    }
}

# ---------------------------------------------------------------- root
try {
    $script:Root = Resolve-WampDeckRoot -Requested $Root
} catch {
    Write-Host "  [FAIL] $($_.Exception.Message)" -ForegroundColor Red
    exit 2
}

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)
$os = [Environment]::OSVersion.VersionString

Write-Host ''
Write-Host '  WampDeck acceptance test' -ForegroundColor White
Write-Host "  root      $script:Root" -ForegroundColor DarkGray
Write-Host "  expected  $ExpectedVersion" -ForegroundColor DarkGray
Write-Host "  windows   $os" -ForegroundColor DarkGray
Write-Host "  admin     $isAdmin" -ForegroundColor DarkGray

# ---------------------------------------------------------------- capture
if ($CaptureBaseline) {
    try {
        $dirs = @(Get-ProjectDirectories -Names $Projects -RootPath $script:Root)
        if ($dirs.Count -eq 0) { throw 'No project folders found under www\. Pass -Projects <name>.' }

        $state = [ordered]@{
            captured = (Get-Date).ToString('o')
            root     = $script:Root
            deep     = [bool]$Deep
            projects = [ordered]@{}
        }
        foreach ($dir in $dirs) {
            $fingerprint = Get-TreeFingerprint -Path $dir.Path -HashContent ([bool]$Deep)
            $state.projects[$dir.Name] = $fingerprint
            Write-Host ("  captured {0,-12} {1} files, {2} bytes" -f $dir.Name, $fingerprint.files, $fingerprint.bytes) -ForegroundColor Green
        }

        $parent = Split-Path -Parent $CaptureBaseline
        if ($parent -and -not (Test-Path $parent)) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
        [IO.File]::WriteAllText($CaptureBaseline, ($state | ConvertTo-Json -Depth 6), (New-Object System.Text.UTF8Encoding($false)))
        Write-Host "  baseline  $CaptureBaseline" -ForegroundColor DarkGray
        exit 0
    } catch {
        Write-Host "  [FAIL] $($_.Exception.Message)" -ForegroundColor Red
        exit 2
    }
}

# ---------------------------------------------------------------- layout
Write-Section 'Layout'

if (Test-Path (Join-Path $script:Root 'config.ps1')) {
    Add-Check 'install-root' 'Install folder exists' 'pass' $script:Root
} else {
    Add-Check 'install-root' 'Install folder exists' 'fail' "config.ps1 is missing under $script:Root"
}

$required = @(
    'WampDeck.exe',
    'wampdeck.cmd',
    'config.ps1',
    'README.md',
    'scripts\setup.ps1',
    'scripts\cli.ps1',
    'lib\bootstrap.ps1',
    'lib\doctor.ps1',
    'lib\supervisor.ps1',
    'bin\nginx\nginx.exe',
    'bin\apache\bin\httpd.exe',
    'bin\mysql\bin\mysqld.exe',
    'bin\mysql\bin\mysql.exe',
    'etc\nginx.conf',
    'etc\my.ini',
    'etc\stack.json',
    'www\panel\index.php'
)
$missing = @($required | Where-Object { -not (Test-Path (Join-Path $script:Root $_)) })
if ($missing.Count -eq 0) {
    Add-Check 'install-files' 'Required files are present' 'pass' "$($required.Count) checked"
} else {
    Add-Check 'install-files' 'Required files are present' 'fail' ('missing: ' + ($missing -join ', '))
}

$phpDirs = @(Get-ChildItem (Join-Path $script:Root 'bin\php') -Directory -ErrorAction SilentlyContinue | Sort-Object Name -Descending)
if ($phpDirs.Count -gt 0 -and (Test-Path (Join-Path $script:Root "bin\php\$($phpDirs[0].Name)\php-cgi.exe"))) {
    Add-Check 'install-php' 'PHP runtime is installed' 'pass' (($phpDirs | ForEach-Object { $_.Name }) -join ', ')
} else {
    Add-Check 'install-php' 'PHP runtime is installed' 'fail' 'no bin\php\<version>\php-cgi.exe found'
}

$sourceOnly = @(
    'installer\WampDeck.iss',
    'dist\WampDeck-Setup.exe',
    'backup\v1',
    'www\ocprobe'
)
$leaked = @($sourceOnly | Where-Object { Test-Path (Join-Path $script:Root $_) })
if ($leaked.Count -eq 0) {
    Add-Check 'install-hygiene' 'No source-only folders were copied' 'pass' 'installer, dist, backup, ocprobe absent'
} else {
    Add-Check 'install-hygiene' 'No source-only folders were copied' 'fail' ('found: ' + ($leaked -join ', '))
}

# ---------------------------------------------------------------- CLI
Write-Section 'Command line'

$versionText = ''
try {
    $versionResult = Invoke-Cli -Arguments @('version')
    $versionText = $versionResult.Text.Trim()
    if ($versionResult.ExitCode -ne 0) { throw "exit $($versionResult.ExitCode): $versionText" }
    if ($versionText -match 'WampDeck\s+(\S+)') {
        $actualVersion = $Matches[1]
        if ($actualVersion -eq $ExpectedVersion) {
            Add-Check 'version' 'wampdeck version' 'pass' $versionText
        } else {
            Add-Check 'version' 'wampdeck version' 'fail' "expected $ExpectedVersion, got $actualVersion"
        }
    } else {
        Add-Check 'version' 'wampdeck version' 'fail' "unexpected output: $versionText"
    }
} catch {
    Add-Check 'version' 'wampdeck version' 'fail' $_.Exception.Message
}

$status = $null
try {
    $statusResult = Invoke-Cli -Arguments @('status', '--json')
    $status = Convert-CliJson -Result $statusResult -Command 'wampdeck status --json'
    Add-Check 'status-json' 'wampdeck status --json' 'pass' "version $($status.version), root $($status.root)"
} catch {
    Add-Check 'status-json' 'wampdeck status --json' 'fail' $_.Exception.Message
}

if ($status) {
    $runningProblems = @()
    if (-not $status.web.running) { $runningProblems += 'web server stopped' }
    if (-not $status.mysql.running) { $runningProblems += 'MySQL stopped' }
    if (-not $status.supervisor) { $runningProblems += 'supervisor stopped' }
    if ($runningProblems.Count -eq 0) {
        Add-Check 'stack-running' 'Web, MySQL and supervisor are running' 'pass' "HTTP $($status.web.port), MySQL $($status.mysql.port)"
    } else {
        Add-Check 'stack-running' 'Web, MySQL and supervisor are running' 'fail' ($runningProblems -join '; ')
    }

    $poolProblems = @()
    $expectedWorkers = 0
    foreach ($pool in @($status.php.pools)) {
        $expectedWorkers += [int]$pool.expected
        if (-not $pool.running -or [int]$pool.alive -ne [int]$pool.expected) {
            $poolProblems += "PHP $($pool.version) $($pool.alive)/$($pool.expected)"
        }
    }
    if ($poolProblems.Count -eq 0 -and $expectedWorkers -gt 0) {
        $detail = (@($status.php.pools) | ForEach-Object { "$($_.version): $($_.alive)/$($_.expected)" }) -join ', '
        Add-Check 'php-pools' 'PHP pools are complete' 'pass' $detail
    } else {
        Add-Check 'php-pools' 'PHP pools are complete' 'fail' (($poolProblems -join '; ') + " expected total $expectedWorkers")
    }
} else {
    $expectedWorkers = 0
}

$projectsJson = @()
try {
    $listResult = Invoke-Cli -Arguments @('list', '--json')
    if ($listResult.Text.Trim()) {
        $parsedProjects = $listResult.Text | ConvertFrom-Json -ErrorAction Stop
        $projectsJson = @($parsedProjects)
    }
    if ($projectsJson.Count -eq 0) {
        Add-Check 'projects' 'Project manifests are valid' 'skip' 'no projects yet'
    } else {
        $projectProblems = @()
        foreach ($project in $projectsJson) {
            $manifestPath = [string]$project.manifest
            $hasManifest = $manifestPath -and (Test-Path -LiteralPath $manifestPath)
            if ($hasManifest -and -not $project.valid) { $projectProblems += "$($project.name): invalid manifest" }
            if (@($project.warnings).Count -gt 0) { $projectProblems += "$($project.name): $($project.warnings -join '; ')" }
        }
        if ($projectProblems.Count -eq 0) {
            Add-Check 'projects' 'Project manifests are valid' 'pass' "$($projectsJson.Count) project(s), no invalid manifests"
        } else {
            Add-Check 'projects' 'Project manifests are valid' 'fail' ($projectProblems -join '; ')
        }
    }
} catch {
    Add-Check 'projects' 'Project manifests are valid' 'fail' $_.Exception.Message
}

# ---------------------------------------------------------------- doctor
Write-Section 'Doctor'

try {
    # The doctor's project probes can race a cold start. Retry once when the
    # only failures are HTTP probes; any other failure keeps the first result.
    $doctor = $null
    $failures = @()
    for ($doctorAttempt = 1; $doctorAttempt -le 2; $doctorAttempt++) {
        $doctorResult = Invoke-Cli -Arguments @('doctor', '--json')
        $doctor = Convert-CliJson -Result $doctorResult -Command 'wampdeck doctor --json'
        $failures = @($doctor.checks | Where-Object { $_.status -eq 'fail' })
        $httpOnly = $failures.Count -gt 0 -and @($failures | Where-Object { $_.id -notlike 'http-*' }).Count -eq 0
        if (-not $httpOnly -or $doctorAttempt -eq 2) { break }
        Start-Sleep -Seconds 3
    }
    $warnings = @($doctor.checks | Where-Object { $_.status -eq 'warn' })
    $summary = "$(@($doctor.checks).Count) checks, $($failures.Count) failed, $($warnings.Count) warnings"

    if ($failures.Count -gt 0) {
        $detail = (($failures | ForEach-Object { "$($_.id): $($_.title)" }) -join '; ')
        Add-Check 'doctor' 'Doctor passes' 'fail' "$summary - $detail"
    } elseif ($warnings.Count -gt 0 -and -not $AllowWarnings) {
        $detail = (($warnings | ForEach-Object { "$($_.id): $($_.title)" }) -join '; ')
        Add-Check 'doctor' 'Doctor passes' 'fail' "$summary - $detail"
    } elseif ($warnings.Count -gt 0) {
        $detail = (($warnings | ForEach-Object { "$($_.id): $($_.title)" }) -join '; ')
        Add-Check 'doctor' 'Doctor passes' 'warn' "$summary - $detail"
    } else {
        Add-Check 'doctor' 'Doctor passes' 'pass' $summary
    }
} catch {
    Add-Check 'doctor' 'Doctor passes' 'fail' $_.Exception.Message
}

# ---------------------------------------------------------------- mysql
if (-not $SkipMysql) {
    Write-Section 'MySQL'

    $mysqlExe = Join-Path $script:Root 'bin\mysql\bin\mysql.exe'
    $myIni = Join-Path $script:Root 'etc\my.ini'
    try {
        $output = @(& $mysqlExe "--defaults-file=$myIni" -u root -N -B -e 'SELECT 1;' 2>&1)
        $code = $LASTEXITCODE
        $text = (($output | ForEach-Object { "$_" }) -join ' ').Trim()
        if ($code -eq 0 -and $text -eq '1') {
            Add-Check 'mysql-select' 'MySQL root login and SELECT 1' 'pass' 'ok'
        } else {
            Add-Check 'mysql-select' 'MySQL root login and SELECT 1' 'fail' "exit $code, output: $text"
        }
    } catch {
        Add-Check 'mysql-select' 'MySQL root login and SELECT 1' 'fail' $_.Exception.Message
    }
}

# ---------------------------------------------------------------- workers
Write-Section 'Processes'

if ($status -and $expectedWorkers -gt 0) {
    $phpProcesses = @(Get-CimInstance Win32_Process -Filter "Name='php-cgi.exe'" -ErrorAction SilentlyContinue |
        Where-Object { $_.ExecutablePath -and $_.ExecutablePath.StartsWith($script:Root + '\bin\php\', [StringComparison]::OrdinalIgnoreCase) })
    if ($phpProcesses.Count -eq $expectedWorkers) {
        Add-Check 'php-processes' 'One php-cgi process per expected worker' 'pass' "$($phpProcesses.Count) processes"
    } else {
        Add-Check 'php-processes' 'One php-cgi process per expected worker' 'fail' "expected $expectedWorkers, found $($phpProcesses.Count)"
    }

    $portProblems = @()
    foreach ($pool in @($status.php.pools)) {
        foreach ($port in @($pool.ports)) {
            $listeners = @(Get-NetTCPConnection -State Listen -LocalPort ([int]$port) -ErrorAction SilentlyContinue)
            if ($listeners.Count -eq 0) {
                $portProblems += "port $port has no listener"
                continue
            }
            $owners = @($listeners | Select-Object -ExpandProperty OwningProcess -Unique)
            $ownedByPhp = $true
            foreach ($ownerPid in $owners) {
                $proc = Get-CimInstance Win32_Process -Filter "ProcessId=$ownerPid" -ErrorAction SilentlyContinue
                $pathOk = $proc -and $proc.ExecutablePath -and $proc.ExecutablePath.StartsWith($script:Root + '\bin\php\', [StringComparison]::OrdinalIgnoreCase)
                if (-not $pathOk -or $proc.Name -ne 'php-cgi.exe') {
                    $ownedByPhp = $false
                }
            }
            if (-not $ownedByPhp) { $portProblems += "port $port is owned by another process" }
            if ($owners.Count -ne 1) { $portProblems += "port $port has $($owners.Count) listeners" }
        }
    }
    if ($portProblems.Count -eq 0) {
        Add-Check 'php-ports' 'Every PHP worker port is owned by this install' 'pass' 'ports checked'
    } else {
        Add-Check 'php-ports' 'Every PHP worker port is owned by this install' 'fail' ($portProblems -join '; ')
    }

    $pidFile = Join-Path $script:Root 'logs\pids\php-supervisor.pid'
    $supervisorOk = $false
    $supervisorDetail = ''
    if (-not (Test-Path $pidFile)) {
        $supervisorDetail = "missing $pidFile"
    } else {
        $supervisorPid = 0
        $rawPid = (Get-Content $pidFile -Raw -ErrorAction SilentlyContinue).Trim()
        if (-not [int]::TryParse($rawPid, [ref]$supervisorPid)) {
            $supervisorDetail = "invalid pid file: $rawPid"
        } else {
            $supervisor = Get-CimInstance Win32_Process -Filter "ProcessId=$supervisorPid" -ErrorAction SilentlyContinue
            if (-not $supervisor) {
                $supervisorDetail = "pid $supervisorPid is not running"
            } elseif ($supervisor.CommandLine -notlike '*supervisor.ps1*') {
                $supervisorDetail = "pid $supervisorPid is not the supervisor"
            } else {
                $supervisorOk = $true
                $supervisorDetail = "pid $supervisorPid"
            }
        }
    }
    if ($supervisorOk) {
        Add-Check 'supervisor' 'PHP supervisor is running' 'pass' $supervisorDetail
    } else {
        Add-Check 'supervisor' 'PHP supervisor is running' 'fail' $supervisorDetail
    }

    $supervisors = @(Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" -ErrorAction SilentlyContinue |
        Where-Object { $_.CommandLine -and $_.CommandLine -like "*$($script:Root)\lib\supervisor.ps1*" })
    if ($supervisors.Count -eq 1) {
        Add-Check 'supervisor-unique' 'Exactly one supervisor per install' 'pass' '1 process'
    } else {
        Add-Check 'supervisor-unique' 'Exactly one supervisor per install' 'fail' "$($supervisors.Count) processes"
    }
} else {
    Add-Check 'php-processes' 'One php-cgi process per expected worker' 'skip' 'stack status unavailable'
    Add-Check 'php-ports' 'Every PHP worker port is owned by this install' 'skip' 'stack status unavailable'
    Add-Check 'supervisor' 'PHP supervisor is running' 'skip' 'stack status unavailable'
    Add-Check 'supervisor-unique' 'Exactly one supervisor per install' 'skip' 'stack status unavailable'
}

# ---------------------------------------------------------------- HTTP
if (-not $SkipHttp) {
    Write-Section 'HTTP'

    $targets = New-Object System.Collections.Generic.List[object]
    if ($status) {
        $port = [int]$status.web.port
        $localUrl = if ($port -eq 80) { 'http://localhost/' } else { "http://localhost:$port/" }
        $targets.Add([pscustomobject]@{ Name = 'localhost'; Url = $localUrl })
        foreach ($project in @($status.projects)) {
            if ($project.url) { $targets.Add([pscustomobject]@{ Name = $project.name; Url = $project.url }) }
        }
    }
    foreach ($extra in $Urls) {
        $targets.Add([pscustomobject]@{ Name = $extra; Url = $extra })
    }

    $seen = @{}
    foreach ($target in $targets) {
        if ($seen.ContainsKey($target.Url)) { continue }
        $seen[$target.Url] = $true
        $id = 'http-' + ($target.Name -replace '[^A-Za-z0-9_.-]', '-')

        # A restart can refuse or stall one connection before php-cgi binds its
        # port. Retry a refused, timed out or 5xx answer once, then report it.
        $httpAttempts = 0
        $httpCode = 0
        $httpMessage = ''
        do {
            $httpAttempts++
            $httpMessage = ''
            try {
                $httpCode = Get-HttpCode -Url $target.Url
            } catch {
                $httpCode = 0
                $httpMessage = $_.Exception.Message
            }
            $httpRetry = ($httpCode -eq 0 -or $httpCode -ge 500)
            if ($httpCode -eq 200 -or -not $httpRetry -or $httpAttempts -ge 2) { break }
            Start-Sleep -Seconds 2
        } while ($true)

        $httpDetail = if ($httpCode -eq 200) {
            if ($httpAttempts -gt 1) { '200 (after retry)' } else { '200' }
        } elseif ($httpCode -eq 0) {
            $httpMessage
        } else {
            "status $httpCode"
        }
        $httpStatus = if ($httpCode -eq 200) { 'pass' } else { 'fail' }
        Add-Check $id "HTTP $($target.Url)" $httpStatus $httpDetail
    }

    if ($targets.Count -eq 0) {
        Add-Check 'http-none' 'HTTP checks' 'skip' 'no URLs to test'
    }
}

# ---------------------------------------------------------------- preserve
if ($Baseline) {
    Write-Section 'Upgrade preservation'

    try {
        if (-not (Test-Path $Baseline)) { throw "baseline not found: $Baseline" }
        $saved = Get-Content -LiteralPath $Baseline -Raw | ConvertFrom-Json
        foreach ($property in $saved.projects.PSObject.Properties) {
            $name = $property.Name
            $before = $property.Value
            $currentPath = Join-Path (Join-Path $script:Root 'www') $name
            $id = 'preserve-' + ($name -replace '[^A-Za-z0-9_.-]', '-')
            if (-not (Test-Path -LiteralPath $currentPath -PathType Container)) {
                Add-Check $id "Project $name survived" 'fail' 'folder is missing'
                continue
            }
            $after = Get-TreeFingerprint -Path $currentPath -HashContent ([bool]$saved.deep)
            if ($after.files -eq $before.files -and $after.bytes -eq $before.bytes -and $after.digest -eq $before.digest) {
                Add-Check $id "Project $name is untouched" 'pass' "$($after.files) files, $($after.bytes) bytes"
            } else {
                Add-Check $id "Project $name is untouched" 'fail' "before $($before.files) files/$($before.bytes) bytes, after $($after.files) files/$($after.bytes) bytes"
            }
        }
    } catch {
        Add-Check 'preserve' 'Upgrade preservation' 'fail' $_.Exception.Message
    }
}

# ---------------------------------------------------------------- report
$failCount = @($script:Checks | Where-Object { $_.status -eq 'fail' }).Count
$warnCount = @($script:Checks | Where-Object { $_.status -eq 'warn' }).Count
$passCount = @($script:Checks | Where-Object { $_.status -eq 'pass' }).Count
$skipCount = @($script:Checks | Where-Object { $_.status -eq 'skip' }).Count

if (-not $ReportPath) {
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $ReportPath = Join-Path (Join-Path $script:Root 'logs') "acceptance-$stamp.json"
}

$report = [ordered]@{}
$report['timestamp'] = (Get-Date).ToString('o')
$report['root'] = $script:Root
$report['expected'] = $ExpectedVersion
$report['version'] = $versionText
$report['windows'] = $os
$report['admin'] = $isAdmin
$report['powershell'] = $PSVersionTable.PSVersion.ToString()
$report['summary'] = [ordered]@{ pass = $passCount; warn = $warnCount; fail = $failCount; skip = $skipCount }
$report['checks'] = $script:Checks.ToArray()

try {
    $reportParent = Split-Path -Parent $ReportPath
    if ($reportParent -and -not (Test-Path $reportParent)) { New-Item -ItemType Directory -Force -Path $reportParent | Out-Null }
    [IO.File]::WriteAllText($ReportPath, ($report | ConvertTo-Json -Depth 8), (New-Object System.Text.UTF8Encoding($false)))
} catch {
    Write-Host "  [WARN] could not write report: $($_.Exception.Message)" -ForegroundColor Yellow
    $ReportPath = ''
}

Write-Host ''
Write-Host ('  PASS {0}  WARN {1}  FAIL {2}  SKIP {3}' -f $passCount, $warnCount, $failCount, $skipCount) -ForegroundColor White
if ($ReportPath) { Write-Host "  report  $ReportPath" -ForegroundColor DarkGray }

if ($failCount -gt 0) {
    Write-Host '  RESULT: FAIL' -ForegroundColor Red
    exit 1
}
if ($warnCount -gt 0 -and -not $AllowWarnings) {
    Write-Host '  RESULT: FAIL (warnings are not accepted; use -AllowWarnings to soften)' -ForegroundColor Red
    exit 1
}
Write-Host '  RESULT: PASS' -ForegroundColor Green
exit 0
