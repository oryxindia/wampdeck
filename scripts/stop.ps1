# Stops every WampDeck service.
#
#   powershell -ExecutionPolicy Bypass -File .\scripts\stop.ps1

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot '..\lib\bootstrap.ps1')

Write-Host ''
Write-Host '  WampDeck - stopping' -ForegroundColor Cyan

$result = Stop-Stack

Write-Ok 'web server stopped'
Write-Ok "PHP workers stopped ($($result.php))"
Write-Ok 'database stopped'
if ($State.mailpit) { Write-Ok 'Mailpit stopped' }
if ($State.redis) { Write-Ok 'Redis stopped' }
if ($State.memcached) { Write-Ok 'Memcached stopped' }

Write-Host ''
Write-Host '  All stopped.' -ForegroundColor Green
Write-Host ''
