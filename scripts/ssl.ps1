# Local SSL control.
#
#   .\ssl.cmd                 status
#   .\ssl.cmd -Enable         create certs, trust CA, enable https
#   .\ssl.cmd -Disable        turn https off (certs stay)
#   .\ssl.cmd -Reset          regenerate certs and trust the new CA
#   .\ssl.cmd -Trust          trust the existing CA in CurrentUser Root

param(
    [switch]$Enable,
    [switch]$Disable,
    [switch]$Reset,
    [switch]$Trust,
    [switch]$SkipTrust
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot '..\lib\bootstrap.ps1')

function Restart-WebIfRunning {
    $status = Get-StackStatus
    if (-not $status.WebRunning) { return }
    Write-Step 'restarting web server'
    Restart-WebServer | Out-Null
    Write-Ok 'web server restarted'
}

function Show-SslStatus {
    $ssl = Get-SslStatus
    Write-Host ''
    Write-Host '  WampDeck SSL' -ForegroundColor Cyan
    Write-Host "  enabled:    $($State.ssl)" -ForegroundColor White
    if ($ssl.HasCa) {
        Write-Host "  local CA:   $($ssl.Ca.Subject)" -ForegroundColor DarkGray
        Write-Host "  trusted:    $($ssl.Trusted)" -ForegroundColor $(if ($ssl.Trusted) { 'Green' } else { 'Yellow' })
    } else {
        Write-Host '  local CA:   missing' -ForegroundColor Yellow
    }
    if ($ssl.HasCert) {
        Write-Host "  cert:       $($ssl.Cert.Subject)" -ForegroundColor DarkGray
        Write-Host "  expires:    $($ssl.Cert.NotAfter.ToString('yyyy-MM-dd')) ($($ssl.Cert.DaysLeft) days)" -ForegroundColor White
        Write-Host "  names:      $($ssl.Cert.San)" -ForegroundColor DarkGray
    } else {
        Write-Host '  cert:       missing' -ForegroundColor Yellow
    }
    Write-Host ''
}

if ($Trust) {
    if (Install-CaTrust) {
        Write-Ok 'WampDeck CA trusted in CurrentUser Root'
    } else {
        Write-Warn 'CA not trusted yet. Confirm the Windows security dialog, or install etc\ssl\ca.crt manually.'
        Start-Process $SslCaCert
    }
    exit 0
}

if ($Reset) {
    Write-Step 'regenerating CA and server certificate'
    $result = Reset-Ssl
    $State.ssl = $true
    Save-StackState
    Write-AllConfigs
    Write-Ok 'certificates regenerated'
    Restart-WebIfRunning
    Show-SslStatus
    exit 0
}

if ($Enable) {
    Write-Step 'creating CA and wildcard certificate'
    $result = Initialize-Ssl -SkipTrust:$SkipTrust
    if (-not $result.Trusted) {
        Write-Warn 'Certificate created, but the CA is not trusted yet.'
        Write-Warn 'Run .\ssl.cmd -Trust and confirm the Windows security dialog once.'
    } else {
        Write-Ok 'CA trusted in CurrentUser Root'
    }
    $State.ssl = $true
    Save-StackState
    Write-AllConfigs
    Write-Ok 'HTTPS enabled'
    Restart-WebIfRunning
    Write-Host ''
    Write-Host "  Panel: $PanelUrlHttps" -ForegroundColor White
    foreach ($project in @(Get-ProjectList)) {
        Write-Host "  $($project.Name): $($project.HttpsUrl)" -ForegroundColor White
    }
    Write-Host ''
    exit 0
}

if ($Disable) {
    $State.ssl = $false
    Save-StackState
    Write-AllConfigs
    Write-Ok 'HTTPS disabled (certificates kept)'
    Restart-WebIfRunning
    Show-SslStatus
    exit 0
}

Show-SslStatus
