# Creates a new project in www\.
#
#   .\new.cmd -Name myapp
#   .\new.cmd -Name blog -Type wordpress
#   .\new.cmd -Name api -Type laravel
#   .\new.cmd -Name shop -Cms wordpress
#   .\new.cmd -Name myapp -Open

param(
    [string]$Name,
    [ValidateSet('blank', 'wordpress', 'laravel')]
    [string]$Type = 'blank',
    [string]$Cms,
    [string]$AdminUser,
    [string]$AdminEmail,
    [string]$AdminPassword,
    [string]$ResultFile,
    [switch]$Force,
    [switch]$Open,
    [switch]$NoHosts
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot '..\lib\bootstrap.ps1')

if (-not $Name) {
    Write-Host ''
    Write-Host '  Usage: .\new.cmd -Name myapp [-Type blank|wordpress|laravel] [-Cms <cms-id>] [-Open]' -ForegroundColor Cyan
    Write-Host '  CMS:   .\new.cmd -Name shop -Cms wordpress' -ForegroundColor DarkGray
    Write-Host '  List:  .\wampdeck.cmd cms list' -ForegroundColor DarkGray
    Write-Host ''
    exit 1
}

$cmsEntry = $null
if ($Cms) {
    $cmsEntry = Resolve-WampDeckCms $Cms
    Write-Host ''
    Write-Host "  Installing $($cmsEntry.Name) in '$Name'..." -ForegroundColor Cyan
} else {
    Write-Host ''
    Write-Host "  Creating $Type project '$Name'..." -ForegroundColor Cyan
}

try {
    if ($cmsEntry) {
        $project = New-WampDeckProject -Name $Name -Cms $cmsEntry.Id `
            -AdminUser $AdminUser -AdminEmail $AdminEmail -AdminPassword $AdminPassword -NoHosts:$NoHosts
    } else {
        $project = New-WampDeckProject -Name $Name -Type $Type -Force:$Force -NoHosts:$NoHosts
    }
} catch {
    Write-Err $_.Exception.Message
    exit 1
}

if ($ResultFile) {
    Ensure-Dir (Split-Path -Parent $ResultFile)
    $payload = [ordered]@{
        project = $project
        cms     = $project.CmsResult
    }
    $payload | ConvertTo-Json -Depth 6 | Set-Content -Path $ResultFile -Encoding UTF8
}

Write-Host ''
Write-Ok "project created in $($project.Folder)"
Write-Host ''
Write-Host "  Local    $($project.Url)" -ForegroundColor White
Write-Host "  .test    $($project.TestUrl)" -ForegroundColor White
if ($State.ssl) { Write-Host "  HTTPS    $($project.HttpsUrl)" -ForegroundColor White }
if ($project.CmsResult) {
    # Avoid $cms: it collides with the [string]$Cms parameter and PowerShell
    # would coerce the result object back to a string.
    $cmsInfo = $project.CmsResult
    Write-Host ''
    Write-Host "  CMS        $($cmsInfo.CmsName) ($($cmsInfo.Category))" -ForegroundColor White
    Write-Host "  Admin URL  $($cmsInfo.AdminUrl)" -ForegroundColor White
    if (-not $ResultFile) {
        Write-Host "  Admin user $($cmsInfo.AdminUser)" -ForegroundColor White
        Write-Host "  Password   $($cmsInfo.AdminPassword)" -ForegroundColor White
        Write-Host "  Email      $($cmsInfo.AdminEmail)" -ForegroundColor White
    }
    Write-Host "  Log        $($cmsInfo.Log)" -ForegroundColor DarkGray
    if (-not $cmsInfo.Verified) {
        Write-Warn 'experimental recipe - check the install log before using this site.'
    }
}
if ($NoHosts) {
    Write-Host ''
    Write-Warn 'hosts file not updated (-NoHosts). Run .\hosts.cmd -Sync for .test domains.'
} elseif (-not $project.HostsSynced) {
    Write-Host ''
    Write-Warn 'hosts file not updated (UAC cancelled). .localhost still works; run .\hosts.cmd -Sync for .test.'
}
Write-Host ''

if ($Open) { Start-Process $project.TestUrl }
