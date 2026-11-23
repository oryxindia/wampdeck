# Regenerates configs after adding/removing project folders by hand.
#
#   .\refresh.cmd              configs + hosts (UAC) + web reload
#   .\refresh.cmd -NoHosts     skip the hosts file
#   .\refresh.cmd -NoRestart   only write configs

param(
    [switch]$NoHosts,
    [switch]$NoRestart
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot '..\lib\bootstrap.ps1')

Write-Host ''
Write-Host '  WampDeck refresh' -ForegroundColor Cyan

Write-AllConfigs
Write-Ok 'configs regenerated'

if (-not $NoHosts) {
    if (Invoke-HostsSyncElevated) {
        Write-Ok 'hosts file synced'
    } else {
        Write-Warn 'hosts file not updated (UAC cancelled)'
    }
}

if (-not $NoRestart) {
    $status = Get-StackStatus
    if ($status.WebRunning) {
        Restart-WebServer | Out-Null
        Write-Ok 'web server reloaded'
    }
}

Write-Host ''
Write-Host "  Panel: $PanelUrl" -ForegroundColor White
Write-Host ''
