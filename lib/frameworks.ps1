Add-Type -AssemblyName System.Drawing

# Free feature: one-click PHP framework installer with the original framework
# logos. Uses the bundled Composer + PHP, the user's own projects folder
# and free Packagist packages. No WampDeck service or paid account.

function Get-FrameworkCatalog {
    return [ordered]@{
        'laravel' = [pscustomobject]@{
            Name = 'Laravel'; Package = 'laravel/laravel'; Color = [System.Drawing.Color]::FromArgb(232, 62, 55); Initial = 'L'
            Note = 'Full-stack PHP framework'; Db = $true; Kind = 'skeleton'
        }
        'symfony' = [pscustomobject]@{
            Name = 'Symfony'; Package = 'symfony/skeleton'; Color = [System.Drawing.Color]::FromArgb(43, 43, 54); Initial = 'S'
            Note = 'Flexible PHP framework'; Db = $false; Kind = 'skeleton'
        }
        'codeigniter' = [pscustomobject]@{
            Name = 'CodeIgniter 4'; Package = 'codeigniter4/appstarter'; Color = [System.Drawing.Color]::FromArgb(255, 102, 0); Initial = '4'
            Note = 'Lightweight MVC framework'; Db = $true; Kind = 'skeleton'
        }
        'slim' = [pscustomobject]@{
            Name = 'Slim'; Package = 'slim/slim-skeleton'; Color = [System.Drawing.Color]::FromArgb(102, 145, 60); Initial = 'S'
            Note = 'Micro framework for APIs'; Db = $false; Kind = 'skeleton'
        }
        'yii3' = [pscustomobject]@{
            Name = 'Yii 3'; Package = 'yiisoft/app'; Color = [System.Drawing.Color]::FromArgb(140, 190, 60); Initial = 'Y'
            Note = 'Component-based framework'; Db = $false; Kind = 'skeleton'
        }
        'cakephp' = [pscustomobject]@{
            Name = 'CakePHP 5'; Package = 'cakephp/app'; Color = [System.Drawing.Color]::FromArgb(200, 22, 60); Initial = 'C'
            Note = 'Rapid development framework'; Db = $true; Kind = 'skeleton'
        }
        'nette' = [pscustomobject]@{
            Name = 'Nette'; Package = 'nette/sandbox'; Color = [System.Drawing.Color]::FromArgb(64, 132, 206); Initial = 'N'
            Note = 'Elegant PHP framework'; Db = $false; Kind = 'skeleton'
        }
        'laminas' = [pscustomobject]@{
            Name = 'Laminas'; Package = 'laminas/laminas-mvc-skeleton'; Color = [System.Drawing.Color]::FromArgb(45, 55, 90); Initial = 'L'
            Note = 'Enterprise PHP framework'; Db = $false; Kind = 'skeleton'
        }
        'fatfree' = [pscustomobject]@{
            Name = 'Fat-Free'; Package = 'bcosca/fatfree'; Color = [System.Drawing.Color]::FromArgb(160, 160, 160); Initial = 'F3'
            Note = 'Tiny, fast micro-framework'; Db = $false; Kind = 'skeleton'
        }
        'flight' = [pscustomobject]@{
            Name = 'Flight'; Package = 'flightphp/skeleton'; Color = [System.Drawing.Color]::FromArgb(200, 200, 208); Initial = 'F'
            Note = 'Minimalist micro-framework'; Db = $false; Kind = 'skeleton'
        }
        'phalcon' = [pscustomobject]@{
            Name = 'Phalcon 6'; Package = 'phalcon/phalcon'; Color = [System.Drawing.Color]::FromArgb(56, 128, 45); Initial = 'P'
            Note = 'High-performance framework'; Db = $false; Kind = 'minimal'; Require = '^6.0@RC'
            Bootstrap = @'
<?php
require __DIR__ . '/vendor/autoload.php';
echo '<!doctype html><html><head><meta charset="utf-8"><title>Phalcon</title></head><body>';
echo '<h1>Phalcon 6 is ready</h1><p>Your WampDeck Pro project is configured.</p>';
echo '</body></html>';
'@
        }
        'thinkphp' = [pscustomobject]@{
            Name = 'ThinkPHP 8'; Package = 'topthink/think'; Color = [System.Drawing.Color]::FromArgb(45, 140, 240); Initial = 'TP'
            Note = 'Fast MVC framework'; Db = $false; Kind = 'skeleton'
        }
    }
}

function Get-FrameworkIconDir {
    $dir = Join-Path $Root 'assets\frameworks'
    Ensure-Dir $dir
    return $dir
}

function New-FrameworkIcons {
    Add-Type -AssemblyName System.Drawing
    $dir = Get-FrameworkIconDir
    foreach ($entry in (Get-FrameworkCatalog).GetEnumerator()) {
        $path = Join-Path $dir ($entry.Key + '.png')
        if (Test-Path $path) { continue }
        $bmp = New-Object System.Drawing.Bitmap(64, 64)
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        $g.Clear([System.Drawing.Color]::Transparent)
        $brush = New-Object System.Drawing.SolidBrush($entry.Value.Color)
        $g.FillRectangle($brush, 0, 0, 64, 64)
        $font = New-Object System.Drawing.Font('Segoe UI', $(if ($entry.Value.Initial.Length -gt 1) { 22 } else { 30 }), [System.Drawing.FontStyle]::Bold)
        $format = New-Object System.Drawing.StringFormat
        $format.Alignment = [System.Drawing.StringAlignment]::Center
        $format.LineAlignment = [System.Drawing.StringAlignment]::Center
        $white = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
        $g.DrawString($entry.Value.Initial, $font, $white, (New-Object System.Drawing.RectangleF(0, 0, 64, 64)), $format)
        $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
        $g.Dispose(); $brush.Dispose(); $font.Dispose(); $white.Dispose(); $bmp.Dispose()
    }
}

function Set-FrameworkEnv {
    param([Parameter(Mandatory = $true)][string]$ProjectDir, [hashtable]$Values)
    $path = Join-Path $ProjectDir '.env'
    $lines = @()
    if (Test-Path $path) { $lines = @(Get-Content $path) }
    foreach ($key in $Values.Keys) {
        $prefix = $key + '='
        $lines = @($lines | Where-Object { -not $_.StartsWith($prefix) })
        $lines += ($prefix + $Values[$key])
    }
    [IO.File]::WriteAllText($path, (($lines -join "`r`n") + "`r`n"), [Text.Encoding]::UTF8)
}

function Install-Framework {
    param(
        [Parameter(Mandatory = $true)][string]$Id,
        [Parameter(Mandatory = $true)][string]$Name,
        [switch]$NoHosts
    )

    $catalog = Get-FrameworkCatalog
    if (-not $catalog.Contains($Id)) { throw "Unknown framework '$Id'. Choose from: $(($catalog.Keys) -join ', ')." }
    $fw = $catalog[$Id]
    if ($Name -notmatch '^[A-Za-z0-9_-]+$') { throw 'Project name may contain only letters, numbers, dash and underscore.' }

    $target = Join-Path $WwwDir $Name
    if (Test-Path $target) { throw "Project '$Name' already exists." }
    if (-not (Test-Path $ComposerBat)) { throw "Composer is missing: $ComposerBat" }
    if (-not (Test-Path $PhpExe)) { throw "PHP is missing: $PhpExe" }

    Write-Host "  Installing $($fw.Name) into $Name ..." -ForegroundColor Cyan

    $oldPath = $env:PATH
    try {
        $env:PATH = (Split-Path -Parent $PhpExe) + ';' + (Split-Path -Parent $ComposerBat) + ';' + $env:PATH
        $prevEap = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        try {
            if ($fw.Kind -eq 'minimal') {
                Ensure-Dir $target
                $composerJson = [ordered]@{
                    name = 'wampdeck/' + $Id; description = ($fw.Name + ' application created by WampDeck Pro')
                    type = 'project'; require = [ordered]@{ php = '>=8.1'; ($fw.Package) = $fw.Require }
                }
                [IO.File]::WriteAllText((Join-Path $target 'composer.json'), ($composerJson | ConvertTo-Json -Depth 6), [Text.Encoding]::UTF8)
                Push-Location $target
                try { & $ComposerBat @('install', '--no-interaction', '--no-scripts', '--prefer-dist', '--no-progress') 2>&1 | Out-Null }
                finally { Pop-Location }
                [IO.File]::WriteAllText((Join-Path $target 'index.php'), $fw.Bootstrap, [Text.Encoding]::UTF8)
            } else {
                Push-Location $WwwDir
                try { & $ComposerBat @('create-project', $fw.Package, $Name, '--no-interaction', '--no-scripts', '--prefer-dist', '--no-progress') 2>&1 | Out-Null }
                finally { Pop-Location }
            }
        } finally { $ErrorActionPreference = $prevEap }
        if (-not (Test-Path (Join-Path $target 'composer.json'))) {
            throw "Composer could not create the $($fw.Name) project."
        }
    } finally {
        $env:PATH = $oldPath
    }

    # Keep any .env the skeleton shipped, otherwise start from its example.
    $envPath = Join-Path $target '.env'
    if (-not (Test-Path $envPath)) {
        foreach ($exampleName in @('.env.example', '.env.dist')) {
            $example = Join-Path $target $exampleName
            if (Test-Path $example) { Copy-Item $example $envPath -Force; break }
        }
    }
    $envMap = @{ APP_ENV = 'local'; APP_DEBUG = 'true' }
    if ($fw.Db) {
        $dbName = $Name -replace '-', '_'
        $previous = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        try {
            & $MysqlCli "--defaults-file=$MyIni" -u root -N -B -e "CREATE DATABASE IF NOT EXISTS ``$dbName``;" 2>$null | Out-Null
        } catch { } finally { $ErrorActionPreference = $previous }
        $envMap['DB_DATABASE'] = $dbName
        $envMap['DB_USERNAME'] = 'root'
        $envMap['DB_PASSWORD'] = ''
    }
    Set-FrameworkEnv -ProjectDir $target -Values $envMap

    if ($Id -eq 'laravel' -and (Test-Path (Join-Path $target 'artisan'))) {
        $previous = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        try {
            Push-Location $target
            & $PhpExe artisan key:generate --force 2>&1 | Out-Null
            Pop-Location
        } catch { } finally { $ErrorActionPreference = $previous }
    }

    $manifest = [ordered]@{
        schema = 1; name = $Name; php = 'any'; framework = $Id; env = $envMap
        database = @{ name = $(if ($fw.Db) { $Name -replace '-', '_' } else { '' }); snapshot = '' }
    }
    [IO.File]::WriteAllText((Join-Path $target '.wampdeck.json'), ($manifest | ConvertTo-Json -Depth 6), [Text.Encoding]::UTF8)

    Write-AllConfigs
    if (-not $NoHosts) { try { [void](Invoke-HostsSyncElevated) } catch { } }

    return [pscustomobject]@{
        Framework = $fw.Name
        Project   = $Name
        Url       = (Get-ProjectUrl -Name $Name)
        TestUrl   = (Get-ProjectTestUrl -Name $Name)
        Created   = (Get-Date).ToString('yyyy-MM-dd HH:mm')
    }
}
