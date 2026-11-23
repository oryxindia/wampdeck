# Starts the WampDeck stack.
#
#   powershell -ExecutionPolicy Bypass -File .\scripts\start.ps1
#   powershell -ExecutionPolicy Bypass -File .\scripts\start.ps1 -Open

param([switch]$Open)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot '..\lib\bootstrap.ps1')

if (-not (Test-Path $PhpCgi) -or -not (Test-Path $Mysqld)) {
    Write-Err 'Stack is incomplete. Run .\setup.cmd first.'
    exit 1
}

Write-Host ''
Write-Host '  WampDeck' -ForegroundColor Cyan
Write-Host "  $Root" -ForegroundColor DarkGray
Write-Host ''

# ---------------------------------------------------------------- ssl
if ($State.ssl -and -not (Test-SslCertificate)) {
    Write-Step 'preparing SSL certificate'
    try {
        Initialize-Ssl | Out-Null
        Write-Ok 'SSL certificate ready'
    } catch {
        Write-Err "SSL setup failed: $($_.Exception.Message)"
        exit 1
    }
}

# ---------------------------------------------------------------- configs
Write-AllConfigs

# ---------------------------------------------------------------- ports
$conflicts = @(Get-WampDeckPortConflicts)
if ($conflicts.Count -gt 0) {
    Write-Err 'Port conflict - the stack cannot start:'
    foreach ($conflict in $conflicts) {
        Write-Host ("    port {0,-5} {1} (pid {2})" -f $conflict.Port, $conflict.Name, $conflict.Pid) -ForegroundColor Yellow
    }
    Write-Host ''
    Write-Host '  Stop the other program, or change the port in .\panel.cmd -> Settings.' -ForegroundColor DarkGray
    exit 1
}

# ---------------------------------------------------------------- start
try {
    $result = Start-Stack
} catch {
    Write-Err $_.Exception.Message
    Write-Host ''
    Write-Host '  Run .\status.cmd for details, or check .\logs.' -ForegroundColor DarkGray
    exit 1
}

Write-Ok "MySQL on port $MysqlPort ($($result.mysql))"

if ($result.php -is [pscustomobject]) {
    Write-Ok "PHP $($State.phpVersion) workers: $($result.php.Total) on ports $($PhpPorts -join ', ')"
}

$webName = if ($State.webServer -eq 'apache') { 'Apache' } else { 'nginx' }
Write-Ok "$webName on port $HttpPort ($($result.web))"

if ($State.mailpit) { Write-Ok "Mailpit on http://127.0.0.1:$MailpitUiPort ($($result.mailpit))" }
if ($State.redis) { Write-Ok "Redis on port $RedisPort ($($result.redis))" }
if ($State.memcached) { Write-Ok "Memcached on port $MemcachedPort ($($result.memcached))" }

# ---------------------------------------------------------------- hosts
$hosts = Get-HostsStatus
if (-not $hosts.Synced) {
    Write-Warn "hosts file missing $($hosts.Missing.Count) project name(s). Run .\hosts.cmd -Sync"
}

# ---------------------------------------------------------------- summary
Write-Host ''
Write-Host '  Ready:' -ForegroundColor Green
Write-Host "    Panel    $PanelUrl" -ForegroundColor White
if ($State.ssl) { Write-Host "    Panel    $PanelUrlHttps" -ForegroundColor White }
foreach ($project in @(Get-ProjectList)) {
    Write-Host "    $($project.Name.PadRight(8)) $($project.Url)" -ForegroundColor White
    if ($State.ssl) { Write-Host "             $($project.HttpsUrl)" -ForegroundColor DarkGray }
}
Write-Host ''

if ($Open) { Start-Process $PanelUrl }
