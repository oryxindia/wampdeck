# Switches PHP version and/or web server.
#
#   .\switch.cmd -Php 8.2.12
#   .\switch.cmd -Web apache
#   .\switch.cmd -Php 8.3.30 -Web nginx

param(
    [string]$Php,
    [ValidateSet('nginx', 'apache')]
    [string]$Web
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot '..\lib\bootstrap.ps1')

if (-not $Php -and -not $Web) {
    Write-Host ''
    Write-Host '  Usage: .\switch.cmd [-Php 8.2.12] [-Web nginx|apache]' -ForegroundColor Cyan
    Write-Host "  PHP versions: $($PhpVersions -join ', ')" -ForegroundColor DarkGray
    Write-Host "  Web servers:  nginx, apache" -ForegroundColor DarkGray
    Write-Host ''
    exit 1
}

$targetPhp = $State.phpVersion
if ($Php) {
    $matches = @($PhpVersions | Where-Object { $_ -eq $Php -or $_ -like "$Php*" })
    if ($matches.Count -eq 0) {
        Write-Err "PHP $Php is not installed. Available: $($PhpVersions -join ', ')"
        exit 1
    }
    $targetPhp = $matches[0]
}

$status = Get-StackStatus
$wasRunning = $status.WebRunning
$phpChanged = ($targetPhp -ne $State.phpVersion)
$webChanged = ($Web -and $Web -ne $State.webServer)

if (-not $phpChanged -and -not $webChanged) {
    Write-Ok 'nothing to change'
    exit 0
}

Write-Host ''
Write-Host '  WampDeck switch' -ForegroundColor Cyan

if ($phpChanged) {
    Write-Step "PHP $($State.phpVersion) -> $targetPhp"
    Stop-PhpWorkers | Out-Null
    $State.phpVersion = $targetPhp

    # Refresh the path variables that config.ps1 derived at load time.
    $PhpDir = Join-Path $PhpRoot $targetPhp
    $PhpExe = Join-Path $PhpDir 'php.exe'
    $PhpCgi = Join-Path $PhpDir 'php-cgi.exe'
    $PhpIni = Join-Path $PhpDir 'php.ini'
    Save-StackState
}

if ($webChanged) {
    Write-Step "web server $($State.webServer) -> $Web"
    Stop-WebServer | Out-Null
    $State.webServer = $Web
    Save-StackState
}

Write-AllConfigs
Write-Ok 'configs regenerated'

if ($wasRunning) {
    if ($phpChanged) { Start-PhpWorkers | Out-Null }
    if ($webChanged -or $phpChanged) {
        # Apache embeds PHP, so always reload the web server after a switch.
        Restart-WebServer | Out-Null
    }
    Write-Ok 'stack restarted with the new selection'
}

Write-Host ''
Write-Host "  PHP:  $($State.phpVersion)" -ForegroundColor White
Write-Host "  Web:  $($State.webServer)" -ForegroundColor White
Write-Host ''
