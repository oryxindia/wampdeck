# Managed hosts-file entries for .test / .localhost projects.
#
#   .\hosts.cmd -Sync     add/update project names (one UAC prompt)
#   .\hosts.cmd -Status   show what is present
#   .\hosts.cmd -Open     open the hosts file in Notepad (admin)

param(
    [switch]$Sync,
    [switch]$Status,
    [switch]$Open
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot '..\lib\bootstrap.ps1')

if ($Open) {
    Start-Process -FilePath 'notepad.exe' -ArgumentList "`"$HostsFile`"" -Verb RunAs
    exit 0
}

if ($Sync) {
    Write-Host ''
    Write-Step 'updating the managed WampDeck block in the hosts file'
    if (Invoke-HostsSyncElevated) {
        $check = Get-HostsStatus
        Write-Ok "hosts file synced ($($check.Present)/$($check.Required) names)"
    } else {
        Write-Err 'hosts file not updated (UAC cancelled)'
        exit 1
    }
    Write-Host ''
    exit 0
}

Write-Host ''
Write-Host '  WampDeck hosts' -ForegroundColor Cyan
Write-Host "  $HostsFile" -ForegroundColor DarkGray
$hosts = Get-HostsStatus
Write-Host "  admin:   $($hosts.IsAdmin)" -ForegroundColor DarkGray
Write-Host "  synced:  $($hosts.Synced)" -ForegroundColor $(if ($hosts.Synced) { 'Green' } else { 'Yellow' })
Write-Host "  names:   $($hosts.Present)/$($hosts.Required)" -ForegroundColor White
if (-not $hosts.Synced) {
    Write-Host '  missing:' -ForegroundColor Yellow
    foreach ($name in $hosts.Missing) { Write-Host "    $name" -ForegroundColor Yellow }
    Write-Host ''
    Write-Host '  Run .\hosts.cmd -Sync to fix.' -ForegroundColor DarkGray
}
Write-Host ''
