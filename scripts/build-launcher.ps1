# Rebuilds WampDeck.exe, the tiny native launcher for the PowerShell panel.
#
#   .\scripts\build-launcher.ps1
#
# The launcher is not a copy of the whole stack: WampDeck.exe sits next to
# panel.ps1 and starts it without a console window. Build output stays in
# %TEMP% first, then is copied into the stack folder (Controlled Folder
# Access-friendly).

param([string]$Output)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
if (-not $Output) { $Output = Join-Path $root 'WampDeck.exe' }

$csc = Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\csc.exe'
if (-not (Test-Path $csc)) {
    $csc = Join-Path $env:WINDIR 'Microsoft.NET\Framework\v4.0.30319\csc.exe'
}
if (-not (Test-Path $csc)) {
    throw 'C# compiler not found. Windows .NET Framework 4.x is required.'
}

$source = Join-Path $root 'launcher\WampDeckLauncher.cs'
$icon = Join-Path $root 'assets\wampdeck.ico'
if (-not (Test-Path $source)) { throw "Missing $source" }
if (-not (Test-Path $icon)) {
    & (Join-Path $PSScriptRoot 'make-icon.ps1')
}

$buildDir = Join-Path $env:TEMP 'wampdeck-build'
New-Item -ItemType Directory -Force -Path $buildDir | Out-Null
$tempExe = Join-Path $buildDir 'WampDeck.exe'

& $csc /nologo /target:winexe /optimize+ "/out:$tempExe" "/win32icon:$icon" `
    /r:System.dll /r:System.Windows.Forms.dll /r:System.Drawing.dll $source
if ($LASTEXITCODE -ne 0 -or -not (Test-Path $tempExe)) {
    throw "csc failed with exit code $LASTEXITCODE"
}

Copy-Item -LiteralPath $tempExe -Destination $Output -Force
Write-Host "built $Output" -ForegroundColor Green
