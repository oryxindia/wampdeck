# Service lifecycle for every WampDeck component.

$MailpitSmtpPort = 1025
$MailpitUiPort = 8025
$RedisPort = 6379
$MemcachedPort = 11211

function Get-LogTail {
    param([string]$Path, [int]$Lines = 12)
    if (-not (Test-Path $Path)) { return @() }
    return @(Get-Content -Path $Path -Tail $Lines -ErrorAction SilentlyContinue)
}

function Test-PortListening {
    param([int]$Port)
    # Cheap check from the cached netstat map refreshed by Get-PortOwnerInfo.
    if ($script:PortMapCache -and ((Get-Date) - $script:PortMapCache.Time).TotalSeconds -le 3) {
        return $script:PortMapCache.Map.ContainsKey([int]$Port)
    }
    return (Get-PortOwnerInfo -Port $Port).InUse
}

function Get-PortOwnerInfo {
    param([int]$Port)

    # Old code called Get-NetTCPConnection once per port. That cmdlet is slow
    # (~1.5 s per call) and Get-StackStatus probes ~8 ports every 3 s, which
    # froze the whole panel. netstat -ano is ~6x faster; parse it once into a
    # port -> pid map and cache it for a couple of seconds.
    if (-not $script:PortMapCache -or ((Get-Date) - $script:PortMapCache.Time).TotalSeconds -gt 2) {
        $map = @{}
        foreach ($line in @(& netstat.exe -ano -p TCP 2>$null)) {
            if ($line -notmatch 'LISTENING') { continue }
            $parts = $line.Trim() -split '\s+'
            if ($parts.Count -lt 5) { continue }
            $local = $parts[1]
            $pidText = $parts[4]
            if ($local -match ':(\d+)$') {
                $p = [int]$Matches[1]
                if (-not $map.ContainsKey($p)) { $map[$p] = [int]$pidText }
            }
        }
        $script:PortMapCache = [pscustomobject]@{ Time = Get-Date; Map = $map }
    }
    $ownerPid = 0
    if ($script:PortMapCache.Map.ContainsKey([int]$Port)) { $ownerPid = $script:PortMapCache.Map[[int]$Port] }
    if ($ownerPid -le 0) {
        return [pscustomobject]@{ Port = $Port; InUse = $false; Pid = 0; Name = ''; Path = ''; IsOurs = $false }
    }
    $process = Get-Process -Id $ownerPid -ErrorAction SilentlyContinue
    $path = ''
    try { $path = $process.Path } catch { }
    $ours = $false
    if ($path) { $ours = $path.StartsWith($Root, [System.StringComparison]::OrdinalIgnoreCase) }
    return [pscustomobject]@{
        Port   = $Port
        InUse  = $true
        Pid    = $ownerPid
        Name   = if ($process) { $process.ProcessName } else { 'unknown' }
        Path   = $path
        IsOurs = $ours
    }
}

function Assert-PortFreeOrOurs {
    param([int]$Port, [string]$ExePath, [string]$Label)
    $owner = Get-PortOwnerInfo -Port $Port
    if (-not $owner.InUse) { return $false }
    if (Test-ProcessPath (Get-Process -Id $owner.Pid -ErrorAction SilentlyContinue) $ExePath) {
        return $true
    }
    throw "$Label port $Port is already in use by $($owner.Name) (pid $($owner.Pid)). Free the port or change it in Settings."
}

function Wait-PortFree {
    param([int]$Port, [int]$Seconds = 10)
    $deadline = (Get-Date).AddSeconds($Seconds)
    while ((Get-Date) -lt $deadline) {
        if (-not (Test-TcpPort -Port $Port)) { return $true }
        Start-Sleep -Milliseconds 300
    }
    return (-not (Test-TcpPort -Port $Port))
}

# ---------------------------------------------------------------- MySQL
function Start-MysqlService {
    if (Assert-PortFreeOrOurs -Port $MysqlPort -ExePath $Mysqld -Label 'MySQL') {
        return 'already'
    }

    Ensure-Dir $LogDir
    Ensure-Dir $DataDir

    if (-not (Test-Path (Join-Path $MysqlData 'mysql'))) {
        Ensure-Dir $MysqlData
        $output = & $Mysqld "--defaults-file=$MyIni" --initialize-insecure 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "MySQL data directory could not be initialized.`n$($output -join [Environment]::NewLine)"
        }
    }

    Start-Process -FilePath $Mysqld `
        -ArgumentList @("--defaults-file=`"$MyIni`"") `
        -WorkingDirectory $Root -WindowStyle Hidden `
        -RedirectStandardOutput (Join-Path $LogDir 'mysql-stdout.log') `
        -RedirectStandardError (Join-Path $LogDir 'mysql-stderr.log') | Out-Null

    if (-not (Wait-TcpPort -Port $MysqlPort -Seconds 45)) {
        $tail = Get-LogTail (Join-Path $LogDir 'mysql-error.log') 20
        throw "MySQL did not start on port $MysqlPort.`n$($tail -join [Environment]::NewLine)"
    }
    return 'started'
}

function Stop-MysqlService {
    $processes = @(Get-StackProcesses $Mysqld)
    if ($processes.Count -eq 0 -and -not (Test-TcpPort -Port $MysqlPort)) { return 'stopped' }

    if (Test-Path $MysqlAdmin) {
        $previous = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        & $MysqlAdmin --host=127.0.0.1 --port=$MysqlPort --user=root --connect-timeout=5 shutdown 2>&1 | Out-Null
        $ErrorActionPreference = $previous
    }

    if (-not (Wait-PortFree -Port $MysqlPort -Seconds 20)) {
        foreach ($process in @(Get-StackProcesses $Mysqld)) {
            Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
        }
        Wait-PortFree -Port $MysqlPort -Seconds 10 | Out-Null
    }
    return 'stopped'
}

# ---------------------------------------------------------------- PHP workers
function Get-PhpWorkerProcesses {
    $cim = Get-CimInstance Win32_Process -Filter "Name = 'php-cgi.exe'" -ErrorAction SilentlyContinue
    return @($cim | Where-Object {
        $_.ExecutablePath -and $_.ExecutablePath.StartsWith($PhpRoot, [System.StringComparison]::OrdinalIgnoreCase)
    })
}

function Get-PhpPoolSpec {
    # One entry per installed PHP version, each with its own port block.
    $specs = @()
    foreach ($version in $PhpVersions) {
        $ports = @($PhpPoolPorts[$version])
        if ($ports.Count -eq 0) { continue }
        $dir = Join-Path $PhpRoot $version
        $cgi = Join-Path $dir 'php-cgi.exe'
        if (-not (Test-Path $cgi)) { continue }
        $specs += [pscustomobject]@{
            Version = $version
            Ports   = $ports
            PhpDir  = $dir
            PhpCgi  = $cgi
        }
    }
    return $specs
}

function Get-PhpWorkerForPort {
    # Finds a php-cgi process for this build that is already configured to
    # serve the port, even if it has not bound the socket yet. Start-Process
    # returns before php-cgi binds, so without this check the supervisor sees
    # a free port right after Start-PhpWorkers and spawns a duplicate worker
    # (Windows lets both of them listen on the same port).
    param([string]$Version, [int]$Port)

    $cgi = Join-Path (Join-Path $PhpRoot $Version) 'php-cgi.exe'
    $needle = "-b 127.0.0.1:$Port"
    $cim = Get-CimInstance Win32_Process -Filter "Name = 'php-cgi.exe'" -ErrorAction SilentlyContinue
    foreach ($process in @($cim)) {
        if (-not $process.CommandLine -or -not $process.ExecutablePath) { continue }
        if ($process.CommandLine.IndexOf($needle, [System.StringComparison]::OrdinalIgnoreCase) -lt 0) { continue }
        try {
            $actual = [System.IO.Path]::GetFullPath($process.ExecutablePath)
            $expected = [System.IO.Path]::GetFullPath($cgi)
        } catch { continue }
        if ($actual.Equals($expected, [System.StringComparison]::OrdinalIgnoreCase)) { return $process }
    }
    return $null
}
function Start-PhpWorkerOnPort {
    param([string]$Version, [int]$Port)

    $dir = Join-Path $PhpRoot $Version
    $cgi = Join-Path $dir 'php-cgi.exe'
    if (-not (Test-Path $cgi)) { throw "php-cgi.exe for PHP $Version was not found." }

    $owner = Get-PortOwnerInfo -Port $Port
    if ($owner.InUse) {
        $process = Get-Process -Id $owner.Pid -ErrorAction SilentlyContinue
        if (Test-ProcessPath $process $cgi) { return 'reused' }
        throw "PHP port $Port is already in use by $($owner.Name) (pid $($owner.Pid))."
    }

    # Start-Process returns before php-cgi binds: reuse the worker that is
    # still starting instead of spawning a second one on the same port.
    if (Get-PhpWorkerForPort -Version $Version -Port $Port) { return 'starting' }

    # A handler exits after this many requests. The supervisor restarts it,
    # so a modest cap keeps long-running workers from growing without bound.
    $env:PHP_FCGI_MAX_REQUESTS = '10000'
    Start-Process -FilePath $cgi `
        -ArgumentList @('-b', "127.0.0.1:$Port") `
        -WorkingDirectory $dir -WindowStyle Hidden `
        -RedirectStandardOutput (Join-Path $LogDir "php-$Port-out.log") `
        -RedirectStandardError (Join-Path $LogDir "php-$Port.log") | Out-Null
    return 'started'
}

function Get-PhpPoolHealth {
    # version -> object with the ports that answer and the ports that do not.
    $result = @{}
    foreach ($spec in @(Get-PhpPoolSpec)) {
        $alivePorts = @()
        $deadPorts = @()
        foreach ($port in $spec.Ports) {
            $owner = Get-PortOwnerInfo -Port $port
            $isOurs = $false
            if ($owner.InUse) {
                $process = Get-Process -Id $owner.Pid -ErrorAction SilentlyContinue
                $isOurs = Test-ProcessPath $process $spec.PhpCgi
            }
            if ($isOurs) { $alivePorts += $port } else { $deadPorts += $port }
        }
        $result[$spec.Version] = [pscustomobject]@{
            Version = $spec.Version
            Spec    = $spec
            Alive   = @($alivePorts)
            Dead    = @($deadPorts)
        }
    }
    return $result
}

function Start-PhpWorkers {
    $started = 0
    $reused = 0

    foreach ($spec in @(Get-PhpPoolSpec)) {
        foreach ($port in $spec.Ports) {
            $workerState = Start-PhpWorkerOnPort -Version $spec.Version -Port $port
            if ($workerState -eq 'started') { $started++ } else { $reused++ }
        }
    }

    Start-Sleep -Milliseconds 900

    # A PHP build whose opcache cannot start dies before it binds the port, and
    # every project on that version would return 502. Retry once without
    # opcache instead of leaving the pool dead.
    $disabled = @()
    foreach ($health in @((Get-PhpPoolHealth).Values)) {
        if ($health.Dead.Count -eq 0) { continue }
        $ini = Join-Path $health.Spec.PhpDir 'php.ini'
        if (-not (Test-Path $ini)) { continue }
        $iniText = Get-Content -Path $ini -Raw -ErrorAction SilentlyContinue
        if ($iniText -notmatch '(?m)^\s*zend_extension=opcache') { continue }

        Write-Step "PHP $($health.Version) failed to start with opcache; retrying without it"
        Set-PhpOpcacheSupport -Version $health.Version -Supported $false
        Write-PhpIni -Version $health.Version
        foreach ($port in $health.Dead) {
            Start-PhpWorkerOnPort -Version $health.Version -Port $port | Out-Null
        }
        $disabled += $health.Version
    }
    if ($disabled.Count -gt 0) { Start-Sleep -Milliseconds 900 }

    $alive = 0
    $missing = @()
    foreach ($health in @((Get-PhpPoolHealth).Values)) {
        $alive += $health.Alive.Count
        foreach ($port in $health.Dead) { $missing += "$($health.Version)@$port" }
    }

    if ($missing.Count -gt 0) {
        $tail = Get-LogTail (Join-Path $LogDir 'php-9000.log') 15
        throw "PHP workers not running: $($missing -join ', ').`n$($tail -join [Environment]::NewLine)"
    }

    return [pscustomobject]@{
        Started  = $started
        Reused   = $reused
        Total    = $alive
        Disabled = @($disabled)
    }
}
function Stop-PhpWorkers {
    $processes = @(Get-PhpWorkerProcesses)
    foreach ($process in $processes) {
        Stop-Process -Id $process.ProcessId -Force -ErrorAction SilentlyContinue
    }
    Start-Sleep -Milliseconds 400
    return $processes.Count
}

# ---------------------------------------------------------------- supervisor
function Get-PhpSupervisorProcesses {
    # The pid file is only a hint. A supervisor left behind by an earlier
    # run (or one started elevated) keeps respawning php-cgi and locks the
    # binaries, so enumerate every supervisor for this install instead of
    # trusting a single recorded pid.
    $rootPattern = [regex]::Escape($Root)
    $cim = Get-CimInstance Win32_Process -Filter "Name = 'powershell.exe'" -ErrorAction SilentlyContinue
    return @($cim | Where-Object {
        $_.CommandLine -and
        $_.CommandLine -match ('supervisor\.ps1.*-Root\s+"?' + $rootPattern + '"?')
    })
}

function Get-PhpSupervisorProcess {
    $processes = @(Get-PhpSupervisorProcesses)
    if ($processes.Count -eq 0) { return $null }
    return $processes[0]
}

function Start-PhpSupervisor {
    $existing = @(Get-PhpSupervisorProcesses)
    if ($existing.Count -gt 0) {
        # Re-point the pid file at a live supervisor so status and stop
        # agree on the same process.
        Ensure-Dir $PidDir
        Set-Content -Path (Join-Path $PidDir 'php-supervisor.pid') -Value $existing[0].ProcessId -Encoding ASCII
        return 'already'
    }

    $script = Join-Path $Root 'lib\supervisor.ps1'
    if (-not (Test-Path $script)) { return 'missing' }

    Ensure-Dir $PidDir
    Remove-Item (Join-Path $LogDir 'php-supervisor.stop') -Force -ErrorAction SilentlyContinue

    # Detach the supervisor from this process's stdout/stderr. Without the
    # redirects the child inherits the caller's pipe, and a piped
    # `wampdeck restart` waits forever even though the stack is back up.
    $process = Start-Process -FilePath 'powershell.exe' `
        -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$script`"", '-Root', "`"$Root`"") `
        -WindowStyle Hidden -PassThru `
        -RedirectStandardOutput (Join-Path $LogDir 'php-supervisor-out.log') `
        -RedirectStandardError (Join-Path $LogDir 'php-supervisor-error.log')
    Set-Content -Path (Join-Path $PidDir 'php-supervisor.pid') -Value $process.Id -Encoding ASCII
    return 'started'
}

function Stop-PhpSupervisor {
    $processes = @(Get-PhpSupervisorProcesses)
    if ($processes.Count -eq 0) {
        Remove-Item (Join-Path $PidDir 'php-supervisor.pid') -Force -ErrorAction SilentlyContinue
        return 'stopped'
    }

    # Ask every supervisor to leave before forcing it: the stop file lets a
    # healthy supervisor finish its current spawn loop cleanly.
    $stopFile = Join-Path $LogDir 'php-supervisor.stop'
    Set-Content -Path $stopFile -Value 'stop' -Encoding ASCII

    $deadline = (Get-Date).AddSeconds(6)
    while ((Get-Date) -lt $deadline) {
        $alive = @(Get-PhpSupervisorProcesses)
        if ($alive.Count -eq 0) { break }
        Start-Sleep -Milliseconds 200
    }

    # Any supervisor still alive ignored the stop file (or cannot see it).
    # Kill each one so no orphan can respawn workers during an upgrade.
    foreach ($process in @(Get-PhpSupervisorProcesses)) {
        Stop-Process -Id $process.ProcessId -Force -ErrorAction SilentlyContinue
    }
    Start-Sleep -Milliseconds 300

    Remove-Item $stopFile -Force -ErrorAction SilentlyContinue
    Remove-Item (Join-Path $PidDir 'php-supervisor.pid') -Force -ErrorAction SilentlyContinue
    return 'stopped'
}
# ---------------------------------------------------------------- nginx
function Start-Nginx {
    if (Assert-PortFreeOrOurs -Port $HttpPort -ExePath $NginxExe -Label 'HTTP') {
        return 'already'
    }
    if ($State.ssl -and (Assert-PortFreeOrOurs -Port $HttpsPort -ExePath $NginxExe -Label 'HTTPS')) {
        return 'already'
    }

    Ensure-Dir $LogDir
    foreach ($logFile in @('nginx-error.log', 'nginx-access.log')) {
        $path = Join-Path $LogDir $logFile
        if (-not (Test-Path $path)) { New-Item -ItemType File -Path $path | Out-Null }
    }

    $previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $test = & $NginxExe -p $Prefix -c 'etc/nginx.conf' -t 2>&1
    $testCode = $LASTEXITCODE
    $ErrorActionPreference = $previous

    if ($testCode -ne 0) {
        throw "nginx configuration test failed.`n$($test -join [Environment]::NewLine)"
    }

    Start-Process -FilePath $NginxExe `
        -ArgumentList @('-p', ('"' + $Prefix + '"'), '-c', 'etc/nginx.conf') `
        -WorkingDirectory $Root -WindowStyle Hidden `
        -RedirectStandardOutput (Join-Path $LogDir 'nginx-stdout.log') `
        -RedirectStandardError (Join-Path $LogDir 'nginx-stderr.log') | Out-Null

    if (-not (Wait-TcpPort -Port $HttpPort -Seconds 12)) {
        $tail = Get-LogTail (Join-Path $LogDir 'nginx-error.log') 15
        throw "nginx did not start on port $HttpPort.`n$($tail -join [Environment]::NewLine)"
    }
    return 'started'
}

function Stop-Nginx {
    $processes = @(Get-StackProcesses $NginxExe)
    if ($processes.Count -eq 0) { return 'stopped' }

    $previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    & $NginxExe -p $Prefix -c 'etc/nginx.conf' -s stop 2>&1 | Out-Null
    $ErrorActionPreference = $previous

    $deadline = (Get-Date).AddSeconds(6)
    while ((Get-Date) -lt $deadline) {
        if (@(Get-StackProcesses $NginxExe).Count -eq 0) { break }
        Start-Sleep -Milliseconds 300
    }

    foreach ($process in @(Get-StackProcesses $NginxExe)) {
        Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
    }
    # Fallback: an elevated nginx master may hide its Path from a non-elevated
    # caller, so Get-StackProcesses returns nothing. Find the listener on the
    # HTTP port directly and stop it too (it is our nginx from this root).
    if (Test-TcpPort -Port $HttpPort) {
        $conn = Get-NetTCPConnection -LocalPort $HttpPort -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($conn -and $conn.OwningProcess -gt 0) {
            Stop-Process -Id $conn.OwningProcess -Force -ErrorAction SilentlyContinue
        }
    }
    Wait-PortFree -Port $HttpPort -Seconds 5 | Out-Null
    return 'stopped'
}

# ---------------------------------------------------------------- Apache
function Start-Apache {
    if (Assert-PortFreeOrOurs -Port $HttpPort -ExePath $ApacheExe -Label 'HTTP') {
        return 'already'
    }
    if ($State.ssl -and (Assert-PortFreeOrOurs -Port $HttpsPort -ExePath $ApacheExe -Label 'HTTPS')) {
        return 'already'
    }

    Ensure-Dir $LogDir

    $previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $test = & $ApacheExe -t -f $ApacheMainConf 2>&1
    $testCode = $LASTEXITCODE
    $ErrorActionPreference = $previous

    if ($testCode -ne 0) {
        throw "Apache configuration test failed.`n$($test -join [Environment]::NewLine)"
    }

    Start-DetachedProcess -FilePath $ApacheExe `
        -Arguments "-f `"$ApacheMainConf`"" `
        -WorkingDirectory $ApacheDir | Out-Null

    if (-not (Wait-TcpPort -Port $HttpPort -Seconds 15)) {
        $tail = Get-LogTail (Join-Path $LogDir 'apache-error.log') 20
        throw "Apache did not start on port $HttpPort.`n$($tail -join [Environment]::NewLine)"
    }
    return 'started'
}

function Stop-Apache {
    $processes = @(Get-StackProcesses $ApacheExe)
    if ($processes.Count -eq 0) { return 'stopped' }

    foreach ($process in $processes) {
        Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
    }
    Wait-PortFree -Port $HttpPort -Seconds 6 | Out-Null
    return 'stopped'
}

# ---------------------------------------------------------------- web server
function Start-WebServer {
    if ($State.webServer -eq 'apache') {
        Stop-Nginx | Out-Null
        return (Start-Apache)
    }
    Stop-Apache | Out-Null
    return (Start-Nginx)
}

function Stop-WebServer {
    Stop-Nginx | Out-Null
    Stop-Apache | Out-Null
    return 'stopped'
}

function Restart-WebServer {
    Stop-WebServer | Out-Null
    Start-Sleep -Milliseconds 400
    return (Start-WebServer)
}

function Reload-WebServer {
    if ($State.webServer -eq 'apache') {
        return (Restart-WebServer)
    }
    if (@(Get-StackProcesses $NginxExe).Count -eq 0) { return 'stopped' }

    $previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    & $NginxExe -p $Prefix -c 'etc/nginx.conf' -s reload 2>&1 | Out-Null
    $code = $LASTEXITCODE
    $ErrorActionPreference = $previous

    if ($code -ne 0) { return (Restart-WebServer) }
    return 'reloaded'
}

# ---------------------------------------------------------------- Mailpit
function Start-MailpitService {
    if (@(Get-StackProcesses $MailpitExe).Count -gt 0) { return 'already' }

    foreach ($port in @($MailpitSmtpPort, $MailpitUiPort)) {
        $owner = Get-PortOwnerInfo -Port $port
        if ($owner.InUse) {
            throw "Mailpit port $port is already in use by $($owner.Name) (pid $($owner.Pid))."
        }
    }

    Ensure-Dir (Join-Path $DataDir 'mailpit')
    $db = Join-Path $DataDir 'mailpit\mailpit.db'

    Start-Process -FilePath $MailpitExe `
        -ArgumentList @('--smtp', "127.0.0.1:$MailpitSmtpPort", '--listen', "127.0.0.1:$MailpitUiPort", '--database', "`"$db`"") `
        -WorkingDirectory (Join-Path $BinDir 'mailpit') -WindowStyle Hidden `
        -RedirectStandardOutput (Join-Path $LogDir 'mailpit.log') `
        -RedirectStandardError (Join-Path $LogDir 'mailpit-error.log') | Out-Null

    if (-not (Wait-TcpPort -Port $MailpitUiPort -Seconds 15)) {
        $tail = Get-LogTail (Join-Path $LogDir 'mailpit-error.log') 15
        throw "Mailpit did not start.`n$($tail -join [Environment]::NewLine)"
    }
    return 'started'
}

function Stop-MailpitService {
    foreach ($process in @(Get-StackProcesses $MailpitExe)) {
        Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
    }
    Wait-PortFree -Port $MailpitUiPort -Seconds 5 | Out-Null
    return 'stopped'
}

# ---------------------------------------------------------------- Redis
function Start-RedisService {
    if (Assert-PortFreeOrOurs -Port $RedisPort -ExePath $RedisExe -Label 'Redis') { return 'already' }

    Ensure-Dir (Join-Path $DataDir 'redis')
    Start-Process -FilePath $RedisExe `
        -ArgumentList @("`"$RedisConf`"") `
        -WorkingDirectory (Join-Path $BinDir 'redis') -WindowStyle Hidden `
        -RedirectStandardOutput (Join-Path $LogDir 'redis-stdout.log') `
        -RedirectStandardError (Join-Path $LogDir 'redis-error.log') | Out-Null

    if (-not (Wait-TcpPort -Port $RedisPort -Seconds 12)) {
        $tail = Get-LogTail (Join-Path $LogDir 'redis.log') 15
        throw "Redis did not start on port $RedisPort.`n$($tail -join [Environment]::NewLine)"
    }
    return 'started'
}

function Stop-RedisService {
    if (Test-Path $RedisCli) {
        $previous = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        & $RedisCli -h 127.0.0.1 -p $RedisPort shutdown nosave 2>&1 | Out-Null
        $ErrorActionPreference = $previous
    }
    if (-not (Wait-PortFree -Port $RedisPort -Seconds 6)) {
        foreach ($process in @(Get-StackProcesses $RedisExe)) {
            Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
        }
        Wait-PortFree -Port $RedisPort -Seconds 5 | Out-Null
    }
    return 'stopped'
}

# ---------------------------------------------------------------- Memcached
function Start-MemcachedService {
    if (Assert-PortFreeOrOurs -Port $MemcachedPort -ExePath $MemcachedExe -Label 'Memcached') { return 'already' }

    Start-Process -FilePath $MemcachedExe `
        -ArgumentList @('-p', "$MemcachedPort", '-l', '127.0.0.1', '-m', '64') `
        -WorkingDirectory (Join-Path $BinDir 'memcached') -WindowStyle Hidden `
        -RedirectStandardOutput (Join-Path $LogDir 'memcached.log') `
        -RedirectStandardError (Join-Path $LogDir 'memcached-error.log') | Out-Null

    if (-not (Wait-TcpPort -Port $MemcachedPort -Seconds 10)) {
        throw "Memcached did not start on port $MemcachedPort."
    }
    return 'started'
}

function Stop-MemcachedService {
    foreach ($process in @(Get-StackProcesses $MemcachedExe)) {
        Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
    }
    Wait-PortFree -Port $MemcachedPort -Seconds 5 | Out-Null
    return 'stopped'
}

# ---------------------------------------------------------------- aggregate
function Start-Stack {
    $result = [ordered]@{}
    $result.mysql = Start-MysqlService
    $result.php = Start-PhpWorkers
    $result.supervisor = Start-PhpSupervisor
    $result.web = Start-WebServer

    if ($State.mailpit) { $result.mailpit = Start-MailpitService }
    if ($State.redis) { $result.redis = Start-RedisService }
    if ($State.memcached) { $result.memcached = Start-MemcachedService }

    return [pscustomobject]$result
}

function Stop-Stack {
    $result = [ordered]@{}
    $result.web = Stop-WebServer
    $result.supervisor = Stop-PhpSupervisor
    $result.php = Stop-PhpWorkers
    $result.mysql = Stop-MysqlService
    $result.mailpit = Stop-MailpitService
    $result.redis = Stop-RedisService
    $result.memcached = Stop-MemcachedService
    return [pscustomobject]$result
}

function Restart-Stack {
    Stop-Stack | Out-Null
    Start-Sleep -Milliseconds 500
    # Match restart.cmd: regenerate every config before starting again, so a
    # changed php.ini or a new PHP build is picked up by the new workers.
    Write-AllConfigs
    return (Start-Stack)
}

function Get-StackStatus {
    # The panel polls this every 3 s. Cache for 2 s so rapid calls (doctor,
    # Refresh-Ui, menu checks) do not each pay the ~200 ms enumeration cost
    # and freeze the UI.
    if ($script:StackStatusCache -and ((Get-Date) - $script:StackStatusCache.Time).TotalSeconds -lt 2) {
        return $script:StackStatusCache.Status
    }
    $webExe = if ($State.webServer -eq 'apache') { $ApacheExe } else { $NginxExe }
    $webProcesses = @(Get-StackProcesses $webExe)
    $webProcess = $webProcesses | Select-Object -First 1
    # Use the cached netstat map instead of Test-TcpPort's 400 ms timeout per
    # closed port; the panel polls this every 3 s and the delays added up.
    $webRunning = ($webProcesses.Count -gt 0) -and (Test-PortListening -Port $HttpPort)

    $pools = @()
    $phpAlive = 0
    foreach ($spec in @(Get-PhpPoolSpec)) {
        $poolAlive = 0
        foreach ($port in $spec.Ports) {
            $owner = Get-PortOwnerInfo -Port $port
            if (-not $owner.InUse) { continue }
            $process = Get-Process -Id $owner.Pid -ErrorAction SilentlyContinue
            if (Test-ProcessPath $process $spec.PhpCgi) { $poolAlive++ }
        }
        $phpAlive += $poolAlive
        $pools += [pscustomobject]@{
            Version  = $spec.Version
            Alive    = $poolAlive
            Expected = $spec.Ports.Count
            Ports    = $spec.Ports
            Running  = ($poolAlive -eq $spec.Ports.Count)
        }
    }

    $defaultPool = $pools | Where-Object { $_.Version -eq $State.phpVersion } | Select-Object -First 1
    $supervisor = Get-PhpSupervisorProcess

    $result = [pscustomobject]@{
        WebServer      = $State.webServer
        WebRunning     = $webRunning
        WebPid         = if ($webProcess) { $webProcess.Id } else { 0 }
        HttpPort       = $HttpPort
        HttpsPort      = $HttpsPort
        SslEnabled     = [bool]$State.ssl
        MysqlRunning   = [bool](Test-PortListening -Port $MysqlPort)
        MysqlPort      = $MysqlPort
        PhpVersion     = $State.phpVersion
        PhpAlive       = $phpAlive
        PhpExpected    = (($pools | ForEach-Object { $_.Expected }) | Measure-Object -Sum).Sum
        PhpPools       = $pools
        PhpDefaultPool = $defaultPool
        PhpSupervisor  = [bool]$supervisor
        MailpitRunning = [bool](Test-PortListening -Port $MailpitUiPort)
        MailpitEnabled = [bool]$State.mailpit
        RedisRunning   = [bool](Test-PortListening -Port $RedisPort)
        RedisEnabled   = [bool]$State.redis
        MemcachedRunning = [bool](Test-PortListening -Port $MemcachedPort)
        MemcachedEnabled = [bool]$State.memcached
    }
    $script:StackStatusCache = [pscustomobject]@{ Time = Get-Date; Status = $result }
    return $result
}

function Get-WampDeckPortConflicts {
    $ports = New-Object System.Collections.Generic.List[int]
    $ports.Add($HttpPort)
    if ($State.ssl) { $ports.Add($HttpsPort) }
    $ports.Add($MysqlPort)
    foreach ($spec in @(Get-PhpPoolSpec)) {
        foreach ($port in $spec.Ports) { $ports.Add($port) }
    }
    if ($State.mailpit) {
        $ports.Add($MailpitSmtpPort)
        $ports.Add($MailpitUiPort)
    }
    if ($State.redis) { $ports.Add($RedisPort) }
    if ($State.memcached) { $ports.Add($MemcachedPort) }

    $result = @()
    foreach ($port in ($ports | Select-Object -Unique)) {
        $owner = Get-PortOwnerInfo -Port $port
        if ($owner.InUse -and -not $owner.IsOurs) {
            $result += [pscustomobject]@{
                Port  = $port
                Name  = $owner.Name
                Pid   = $owner.Pid
                Path  = $owner.Path
            }
        }
    }
    return $result
}
