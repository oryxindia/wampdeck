# Shows what is running, project URLs, SSL and hosts state.
#
#   powershell -ExecutionPolicy Bypass -File .\scripts\status.ps1
#   powershell -ExecutionPolicy Bypass -File .\scripts\status.ps1 -Tools

param([switch]$Tools)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot '..\lib\bootstrap.ps1')

function Write-StatusRow {
    param([string]$Component, [bool]$Running, [string]$Details)
    $stateLabel = if ($Running) { 'running' } else { 'stopped' }
    $color = if ($Running) { 'Green' } else { 'Red' }
    Write-Host ('  {0,-12} ' -f $Component) -NoNewline
    Write-Host ('{0,-9} ' -f $stateLabel) -NoNewline -ForegroundColor $color
    Write-Host $Details -ForegroundColor DarkGray
}

Write-Host ''
Write-Host '  WampDeck status' -ForegroundColor Cyan
Write-Host "  $Root" -ForegroundColor DarkGray
Write-Host ''

$status = Get-StackStatus
$webName = if ($status.WebServer -eq 'apache') { 'Apache' } else { 'nginx' }
$phpText = "$($status.PhpAlive)/$($status.PhpExpected) workers on ports $($PhpPorts -join ', ')"

Write-StatusRow $webName $status.WebRunning "port $HttpPort"
Write-StatusRow "PHP $($status.PhpVersion)" ($status.PhpAlive -eq $status.PhpExpected) $phpText

$dbText = "port $MysqlPort"
if ($status.MysqlRunning) {
    try {
        $version = & $MysqlCli "--defaults-file=$MyIni" -u root -N -B -e 'SELECT VERSION();' 2>$null
        if ($version) { $dbText += ", $($version.Trim())" }
    } catch { }
}
Write-StatusRow 'MySQL' $status.MysqlRunning $dbText

if ($status.MailpitEnabled) {
    Write-StatusRow 'Mailpit' $status.MailpitRunning "SMTP 127.0.0.1:$MailpitSmtpPort, UI http://127.0.0.1:$MailpitUiPort"
}
if ($status.RedisEnabled) {
    Write-StatusRow 'Redis' $status.RedisRunning "port $RedisPort"
}
if ($status.MemcachedEnabled) {
    Write-StatusRow 'Memcached' $status.MemcachedRunning "port $MemcachedPort"
}

Write-Host ''
Write-Host '  URLs' -ForegroundColor Cyan
Write-Host "    Panel       $PanelUrl" -ForegroundColor White
if ($State.ssl) { Write-Host "    Panel SSL   $PanelUrlHttps" -ForegroundColor White }

$projects = @(Get-ProjectList)
if ($projects.Count -eq 0) {
    Write-Host '    (no projects yet - run .\new.cmd -Name myapp)' -ForegroundColor DarkGray
} else {
    foreach ($project in $projects) {
        Write-Host "    $($project.Name.PadRight(11)) $($project.Url)" -ForegroundColor White
        if ($State.ssl) { Write-Host "                $($project.HttpsUrl)" -ForegroundColor DarkGray }
    }
}

# ---------------------------------------------------------------- hosts
Write-Host ''
Write-Host '  Hosts file' -ForegroundColor Cyan
$hosts = Get-HostsStatus
if ($hosts.Synced) {
    Write-Host "    synced ($($hosts.Present)/$($hosts.Required) names)" -ForegroundColor Green
} else {
    Write-Host "    missing $($hosts.Missing.Count) of $($hosts.Required) names - run .\hosts.cmd -Sync" -ForegroundColor Yellow
}

# ---------------------------------------------------------------- ssl
Write-Host ''
Write-Host '  SSL' -ForegroundColor Cyan
if (-not $State.ssl) {
    Write-Host '    disabled - run .\ssl.cmd -Enable' -ForegroundColor DarkGray
} else {
    $ssl = Get-SslStatus
    if ($ssl.HasCert) {
        Write-Host "    certificate valid until $($ssl.Cert.NotAfter.ToString('yyyy-MM-dd')) ($($ssl.Cert.DaysLeft) days)" -ForegroundColor Green
    } else {
        Write-Host '    certificate missing - run .\ssl.cmd -Enable' -ForegroundColor Yellow
    }
    if ($ssl.Trusted) {
        Write-Host '    local CA trusted (CurrentUser Root)' -ForegroundColor Green
    } else {
        Write-Host '    local CA not trusted - run .\ssl.cmd -Trust' -ForegroundColor Yellow
    }
}

# ---------------------------------------------------------------- conflicts
$conflicts = @(Get-WampDeckPortConflicts)
if ($conflicts.Count -gt 0) {
    Write-Host ''
    Write-Host '  Port conflicts' -ForegroundColor Yellow
    foreach ($conflict in $conflicts) {
        Write-Host ("    {0,-5} {1} (pid {2})" -f $conflict.Port, $conflict.Name, $conflict.Pid) -ForegroundColor Yellow
    }
}

# ---------------------------------------------------------------- tools
if ($Tools) {
    Write-Host ''
    Write-Host '  Tools' -ForegroundColor Cyan
    foreach ($tool in @(Get-ToolVersions)) {
        Write-Host ('    {0,-11} {1}' -f $tool.Name, $tool.Version) -ForegroundColor DarkGray
    }
}

Write-Host ''
