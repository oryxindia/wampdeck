# Fetches signtool.exe without installing the Windows SDK or needing admin.
#
#   .\scripts\get-signtool.ps1
#
# The Microsoft.Windows.SDK.BuildTools NuGet package ships the same
# signtool.exe the SDK installs. It lands in
# %LOCALAPPDATA%\wampdeck-build-tools, which scripts\sign-installer.ps1
# searches. Nothing here is bundled into the installer.

$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$dest = Join-Path $env:LOCALAPPDATA 'wampdeck-build-tools'
$nupkg = Join-Path $dest 'sdk-buildtools.nupkg'
$extract = Join-Path $dest 'sdk'

New-Item -ItemType Directory -Force -Path $dest | Out-Null

if (-not (Test-Path $nupkg) -or (Get-Item $nupkg).Length -lt 1MB) {
    Write-Host 'Downloading Microsoft.Windows.SDK.BuildTools ...'
    Invoke-WebRequest -Uri 'https://www.nuget.org/api/v2/package/Microsoft.Windows.SDK.BuildTools' `
        -OutFile $nupkg -UseBasicParsing
}

# A .nupkg is a zip with a different extension.
$zip = Join-Path $dest 'sdk-buildtools.zip'
Copy-Item $nupkg $zip -Force
if (Test-Path $extract) { Remove-Item $extract -Recurse -Force }
Expand-Archive -Path $zip -DestinationPath $extract -Force
Remove-Item $zip -Force

$signtool = Get-ChildItem $extract -Recurse -Filter signtool.exe -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -match '\\x64\\signtool\.exe$' } |
    Select-Object -First 1
if (-not $signtool) { throw 'signtool.exe was not found in the BuildTools package.' }

Write-Host "signtool: $($signtool.FullName)" -ForegroundColor Green
