# Builds a code-signed WampDeck-Setup.exe.
#
#   .\scripts\sign-installer.ps1 -Thumbprint <cert-thumbprint>
#   .\scripts\sign-installer.ps1 -Pfx .\wampdeck.pfx -Password <password>
#
# The certificate must be a code-signing certificate (OV or EV). Without one
# the installer still builds, but SmartScreen will warn on other machines.
#
# A certificate in CurrentUser\My (recommended: EV hardware token) needs only
# its thumbprint, so no password ever appears on a command line.

param(
    [string]$Thumbprint,
    [string]$Pfx,
    [string]$Password,
    [string]$TimestampUrl = 'http://timestamp.digicert.com'
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

$iscc = Join-Path $env:LOCALAPPDATA 'Programs\Inno Setup 6\ISCC.exe'
if (-not (Test-Path $iscc)) {
    $iscc = 'C:\Program Files (x86)\Inno Setup 6\ISCC.exe'
}
if (-not (Test-Path $iscc)) { throw 'ISCC.exe not found. Install Inno Setup 6.' }

# signtool ships with the Windows SDK. Look in an installed SDK first, then in
# the SDK BuildTools copy that scripts\get-signtool.ps1 extracts without admin.
$searchRoots = @(
    'C:\Program Files (x86)\Windows Kits\10\bin',
    (Join-Path $env:LOCALAPPDATA 'wampdeck-build-tools')
)
$signtool = $null
foreach ($searchRoot in $searchRoots) {
    if (-not (Test-Path $searchRoot)) { continue }
    $signtool = Get-ChildItem $searchRoot -Recurse -Filter signtool.exe -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -match '\\x64\\signtool\.exe$' } |
        Sort-Object FullName -Descending | Select-Object -First 1
    if ($signtool) { break }
}
if (-not $signtool) { throw 'signtool.exe not found. Run scripts\get-signtool.ps1 or install the Windows SDK signing tools.' }

# Inno Setup passes the Sign Tool command to CreateProcess as-is, so the
# command must not contain quotes it has to parse. Give it space-free paths:
# use the 8.3 short name, or stage the file in a path without spaces.
function Get-QuotelessPath([string]$Path) {
    if ($Path -notmatch '\s') { return $Path }
    try {
        $fso = New-Object -ComObject Scripting.FileSystemObject
        $short = $fso.GetFile($Path).ShortPath
        if ($short -and $short -notmatch '\s') { return $short }
    } catch { }
    $stage = Join-Path $env:LOCALAPPDATA 'wampdeck-build-tools\stage'
    New-Item -ItemType Directory -Force -Path $stage | Out-Null
    $copy = Join-Path $stage (Split-Path -Leaf $Path)
    Copy-Item $Path $copy -Force
    return $copy
}

$signtoolPath = Get-QuotelessPath $signtool.FullName

$certArgs = ''
if ($Thumbprint) {
    $certArgs = "/sha1 $($Thumbprint -replace '\s','')"
} elseif ($Pfx) {
    if (-not [System.IO.Path]::IsPathRooted($Pfx)) { $Pfx = Join-Path $root $Pfx }
    if (-not (Test-Path $Pfx)) { throw "Certificate not found: $Pfx" }
    $certArgs = "/f $(Get-QuotelessPath (Resolve-Path $Pfx).Path)"
    # Inno passes the command unquoted, so a PFX password must not contain spaces.
    if ($Password) { $certArgs += " /p $Password" }
} else {
    throw 'Pass -Thumbprint (certificate store) or -Pfx/-Password.'
}

$signCommand = "$signtoolPath sign /fd SHA256 /td SHA256 /tr $TimestampUrl $certArgs `$f"
Write-Host "Signing with: $signtoolPath"
Write-Host "Certificate : $(if ($Thumbprint) { "store $Thumbprint" } else { $Pfx })"

# Inno resolves relative paths in the script (OutputDir, SourceDir) against the
# current directory, so compile from the project root.
Push-Location $root
try {
    & $iscc /DSIGN "/Swampdeck=$signCommand" 'installer\WampDeck.iss'
    $code = $LASTEXITCODE
} finally {
    Pop-Location
}
if ($code -ne 0) { throw "ISCC failed with exit code $code" }

$setup = Join-Path $root 'dist\WampDeck-Setup.exe'
Write-Host "Signed installer: $setup" -ForegroundColor Green
Get-AuthenticodeSignature $setup |
    Select-Object Status, StatusMessage, @{ n = 'Signer'; e = { $_.SignerCertificate.Subject } } |
    Format-List
