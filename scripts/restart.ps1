# Restarts the stack (configs are regenerated).
#
#   powershell -ExecutionPolicy Bypass -File .\scripts\restart.ps1
#   powershell -ExecutionPolicy Bypass -File .\scripts\restart.ps1 -Open

param([switch]$Open)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot '..\lib\bootstrap.ps1')

Write-Host ''
Write-Host '  WampDeck - restarting' -ForegroundColor Cyan

Stop-Stack | Out-Null
Start-Sleep -Milliseconds 600
Write-AllConfigs

try {
    $result = Start-Stack
} catch {
    Write-Err $_.Exception.Message
    exit 1
}

$webName = if ($State.webServer -eq 'apache') { 'Apache' } else { 'nginx' }
Write-Ok "$webName on port $HttpPort"
Write-Ok "MySQL on port $MysqlPort"
Write-Ok "PHP $($State.phpVersion) workers running"
if ($State.mailpit) { Write-Ok "Mailpit on http://127.0.0.1:$MailpitUiPort" }
if ($State.redis) { Write-Ok "Redis on port $RedisPort" }
if ($State.memcached) { Write-Ok "Memcached on port $MemcachedPort" }
Write-Host ''
Write-Host "  Panel: $PanelUrl" -ForegroundColor White
Write-Host ''

if ($Open) { Start-Process $PanelUrl }
