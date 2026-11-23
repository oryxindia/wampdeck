# Adds (or removes) the WampDeck binaries in the Windows Defender
# Controlled Folder Access allow list.
#
# Run as administrator:
#   right-click this file -> Run with PowerShell (as admin)
# or from an elevated PowerShell:
#   .\scripts\allow-cfa.ps1
#
# Remove them again:
#   .\scripts\allow-cfa.ps1 -Remove

param([switch]$Remove)

$ErrorActionPreference = 'Stop'

$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host ''
    Write-Host '  Administrator rights are required.' -ForegroundColor Yellow
    Write-Host '  Right-click scripts\allow-cfa.ps1 and choose "Run with PowerShell" as administrator,'
    Write-Host '  or open an elevated PowerShell and run:'
    Write-Host "    & '$PSCommandPath'" -ForegroundColor Cyan
    Write-Host ''
    exit 1
}

$root = Split-Path -Parent $PSScriptRoot

$apps = @()
foreach ($phpDir in @(Get-ChildItem (Join-Path $root 'bin\php') -Directory -ErrorAction SilentlyContinue)) {
    $apps += Join-Path $phpDir.FullName 'php.exe'
}
$apps += @(
    (Join-Path $root 'bin\nginx\nginx.exe'),
    (Join-Path $root 'bin\apache\bin\httpd.exe'),
    (Join-Path $root 'bin\mysql\bin\mysqld.exe'),
    (Join-Path $root 'bin\redis\redis-server.exe'),
    (Join-Path $root 'bin\memcached\memcached.exe'),
    (Join-Path $root 'bin\mailpit\mailpit.exe'),
    (Join-Path $root 'bin\git\mingw64\bin\git.exe'),
    (Join-Path $root 'bin\nodejs\node.exe'),
    (Join-Path $root 'bin\python\python.exe'),
    (Join-Path $root 'bin\ngrok\ngrok.exe'),
    'C:\Program Files\7-Zip\7z.exe',
    "$env:SystemRoot\System32\cmd.exe",
    "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
)
$apps = @($apps | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -Unique)

if ($apps.Count -eq 0) {
    Write-Host '  No WampDeck executables found. Is the folder complete?' -ForegroundColor Red
    exit 1
}

Write-Host ''
if ($Remove) {
    Write-Host '  Removing Controlled Folder Access allowances...' -ForegroundColor Cyan
    Remove-MpPreference -ControlledFolderAccessAllowedApplications $apps
    Write-Host '  Removed.' -ForegroundColor Green
} else {
    Write-Host '  Allowing WampDeck in Controlled Folder Access...' -ForegroundColor Cyan
    Add-MpPreference -ControlledFolderAccessAllowedApplications $apps
    Write-Host '  Added.' -ForegroundColor Green
}

Write-Host ''
Write-Host '  Applications:' -ForegroundColor White
foreach ($app in $apps) { Write-Host "    $app" }
Write-Host ''
Write-Host '  Restart the stack or retry the failed action.' -ForegroundColor DarkGray
Write-Host ''
