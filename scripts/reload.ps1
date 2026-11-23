# Regenerates configs and reloads PHP / the web server without touching MySQL.
# Used by the panel after changing PHP extensions or the PHP version.
#
#   powershell -ExecutionPolicy Bypass -File .\scripts\reload.ps1

param([switch]$NoRestart)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot '..\lib\bootstrap.ps1')

Write-AllConfigs

if (-not $NoRestart) {
    $status = Get-StackStatus
    if ($status.WebRunning) {
        Stop-PhpWorkers | Out-Null
        if ($State.webServer -ne 'apache') {
            Start-PhpWorkers | Out-Null
        }
        Restart-WebServer | Out-Null
    }
}

Write-Ok 'configs regenerated and PHP reloaded'
