# Launches bundled tools.
#
#   .\tools.cmd -Heidi
#   .\tools.cmd -Ngrok
#   .\tools.cmd -Versions
#   .\tools.cmd -Edit www\demo\index.php

param(
    [switch]$Heidi,
    [switch]$Mailpit,
    [switch]$Ngrok,
    [switch]$StopNgrok,
    [switch]$Cmder,
    [switch]$Notepad,
    [switch]$Cronical,
    [switch]$Versions,
    [string]$Edit
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot '..\lib\bootstrap.ps1')

if ($Heidi) { Open-HeidiSql; exit 0 }
if ($Mailpit) { Open-Mailpit; exit 0 }
if ($Cmder) { Open-Cmder; exit 0 }
if ($Notepad) { Open-Notepad; exit 0 }
if ($Cronical) { Start-Cronical; exit 0 }
if ($Edit) { Open-Notepad -Path (Resolve-Path $Edit).Path; exit 0 }
if ($StopNgrok) { Stop-NgrokTunnel; Write-Ok 'ngrok stopped'; exit 0 }

if ($Ngrok) {
    try {
        $url = Start-NgrokTunnel
        if ($url) {
            Write-Ok "public URL: $url"
        } else {
            Write-Warn 'ngrok started, but no public URL yet. Add your authtoken: .\bin\ngrok\ngrok.exe config add-authtoken <token>'
        }
    } catch {
        Write-Err $_.Exception.Message
    }
    exit 0
}

Write-Host ''
Write-Host "  WampDeck tools - PHP $($State.phpVersion)" -ForegroundColor Cyan
Write-Host ''
$versions = @(Get-ToolVersions)
foreach ($tool in $versions) {
    Write-Host ('    {0,-11} {1}' -f $tool.Name, $tool.Version) -ForegroundColor DarkGray
}
Write-Host ''
Write-Host '  Launchers:' -ForegroundColor White
Write-Host '    .\tools.cmd -Heidi       HeidiSQL (127.0.0.1, root, empty password)' -ForegroundColor DarkGray
Write-Host '    .\tools.cmd -Mailpit     open the Mailpit inbox' -ForegroundColor DarkGray
Write-Host '    .\tools.cmd -Ngrok       public tunnel for the panel' -ForegroundColor DarkGray
Write-Host '    .\tools.cmd -Cmder       terminal in www\' -ForegroundColor DarkGray
Write-Host '    .\tools.cmd -Notepad     Notepad++' -ForegroundColor DarkGray
Write-Host '    .\tools.cmd -Cronical    Cronical scheduler' -ForegroundColor DarkGray
Write-Host ''
