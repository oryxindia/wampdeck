# PHP worker supervisor.
#
# php-cgi -b exits after PHP_FCGI_MAX_REQUESTS. Without something watching the
# pool, the stack silently degrades to 502: nginx keeps a dead port in the
# upstream, retries, marks it disabled, and every project starts failing.
#
# This process is started hidden by Start-PhpSupervisor and stopped by
# Stop-PhpSupervisor (which drops a stop file and waits). It never touches a
# port that belongs to another program.

param([Parameter(Mandatory = $true)][string]$Root)

$ErrorActionPreference = 'Continue'

. (Join-Path $Root 'config.ps1')
. (Join-Path $Root 'lib\common.ps1')
. (Join-Path $Root 'lib\manifest.ps1')
. (Join-Path $Root 'lib\stack.ps1')

$supervisorLog = Join-Path $LogDir 'php-supervisor.log'
$stopFile = Join-Path $LogDir 'php-supervisor.stop'
$pidFile = Join-Path $PidDir 'php-supervisor.pid'

function Write-SupervisorLog {
    param([string]$Message)
    $line = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $Message"
    Add-Content -Path $supervisorLog -Value $line -Encoding ASCII -ErrorAction SilentlyContinue
}

Ensure-Dir $PidDir

# One supervisor per install. Two supervisors race each other, spawn
# duplicate php-cgi workers on the same ports, and keep those binaries locked
# while an installer tries to replace them. Holding an exclusive file handle
# for the life of this process is enough to make the second one exit.
$lockFile = Join-Path $PidDir 'php-supervisor.lock'
try {
    $supervisorLock = [System.IO.File]::Open(
        $lockFile,
        [System.IO.FileMode]::OpenOrCreate,
        [System.IO.FileAccess]::ReadWrite,
        [System.IO.FileShare]::None)
    $supervisorLock.SetLength(0)
    $lockText = [System.Text.Encoding]::ASCII.GetBytes("$PID")
    $supervisorLock.Write($lockText, 0, $lockText.Length)
    $supervisorLock.Flush()
} catch {
    exit 0
}

Set-Content -Path $pidFile -Value $PID -Encoding ASCII
Write-SupervisorLog "supervisor started (pid $PID)"

$failures = @{}
$cooldown = @{}
$lastTrim = Get-Date

try {
    while (-not (Test-Path $stopFile)) {
        foreach ($spec in @(Get-PhpPoolSpec)) {
            foreach ($port in $spec.Ports) {
                $key = "$($spec.Version):$port"

                $owner = Get-PortOwnerInfo -Port $port
                if ($owner.InUse) {
                    $process = Get-Process -Id $owner.Pid -ErrorAction SilentlyContinue
                    if (Test-ProcessPath $process $spec.PhpCgi) {
                        $failures[$key] = 0
                        continue
                    }
                    # Someone else owns the port. Report once, never fight it.
                    if (-not $failures.ContainsKey($key)) {
                        Write-SupervisorLog "port $port is held by $($owner.Name) (pid $($owner.Pid)); leaving it alone"
                        $failures[$key] = 0
                    }
                    continue
                }

                if ($cooldown.ContainsKey($key) -and (Get-Date) -lt $cooldown[$key]) { continue }

                try {
                    $spawn = Start-PhpWorkerOnPort -Version $spec.Version -Port $port
                    if ($spawn -ne 'starting') {
                        Write-SupervisorLog "started PHP $($spec.Version) on port $port"
                    }
                    $failures[$key] = 0
                    $cooldown.Remove($key)
                } catch {
                    $count = 0
                    if ($failures.ContainsKey($key)) { $count = [int]$failures[$key] }
                    $count++
                    $failures[$key] = $count
                    Write-SupervisorLog "could not start PHP $($spec.Version) on port $port (attempt $count): $($_.Exception.Message)"
                    if ($count -ge 5) {
                        $cooldown[$key] = (Get-Date).AddSeconds(30)
                        $failures[$key] = 0
                        Write-SupervisorLog "backing off port $port for 30 seconds"
                    }
                }
            }
        }

        if (((Get-Date) - $lastTrim).TotalMinutes -ge 10) {
            $lastTrim = Get-Date
            $size = 0
            if (Test-Path $supervisorLog) { $size = (Get-Item $supervisorLog).Length }
            if ($size -gt 1MB) { Set-Content -Path $supervisorLog -Value '' -Encoding ASCII }
        }

        Start-Sleep -Seconds 3
    }
} finally {
    Write-SupervisorLog 'supervisor stopping'
    Remove-Item -Path $pidFile -Force -ErrorAction SilentlyContinue
}