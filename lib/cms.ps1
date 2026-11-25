# CMS catalog and silent installers.
#
# Everything here is shared by the panel and `wampdeck cms`. An install
# creates a normal WampDeck project, so the CMS is served like any other
# folder in www\ and gets the same manifest, hosts entry and PHP pool.
#
# The catalog order is the order shown in the GUI and CLI.

$script:CmsCatalog = @(
    [pscustomobject]@{ Id = 'drupal';      Name = 'Drupal';      Category = 'Enterprise CMS';      Verified = $true; Kind = 'composer' }
    [pscustomobject]@{ Id = 'wordpress';   Name = 'WordPress';   Category = 'General websites';    Verified = $true;  Kind = 'download' }
    [pscustomobject]@{ Id = 'typo3';       Name = 'TYPO3';       Category = 'Corporate portals';   Verified = $true; Kind = 'composer' }
    [pscustomobject]@{ Id = 'joomla';      Name = 'Joomla';      Category = 'Business portals';    Verified = $true;  Kind = 'download' }
    [pscustomobject]@{ Id = 'processwire'; Name = 'ProcessWire'; Category = 'Custom development';  Verified = $true;  Kind = 'download' }
    [pscustomobject]@{ Id = 'concrete';    Name = 'Concrete CMS'; Category = 'Visual editing';     Verified = $true; Kind = 'composer' }
    [pscustomobject]@{ Id = 'grav';        Name = 'Grav';        Category = 'Lightweight sites';   Verified = $true;  Kind = 'download' }
    [pscustomobject]@{ Id = 'winter';      Name = 'Winter CMS';  Category = 'Laravel CMS';         Verified = $true; Kind = 'composer' }
    [pscustomobject]@{ Id = 'twill';       Name = 'Twill';       Category = 'Laravel admin/content'; Verified = $true; Kind = 'composer' }
    [pscustomobject]@{ Id = 'craftcms';     Name = 'Craft CMS';   Category = 'Premium CMS';    Verified = $true; Kind = 'composer' }
    [pscustomobject]@{ Id = 'statamic';     Name = 'Statamic';    Category = 'Flat-file CMS';  Verified = $true; Kind = 'composer' }
    [pscustomobject]@{ Id = 'octobercms';   Name = 'October CMS'; Category = 'Laravel CMS';    Verified = $true; Kind = 'composer' }
)

$script:CmsJoomlaVersion = '5.4.10'
$script:CmsLogFile = $null
$script:CmsSecrets = @()

function Get-WampDeckCmsCatalog {
    return @($script:CmsCatalog | ForEach-Object {
        [pscustomobject]@{
            Id       = $_.Id
            Name     = $_.Name
            Category = $_.Category
            Verified = [bool]$_.Verified
            Kind     = $_.Kind
        }
    })
}

function Resolve-WampDeckCms {
    # Accepts an id, a display name or a friendly alias such as "concrete cms".
    param([string]$Cms)

    if (-not $Cms) { throw 'A CMS id is required.' }
    $key = ($Cms -replace '[\s\-_.]', '').ToLowerInvariant()
    $aliases = @{
        wp             = 'wordpress'
        wordpress      = 'wordpress'
        drupal         = 'drupal'
        typo3          = 'typo3'
        typo3cms       = 'typo3'
        joomla         = 'joomla'
        joomlacms      = 'joomla'
        processwire    = 'processwire'
        pw             = 'processwire'
        concrete       = 'concrete'
        concretecms    = 'concrete'
        concrete5      = 'concrete'
        grav           = 'grav'
        winter         = 'winter'
        wintercms      = 'winter'
        twill          = 'twill'
        twillcms       = 'twill'
        craft          = 'craftcms'
        craftcms       = 'craftcms'
        statamic       = 'statamic'
        october        = 'octobercms'
        octobercms     = 'octobercms'
    }
    $id = $null
    if ($aliases.ContainsKey($key)) { $id = $aliases[$key] } else { $id = $key }
    $entry = @($script:CmsCatalog | Where-Object { $_.Id -eq $id } | Select-Object -First 1)
    if ($entry.Count -eq 0) {
        $ids = (@($script:CmsCatalog | ForEach-Object { $_.Id }) -join ', ')
        throw "Unknown CMS '$Cms'. Available: $ids"
    }
    return $entry[0]
}

function New-CmsToken {
    param([int]$Length = 40)
    $chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    $bytes = New-Object byte[] $Length
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    try { $rng.GetBytes($bytes) } finally { $rng.Dispose() }
    $builder = New-Object System.Text.StringBuilder
    foreach ($byte in $bytes) { [void]$builder.Append($chars[$byte % $chars.Length]) }
    return $builder.ToString()
}

function New-CmsPassword {
    param([int]$Length = 20)
    $lower = 'abcdefghijkmnopqrstuvwxyz'
    $upper = 'ABCDEFGHJKLMNPQRSTUVWXYZ'
    $digits = '23456789'
    $symbols = '!@#%*+-_'
    $all = $lower + $upper + $digits + $symbols
    $bytes = New-Object byte[] $Length
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    try { $rng.GetBytes($bytes) } finally { $rng.Dispose() }
    $characters = New-Object System.Collections.Generic.List[char]
    $characters.Add($lower[$bytes[0] % $lower.Length])
    $characters.Add($upper[$bytes[1] % $upper.Length])
    $characters.Add($digits[$bytes[2] % $digits.Length])
    $characters.Add($symbols[$bytes[3] % $symbols.Length])
    for ($index = 4; $index -lt $Length; $index++) {
        $characters.Add($all[$bytes[$index] % $all.Length])
    }
    # Shuffle so the guaranteed classes are not always the first four chars.
    for ($index = $characters.Count - 1; $index -gt 0; $index--) {
        $swap = $bytes[$index % $Length] % ($index + 1)
        $temporary = $characters[$index]
        $characters[$index] = $characters[$swap]
        $characters[$swap] = $temporary
    }
    return (-join $characters)
}

function Protect-CmsText {
    # Keeps passwords out of logs even when a tool prints one on its own.
    param([string]$Text)

    if (-not $Text) { return $Text }
    $result = [string]$Text
    foreach ($secret in @($script:CmsSecrets)) {
        if ($secret) { $result = $result.Replace([string]$secret, '***') }
    }
    # Winter's first winter:up seeds an admin with a random password and
    # prints it. The panel replaces that account straight away, so keep the
    # throwaway value out of the log too.
    $result = [regex]::Replace(
        $result,
        '(?i)(automatically generated for the [^\r\n:]*account:\s*)(?:<[^>]+>)*[^\s<]+',
        '$1***')
    return $result
}

function Write-CmsLog {
    param([string]$Message)
    if (-not $script:CmsLogFile) { return }
    $line = Protect-CmsText ([string]$Message)
    Add-Content -LiteralPath $script:CmsLogFile -Value $line -Encoding UTF8 -ErrorAction SilentlyContinue
}

function Start-CmsLog {
    param($Entry, [string]$Name)
    Ensure-Dir $LogDir
    $script:CmsLogFile = Join-Path $LogDir ("cms-{0}.log" -f $Entry.Id)
    $header = "===== {0} | {1} ({2}) | project {3} =====" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Entry.Name, $Entry.Id, $Name
    Add-Content -LiteralPath $script:CmsLogFile -Value $header -Encoding UTF8
}

function Initialize-CmsEnvironment {
    $env:PATH = "$PhpDir;$BinDir\composer;$BinDir\git\cmd;$BinDir\nodejs;$env:PATH"
    $env:COMPOSER_HOME = Join-Path $DataDir 'composer'
    $env:COMPOSER_NO_INTERACTION = '1'
    $env:COMPOSER_MEMORY_LIMIT = '-1'
    $env:COMPOSER_PROCESS_TIMEOUT = '1800'
    Ensure-Dir $env:COMPOSER_HOME
}

function Invoke-CmsProcess {
    param(
        [string]$FilePath,
        [string[]]$Arguments = @(),
        [string]$WorkingDirectory = $Root,
        [string]$Label = 'running command',
        [string[]]$Secrets = @(),
        [switch]$Quiet
    )

    # Per-call secrets supplement the install-wide list used by Write-CmsLog.
    $allSecrets = @($script:CmsSecrets) + @($Secrets)
    $display = @($Arguments | ForEach-Object {
        $value = [string]$_
        foreach ($secret in $allSecrets) {
            if ($secret) { $value = $value.Replace([string]$secret, '***') }
        }
        $value
    })
    Write-Step $Label
    Write-CmsLog (">>> $FilePath $($display -join ' ')")

    $code = 0
    $output = @()
    $previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $pushed = $false
    try {
        Push-Location -LiteralPath $WorkingDirectory
        $pushed = $true
        $output = & $FilePath @Arguments 2>&1
        $code = $LASTEXITCODE
    } finally {
        if ($pushed) { Pop-Location }
        $ErrorActionPreference = $previous
    }

    if (-not $Quiet) {
        foreach ($line in @($output)) {
            Write-CmsLog ([string]$line)
        }
    }

    if ($code -ne 0) {
        $tail = @($output | Select-Object -Last 15 | ForEach-Object { Protect-CmsText ([string]$_) })
        throw "$Label failed (exit $code).`n$($tail -join [Environment]::NewLine)"
    }

    # Command output belongs in the install log, not in the caller's
    # pipeline: CMS installers return a single result object and must not
    # be polluted with raw command text.
    return
}

function Get-ComposerDownloadFailures {
    param([string]$LogPath)

    $failures = @()
    if (-not $LogPath -or -not (Test-Path -LiteralPath $LogPath)) { return $failures }
    foreach ($line in Get-Content -LiteralPath $LogPath) {
        # Composer prints:
        #   Failed to download vendor/package from dist: curl error 56 while downloading https://...: ...
        $match = [regex]::Match([string]$line, 'Failed to download\s+(\S+)\s+from dist:.*?downloading\s+(https?://\S+)')
        if ($match.Success) {
            $url = $match.Groups[2].Value.TrimEnd('.', ',', ')', ':')
            $failures += [pscustomobject]@{ Name = $match.Groups[1].Value; Url = $url }
        }
    }
    return $failures
}

function Save-ComposerDistCache {
    param($Failure)

    $url = [string]$Failure.Url
    $name = ([string]$Failure.Name).ToLowerInvariant()
    if (-not $url -or -not $name) { return $false }

    $extension = 'zip'
    if ($url -match '\.(tar\.gz|tgz)(\?|$)') { $extension = 'tar' }
    elseif ($url -match '\.tar(\?|$)') { $extension = 'tar' }

    # Composer keys its download cache with the package metadata URL
    # (api.github.com/.../zipball/...) while curl errors report the final
    # codeload.github.com URL. Seed both keys with the same archive.
    $urls = @($url)
    if ($url -match '^https://codeload\.github\.com/([^/]+)/([^/]+)/(?:legacy\.zip|zip)/(.+)$') {
        $urls += "https://api.github.com/repos/$($Matches[1])/$($Matches[2])/zipball/$($Matches[3])"
    }

    $composerHome = $env:COMPOSER_HOME
    if (-not $composerHome) { $composerHome = Join-Path $DataDir 'composer' }
    $cacheDir = Join-Path $composerHome ('cache\files\' + ($name -replace '/', '\'))
    Ensure-Dir $cacheDir

    $targets = @()
    foreach ($candidate in $urls) {
        $sha1 = [BitConverter]::ToString(
            [System.Security.Cryptography.SHA1]::Create().ComputeHash(
                [System.Text.Encoding]::UTF8.GetBytes($candidate)
            )
        ).Replace('-', '').ToLowerInvariant()
        $cacheFile = Join-Path $cacheDir ("$sha1.$extension")
        if (-not (Test-Path -LiteralPath $cacheFile)) { $targets += $cacheFile }
    }
    if ($targets.Count -eq 0) { return $false }

    $temp = Join-Path $TmpDir ('composer-dist-' + [guid]::NewGuid().ToString('N') + '.' + $extension)
    try {
        # Save-RemoteFile resumes partial downloads, so a package that is too
        # large for one TLS connection still arrives in one piece.
        Save-RemoteFile -Url $url -Destination $temp
        foreach ($cacheFile in $targets) {
            Copy-Item -LiteralPath $temp -Destination $cacheFile -Force
        }
        Write-Step ("cached composer download {0}" -f $name)
        return $true
    } finally {
        Remove-Item -LiteralPath $temp -Force -ErrorAction SilentlyContinue
    }
}

function Invoke-CmsComposer {
    param(
        [string[]]$Arguments,
        [string]$WorkingDirectory = $Root,
        [string]$Label = 'composer',
        [string[]]$Secrets = @(),
        [int]$MaxDownloadRetries = 8
    )

    $all = @($ComposerPhar) + @($Arguments)
    $attempt = 0
    while ($true) {
        $attempt++
        try {
            return Invoke-CmsProcess -FilePath $PhpExe -Arguments $all -WorkingDirectory $WorkingDirectory -Label $Label -Secrets $Secrets
        } catch {
            if ($attempt -ge $MaxDownloadRetries) { throw }

            # Large Composer dists can be cut off by flaky networks. Composer
            # does not resume them, so fetch each failed dist with the
            # resumable downloader, place it in Composer's cache and retry.
            $failures = @(Get-ComposerDownloadFailures -LogPath $script:CmsLogFile)
            $seeded = 0
            foreach ($failure in $failures) {
                if (Save-ComposerDistCache -Failure $failure) { $seeded++ }
            }
            if ($seeded -eq 0) { throw }

            # composer create-project refuses to reuse a folder that already
            # contains the partial project from the failed attempt.
            if ($Arguments.Count -ge 3 -and $Arguments[0] -eq 'create-project') {
                $projectTarget = [string]$Arguments[2]
                if (-not [System.IO.Path]::IsPathRooted($projectTarget)) {
                    $projectTarget = Join-Path $WorkingDirectory $projectTarget
                }
                if (Test-Path -LiteralPath $projectTarget) {
                    Get-ChildItem -LiteralPath $projectTarget -Force -ErrorAction SilentlyContinue |
                        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
                }
            }
            Write-Step ("retrying $Label after caching $seeded download(s)")
        }
    }
}

function Invoke-CmsArtisan {
    param(
        [string]$Target,
        [string[]]$Arguments,
        [string]$Label = 'php artisan',
        [string[]]$Secrets = @(),
        [switch]$Quiet
    )
    $all = @('artisan') + @($Arguments)
    return Invoke-CmsProcess -FilePath $PhpExe -Arguments $all -WorkingDirectory $Target -Label $Label -Secrets $Secrets -Quiet:$Quiet
}

function Expand-CmsArchive {
    param([string]$Zip, [string]$Target)

    $stage = Join-Path $TmpDir ('cms-' + [guid]::NewGuid().ToString('N'))
    Ensure-Dir $stage
    try {
        Write-Step "extracting $(Split-Path -Leaf $Zip)"
        Expand-Archive -Path $Zip -DestinationPath $stage -Force
        $entries = @(Get-ChildItem -LiteralPath $stage -Force | Where-Object { $_.Name -ne '__MACOSX' })
        $source = $stage
        if ($entries.Count -eq 1 -and $entries[0].PSIsContainer) { $source = $entries[0].FullName }
        Get-ChildItem -LiteralPath $source -Force | ForEach-Object {
            Copy-Item -LiteralPath $_.FullName -Destination $Target -Recurse -Force
        }
    } finally {
        Remove-Item -LiteralPath $stage -Recurse -Force -ErrorAction SilentlyContinue
    }
}

function Set-CmsLaravelEnvironment {
    param(
        [string]$Target,
        [string]$DbName,
        [string]$Url,
        [string]$AppName
    )

    $envFile = Join-Path $Target '.env'
    if (-not (Test-Path $envFile)) {
        $example = Join-Path $Target '.env.example'
        if (Test-Path $example) {
            Copy-Item -LiteralPath $example -Destination $envFile -Force
        } else {
            Set-Content -LiteralPath $envFile -Value '' -Encoding ASCII
        }
    }

    $lines = @(Get-Content -LiteralPath $envFile -ErrorAction SilentlyContinue)
    $keys = @(
        'APP_NAME', 'APP_ENV', 'APP_DEBUG', 'APP_URL',
        'DB_CONNECTION', 'DB_HOST', 'DB_PORT', 'DB_DATABASE', 'DB_USERNAME', 'DB_PASSWORD',
        'CACHE_DRIVER', 'CACHE_STORE', 'SESSION_DRIVER', 'QUEUE_CONNECTION', 'MAIL_MAILER'
    )
    $escaped = @($keys | ForEach-Object { [regex]::Escape($_) }) -join '|'
    $pattern = '^\s*#?\s*(' + $escaped + ')\s*='
    $lines = @($lines | Where-Object { $_ -notmatch $pattern })

    $values = [ordered]@{
        APP_NAME        = '"' + $AppName + '"'
        APP_ENV         = 'local'
        APP_DEBUG       = 'true'
        APP_URL         = $Url
        DB_CONNECTION   = 'mysql'
        DB_HOST         = '127.0.0.1'
        DB_PORT         = [string]$MysqlPort
        DB_DATABASE     = $DbName
        DB_USERNAME     = 'root'
        DB_PASSWORD     = ''
        CACHE_DRIVER    = 'file'
        CACHE_STORE     = 'file'
        SESSION_DRIVER  = 'file'
        QUEUE_CONNECTION = 'sync'
        MAIL_MAILER     = 'log'
    }
    foreach ($key in $values.Keys) { $lines += "$key=$($values[$key])" }

    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($envFile, (($lines -join "`r`n") + "`r`n"), $encoding)

    $sqlite = Join-Path $Target 'database\database.sqlite'
    if (Test-Path $sqlite) { Remove-Item -LiteralPath $sqlite -Force -ErrorAction SilentlyContinue }
}

function Invoke-CmsMysqlFile {
    param([string]$Database, [string]$File, [string]$Label)

    if (-not (Test-Path -LiteralPath $File)) { throw "SQL file not found: $File" }

    # ProcessWire ships dumps wrapped in "--- WireDatabaseBackup {...}" and
    # "--- /WireDatabaseBackup {...}" marker lines. MySQL only treats
    # "-- " (dash dash space) as a comment, so those markers must be removed
    # before the file is piped into the client.
    $importFile = $File
    $lines = [System.IO.File]::ReadAllLines($File)
    $clean = @($lines | Where-Object { $_ -notmatch '^---\s*/?WireDatabaseBackup' })
    if ($clean.Count -ne $lines.Count) {
        $importFile = Join-Path $TmpDir ('cms-import-' + [guid]::NewGuid().ToString('N') + '.sql')
        [System.IO.File]::WriteAllLines($importFile, [string[]]$clean, (New-Object System.Text.UTF8Encoding($false)))
    }

    Write-Step $Label
    Write-CmsLog (">>> mysql $Database < $File")
    $command = '"{0}" --defaults-file="{1}" -u root "{2}" < "{3}"' -f $MysqlCli, $MyIni, $Database, $importFile
    $previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $output = & cmd.exe /d /c $command 2>&1
        $code = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $previous
        if ($importFile -ne $File) { Remove-Item -LiteralPath $importFile -Force -ErrorAction SilentlyContinue }
    }
    foreach ($line in @($output)) { Write-CmsLog ([string]$line) }
    if ($code -ne 0) {
        $tail = @($output | Select-Object -Last 15 | ForEach-Object { [string]$_ })
        throw "$Label failed (exit $code).`n$($tail -join [Environment]::NewLine)"
    }
}

function Install-CmsDrupal {
    param($Ctx)
    New-ProjectDatabase -Name $Ctx.Name | Out-Null

    Invoke-CmsComposer -Arguments @('create-project', 'drupal/recommended-project', $Ctx.Target, '--no-interaction', '--no-dev', '--prefer-dist', '--no-progress') `
        -WorkingDirectory $Root -Label 'composer create-project drupal/recommended-project'
    Invoke-CmsComposer -Arguments @('require', 'drush/drush', '--no-interaction', '--no-progress', '--update-with-dependencies', '--update-no-dev') `
        -WorkingDirectory $Ctx.Target -Label 'composer require drush/drush'

    $dbUrl = "mysql://root:@127.0.0.1:$MysqlPort/$($Ctx.Database)"
    Invoke-CmsProcess -FilePath $PhpExe -WorkingDirectory $Ctx.Target -Label 'drush site:install' -Secrets @($Ctx.AdminPassword) -Arguments @(
        'vendor/drush/drush/drush.php', 'site:install', 'standard',
        "--db-url=$dbUrl",
        "--site-name=$($Ctx.Name)",
        "--account-name=$($Ctx.AdminUser)",
        "--account-pass=$($Ctx.AdminPassword)",
        "--account-mail=$($Ctx.AdminEmail)",
        '--yes', '--no-interaction'
    )

    if (-not (Test-Path (Join-Path $Ctx.Target 'web\index.php'))) { throw 'Drupal did not create web/index.php.' }
    if (-not (Test-Path (Join-Path $Ctx.Target 'web\sites\default\settings.php'))) { throw 'Drupal did not finish site:install (settings.php is missing).' }
    $Ctx.DocRoot = 'web'
    $Ctx.AdminUrl = $Ctx.Url + '/user/login'
}

function Install-CmsWordPress {
    param($Ctx)
    New-WordPressProject -Name $Ctx.Name -Target $Ctx.Target | Out-Null

    $helper = Join-Path $Root 'lib\cms\wordpress-install.php'
    Invoke-CmsProcess -FilePath $PhpExe -WorkingDirectory $Ctx.Target -Label 'wordpress silent install' -Secrets @($Ctx.AdminPassword) -Arguments @(
        $helper, $Ctx.Target, $Ctx.Name, $Ctx.AdminUser, $Ctx.AdminEmail, $Ctx.AdminPassword, $Ctx.Url
    )

    $Ctx.DocRoot = ''
    $Ctx.AdminUrl = $Ctx.Url + '/wp-login.php'
}

function Install-CmsTypo3 {
    param($Ctx)
    New-ProjectDatabase -Name $Ctx.Name | Out-Null

    Invoke-CmsComposer -Arguments @('create-project', 'typo3/cms-base-distribution', $Ctx.Target, '--no-interaction', '--no-dev', '--prefer-dist', '--no-progress') `
        -WorkingDirectory $Root -Label 'composer create-project typo3/cms-base-distribution'

    Invoke-CmsProcess -FilePath $PhpExe -WorkingDirectory $Ctx.Target -Label 'typo3 setup' -Secrets @($Ctx.AdminPassword) -Arguments @(
        'vendor/bin/typo3', 'setup', '--force', '--no-interaction',
        '--driver=mysqli', '--host=127.0.0.1', "--port=$MysqlPort",
        "--dbname=$($Ctx.Database)", '--username=root', '--password=',
        "--admin-username=$($Ctx.AdminUser)",
        "--admin-user-password=$($Ctx.AdminPassword)",
        "--admin-email=$($Ctx.AdminEmail)",
        "--project-name=$($Ctx.Name)",
        "--create-site=$($Ctx.Url)/",
        '--server-type=other'
    )

    if (-not (Test-Path (Join-Path $Ctx.Target 'public\index.php'))) { throw 'TYPO3 did not create public/index.php.' }
    $Ctx.DocRoot = 'public'
    $Ctx.AdminUrl = $Ctx.Url + '/typo3/'
}

function Install-CmsJoomla {
    param($Ctx)
    New-ProjectDatabase -Name $Ctx.Name | Out-Null

    $zip = Join-Path $TmpDir ("joomla-$($script:CmsJoomlaVersion).zip")
    if (-not (Test-Path $zip)) {
        $primary = "https://github.com/joomla/joomla-cms/releases/download/$($script:CmsJoomlaVersion)/Joomla_$($script:CmsJoomlaVersion)-Stable-Full_Package.zip"
        try {
            Save-RemoteFile -Url $primary -Destination $zip
        } catch {
            $fallbackVersion = $script:CmsJoomlaVersion -replace '\.', '-'
            Save-RemoteFile -Url "https://downloads.joomla.org/cms/joomla5/$fallbackVersion/Joomla_$($script:CmsJoomlaVersion)-Stable-Full_Package.zip?format=zip" -Destination $zip
        }
    }
    Expand-CmsArchive -Zip $zip -Target $Ctx.Target

    $dbHost = '127.0.0.1'
    if ($MysqlPort -ne 3306) { $dbHost = "127.0.0.1:$MysqlPort" }
    $installer = Join-Path $Ctx.Target 'installation\joomla.php'
    if (-not (Test-Path $installer)) { throw 'Joomla package is missing installation/joomla.php.' }

    Invoke-CmsProcess -FilePath $PhpExe -WorkingDirectory $Ctx.Target -Label 'joomla cli install' -Secrets @($Ctx.AdminPassword) -Arguments @(
        'installation/joomla.php', 'install',
        "--site-name=$($Ctx.Name)",
        '--admin-user=Site Administrator',
        "--admin-username=$($Ctx.AdminUser)",
        "--admin-password=$($Ctx.AdminPassword)",
        "--admin-email=$($Ctx.AdminEmail)",
        '--db-type=mysqli',
        "--db-host=$dbHost",
        '--db-user=root',
        '--db-pass=',
        "--db-name=$($Ctx.Database)",
        '--db-prefix=jos_',
        '--db-encryption=0'
    )

    if (-not (Test-Path (Join-Path $Ctx.Target 'configuration.php'))) { throw 'Joomla did not write configuration.php.' }
    $Ctx.DocRoot = ''
    $Ctx.AdminUrl = $Ctx.Url + '/administrator/'
}

function Install-CmsProcessWire {
    param($Ctx)
    New-ProjectDatabase -Name $Ctx.Name | Out-Null

    $zip = Join-Path $TmpDir 'processwire-master.zip'
    if (-not (Test-Path $zip)) {
        Save-RemoteFile -Url 'https://github.com/processwire/processwire/archive/refs/heads/master.zip' -Destination $zip
    }
    Expand-CmsArchive -Zip $zip -Target $Ctx.Target

    $blank = Join-Path $Ctx.Target 'site-blank'
    $site = Join-Path $Ctx.Target 'site'
    if (-not (Test-Path $blank)) { throw 'ProcessWire package is missing site-blank.' }
    if (Test-Path $site) { Remove-Item -LiteralPath $site -Recurse -Force }
    Copy-Item -LiteralPath $blank -Destination $site -Recurse -Force
    Remove-Item -LiteralPath $blank -Recurse -Force -ErrorAction SilentlyContinue

    $authSalt = New-CmsToken 40
    $tableSalt = New-CmsToken 40
    $sessionName = 'pw' + (Get-Random -Minimum 100 -Maximum 999)
    $configTemplate = @'

/** Installer: Database Configuration */
$config->dbHost = '{{DB_HOST}}';
$config->dbName = '{{DB_NAME}}';
$config->dbUser = 'root';
$config->dbPass = '';
$config->dbPort = '{{DB_PORT}}';
$config->dbCharset = 'utf8mb4';
$config->dbEngine = 'InnoDB';

/** Installer: User Authentication Salt */
$config->userAuthSalt = '{{AUTH_SALT}}';

/** Installer: Table Salt */
$config->tableSalt = '{{TABLE_SALT}}';

/** Installer: File Permission Configuration */
$config->chmodDir = '0755';
$config->chmodFile = '0644';

/** Installer: Time zone setting */
$config->timezone = 'UTC';

/** Installer: Admin theme */
$config->defaultAdminTheme = 'AdminThemeUikit';

/** Installer: Unix timestamp of date/time installed */
$config->installed = {{INSTALLED}};

/** Installer: Session name */
$config->sessionName = '{{SESSION_NAME}}';

/** Installer: HTTP Hosts Whitelist */
$config->httpHosts = array('{{HOST_LOCAL}}', '{{HOST_TEST}}', '127.0.0.1', 'localhost');

/** Installer: Debug mode */
$config->debug = true;
'@
    $configText = $configTemplate.
        Replace('{{DB_HOST}}', '127.0.0.1').
        Replace('{{DB_NAME}}', $Ctx.Database).
        Replace('{{DB_PORT}}', [string]$MysqlPort).
        Replace('{{AUTH_SALT}}', $authSalt).
        Replace('{{TABLE_SALT}}', $tableSalt).
        Replace('{{INSTALLED}}', [string][int][DateTimeOffset]::UtcNow.ToUnixTimeSeconds()).
        Replace('{{SESSION_NAME}}', $sessionName).
        Replace('{{HOST_LOCAL}}', "$($Ctx.Name).localhost").
        Replace('{{HOST_TEST}}', "$($Ctx.Name).test")
    $configPath = Join-Path $site 'config.php'
    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::AppendAllText($configPath, $configText, $encoding)

    $importer = Join-Path $Root 'lib\cms\processwire-import.php'
    Invoke-CmsProcess -FilePath $PhpExe -WorkingDirectory $Ctx.Target -Label 'importing ProcessWire schema' -Arguments @(
        $importer, $Ctx.Target, $Ctx.Database, [string]$MysqlPort
    )

    $helper = Join-Path $Root 'lib\cms\processwire-install.php'
    Invoke-CmsProcess -FilePath $PhpExe -WorkingDirectory $Ctx.Target -Label 'creating ProcessWire superuser' -Secrets @($Ctx.AdminPassword) -Arguments @(
        $helper, $Ctx.Target, $Ctx.Url, $Ctx.AdminUser, $Ctx.AdminEmail, $Ctx.AdminPassword
    )

    Remove-Item -LiteralPath (Join-Path $Ctx.Target 'install.php') -Force -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath (Join-Path $site 'install') -Recurse -Force -ErrorAction SilentlyContinue
    $installedFile = Join-Path $site 'assets\installed.php'
    $installedText = "<?php // The existence of this file prevents the installer from running. Do not delete it unless you want to re-run the install." + "`r`n"
    [System.IO.File]::WriteAllText($installedFile, $installedText, $encoding)

    $Ctx.DocRoot = ''
    $Ctx.AdminUrl = $Ctx.Url + '/processwire/'
}

function Install-CmsConcrete {
    param($Ctx)
    New-ProjectDatabase -Name $Ctx.Name | Out-Null

    Invoke-CmsComposer -Arguments @('create-project', 'concretecms/composer', $Ctx.Target, '--no-interaction', '--no-dev', '--prefer-dist', '--no-progress') `
        -WorkingDirectory $Root -Label 'composer create-project concretecms/composer'

    $bin = Join-Path $Ctx.Target 'public\concrete\bin\concrete'
    if (-not (Test-Path $bin)) { $bin = Join-Path $Ctx.Target 'vendor\bin\concrete' }
    if (-not (Test-Path $bin)) { throw 'Concrete CMS console binary was not found.' }

    $dbServer = '127.0.0.1'
    if ($MysqlPort -ne 3306) { $dbServer = "127.0.0.1:$MysqlPort" }

    # The composer skeleton keeps the web root in "public" (DIR_BASE), so the
    # writable folders that c5:install checks live below public, not the
    # project root. Composer archives cannot carry empty directories either.
    Ensure-Dir (Join-Path $Ctx.Target 'public\application\files')
    Ensure-Dir (Join-Path $Ctx.Target 'public\application\config')
    Ensure-Dir (Join-Path $Ctx.Target 'public\packages')

    Invoke-CmsProcess -FilePath $PhpExe -WorkingDirectory $Ctx.Target -Label 'concrete c5:install' -Secrets @($Ctx.AdminPassword) -Arguments @(
        $bin, 'c5:install',
        "--db-server=$dbServer",
        '--db-username=root',
        '--db-password=',
        "--db-database=$($Ctx.Database)",
        "--site=$($Ctx.Name)",
        "--canonical-url=$($Ctx.Url)/",
        '--starting-point=atomik_blank',
        "--admin-email=$($Ctx.AdminEmail)",
        "--admin-password=$($Ctx.AdminPassword)",
        '--timezone=UTC',
        '--session-handler=file',
        '--disable-marketplace-connect',
        '--ignore-warnings'
    )

    if (-not (Test-Path (Join-Path $Ctx.Target 'public\index.php'))) { throw 'Concrete CMS did not create public/index.php.' }
    $Ctx.DocRoot = 'public'
    $Ctx.AdminUrl = $Ctx.Url + '/login'
}

function Install-CmsGrav {
    param($Ctx)
    New-ProjectDatabase -Name $Ctx.Name | Out-Null

    $zip = Join-Path $TmpDir 'grav-admin-latest.zip'
    if (-not (Test-Path $zip)) {
        Save-RemoteFile -Url 'https://getgrav.org/download/core/grav-admin/latest' -Destination $zip
    }
    Expand-CmsArchive -Zip $zip -Target $Ctx.Target

    if (-not (Test-Path (Join-Path $Ctx.Target 'bin\plugin'))) { throw 'Grav admin package is missing bin/plugin.' }
    Invoke-CmsProcess -FilePath $PhpExe -WorkingDirectory $Ctx.Target -Label 'creating Grav admin user' -Secrets @($Ctx.AdminPassword) -Arguments @(
        'bin/plugin', 'login', 'new-user',
        '-u', $Ctx.AdminUser,
        '-p', $Ctx.AdminPassword,
        '-e', $Ctx.AdminEmail,
        '-P', 'b',
        '-N', 'Administrator',
        '-t', 'Site Administrator',
        '-n'
    )

    $account = Join-Path $Ctx.Target ("user\accounts\{0}.yaml" -f $Ctx.AdminUser)
    if (-not (Test-Path $account)) { throw "Grav did not create $account." }
    $Ctx.DocRoot = ''
    $Ctx.AdminUrl = $Ctx.Url + '/admin'
}

function Install-CmsWinter {
    param($Ctx)
    New-ProjectDatabase -Name $Ctx.Name | Out-Null

    Invoke-CmsComposer -Arguments @('create-project', 'wintercms/winter', $Ctx.Target, '--no-interaction', '--no-dev', '--no-scripts', '--prefer-dist', '--no-progress') `
        -WorkingDirectory $Root -Label 'composer create-project wintercms/winter'

    Set-CmsLaravelEnvironment -Target $Ctx.Target -DbName $Ctx.Database -Url $Ctx.Url -AppName $Ctx.Name
    Invoke-CmsArtisan -Target $Ctx.Target -Arguments @('key:generate', '--force') -Label 'winter key:generate'

    # winter:install is interactive and its database question defaults to
    # SQLite when no input is attached. winter:up runs the same migrations
    # and seeds (including the Backend admin); the helper then replaces that
    # account with the credentials WampDeck shows to the user.
    Invoke-CmsArtisan -Target $Ctx.Target -Arguments @('winter:up', '--no-interaction') -Label 'winter:up' -Quiet

    $helper = Join-Path $Root 'lib\cms\winter-admin.php'
    Invoke-CmsProcess -FilePath $PhpExe -WorkingDirectory $Ctx.Target -Label 'setting Winter admin credentials' -Secrets @($Ctx.AdminPassword) -Arguments @(
        $helper, $Ctx.Target, $Ctx.AdminUser, $Ctx.AdminEmail, $Ctx.AdminPassword
    )

    # Winter is designed to serve from the project root (like the classic
    # October structure). winter:mirror relies on symlinks and on Windows it
    # falls back to hardlinks, which break index.php's __DIR__ bootstrap path.
    if (-not (Test-Path (Join-Path $Ctx.Target 'index.php'))) { throw 'Winter CMS did not create index.php.' }
    $Ctx.DocRoot = ''
    $Ctx.AdminUrl = $Ctx.Url + '/backend'
}

function Install-CmsTwill {
    param($Ctx)
    New-ProjectDatabase -Name $Ctx.Name | Out-Null

    Invoke-CmsComposer -Arguments @('create-project', 'laravel/laravel', $Ctx.Target, '--no-interaction', '--no-dev', '--prefer-dist', '--no-progress') `
        -WorkingDirectory $Root -Label 'composer create-project laravel/laravel'
    Set-CmsLaravelEnvironment -Target $Ctx.Target -DbName $Ctx.Database -Url $Ctx.Url -AppName $Ctx.Name

    Invoke-CmsComposer -Arguments @('require', 'area17/twill:^3.6', '--no-interaction', '--no-progress', '--update-with-dependencies', '--update-no-dev') `
        -WorkingDirectory $Ctx.Target -Label 'composer require area17/twill'

    Invoke-CmsArtisan -Target $Ctx.Target -Arguments @('twill:install', '--no-interaction') -Label 'twill:install'
    Invoke-CmsArtisan -Target $Ctx.Target -Label 'twill:superadmin' -Secrets @($Ctx.AdminPassword) -Arguments @(
        'twill:superadmin', $Ctx.AdminEmail, $Ctx.AdminPassword
    )

    if (-not (Test-Path (Join-Path $Ctx.Target 'public\index.php'))) { throw 'Twill did not create public/index.php.' }
    $Ctx.DocRoot = 'public'
    $Ctx.AdminUrl = $Ctx.Url + '/admin'
}

function New-CmsInstallContext {
    param(
        [string]$Name,
        [string]$Target,
        $Entry,
        [string]$AdminUser,
        [string]$AdminEmail,
        [string]$AdminPassword
    )

    if (-not $AdminUser) { $AdminUser = 'admin' }
    if ($Entry.Id -eq 'processwire') {
        $AdminUser = ($AdminUser.ToLowerInvariant() -replace '[^a-z0-9]', '')
        if (-not $AdminUser) { $AdminUser = 'admin' }
    }
    if ($AdminUser -notmatch '^[A-Za-z0-9][A-Za-z0-9._-]{1,31}$') {
        throw 'Admin user must be 2-32 letters, digits, dots, dashes or underscores.'
    }
    if (-not $AdminEmail) { $AdminEmail = "admin@$Name.test" }
    if ($AdminEmail -notmatch '^[^@\s]+@[^@\s]+\.[^@\s]+$') {
        throw "Admin email '$AdminEmail' is not valid."
    }
    if (-not $AdminPassword) { $AdminPassword = New-CmsPassword }
    if ($AdminPassword.Length -lt 8) { throw 'Admin password must be at least 8 characters.' }
    if ($Entry.Id -eq 'typo3' -and $AdminPassword -notmatch '[^A-Za-z0-9]') {
        throw 'TYPO3 requires an admin password with at least one special character (for example !, @, # or %).'
    }

    return [pscustomobject]@{
        Entry         = $Entry
        Name          = $Name
        Target        = $Target
        Database      = $Name -replace '-', '_'
        Url           = Get-ProjectUrl $Name
        TestUrl       = Get-ProjectTestUrl $Name
        AdminUser     = $AdminUser
        AdminEmail    = $AdminEmail
        AdminPassword = $AdminPassword
        DocRoot       = ''
        AdminUrl      = ''
        Notes         = @()
    }
}

function Install-CmsComposerStarter {
    param(
        $Ctx,
        [Parameter(Mandatory = $true)][string]$Package,
        [string]$AdminPath = '/admin',
        [switch]$WithDb
    )

    Invoke-CmsComposer -Arguments @('create-project', $Package, $Ctx.Target, '--no-interaction', '--no-scripts', '--prefer-dist', '--no-progress') `
        -WorkingDirectory $Root -Label ("composer create-project " + $Package)
    if (-not (Test-Path (Join-Path $Ctx.Target 'composer.json'))) {
        throw "Composer did not create the project from $Package."
    }

    $envLines = @('APP_ENV=local', 'APP_DEBUG=true')
    if ($WithDb) {
        $previous = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        try {
            & $MysqlCli "--defaults-file=$MyIni" -u root -N -B -e "CREATE DATABASE IF NOT EXISTS ``$($Ctx.Database)``;" 2>$null | Out-Null
        } catch { } finally { $ErrorActionPreference = $previous }
        $envLines += @(('DB_DATABASE=' + $Ctx.Database), 'DB_USERNAME=root', 'DB_PASSWORD=')
        [void]$Ctx.Notes.Add(('Database {0} created. Finish the admin setup in the browser.' -f $Ctx.Database))
    } else {
        [void]$Ctx.Notes.Add('Flat-file install. Finish the admin setup in the browser.')
    }
    [IO.File]::WriteAllText((Join-Path $Ctx.Target '.env'), (($envLines -join "`r`n") + "`r`n"), [Text.Encoding]::UTF8)
    $Ctx.DocRoot = ''
    $Ctx.AdminUrl = $Ctx.Url.TrimEnd('/') + $AdminPath
}
function Install-WampDeckCms {
    param(
        [string]$Cms,
        [string]$Name,
        [string]$Target,
        [string]$AdminUser,
        [string]$AdminEmail,
        [string]$AdminPassword
    )

    $entry = Resolve-WampDeckCms $Cms
    $ctx = New-CmsInstallContext -Name $Name -Target $Target -Entry $entry `
        -AdminUser $AdminUser -AdminEmail $AdminEmail -AdminPassword $AdminPassword

    Start-CmsLog -Entry $entry -Name $Name
    $script:CmsSecrets = @([string]$ctx.AdminPassword)
    Write-CmsLog "target: $Target"
    Write-CmsLog "url: $($ctx.Url)"
    Write-CmsLog "database: $($ctx.Database)"

    if (@(Get-ChildItem -LiteralPath $Target -Force).Count -gt 0) {
        throw "CMS install needs an empty folder, but $Target is not empty."
    }

    Initialize-CmsEnvironment
    $logPath = $script:CmsLogFile

    try {
        switch ($entry.Id) {
            'drupal'      { Install-CmsDrupal $ctx }
            'wordpress'   { Install-CmsWordPress $ctx }
            'typo3'       { Install-CmsTypo3 $ctx }
            'joomla'      { Install-CmsJoomla $ctx }
            'processwire' { Install-CmsProcessWire $ctx }
            'concrete'    { Install-CmsConcrete $ctx }
            'grav'        { Install-CmsGrav $ctx }
            'winter'      { Install-CmsWinter $ctx }
            'twill'       { Install-CmsTwill $ctx }
            'craftcms'    { Install-CmsComposerStarter -Ctx $ctx -Package 'craftcms/craft' -AdminPath '/admin' -WithDb }
            'statamic'    { Install-CmsComposerStarter -Ctx $ctx -Package 'statamic/statamic' -AdminPath '/cp' }
            'octobercms'  { Install-CmsComposerStarter -Ctx $ctx -Package 'october/october' -AdminPath '/backend' -WithDb }
            default       { throw "No installer for CMS '$($entry.Id)'." }
        }
    } catch {
        Write-CmsLog "FAILED: $($_.Exception.Message)"
        throw "$($entry.Name) install failed: $($_.Exception.Message)`nLog: $logPath"
    } finally {
        $script:CmsSecrets = @()
    }

    Write-CmsLog "OK: $($entry.Name) installed in $Target"

    # Remove the downloaded package after a successful install. It is only
    # needed while extracting; keeping it wastes ~30-50 MB per CMS in tmp\.
    # Only this CMS's known package names are removed, never another running
    # install's files.
    $packageNames = @(
        'wordpress-latest.zip', 'joomla-*.zip', 'processwire-master.zip',
        'grav-admin-latest.zip', 'drupal-*.zip', 'typo3-*.zip',
        'concrete-*.zip', 'winter-*.zip', 'twill-*.zip'
    )
    foreach ($pattern in $packageNames) {
        Get-ChildItem -LiteralPath $TmpDir -Filter $pattern -File -ErrorAction SilentlyContinue |
            Remove-Item -Force -ErrorAction SilentlyContinue
    }

    return [pscustomobject]@{
        Cms           = $entry.Id
        CmsName       = $entry.Name
        Category      = $entry.Category
        Verified      = [bool]$entry.Verified
        Name          = $ctx.Name
        Folder        = $ctx.Target
        Database      = $ctx.Database
        Url           = $ctx.Url
        TestUrl       = $ctx.TestUrl
        AdminUrl      = $ctx.AdminUrl
        AdminUser     = $ctx.AdminUser
        AdminPassword = $ctx.AdminPassword
        AdminEmail    = $ctx.AdminEmail
        DocRoot       = $ctx.DocRoot
        Log           = $logPath
        Notes         = @($ctx.Notes)
    }
}
