# One-click recipes: WordPress and Laravel.

function New-WordPressProject {
    param(
        [string]$Name,
        [string]$Target,
        [switch]$Force
    )

    $dbName = New-ProjectDatabase -Name $Name

    $zip = Join-Path $TmpDir 'wordpress-latest.zip'
    if (-not (Test-Path $zip) -or $Force) {
        Save-RemoteFile -Url 'https://wordpress.org/latest.zip' -Destination $zip
    }

    $stage = Join-Path $TmpDir ('wp-' + [guid]::NewGuid().ToString('N'))
    Ensure-Dir $stage
    try {
        Expand-Archive -Path $zip -DestinationPath $stage -Force
        $source = Join-Path $stage 'wordpress'
        if (-not (Test-Path $source)) { $source = $stage }

        # Robocopy is much faster than Copy-Item for the ~3,800 WordPress
        # files and still ships with Windows. Exit codes below 8 are success.
        & robocopy.exe $source $Target /E /MT:8 /NFL /NDL /NJH /NJS /NP /R:1 /W:1 | Out-Null
        if ($LASTEXITCODE -ge 8) { throw "Copying WordPress failed (robocopy exit $LASTEXITCODE)." }
    } finally {
        Remove-Item $stage -Recurse -Force -ErrorAction SilentlyContinue
    }

    $salts = @(
        'AUTH_KEY', 'SECURE_AUTH_KEY', 'LOGGED_IN_KEY', 'NONCE_KEY',
        'AUTH_SALT', 'SECURE_AUTH_SALT', 'LOGGED_IN_SALT', 'NONCE_SALT'
    )
    $saltLines = foreach ($salt in $salts) {
        "define('$salt', '$(New-Salt 64)');"
    }

    $template = @'
<?php
define('DB_NAME', '{{DB_NAME}}');
define('DB_USER', 'root');
define('DB_PASSWORD', '');
define('DB_HOST', '127.0.0.1:{{DB_PORT}}');
define('DB_CHARSET', 'utf8mb4');
define('DB_COLLATE', '');

{{SALTS}}

$table_prefix = 'wp_';

define('WP_DEBUG', true);
define('WP_DEBUG_LOG', true);
define('WP_DEBUG_DISPLAY', false);

if (!defined('ABSPATH')) {
    define('ABSPATH', __DIR__ . '/');
}
require_once ABSPATH . 'wp-settings.php';
'@

    $config = $template.Replace('{{DB_NAME}}', $dbName).
        Replace('{{DB_PORT}}', "$MysqlPort").
        Replace('{{SALTS}}', ($saltLines -join "`r`n"))
    Set-Content -Path (Join-Path $Target 'wp-config.php') -Value $config -Encoding UTF8
    # The downloaded package is only needed during extraction. Remove it now
    # so tmp\ does not keep a 35 MB zip after every WordPress install.
    Remove-Item -LiteralPath $zip -Force -ErrorAction SilentlyContinue
    return 'wordpress'
}

function New-LaravelProject {
    param([string]$Name, [string]$Target)

    $composerPhar = Join-Path $BinDir 'composer\composer.phar'
    if (-not (Test-Path $composerPhar)) { throw 'Composer is not installed.' }

    if (Test-Path $Target) {
        if (@(Get-ChildItem $Target -Force).Count -eq 0) {
            Remove-Item $Target -Force
        }
    }

    $env:PATH = "$PhpDir;$BinDir\composer;$BinDir\git\cmd;$BinDir\nodejs;$env:PATH"
    $env:COMPOSER_HOME = Join-Path $DataDir 'composer'
    Ensure-Dir $env:COMPOSER_HOME

    Write-Step 'running composer create-project (this can take a few minutes)'
    # Composer writes progress to stderr; with ErrorActionPreference=Stop
    # PowerShell 5.1 would abort on the first line. Keep it non-terminating
    # and check the exit code instead.
    $previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $output = & $PhpExe $composerPhar create-project laravel/laravel $Target --no-interaction --prefer-dist 2>&1
    $composerCode = $LASTEXITCODE
    $ErrorActionPreference = $previous
    if ($composerCode -ne 0) {
        $tail = @($output | Select-Object -Last 20)
        throw "Laravel install failed.`n$($tail -join [Environment]::NewLine)"
    }

    $dbName = New-ProjectDatabase -Name $Name

    $envFile = Join-Path $Target '.env'
    if (Test-Path $envFile) {
        $content = Get-Content -Path $envFile -Raw
        $content = $content -replace '(?m)^DB_CONNECTION=.*$', 'DB_CONNECTION=mysql'
        $content = $content -replace '(?m)^# DB_HOST=.*$', "DB_HOST=127.0.0.1"
        $content = $content -replace '(?m)^DB_HOST=.*$', 'DB_HOST=127.0.0.1'
        $content = $content -replace '(?m)^# DB_PORT=.*$', "DB_PORT=$MysqlPort"
        $content = $content -replace '(?m)^DB_PORT=.*$', "DB_PORT=$MysqlPort"
        $content = $content -replace '(?m)^# DB_DATABASE=.*$', "DB_DATABASE=$dbName"
        $content = $content -replace '(?m)^DB_DATABASE=.*$', "DB_DATABASE=$dbName"
        $content = $content -replace '(?m)^# DB_USERNAME=.*$', 'DB_USERNAME=root'
        $content = $content -replace '(?m)^DB_USERNAME=.*$', 'DB_USERNAME=root'
        $content = $content -replace '(?m)^# DB_PASSWORD=.*$', 'DB_PASSWORD='
        $content = $content -replace '(?m)^DB_PASSWORD=.*$', 'DB_PASSWORD='
        $content = $content -replace '(?m)^APP_URL=.*$', "APP_URL=$((Get-ProjectUrl $Name))"
        $content = $content -replace '(?m)^MAIL_MAILER=.*$', 'MAIL_MAILER=smtp'
        $content = $content -replace '(?m)^MAIL_HOST=.*$', 'MAIL_HOST=127.0.0.1'
        $content = $content -replace '(?m)^MAIL_PORT=.*$', 'MAIL_PORT=1025'
        $content = $content -replace '(?m)^MAIL_USERNAME=.*$', 'MAIL_USERNAME=null'
        $content = $content -replace '(?m)^MAIL_PASSWORD=.*$', 'MAIL_PASSWORD=null'
        $content = $content -replace '(?m)^MAIL_FROM_ADDRESS=.*$', 'MAIL_FROM_ADDRESS="hello@wampdeck.test"'
        Set-Content -Path $envFile -Value $content -Encoding UTF8
    }

    $sqlite = Join-Path $Target 'database\database.sqlite'
    if (Test-Path $sqlite) { Remove-Item $sqlite -Force -ErrorAction SilentlyContinue }

    Push-Location $Target
    try {
        $previous = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        & $PhpExe artisan key:generate --force 2>&1 | Out-Null
        $keyCode = $LASTEXITCODE
        $migrate = & $PhpExe artisan migrate --force 2>&1
        $migrateCode = $LASTEXITCODE
        $ErrorActionPreference = $previous
        if ($keyCode -ne 0) { throw 'Laravel key generation failed.' }
        if ($migrateCode -ne 0) {
            $tail = @($migrate | Select-Object -Last 10)
            throw "Laravel migrations failed.`n$($tail -join [Environment]::NewLine)"
        }
    } finally {
        Pop-Location
    }

    return 'laravel'
}
