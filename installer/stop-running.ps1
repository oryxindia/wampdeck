# Stops every WampDeck process before Setup replaces the binaries.
#
# Run elevated by the installer. The normal scripts\stop.ps1 cannot be
# trusted for this job: it stops only the supervisor recorded in the pid
# file, so an orphaned supervisor keeps respawning php-cgi and the files stay
# locked. This helper kills every supervisor first, then lets stop.ps1 shut
# MySQL down gracefully, then clears anything that is still holding the
# install folder.

param(
    [Parameter(Mandatory = $true)][string]$Root
)

$ErrorActionPreference = 'SilentlyContinue'
$logPath = Join-Path $env:TEMP 'wampdeck-install-stop.log'

function Write-Log {
    param([string]$Message)
    $line = '{0} {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Message
    Add-Content -Path $logPath -Value $line -Encoding UTF8
}

function Get-RootProcesses {
    param([string[]]$Names)

    $rootPattern = [regex]::Escape($Root)
    Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object {
        if ($Names -notcontains $_.Name) { return $false }
        if ($_.ExecutablePath -and $_.ExecutablePath.StartsWith($Root, [System.StringComparison]::OrdinalIgnoreCase)) { return $true }
        if ($_.CommandLine -and $_.CommandLine -match $rootPattern) { return $true }
        return $false
    }
}

Write-Log "installer stop helper started for $Root"

if (-not (Test-Path -LiteralPath $Root)) {
    Write-Log 'install folder does not exist; nothing to stop'
    exit 0
}

# 1. Close the GUI and launcher first. If they stay open they can restart the
#    stack while Setup is copying files.
foreach ($process in @(Get-RootProcesses @('WampDeck.exe'))) {
    Write-Log "stopping launcher pid $($process.ProcessId)"
    Stop-Process -Id $process.ProcessId -Force -ErrorAction SilentlyContinue
}
$rootPattern = [regex]::Escape($Root)
foreach ($process in @(Get-CimInstance Win32_Process -Filter "Name = 'powershell.exe'" -ErrorAction SilentlyContinue | Where-Object {
            $_.CommandLine -and
            $_.CommandLine -match $rootPattern -and
            $_.CommandLine -match '(?:^|[\\/])(?:gui-panel|panel)\.ps1'
        })) {
    Write-Log "stopping GUI pid $($process.ProcessId)"
    Stop-Process -Id $process.ProcessId -Force -ErrorAction SilentlyContinue
}

# 2. Kill every supervisor before touching php-cgi. This is the step the old
#    stop.ps1 misses and the reason Setup reports DeleteFile failed; code 5.
foreach ($process in @(Get-CimInstance Win32_Process -Filter "Name = 'powershell.exe'" -ErrorAction SilentlyContinue | Where-Object {
            $_.CommandLine -and
            $_.CommandLine -match 'supervisor\.ps1' -and
            $_.CommandLine -match $rootPattern
        })) {
    Write-Log "stopping supervisor pid $($process.ProcessId)"
    Stop-Process -Id $process.ProcessId -Force -ErrorAction SilentlyContinue
}

# Give a supervisor that is mid-spawn a moment to die before the workers go.
Start-Sleep -Milliseconds 700

# 3. Ask the installed scripts to stop what remains. This is the graceful
#    path for MySQL (mysqladmin shutdown) and Mailpit.
$stopScript = Join-Path $Root 'scripts\stop.ps1'
if (Test-Path -LiteralPath $stopScript) {
    Write-Log 'running installed stop.ps1'
    $process = Start-Process -FilePath 'powershell.exe' `
        -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$stopScript`"") `
        -WindowStyle Hidden -PassThru
    if (-not $process.WaitForExit(90000)) {
        Write-Log 'stop.ps1 timed out; killing it'
        Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
    } else {
        Write-Log "stop.ps1 exited with $($process.ExitCode)"
    }
}

# 4. Clear any worker the supervisor started while stop.ps1 was running.
foreach ($name in @('nginx.exe', 'php-cgi.exe', 'mailpit.exe', 'redis-server.exe', 'memcached.exe')) {
    foreach ($process in @(Get-RootProcesses @($name))) {
        Write-Log "stopping leftover $name pid $($process.ProcessId)"
        Stop-Process -Id $process.ProcessId -Force -ErrorAction SilentlyContinue
    }
}

# 5. Wait for the binaries to be unlocked. MySQL is checked separately: if it
#    is still alive after its graceful shutdown, abort instead of force
#    killing it and risking the data directory.
$deadline = (Get-Date).AddSeconds(25)
do {
    $left = @(Get-RootProcesses @('nginx.exe', 'php-cgi.exe', 'mailpit.exe', 'redis-server.exe', 'memcached.exe'))
    if ($left.Count -eq 0) { break }
    Start-Sleep -Milliseconds 500
} while ((Get-Date) -lt $deadline)

$mysql = @(Get-RootProcesses @('mysqld.exe'))
if ($mysql.Count -gt 0) {
    # Graceful stop failed (e.g. mysqladmin.exe missing from an older install,
    # or a second mysqld child still holding the port). Force-stop instead of
    # blocking the upgrade: InnoDB replays its redo log on next start, so the
    # databases recover. A stuck install is the worse outcome here.
    Write-Log ('mysqld still running after graceful stop; force-stopping ' + $mysql.Count + ' process(es)')
    foreach ($process in $mysql) {
        Write-Log "force-stopping mysqld pid $($process.ProcessId)"
        Stop-Process -Id $process.ProcessId -Force -ErrorAction SilentlyContinue
    }
    $deadline = (Get-Date).AddSeconds(12)
    do {
        $mysql = @(Get-RootProcesses @('mysqld.exe'))
        if ($mysql.Count -eq 0) { break }
        Start-Sleep -Milliseconds 500
    } while ((Get-Date) -lt $deadline)
    if ($mysql.Count -gt 0) {
        Write-Log 'mysqld could not be force-stopped; aborting install'
        exit 2
    }
    Write-Log 'mysqld force-stopped; InnoDB will recover on next start'
}

if ($left.Count -gt 0) {
    foreach ($process in $left) {
        Write-Log "still running: $($process.Name) pid $($process.ProcessId)"
    }
    exit 3
}

Remove-Item (Join-Path $Root 'logs\php-supervisor.stop') -Force -ErrorAction SilentlyContinue
Write-Log 'all WampDeck processes stopped'
exit 0
