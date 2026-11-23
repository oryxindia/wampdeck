# Lists and toggles PHP extensions for the selected version.
#
#   .\extensions.cmd
#   .\extensions.cmd -Enable xsl,gd
#   .\extensions.cmd -Disable opcache

param(
    [string]$Enable,
    [string]$Disable
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot '..\lib\bootstrap.ps1')

$enableList = @()
$disableList = @()
if ($Enable) { $enableList = @($Enable -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }) }
if ($Disable) { $disableList = @($Disable -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }) }

if ($enableList.Count -gt 0 -or $disableList.Count -gt 0) {
    try {
        if ($enableList.Count -gt 0) { Set-PhpExtensions -Enable $enableList | Out-Null }
        if ($disableList.Count -gt 0) { Set-PhpExtensions -Disable $disableList | Out-Null }
    } catch {
        Write-Err $_.Exception.Message
        exit 1
    }
    Write-Ok "php.ini updated for PHP $($State.phpVersion)"

    $status = Get-StackStatus
    if ($status.WebRunning) {
        Write-Step 'restarting PHP and the web server'
        if ($State.webServer -eq 'apache') {
            Restart-WebServer | Out-Null
        } else {
            Stop-PhpWorkers | Out-Null
            Start-PhpWorkers | Out-Null
            Restart-WebServer | Out-Null
        }
        Write-Ok 'reloaded'
    }
}

Write-Host ''
Write-Host "  PHP $($State.phpVersion) extensions" -ForegroundColor Cyan
$extensions = @(Get-PhpExtensions)
$enabled = @($extensions | Where-Object { $_.Enabled }).Count
Write-Host "  $enabled of $($extensions.Count) enabled" -ForegroundColor DarkGray
Write-Host ''
foreach ($ext in $extensions) {
    $mark = if ($ext.Enabled) { '[x]' } else { '[ ]' }
    $color = if ($ext.Enabled) { 'Green' } else { 'DarkGray' }
    Write-Host ("    {0} {1}" -f $mark, $ext.Name) -ForegroundColor $color
}
Write-Host ''
Write-Host '  Toggle: .\extensions.cmd -Enable name  |  -Disable name' -ForegroundColor DarkGray
Write-Host ''
