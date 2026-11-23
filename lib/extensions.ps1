# PHP extension state, persisted in etc\extensions.json.
# php.ini is regenerated from this state, so toggles survive refresh/setup.

$ExtensionStateFile = Join-Path $EtcDir 'extensions.json'
$script:ExtensionState = $null

function Get-ExtensionDefaults {
    return @(
        'curl', 'fileinfo', 'gd', 'intl', 'mbstring', 'exif', 'mysqli',
        'openssl', 'pdo_mysql', 'pdo_sqlite', 'sqlite3', 'zip', 'sodium',
        'xsl', 'opcache'
    )
}

function Get-ExtensionState {
    if ($null -ne $script:ExtensionState) { return $script:ExtensionState }

    $extensionState = @{}
    if (Test-Path $ExtensionStateFile) {
        try {
            $json = Get-Content -Path $ExtensionStateFile -Raw | ConvertFrom-Json
            foreach ($versionProp in $json.PSObject.Properties) {
                $map = @{}
                foreach ($extProp in $versionProp.Value.PSObject.Properties) {
                    $map[$extProp.Name] = [bool]$extProp.Value
                }
                $extensionState[$versionProp.Name] = $map
            }
        } catch { $extensionState = @{} }
    }
    $script:ExtensionState = $extensionState
    return $extensionState
}

function Save-ExtensionState {
    $extensionState = Get-ExtensionState
    $extensionState | ConvertTo-Json -Depth 5 | Set-Content -Path $ExtensionStateFile -Encoding ASCII
    $script:ExtensionState = $null
}

function Get-ExtensionMap {
    param([string]$Version = $State.phpVersion)
    $map = @{}
    foreach ($name in @(Get-ExtensionDefaults)) { $map[$name] = $true }
    $extensionState = Get-ExtensionState
    if ($extensionState.ContainsKey($Version)) {
        foreach ($key in $extensionState[$Version].Keys) { $map[$key] = [bool]$extensionState[$Version][$key] }
    }
    return $map
}

function Get-PhpExtensions {
    param([string]$Version = $State.phpVersion)
    $extDir = Join-Path (Join-Path $PhpRoot $Version) 'ext'
    if (-not (Test-Path $extDir)) { return @() }
    $map = Get-ExtensionMap -Version $Version

    $result = @()
    foreach ($dll in (Get-ChildItem $extDir -Filter 'php_*.dll' -ErrorAction SilentlyContinue | Sort-Object Name)) {
        $name = $dll.BaseName -replace '^php_', ''
        $result += [pscustomobject]@{
            Name    = $name
            Dll     = $dll.Name
            Enabled = ($map[$name] -eq $true)
            Zend    = ($name -eq 'opcache')
        }
    }
    return $result
}

function Set-PhpExtension {
    param(
        [string]$Name,
        [bool]$Enabled,
        [string]$Version = $State.phpVersion
    )

    $extDir = Join-Path (Join-Path $PhpRoot $Version) 'ext'
    if (-not (Test-Path (Join-Path $extDir "php_$Name.dll"))) {
        throw "Extension '$Name' is not available for PHP $Version."
    }

    $extensionState = Get-ExtensionState
    $map = Get-ExtensionMap -Version $Version
    $map[$Name] = $Enabled
    $extensionState[$Version] = $map
    Save-ExtensionState

    Write-PhpIni -Version $Version
    return $Enabled
}

function Set-PhpExtensions {
    param(
        [string[]]$Enable = @(),
        [string[]]$Disable = @(),
        [string]$Version = $State.phpVersion
    )
    foreach ($name in $Enable) { Set-PhpExtension -Name $name -Enabled $true -Version $Version | Out-Null }
    foreach ($name in $Disable) { Set-PhpExtension -Name $name -Enabled $false -Version $Version | Out-Null }
    return (Get-PhpExtensions -Version $Version)
}
