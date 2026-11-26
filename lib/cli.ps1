# wampdeck - the command line for a WampDeck install.
#
# It talks to the same lib\ functions as the panel, so nothing here can drift
# from what the GUI does.
#
#   wampdeck status
#   wampdeck list
#   wampdeck doctor [--project blog] [--fix]
#   wampdeck update [--check] [--yes]
#   wampdeck wizard [--force]
#   wampdeck start | stop | restart
#   wampdeck php blog 8.2 | wampdeck php blog --clear
#   wampdeck snapshot blog --label before-update
#   wampdeck restore blog 20261101-101500-before-update.sql --yes
#   wampdeck export blog --out D:\handoff\blog.zip
#   wampdeck import D:\handoff\blog.zip --name blog-copy
#   wampdeck deploy blog --json
#   wampdeck new shop --preset wordpress
#   wampdeck hosts sync
#   wampdeck logs nginx

$CliCommands = @(
    'status', 'list', 'doctor', 'start', 'stop', 'restart', 'open', 'php',
    'snapshot', 'snapshots', 'restore', 'export', 'import', 'deploy', 'new', 'cms', 'hosts',
    'logs', 'update', 'wizard', 'help', 'version'
)

function Split-CommandLine {
    # Splits a raw command line the way cmd.exe handed it to us, keeping
    # quoted paths with spaces together.
    param([string]$Text)

    $result = New-Object System.Collections.Generic.List[string]
    $current = New-Object System.Text.StringBuilder
    $inQuotes = $false
    foreach ($character in $Text.ToCharArray()) {
        if ($character -eq '"') { $inQuotes = -not $inQuotes; continue }
        if ($character -eq ' ' -and -not $inQuotes) {
            if ($current.Length -gt 0) { $result.Add($current.ToString()); [void]$current.Clear() }
            continue
        }
        [void]$current.Append($character)
    }
    if ($current.Length -gt 0) { $result.Add($current.ToString()) }
    return $result.ToArray()
}
function Get-CliUsage {
    return @"

  wampdeck $WampDeckVersion - local PHP, MySQL and web server for Windows

  Usage: wampdeck <command> [options]

  Everyday
    status                     what is running, which PHP pool serves what
    list                       projects with their PHP version and URL
    start | stop | restart     control the stack
    open <project>             open the project in the browser

  Projects
    new <name> [--preset blank|wordpress|laravel|<cms>]
    cms list                   the nine supported CMS installers
    cms install <cms> [--name <folder>] [--user <admin>] [--email <mail>] [--password <pass>]
    php <project> [<version>]  pin a PHP version (for example 8.2)
    php <project> --clear      go back to the stack default

  Health
    doctor [--json] [--project <name>] [--fix]
    update [--check] [--yes]  check/download a free public update
    wizard [--force]          three-step first-run setup
    logs <nginx|mysql|php|supervisor|mailpit> [--tail 40]

  Data
    snapshot <project> [--label <text>]
    snapshots <project>
    restore <project> <file> --yes
    export <project> [--out <zip>] [--no-db]
    import <zip|folder> [--name <name>] [--php <version>] [--force]

  Deploy
    deploy <project> [--json]  VPS pre-check + deployment checklist

  Other
    hosts sync                 write the managed block in the hosts file
    version                    print the WampDeck version
    help                       this text

"@
}

function ConvertFrom-CliArguments {
    param([string[]]$Arguments)

    $options = @{}
    $positional = New-Object System.Collections.Generic.List[string]
    $index = 0
    while ($index -lt $Arguments.Count) {
        $argument = $Arguments[$index]
        if ($argument -match '^--?([A-Za-z][A-Za-z0-9-]*)(=(.*))?$') {
            $name = $Matches[1].ToLowerInvariant()
            if ($Matches[2]) {
                $options[$name] = $Matches[3]
            } elseif ($index + 1 -lt $Arguments.Count -and $Arguments[$index + 1] -notmatch '^--?[A-Za-z]') {
                $options[$name] = $Arguments[$index + 1]
                $index++
            } else {
                $options[$name] = $true
            }
        } else {
            $positional.Add($argument)
        }
        $index++
    }
    return [pscustomobject]@{ Options = $options; Positional = @($positional) }
}

function Write-CliTitle {
    param([string]$Text)
    Write-Host ''
    Write-Host "  $Text" -ForegroundColor Cyan
}

function Format-CliSize {
    param([long]$Bytes)
    if ($Bytes -ge 1GB) { return ('{0:N1} GB' -f ($Bytes / 1GB)) }
    if ($Bytes -ge 1MB) { return ('{0:N1} MB' -f ($Bytes / 1MB)) }
    return ('{0:N1} KB' -f ($Bytes / 1KB))
}

function Confirm-CliAction {
    param([string]$Question, [switch]$AssumeYes)

    if ($AssumeYes) { return $true }
    if ([Console]::IsInputRedirected) {
        throw 'Refusing to continue. Add --yes to confirm in a script.'
    }
    $answer = Read-Host "  $Question [y/N]"
    return ($answer -match '^(y|yes)$')
}

function Get-CliProject {
    param([string]$Name)

    if (-not $Name) { throw 'A project name is required.' }
    $project = Get-ProjectByName $Name
    if (-not $project) { throw "Project '$Name' was not found in $WwwDir." }
    return $project
}

# ---------------------------------------------------------------- status
function Invoke-CliStatus {
    param($Parsed)

    if ($Parsed.Options.ContainsKey('json')) {
        $status = Get-StackStatus
        $projects = @(Get-ProjectList)
        $payload = [ordered]@{
            version    = $WampDeckVersion
            root       = $Root
            web        = [ordered]@{ server = $status.WebServer; running = $status.WebRunning; pid = $status.WebPid; port = $status.HttpPort }
            mysql      = [ordered]@{ running = $status.MysqlRunning; port = $status.MysqlPort }
            php        = [ordered]@{
                default  = $status.PhpVersion
                alive    = $status.PhpAlive
                expected = $status.PhpExpected
                pools    = @($status.PhpPools | ForEach-Object { [ordered]@{ version = $_.Version; alive = $_.Alive; expected = $_.Expected; ports = $_.Ports; running = $_.Running } })
            }
            supervisor = $status.PhpSupervisor
            projects   = @($projects | ForEach-Object { [ordered]@{ name = $_.Name; php = $_.PhpVersion; pinned = $_.PhpPinned; url = $_.TestUrl; docroot = $_.DocumentRoot } })
        }
        $payload | ConvertTo-Json -Depth 6
        return 0
    }

    $status = Get-StackStatus
    Write-CliTitle "WampDeck $WampDeckVersion"
    Write-Host "  $Root" -ForegroundColor DarkGray

    Write-Host ''
    $webName = if ($status.WebServer -eq 'apache') { 'Apache' } else { 'Nginx' }
    $webState = if ($status.WebRunning) { 'running' } else { 'stopped' }
    $webColor = if ($status.WebRunning) { 'Green' } else { 'Red' }
    Write-Host ('    {0,-11} ' -f $webName) -NoNewline
    Write-Host ('{0,-9} ' -f $webState) -NoNewline -ForegroundColor $webColor
    Write-Host "port $($status.HttpPort)" -ForegroundColor DarkGray

    $dbState = if ($status.MysqlRunning) { 'running' } else { 'stopped' }
    $dbColor = if ($status.MysqlRunning) { 'Green' } else { 'Red' }
    Write-Host ('    {0,-11} ' -f 'MySQL') -NoNewline
    Write-Host ('{0,-9} ' -f $dbState) -NoNewline -ForegroundColor $dbColor
    Write-Host "port $($status.MysqlPort)" -ForegroundColor DarkGray

    foreach ($pool in @($status.PhpPools)) {
        $stateLabel = if ($pool.Running) { 'running' } else { 'degraded' }
        $color = if ($pool.Running) { 'Green' } else { 'Yellow' }
        Write-Host ('    {0,-11} ' -f "PHP $($pool.Version)") -NoNewline
        Write-Host ('{0,-9} ' -f $stateLabel) -NoNewline -ForegroundColor $color
        Write-Host ("{0}/{1} workers on ports {2}-{3}" -f $pool.Alive, $pool.Expected, $pool.Ports[0], $pool.Ports[$pool.Ports.Count - 1]) -ForegroundColor DarkGray
    }

    $supState = if ($status.PhpSupervisor) { 'running' } else { 'stopped' }
    $supColor = if ($status.PhpSupervisor) { 'Green' } else { 'Yellow' }
    Write-Host ('    {0,-11} ' -f 'supervisor') -NoNewline
    Write-Host ('{0,-9}' -f $supState) -ForegroundColor $supColor

    Write-Host ''
    Write-Host '  URLs' -ForegroundColor Cyan
    Write-Host "    panel       $PanelUrl" -ForegroundColor White
    $projects = @(Get-ProjectList)
    if ($projects.Count -eq 0) {
        Write-Host '    (no projects yet - wampdeck new myapp)' -ForegroundColor DarkGray
    } else {
        foreach ($project in $projects) {
            $pin = if ($project.PhpPinned) { "PHP $($project.PhpVersion) (pinned)" } else { "PHP $($project.PhpVersion)" }
            Write-Host ('    {0,-11} {1}' -f $project.Name, $project.TestUrl) -ForegroundColor White
            Write-Host ('    {0,-11} {1}' -f '', $pin) -ForegroundColor DarkGray
        }
    }
    Write-Host ''
    return 0
}

# ---------------------------------------------------------------- list
function Invoke-CliList {
    param($Parsed)

    $projects = @(Get-ProjectList)
    if ($Parsed.Options.ContainsKey('json')) {
        $items = @($projects | ForEach-Object {
            [ordered]@{
                name      = $_.Name
                php       = $_.PhpVersion
                pinned    = $_.PhpPinned
                url       = $_.TestUrl
                docroot   = $_.DocumentRoot
                manifest  = $_.Manifest.Path
                valid     = $_.Manifest.Valid
                warnings  = @($_.Manifest.Warnings)
            }
        })
        $items | ConvertTo-Json -Depth 5
        return 0
    }

    Write-CliTitle 'Projects'
    if ($projects.Count -eq 0) {
        Write-Host '  No projects yet. Create one with: wampdeck new myapp' -ForegroundColor DarkGray
        Write-Host ''
        return 0
    }

    Write-Host ('    {0,-14} {1,-12} {2}' -f 'NAME', 'PHP', 'URL') -ForegroundColor DarkGray
    foreach ($project in $projects) {
        $php = $project.PhpVersion
        if ($project.PhpPinned) { $php += ' *' }
        Write-Host ('    {0,-14} {1,-12} {2}' -f $project.Name, $php, $project.TestUrl) -ForegroundColor White
    }
    Write-Host ''
    Write-Host '    * pinned in .wampdeck.json' -ForegroundColor DarkGray
    Write-Host ''
    return 0
}

# ---------------------------------------------------------------- doctor
function Invoke-CliDoctor {
    param($Parsed)

    $filter = ''
    if ($Parsed.Options.ContainsKey('project')) { $filter = [string]$Parsed.Options['project'] }
    $checks = @(Invoke-Doctor -Project $filter)

    if ($Parsed.Options.ContainsKey('json')) {
        [ordered]@{
            version = $WampDeckVersion
            root    = $Root
            verdict = Get-DoctorVerdict -Checks $checks
            checks  = @($checks)
        } | ConvertTo-Json -Depth 6
        return $(if ((Get-DoctorVerdict -Checks $checks) -eq 'fail') { 2 } else { 0 })
    }

    Write-CliTitle "Doctor - WampDeck $WampDeckVersion"
    foreach ($check in $checks) {
        switch ($check.Status) {
            'pass' {
                Write-Host '    [ok]   ' -NoNewline -ForegroundColor Green
                Write-Host ('{0,-34} ' -f $check.Title) -NoNewline
                Write-Host $check.Detail -ForegroundColor DarkGray
            }
            'warn' {
                Write-Host '    [warn] ' -NoNewline -ForegroundColor Yellow
                Write-Host ('{0,-34} ' -f $check.Title) -NoNewline
                Write-Host $check.Detail -ForegroundColor Yellow
                if ($check.Fix) { Write-Host ('           -> {0}' -f $check.Fix) -ForegroundColor DarkGray }
            }
            'fail' {
                Write-Host '    [fail] ' -NoNewline -ForegroundColor Red
                Write-Host ('{0,-34} ' -f $check.Title) -NoNewline
                Write-Host $check.Detail -ForegroundColor Red
                if ($check.Fix) { Write-Host ('           -> {0}' -f $check.Fix) -ForegroundColor Yellow }
            }
            default {
                Write-Host '    [skip] ' -NoNewline -ForegroundColor DarkGray
                Write-Host ('{0,-34} ' -f $check.Title) -NoNewline
                Write-Host $check.Detail -ForegroundColor DarkGray
            }
        }
    }

    $fail = @($checks | Where-Object { $_.Status -eq 'fail' }).Count
    $warn = @($checks | Where-Object { $_.Status -eq 'warn' }).Count
    $pass = @($checks | Where-Object { $_.Status -eq 'pass' }).Count
    Write-Host ''
    $line = "  $pass passed, $warn warnings, $fail failed"
    if ($fail -gt 0) { Write-Host $line -ForegroundColor Red }
    elseif ($warn -gt 0) { Write-Host $line -ForegroundColor Yellow }
    else { Write-Host $line -ForegroundColor Green }
    Write-Host ''
    if ($Parsed.Options.ContainsKey('fix')) {
        Write-Host '  Applying safe fixes (config and hosts only) ...' -ForegroundColor Cyan
        $fixes = @(Invoke-DoctorFix -Checks $checks)
        foreach ($fix in $fixes) {
            if ($fix.Applied) {
                Write-Host ('    [fixed] ' + $fix.Id + ' - ' + $fix.Detail) -ForegroundColor Green
            } else {
                Write-Host ('    [skip]  ' + $fix.Id + ' - ' + $fix.Detail) -ForegroundColor DarkGray
            }
        }
        $after = @(Invoke-Doctor -Project $filter)
        $fail2 = @($after | Where-Object { $_.Status -eq 'fail' }).Count
        $warn2 = @($after | Where-Object { $_.Status -eq 'warn' }).Count
        Write-Host ''
        Write-Host ('  After fixes: ' + @($after).Count + ' checks, ' + $warn2 + ' warnings, ' + $fail2 + ' failed') -ForegroundColor 
            $(if ($fail2 -gt 0) { 'Red' } elseif ($warn2 -gt 0) { 'Yellow' } else { 'Green' })
        Write-Host ''
        if ($fail2 -gt 0) { return 2 }
        return 0
    }

    if ($fail -gt 0) { return 2 }
    return 0
}

# ---------------------------------------------------------------- update
function Invoke-CliUpdate {
    param($Parsed)
    return (Invoke-WampDeckUpdate -Check:$($Parsed.Options.ContainsKey('check')) -Yes:$($Parsed.Options.ContainsKey('yes')))
}

# ---------------------------------------------------------------- deploy pre-check
# Runs local pre-deployment checks for a finished CMS project and prints a
# VPS deployment checklist so the user can move the project to an online
# server without guesswork.
function Get-DeployCmsFromFolder {
    param([string]$Folder)

    $files = @(Get-ChildItem -Path $Folder -File -ErrorAction SilentlyContinue | ForEach-Object { $_.Name })
    if ($files -contains 'wp-config.php') { return 'wordpress' }
    if ($files -contains 'artisan') { return 'twill' }
    if ($files -contains 'configuration.php') { return 'joomla' }
    if ($files -contains 'LocalSettings.php') { return 'joomla' }
    if (Test-Path (Join-Path $Folder 'wire')) { return 'processwire' }
    if (Test-Path (Join-Path $Folder 'user')) { return 'grav' }
    if (Test-Path (Join-Path $Folder 'concrete')) { return 'concrete' }
    if (Test-Path (Join-Path $Folder 'typo3conf')) { return 'typo3' }
    if ((Get-ChildItem -Path $Folder -Filter '*.twig' -File -ErrorAction SilentlyContinue).Count -gt 0) { return 'winter' }
    return ''
}

function Get-DeployRequiredExtensions {
    param([string]$CmsId)

    $common = @('mysqli', 'pdo_mysql', 'curl', 'mbstring', 'xml', 'fileinfo', 'openssl', 'zip')
    $extra = @{
        'wordpress' = @('gd', 'exif', 'imagick')
        'concrete'  = @('gd', 'exif', 'imagick')
        'typo3'     = @('gd', 'intl')
        'joomla'    = @('gd')
        'processwire' = @('gd')
        'grav'      = @('gd')
        'winter'    = @('gd')
        'twill'     = @('pdo', 'tokenizer', 'ctype', 'json', 'bcmath')
    }
    $required = @($common)
    if ($CmsId -and $extra.ContainsKey($CmsId)) {
        foreach ($e in $extra[$CmsId]) { if ($required -notcontains $e) { $required += $e } }
    }
    return $required
}

function Get-DeployLoadedExtensions {
    param([string]$Version)

    $exe = Join-Path (Join-Path $PhpRoot $Version) 'php.exe'
    if (-not (Test-Path $exe)) { return @() }
    $modules = @(& $exe -m 2>$null)
    return @($modules | ForEach-Object { $_.Trim() } | Where-Object { $_ -match '^[A-Za-z0-9_]+$' })
}

function Get-DeployDocRoot {
    param([object]$Project)

    $manifest = $Project.Manifest
    if ($manifest -and $manifest.Valid -and $manifest.Data.DocRoot) {
        return (Join-Path $Project.Folder $manifest.Data.DocRoot)
    }
    return $Project.Folder
}

function Invoke-CliDeploy {
    param($Parsed)

    $projectName = $Parsed.Positional[1]
    if (-not $projectName) { throw 'Usage: wampdeck deploy <project>' }
    $project = Get-CliProject -Name $projectName

    $json = $Parsed.Options.ContainsKey('json')
    $cmsId = Get-DeployCmsFromFolder -Folder $project.Folder
    $phpVersion = $project.PhpVersion
    $docRoot = Get-DeployDocRoot -Project $project
    $dbName = Get-ProjectDatabaseName -Project $project

    $checks = New-Object System.Collections.Generic.List[object]

    # ------------------------------------------------------------ PHP version
    $phpInstalled = $false
    if (-not $PhpVersions) { $PhpVersions = @() }
    foreach ($v in $PhpVersions) { if ($v -eq $phpVersion) { $phpInstalled = $true; break } }
    if ($phpInstalled) {
        $checks.Add((New-DoctorCheck -Id 'deploy.php' -Title 'PHP version installed' -Status 'pass' -Detail "$phpVersion is installed locally" -Fix ''))
    } else {
        $checks.Add((New-DoctorCheck -Id 'deploy.php' -Title 'PHP version installed' -Status 'warn' -Detail "$phpVersion may not match the target server" -Fix 'Install the same PHP version on the VPS, or pin a different version.'))
    }

    # ------------------------------------------------------------ extensions
    $required = Get-DeployRequiredExtensions -CmsId $cmsId
    $loaded = Get-DeployLoadedExtensions -Version $phpVersion
    $missingExt = @()
    foreach ($ext in $required) {
        if ($loaded -notcontains $ext) { $missingExt += $ext }
    }
    if ($missingExt.Count -eq 0) {
        $checks.Add((New-DoctorCheck -Id 'deploy.extensions' -Title 'PHP extensions' -Status 'pass' -Detail "All required extensions present ($($required -join ', '))" -Fix ''))
    } else {
        $checks.Add((New-DoctorCheck -Id 'deploy.extensions' -Title 'PHP extensions' -Status 'fail' -Detail "Missing: $($missingExt -join ', ')" -Fix "Enable these extensions in php.ini on the VPS."))
    }

    # ------------------------------------------------------------ web server
    $status = Get-StackStatus
    if ($status.WebRunning) {
        $checks.Add((New-DoctorCheck -Id 'deploy.web' -Title 'Web server running' -Status 'pass' -Detail "$($status.WebServer) on port $($status.HttpPort)" -Fix ''))
    } else {
        $checks.Add((New-DoctorCheck -Id 'deploy.web' -Title 'Web server running' -Status 'warn' -Detail 'Web server is stopped locally' -Fix 'Start the stack before deploy testing.'))
    }

    # ------------------------------------------------------------ docroot
    if (Test-Path $docRoot) {
        $checks.Add((New-DoctorCheck -Id 'deploy.docroot' -Title 'Document root exists' -Status 'pass' -Detail $docRoot -Fix ''))
    } else {
        $checks.Add((New-DoctorCheck -Id 'deploy.docroot' -Title 'Document root exists' -Status 'fail' -Detail "Missing: $docRoot" -Fix 'Create the document root folder on the VPS.'))
    }

    # ------------------------------------------------------------ local HTTP
    $httpOk = $false
    $httpDetail = ''
    try {
        $probe = Invoke-Http -Url $project.TestUrl -TimeoutSec 8
        if ($probe.Ok) { $httpOk = $true; $httpDetail = "HTTP $($probe.Status) on $($project.TestUrl)" }
        else { $httpDetail = "No response on $($project.TestUrl): $($probe.Content)" }
    } catch { $httpDetail = "Could not reach $($project.TestUrl)" }
    if ($httpOk) {
        $checks.Add((New-DoctorCheck -Id 'deploy.http' -Title 'Local site responds' -Status 'pass' -Detail $httpDetail -Fix ''))
    } else {
        $checks.Add((New-DoctorCheck -Id 'deploy.http' -Title 'Local site responds' -Status 'fail' -Detail $httpDetail -Fix 'Fix the local site before deploying.'))
    }

    # ------------------------------------------------------------ database
    $dbOk = $false
    $dbDetail = ''
    try {
        $ping = & "$BinDir\mysql\bin\mysqladmin.exe" --host=127.0.0.1 --port=$($status.MysqlPort) --user=root ping 2>$null
        if ($LASTEXITCODE -eq 0 -or $ping -like '*alive*') { $dbOk = $true; $dbDetail = "MySQL reachable on 127.0.0.1:$($status.MysqlPort)" }
        else { $dbDetail = "mysqladmin ping returned: $ping" }
    } catch { $dbDetail = "Could not reach MySQL: $($_.Exception.Message)" }
    if ($dbOk) {
        $checks.Add((New-DoctorCheck -Id 'deploy.db' -Title 'Database reachable' -Status 'pass' -Detail "$dbName on 127.0.0.1:$($status.MysqlPort)" -Fix ''))
    } else {
        $checks.Add((New-DoctorCheck -Id 'deploy.db' -Title 'Database reachable' -Status 'warn' -Detail $dbDetail -Fix ("Create database '$dbName' and a DB user on the VPS.")))
    }

    # ------------------------------------------------------------ writable dirs
    $writableOk = $true
    $writableDetail = ''
    foreach ($d in @('uploads', 'storage', 'application/config', 'site/config')) {
        $p = Join-Path $docRoot $d
        if (Test-Path $p) {
            try {
                $probe = Join-Path $p '.wampdeck-deploy-probe'
                Set-Content -Path $probe -Value 'ok' -Encoding ASCII -ErrorAction Stop
                Remove-Item -LiteralPath $probe -Force -ErrorAction SilentlyContinue
            } catch { $writableOk = $false; $writableDetail = "$p is not writable" }
        }
    }
    if ($writableOk) {
        $checks.Add((New-DoctorCheck -Id 'deploy.perms' -Title 'Writable folders' -Status 'pass' -Detail 'uploads/storage folders writable' -Fix ''))
    } else {
        $checks.Add((New-DoctorCheck -Id 'deploy.perms' -Title 'Writable folders' -Status 'warn' -Detail $writableDetail -Fix 'Make uploads/storage writable by the web server user on the VPS.'))
    }

    # ------------------------------------------------------------ output
    $checklist = @(
        "  1. PHP version : $phpVersion",
        "  2. Extensions  : $($required -join ', ')",
        "  3. Database    : $dbName (user/password from your CMS install)",
        "  4. Web server  : Nginx or Apache, docroot = $docRoot",
        "  5. Permissions : make uploads/storage writable by www-data (Linux) or IIS_IUSRS (Windows)"
    )
    if ($cmsId -eq 'twill') { $checklist += '  6. Cron        : `* * * * * php /path/to/artisan schedule:run >> /dev/null 2>&1`' }
    elseif ($cmsId -eq 'wordpress') { $checklist += '  6. Permalinks  : enable mod_rewrite (Apache) or try_files (Nginx)' }
    else { $checklist += '  6. Config      : set APP_ENV/SITE_URL and DB host to the VPS values' }
    $checklist += "  7. Upload      : export the project (`wampdeck export $projectName --out project.zip`) and extract on the VPS"
    $checklist += "  8. Database    : import the included SQL dump, update wp-config/.env with VPS DB credentials"
    $checklist += "  9. HTTPS       : trust a cert for your domain (Let's Encrypt or your host)"

    if ($json) {
        $payload = [ordered]@{
            version     = $WampDeckVersion
            root        = $Root
            project     = $project.Name
            folder      = $project.Folder
            cms         = $cmsId
            phpVersion  = $phpVersion
            database    = $dbName
            docRoot     = $docRoot
            testUrl     = $project.TestUrl
            checks      = @($checks | ForEach-Object { [ordered]@{ id = $_.Id; title = $_.Title; status = $_.Status; detail = $_.Detail; fix = $_.Fix } })
            checklist   = @($checklist)
        }
        $payload | ConvertTo-Json -Depth 5
        $fail = @($checks | Where-Object { $_.Status -eq 'fail' }).Count
        return $(if ($fail -gt 0) { 2 } else { 0 })
    }

    Write-CliTitle "Deploy pre-check - $($project.Name)"
    foreach ($check in $checks) {
        switch ($check.Status) {
            'pass' { Write-Host '    [ok]   ' -NoNewline -ForegroundColor Green; Write-Host ('{0,-26} ' -f $check.Title) -NoNewline; Write-Host $check.Detail -ForegroundColor DarkGray }
            'warn' { Write-Host '    [warn] ' -NoNewline -ForegroundColor Yellow; Write-Host ('{0,-26} ' -f $check.Title) -NoNewline; Write-Host $check.Detail -ForegroundColor Yellow; if ($check.Fix) { Write-Host ('           -> {0}' -f $check.Fix) -ForegroundColor DarkGray } }
            'fail' { Write-Host '    [fail] ' -NoNewline -ForegroundColor Red; Write-Host ('{0,-26} ' -f $check.Title) -NoNewline; Write-Host $check.Detail -ForegroundColor Red; if ($check.Fix) { Write-Host ('           -> {0}' -f $check.Fix) -ForegroundColor Yellow } }
            default { Write-Host '    [skip] ' -NoNewline -ForegroundColor DarkGray; Write-Host ('{0,-26} ' -f $check.Title) -NoNewline; Write-Host $check.Detail -ForegroundColor DarkGray }
        }
    }
    Write-Host ''

    # ------------------------------------------------------------ VPS checklist
    Write-CliTitle 'VPS deployment checklist'
    foreach ($line in $checklist) { Write-Host $line -ForegroundColor White }
    Write-Host ''
    $fail = @($checks | Where-Object { $_.Status -eq 'fail' }).Count
    $warn = @($checks | Where-Object { $_.Status -eq 'warn' }).Count
    $pass = @($checks | Where-Object { $_.Status -eq 'pass' }).Count
    $line = "  $pass passed, $warn warnings, $fail failed"
    if ($fail -gt 0) { Write-Host $line -ForegroundColor Red }
    elseif ($warn -gt 0) { Write-Host $line -ForegroundColor Yellow }
    else { Write-Host $line -ForegroundColor Green }
    Write-Host ''
    if ($fail -gt 0) { return 2 }
    return 0
}
function Invoke-CliStart {
    param($Parsed)
    Write-CliTitle 'Starting WampDeck'
    $result = Start-Stack
    Write-Host ''
    Write-Host "    web         $($result.web)" -ForegroundColor DarkGray
    Write-Host "    php         $($result.php.Total) workers ($($result.php.Started) started, $($result.php.Reused) reused)" -ForegroundColor DarkGray
    Write-Host "    supervisor  $($result.supervisor)" -ForegroundColor DarkGray
    Write-Host "    mysql       $($result.mysql)" -ForegroundColor DarkGray
    Write-Host ''
    Write-Host "  Panel  $PanelUrl" -ForegroundColor White
    Write-Host ''
    return 0
}

function Invoke-CliStop {
    param($Parsed)
    Write-CliTitle 'Stopping WampDeck'
    $result = Stop-Stack
    Write-Host ''
    Write-Host '  Stopped.' -ForegroundColor Green
    Write-Host ''
    return 0
}

function Invoke-CliRestart {
    param($Parsed)
    Write-CliTitle 'Restarting WampDeck'
    $result = Restart-Stack
    Write-Host ''
    Write-Host "  Web  $($result.web), PHP $($result.php.Total) workers, MySQL $($result.mysql)" -ForegroundColor Green
    Write-Host ''
    return 0
}

function Invoke-CliOpen {
    param($Parsed)
    $project = Get-CliProject -Name $Parsed.Positional[1]
    Start-Process $project.TestUrl
    Write-Host "  Opened $($project.TestUrl)" -ForegroundColor Green
    return 0
}

# ---------------------------------------------------------------- php pin
function Invoke-CliPhp {
    param($Parsed)

    $project = Get-CliProject -Name $Parsed.Positional[1]
    $clear = $Parsed.Options.ContainsKey('clear')
    $spec = ''
    if ($Parsed.Positional.Count -gt 2) { $spec = $Parsed.Positional[2] }
    if ($Parsed.Options.ContainsKey('php')) { $spec = [string]$Parsed.Options['php'] }

    if ($clear) {
        Update-WampDeckManifest -ProjectDir $project.Folder -Values @{ php = 'any' } | Out-Null
        $spec = 'any'
    } elseif ($spec) {
        $resolved = Resolve-PhpVersionSpec -Spec $spec
        if (-not $resolved) {
            throw "PHP $spec is not installed. Installed: $($PhpVersions -join ', ')"
        }
        Update-WampDeckManifest -ProjectDir $project.Folder -Values @{ php = $spec } | Out-Null
    } else {
        Write-CliTitle "PHP for $($project.Name)"
        Write-Host "    current     $($project.PhpVersion)$(if ($project.PhpPinned) { ' (pinned)' } else { ' (stack default)' })" -ForegroundColor White
        Write-Host "    installed   $($PhpVersions -join ', ')" -ForegroundColor DarkGray
        Write-Host ''
        Write-Host "  Change it with: wampdeck php $($project.Name) 8.2" -ForegroundColor DarkGray
        Write-Host "  Back to default: wampdeck php $($project.Name) --clear" -ForegroundColor DarkGray
        Write-Host ''
        return 0
    }

    Write-AllConfigs
    try { if ((Get-StackStatus).WebRunning) { Reload-WebServer | Out-Null } } catch { }

    $updated = Get-ProjectByName $project.Name
    $label = if ($updated.PhpPinned) { "PHP $($updated.PhpVersion) (pinned)" } else { "PHP $($updated.PhpVersion) (stack default)" }
    Write-Host ''
    Write-Host "  $($updated.Name): $label" -ForegroundColor Green
    Write-Host "  $($updated.TestUrl)" -ForegroundColor White
    Write-Host ''
    return 0
}

# ---------------------------------------------------------------- snapshots
function Invoke-CliSnapshot {
    param($Parsed)

    $project = Get-CliProject -Name $Parsed.Positional[1]
    $label = ''
    if ($Parsed.Options.ContainsKey('label')) { $label = [string]$Parsed.Options['label'] }

    $snapshot = New-DbSnapshot -Project $project -Label $label
    Write-Host ''
    Write-Host "  Snapshot saved: $($snapshot.Path)" -ForegroundColor Green
    Write-Host "  database $($snapshot.Database), $(Format-CliSize $snapshot.Size)" -ForegroundColor DarkGray
    Write-Host ''
    return 0
}

function Invoke-CliSnapshots {
    param($Parsed)

    $project = Get-CliProject -Name $Parsed.Positional[1]
    $files = @(Get-DbSnapshotFiles -Project $project)

    if ($Parsed.Options.ContainsKey('json')) {
        @($files | ForEach-Object { [ordered]@{ name = $_.Name; path = $_.Path; size = $_.Size; created = $_.Created.ToString('o') } }) | ConvertTo-Json -Depth 4
        return 0
    }

    Write-CliTitle "Snapshots - $($project.Name)"
    if ($files.Count -eq 0) {
        Write-Host '  None yet. Create one with: wampdeck snapshot ' + $project.Name -ForegroundColor DarkGray
        Write-Host ''
        return 0
    }
    foreach ($file in $files) {
        Write-Host ('    {0,-42} {1,10}  {2}' -f $file.Name, (Format-CliSize $file.Size), $file.Created.ToString('yyyy-MM-dd HH:mm')) -ForegroundColor White
    }
    Write-Host ''
    return 0
}

function Invoke-CliRestore {
    param($Parsed)

    $project = Get-CliProject -Name $Parsed.Positional[1]
    $file = ''
    if ($Parsed.Positional.Count -gt 2) { $file = $Parsed.Positional[2] }
    if (-not $file) { throw 'Usage: wampdeck restore <project> <file> --yes' }

    $resolved = $file
    if (-not (Test-Path $resolved)) {
        $candidate = Join-Path (Get-SnapshotDir $project) $file
        if (Test-Path $candidate) { $resolved = $candidate }
    }
    if (-not (Test-Path $resolved)) { throw "Snapshot not found: $file" }

    $database = Get-ProjectDatabaseName -Project $project
    Write-CliTitle "Restore - $($project.Name)"
    Write-Host "    database    $database" -ForegroundColor DarkGray
    Write-Host "    snapshot    $resolved" -ForegroundColor DarkGray
    if (-not (Confirm-CliAction -Question "Replace the current '$database' data?" -AssumeYes:($Parsed.Options.ContainsKey('yes')))) {
        Write-Host '  Cancelled.' -ForegroundColor DarkGray
        return 0
    }

    $result = Restore-DbSnapshot -Project $project -Path $resolved -NoBackup:($Parsed.Options.ContainsKey('no-backup'))
    Write-Host ''
    Write-Host "  Restored $($project.Name)." -ForegroundColor Green
    if ($result.Backup) { Write-Host "  Previous data saved to $($result.Backup)" -ForegroundColor DarkGray }
    Write-Host ''
    return 0
}

# ---------------------------------------------------------------- export
function Invoke-CliExport {
    param($Parsed)

    $project = Get-CliProject -Name $Parsed.Positional[1]
    $out = ''
    if ($Parsed.Options.ContainsKey('out')) { $out = [string]$Parsed.Options['out'] }

    Write-CliTitle "Export - $($project.Name)"
    $bundle = Export-ProjectBundle -Project $project -OutPath $out -NoDatabase:($Parsed.Options.ContainsKey('no-db'))
    Write-Host ''
    Write-Host "  Bundle ready: $($bundle.Path)" -ForegroundColor Green
    Write-Host "  $(Format-CliSize $bundle.Size), PHP $($bundle.Php)$(if ($bundle.Database) { ", database $($bundle.Database)" })" -ForegroundColor DarkGray
    Write-Host ''
    Write-Host '  Send the zip. The other machine runs: wampdeck import <zip>' -ForegroundColor DarkGray
    Write-Host ''
    return 0
}

# ---------------------------------------------------------------- import
function Invoke-CliImport {
    param($Parsed)

    $path = $Parsed.Positional[1]
    if (-not $path) { throw 'Usage: wampdeck import <zip|folder> [--name <name>] [--allow-scripts]' }
    $name = ''
    if ($Parsed.Options.ContainsKey('name')) { $name = [string]$Parsed.Options['name'] }
    $php = ''
    if ($Parsed.Options.ContainsKey('php')) { $php = [string]$Parsed.Options['php'] }

    Write-CliTitle "Import - $path"
    $result = Import-ProjectBundle -Path $path -Name $name -Php $php `
        -Force:($Parsed.Options.ContainsKey('force')) -NoHosts:($Parsed.Options.ContainsKey('no-hosts')) -AllowScripts:($Parsed.Options.ContainsKey('allow-scripts'))

    Write-Host ''
    Write-Host "  Imported $($result.Name) with PHP $($result.Php)" -ForegroundColor Green
    Write-Host "  $($result.TestUrl)" -ForegroundColor White
    if ($result.DatabaseImported) {
        Write-Host "  database $($result.Database) restored" -ForegroundColor DarkGray
    }
    foreach ($step in @($result.PostCreate)) {
        $stateLabel = if ($step.ExitCode -eq 0) { 'ok' } else { "exit $($step.ExitCode)" }
        Write-Host "  postCreate: $($step.Command) ($stateLabel)" -ForegroundColor DarkGray
    }
    if (-not $result.HostsSynced) {
        Write-Host '  hosts file not changed - run wampdeck hosts sync (needs administrator)' -ForegroundColor Yellow
    }
    Write-Host ''
    return 0
}

# ---------------------------------------------------------------- new
function Invoke-CliNew {
    param($Parsed)

    $name = $Parsed.Positional[1]
    if (-not $name) { throw 'Usage: wampdeck new <name> [--preset blank|wordpress|laravel|<cms>] [--cms <id>]' }
    $preset = 'blank'
    if ($Parsed.Options.ContainsKey('preset')) { $preset = [string]$Parsed.Options['preset'] }
    $cms = $null
    if ($Parsed.Options.ContainsKey('cms')) { $cms = [string]$Parsed.Options['cms'] }
    elseif (@('blank', 'wordpress', 'laravel') -notcontains $preset.ToLowerInvariant()) {
        # A CMS id in --preset is a shortcut for a silent CMS install.
        $cms = $preset
        $preset = 'blank'
    }

    if ($cms) {
        $entry = Resolve-WampDeckCms $cms
        Write-CliTitle "Installing $($entry.Name) - $name"
        $project = New-WampDeckProject -Name $name -Cms $entry.Id `
            -AdminUser ([string]$Parsed.Options['user']) `
            -AdminEmail ([string]$Parsed.Options['email']) `
            -AdminPassword ([string]$Parsed.Options['password']) `
            -NoHosts:($Parsed.Options.ContainsKey('no-hosts'))
    } else {
        Write-CliTitle "New $preset project - $name"
        $project = New-WampDeckProject -Name $name -Type $preset `
            -Force:($Parsed.Options.ContainsKey('force')) -NoHosts:($Parsed.Options.ContainsKey('no-hosts')) -AllowScripts:($Parsed.Options.ContainsKey('allow-scripts'))
    }

    Write-Host ''
    Write-Host "  Created $($project.Folder)" -ForegroundColor Green
    Write-Host "  $($project.TestUrl)" -ForegroundColor White
    if ($project.CmsResult) {
        $cmsResult = $project.CmsResult
        Write-Host ''
        Write-Host "  Admin URL  $($cmsResult.AdminUrl)" -ForegroundColor White
        Write-Host "  User       $($cmsResult.AdminUser)" -ForegroundColor White
        Write-Host "  Password   $($cmsResult.AdminPassword)" -ForegroundColor White
        Write-Host "  Email      $($cmsResult.AdminEmail)" -ForegroundColor White
        Write-Host "  Log        $($cmsResult.Log)" -ForegroundColor DarkGray
        if (-not $cmsResult.Verified) { Write-Host '  experimental recipe - check the log' -ForegroundColor Yellow }
    }
    if (-not $project.HostsSynced) {
        Write-Host '  hosts file not changed - run wampdeck hosts sync (needs administrator)' -ForegroundColor Yellow
    }
    Write-Host ''
    return 0
}

# ---------------------------------------------------------------- cms
function Invoke-CliCms {
    param($Parsed)

    $action = 'list'
    if ($Parsed.Positional.Count -gt 1) { $action = $Parsed.Positional[1].ToLowerInvariant() }

    if ($action -eq 'list') {
        Write-CliTitle 'CMS catalog'
        Write-Host ('    {0,-13} {1,-13} {2,-22} {3}' -f 'NAME', 'ID', 'CATEGORY', 'STATUS') -ForegroundColor DarkGray
        foreach ($entry in Get-WampDeckCmsCatalog) {
            $status = if ($entry.Verified) { 'verified' } else { 'experimental' }
            $color = if ($entry.Verified) { 'White' } else { 'Yellow' }
            Write-Host ('    {0,-13} {1,-13} {2,-22} {3}' -f $entry.Name, $entry.Id, $entry.Category, $status) -ForegroundColor $color
        }
        Write-Host ''
        Write-Host '  Install: wampdeck cms install <id> [--name <folder>]' -ForegroundColor DarkGray
        Write-Host ''
        return 0
    }

    if ($action -ne 'install') {
        throw 'Usage: wampdeck cms list | wampdeck cms install <id> [--name <folder>] [--user <admin>] [--email <mail>] [--password <pass>]'
    }

    $id = $null
    if ($Parsed.Positional.Count -gt 2) { $id = $Parsed.Positional[2] }
    if (-not $id) { throw 'Usage: wampdeck cms install <id> [--name <folder>]' }
    $entry = Resolve-WampDeckCms $id
    $name = $entry.Id
    if ($Parsed.Options.ContainsKey('name')) { $name = [string]$Parsed.Options['name'] }

    Write-CliTitle "Installing $($entry.Name) - $name"
    Write-Host "  This can take a few minutes; output goes to logs\cms-$($entry.Id).log" -ForegroundColor DarkGray
    $project = New-WampDeckProject -Name $name -Cms $entry.Id `
        -AdminUser ([string]$Parsed.Options['user']) `
        -AdminEmail ([string]$Parsed.Options['email']) `
        -AdminPassword ([string]$Parsed.Options['password']) `
        -NoHosts:($Parsed.Options.ContainsKey('no-hosts'))

    $cms = $project.CmsResult
    Write-Host ''
    Write-Host "  Installed $($cms.CmsName) in $($cms.Folder)" -ForegroundColor Green
    Write-Host "  Site       $($cms.Url)" -ForegroundColor White
    Write-Host "  Admin      $($cms.AdminUrl)" -ForegroundColor White
    Write-Host "  User       $($cms.AdminUser)" -ForegroundColor White
    Write-Host "  Password   $($cms.AdminPassword)" -ForegroundColor White
    Write-Host "  Email      $($cms.AdminEmail)" -ForegroundColor White
    Write-Host "  Log        $($cms.Log)" -ForegroundColor DarkGray
    if (-not $cms.Verified) {
        Write-Host '  experimental recipe - check the log before using this site' -ForegroundColor Yellow
    }
    if (-not $project.HostsSynced) {
        Write-Host '  hosts file not changed - run wampdeck hosts sync (needs administrator)' -ForegroundColor Yellow
    }
    Write-Host ''
    return 0
}

# ---------------------------------------------------------------- hosts
function Invoke-CliHosts {
    param($Parsed)

    $action = 'status'
    if ($Parsed.Positional.Count -gt 1) { $action = $Parsed.Positional[1].ToLowerInvariant() }

    if ($action -eq 'sync') {
        Write-CliTitle 'Hosts file'
        $synced = $false
        if (Test-Admin) { $synced = Sync-HostsFile } else { $synced = Invoke-HostsSyncElevated }
        if ($synced) { Write-Host '  Hosts file updated.' -ForegroundColor Green }
        else {
            Write-Host '  Hosts file was not updated.' -ForegroundColor Yellow
            Write-Host '  .localhost names still work; .test names need the hosts entry.' -ForegroundColor DarkGray
        }
        Write-Host ''
        return 0
    }

    $status = Get-HostsStatus
    Write-CliTitle 'Hosts file'
    Write-Host "    file        $($status.File)" -ForegroundColor DarkGray
    Write-Host "    names       $($status.Present)/$($status.Required)" -ForegroundColor White
    if (-not $status.Synced) {
        foreach ($name in $status.Missing) { Write-Host "    missing     $name" -ForegroundColor Yellow }
        Write-Host ''
        Write-Host '  Run: wampdeck hosts sync' -ForegroundColor DarkGray
    }
    Write-Host ''
    return 0
}

# ---------------------------------------------------------------- logs
function Invoke-CliLogs {
    param($Parsed)

    $name = 'nginx'
    if ($Parsed.Positional.Count -gt 1) { $name = $Parsed.Positional[1].ToLowerInvariant() }
    $tail = 40
    if ($Parsed.Options.ContainsKey('tail')) { $tail = [int]$Parsed.Options['tail'] }

    $candidates = @{
        nginx      = 'nginx-error.log'
        apache     = 'apache-error.log'
        mysql      = 'mysql-error.log'
        supervisor = 'php-supervisor.log'
        mailpit    = 'mailpit.log'
    }

    $file = $null
    if ($candidates.ContainsKey($name)) {
        $file = Join-Path $LogDir $candidates[$name]
    } elseif ($name -eq 'php') {
        $file = @(Get-ChildItem $LogDir -Filter 'php-*.log' -File -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName
    } else {
        $file = Join-Path $LogDir $name
    }

    if (-not $file -or -not (Test-Path $file)) {
        throw "No log file matched '$name' in $LogDir."
    }
    Write-CliTitle ([IO.Path]::GetFileName($file))
    Get-Content -Path $file -Tail $tail -ErrorAction SilentlyContinue | ForEach-Object { Write-Host "  $_" }
    Write-Host ''
    return 0
}

# ---------------------------------------------------------------- dispatcher
function Invoke-WampDeckCli {
    param([string[]]$Arguments)

    $parsed = ConvertFrom-CliArguments -Arguments @($Arguments)
    $command = 'help'
    if ($parsed.Positional.Count -gt 0) { $command = $parsed.Positional[0].ToLowerInvariant() }
    if ($parsed.Options.ContainsKey('help') -or $parsed.Options.ContainsKey('h')) { $command = 'help' }
    if ($parsed.Options.ContainsKey('version') -and $command -eq 'help') { $command = 'version' }

    try {
        switch ($command) {
            'status' { return (Invoke-CliStatus -Parsed $parsed) }
            'list' { return (Invoke-CliList -Parsed $parsed) }
            'doctor' { return (Invoke-CliDoctor -Parsed $parsed) }
            'start' { return (Invoke-CliStart -Parsed $parsed) }
            'stop' { return (Invoke-CliStop -Parsed $parsed) }
            'restart' { return (Invoke-CliRestart -Parsed $parsed) }
            'open' { return (Invoke-CliOpen -Parsed $parsed) }
            'php' { return (Invoke-CliPhp -Parsed $parsed) }
            'snapshot' { return (Invoke-CliSnapshot -Parsed $parsed) }
            'snapshots' { return (Invoke-CliSnapshots -Parsed $parsed) }
            'restore' { return (Invoke-CliRestore -Parsed $parsed) }
            'export' { return (Invoke-CliExport -Parsed $parsed) }
            'import' { return (Invoke-CliImport -Parsed $parsed) }
            'deploy' { return (Invoke-CliDeploy -Parsed $parsed) }
            'new' { return (Invoke-CliNew -Parsed $parsed) }
            'cms' { return (Invoke-CliCms -Parsed $parsed) }
            'hosts' { return (Invoke-CliHosts -Parsed $parsed) }
            'logs' { return (Invoke-CliLogs -Parsed $parsed) }
            'update' { return (Invoke-CliUpdate -Parsed $parsed) }
            'wizard' { return (Invoke-FirstRunWizard -Force:$($parsed.Options.ContainsKey('force'))) }
            'version' {
                Write-Host "  WampDeck $WampDeckVersion"
                return 0
            }
            'help' {
                Write-Host (Get-CliUsage) -ForegroundColor Gray
                return 0
            }
            default {
                Write-Host ''
                Write-Host "  Unknown command '$command'." -ForegroundColor Red
                Write-Host (Get-CliUsage) -ForegroundColor Gray
                return 1
            }
        }
    } catch {
        Write-Host ''
        Write-Host "  $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ''
        return 1
    }
}