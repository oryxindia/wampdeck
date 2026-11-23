# Generates every config file from the current state.

function Get-PhpOpcacheMode {
    # Some Windows builds abort in the CGI SAPI with
    # "Opcode handlers are unusable due to ASLR" as soon as opcache uses
    # shared memory. Those builds still work with opcache's file cache, so
    # probe for that before giving up. Returns "shm", "file" or $false.
    param([string]$Version)

    $dir = Join-Path $PhpRoot $Version
    $cgi = Join-Path $dir 'php-cgi.exe'
    $dll = Join-Path $dir 'ext\php_opcache.dll'
    if (-not (Test-Path $cgi) -or -not (Test-Path $dll)) { return $false }

    if (-not $script:OpcacheSupport) { $script:OpcacheSupport = @{} }
    if ($script:OpcacheSupport.ContainsKey($Version)) { return $script:OpcacheSupport[$Version] }

    $cacheFile = Join-Path $EtcDir 'php-runtime.json'
    $stamp = (Get-Item $cgi).LastWriteTimeUtc.Ticks
    $cache = @{}
    if (Test-Path $cacheFile) {
        try {
            $raw = Get-Content -Path $cacheFile -Raw -ErrorAction Stop
            if ($raw.Trim()) {
                $loaded = $raw | ConvertFrom-Json -ErrorAction Stop
                foreach ($property in $loaded.PSObject.Properties) {
                    $cache[$property.Name] = $property.Value
                }
            }
        } catch { $cache = @{} }
    }

    # probe = 3 re-tests shared memory unconditionally. Older probes cached a
    # false "opcache crashes" result that survived the build that fixed it,
    # leaving every worker disabled long after the bug was gone. Bumping this
    # number discards those stale entries so the current build is probed again.
    if ($cache.ContainsKey($Version)) {
        $entry = $cache[$Version]
        if ($entry.stamp -eq $stamp -and $entry.probe -eq 3) {
            $cached = if ($entry.mode) { [string]$entry.mode } elseif ([bool]$entry.ok) { 'shm' } else { $false }
            $script:OpcacheSupport[$Version] = $cached
            return $cached
        }
    }

    Ensure-Dir $TmpDir
    $probeIni = Join-Path $TmpDir "opcache-probe-$Version.ini"
    $extFwd = (Join-Path $dir 'ext') -replace '\\', '/'

    $runProbe = {
        param([string]$IniText)

        Set-Content -Path $probeIni -Value $IniText -Encoding ASCII
        $previous = $ErrorActionPreference
        $previousRequests = $env:PHP_FCGI_MAX_REQUESTS
        $previousLocation = (Get-Location).Path
        $ErrorActionPreference = 'Continue'
        $env:PHP_FCGI_MAX_REQUESTS = '10000'
        try {
            Push-Location $dir
            $output = & $cgi -c $probeIni -v 2>&1
        } catch {
            $output = @("$($_.Exception.Message)")
        } finally {
            Pop-Location
            $env:PHP_FCGI_MAX_REQUESTS = $previousRequests
            Set-Location $previousLocation
            $ErrorActionPreference = $previous
        }
        $text = ($output -join ' ')
        return (($text -match 'with Zend OPcache') -and ($text -notmatch 'Fatal Error'))
    }

    # First choice: shared memory opcache.
    $mode = $false
    $ini = "extension_dir = `"$extFwd`"`r`nzend_extension=opcache`r`nopcache.enable=1`r`n"
    if (& $runProbe $ini) {
        $mode = 'shm'
    } else {
        # Second choice: file cache only. The ASLR check that kills shared
        # memory opcache does not run in this mode.
        $fileCacheDir = Join-Path $TmpDir "opcache-files\$Version"
        Ensure-Dir $fileCacheDir
        $fileCacheFwd = $fileCacheDir -replace '\\', '/'
        $ini = "extension_dir = `"$extFwd`"`r`nzend_extension=opcache`r`nopcache.enable=1`r`n" +
               "opcache.file_cache=`"$fileCacheFwd`"`r`nopcache.file_cache_fallback=1`r`n"
        if (& $runProbe $ini) { $mode = 'file' }
    }
    Remove-Item $probeIni -Force -ErrorAction SilentlyContinue

    $cache[$Version] = [pscustomobject]@{ ok = [bool]$mode; mode = $(if ($mode) { $mode } else { '' }); probe = 3; stamp = $stamp }
    try {
        Ensure-Dir $EtcDir
        Set-Content -Path $cacheFile -Value ($cache | ConvertTo-Json -Depth 4) -Encoding ASCII
    } catch { }

    $script:OpcacheSupport[$Version] = $mode
    return $mode
}

function Test-PhpOpcacheSupport {
    param([string]$Version)
    return [bool](Get-PhpOpcacheMode -Version $Version)
}
function Set-PhpOpcacheSupport {
    # Records the probe result so the next php.ini keeps opcache off.
    param([string]$Version, [bool]$Supported)

    if (-not $script:OpcacheSupport) { $script:OpcacheSupport = @{} }
    $script:OpcacheSupport[$Version] = $Supported

    $cacheFile = Join-Path $EtcDir 'php-runtime.json'
    $cache = [ordered]@{}
    if (Test-Path $cacheFile) {
        try {
            $raw = Get-Content -Path $cacheFile -Raw -ErrorAction Stop
            if ($raw.Trim()) {
                $loaded = $raw | ConvertFrom-Json -ErrorAction Stop
                foreach ($property in $loaded.PSObject.Properties) {
                    $cache[$property.Name] = $property.Value
                }
            }
        } catch { }
    }

    $cgi = Join-Path (Join-Path $PhpRoot $Version) 'php-cgi.exe'
    $stamp = 0
    if (Test-Path $cgi) { $stamp = (Get-Item $cgi).LastWriteTimeUtc.Ticks }
    $cache[$Version] = [pscustomobject]@{ ok = $Supported; mode = $(if ($Supported) { 'shm' } else { '' }); probe = 3; stamp = $stamp }

    try {
        Ensure-Dir $EtcDir
        Set-Content -Path $cacheFile -Value ($cache | ConvertTo-Json -Depth 4) -Encoding ASCII
    } catch { }
}

function Write-PhpIni {
    param([string]$Version)

    $dir = Join-Path $PhpRoot $Version
    if (-not (Test-Path (Join-Path $dir 'php.exe'))) { return }

    $rootFwd = $Root -replace '\\', '/'
    $dirFwd = $dir -replace '\\', '/'
    $extDir = Join-Path $dir 'ext'
    $session = Join-Path $SessionDir $Version
    Ensure-Dir $session
    $sessionFwd = $session -replace '\\', '/'

    if (Get-Command Get-ExtensionMap -ErrorAction SilentlyContinue) {
        $extensionMap = Get-ExtensionMap -Version $Version
        $extensions = @($extensionMap.Keys | Where-Object { $extensionMap[$_] } | Sort-Object)
    } else {
        $extensions = @(
            'curl', 'fileinfo', 'gd', 'intl', 'mbstring', 'exif', 'mysqli',
            'openssl', 'pdo_mysql', 'pdo_sqlite', 'sqlite3', 'zip', 'sodium', 'xsl'
        )
    }
    $extLines = foreach ($name in $extensions) {
        if ($name -eq 'opcache') { continue }
        if (Test-Path (Join-Path $extDir "php_$name.dll")) { "extension=$name" }
    }

    $zendLines = @()
    $opcacheEnabled = $true
    if (Get-Command Get-ExtensionMap -ErrorAction SilentlyContinue) {
        $opcacheEnabled = ((Get-ExtensionMap -Version $Version)['opcache'] -eq $true)
    }
    if ($opcacheEnabled -and (Test-Path (Join-Path $extDir 'php_opcache.dll'))) {
        $opcacheMode = Get-PhpOpcacheMode -Version $Version
        if ($opcacheMode) {
            $zendLines += @(
                'zend_extension=opcache'
                'opcache.enable=1'
                'opcache.enable_cli=0'
                'opcache.memory_consumption=128'
                'opcache.interned_strings_buffer=16'
                'opcache.max_accelerated_files=20000'
                'opcache.revalidate_freq=0'
                'opcache.validate_timestamps=1'
            )
            if ($opcacheMode -eq 'file') {
                # Shared memory opcache dies on this build (ASLR); the file
                # cache keeps compiled scripts on disk instead.
                $fileCacheDir = Join-Path $TmpDir "opcache-files\$Version"
                Ensure-Dir $fileCacheDir
                $fileCacheFwd = $fileCacheDir -replace '\\', '/'
                $zendLines += @(
                    "opcache.file_cache=`"$fileCacheFwd`""
                    'opcache.file_cache_fallback=1'
                )
            }
        } else {
            # This build crashes when opcache starts, even with the file
            # cache, so leave it off instead of taking the whole worker down.
            $zendLines += @(
                ';opcache is disabled: this PHP build fails to start with it'
            )
        }
    }
    $caFile = Join-Path $EtcDir 'cacert.pem'
    $caLines = @()
    if (Test-Path $caFile) {
        $caLines += @(
            "curl.cainfo = `"$rootFwd/etc/cacert.pem`""
            "openssl.cafile = `"$rootFwd/etc/cacert.pem`""
        )
    }

    # Keep PHP temp files outside the project folder: Composer's write test can
    # fail while antivirus/cloud sync briefly locks files inside Documents.
    $sysTemp = Join-Path $env:LOCALAPPDATA 'WampDeck\tmp'
    if (-not $env:LOCALAPPDATA) { $sysTemp = Join-Path $Root 'tmp' }
    Ensure-Dir $sysTemp
    $sysTempFwd = $sysTemp -replace '\\', '/'

    $ini = @"
[PHP]
engine = On
short_open_tag = Off
precision = 14
output_buffering = 4096
zlib.output_compression = Off
implicit_flush = Off
serialize_precision = -1
max_execution_time = 36000
max_input_time = 36000
max_input_vars = 10000
memory_limit = 512M
error_reporting = E_ALL
display_errors = On
display_startup_errors = On
log_errors = On
error_log = "$rootFwd/logs/php-$Version-error.log"
post_max_size = 2G
upload_max_filesize = 2G
max_file_uploads = 50
default_socket_timeout = 60
default_charset = "UTF-8"
date.timezone = "Asia/Kolkata"
expose_php = Off
cgi.fix_pathinfo = 1
cgi.force_redirect = 0
fastcgi.impersonate = 1
extension_dir = "$dirFwd/ext"
sys_temp_dir = "$sysTempFwd"
upload_tmp_dir = "$rootFwd/tmp"
session.save_path = "$sessionFwd"
mysqli.default_port = $MysqlPort
SMTP = 127.0.0.1
smtp_port = 1025
sendmail_from = "dev@wampdeck.test"
mail.add_x_header = On

$($extLines -join "`r`n")

$($zendLines -join "`r`n")

$($caLines -join "`r`n")
"@

    Set-Content -Path (Join-Path $dir 'php.ini') -Value $ini -Encoding ASCII
}

function Write-MyIni {
    $mysqlFwd = $MysqlDir -replace '\\', '/'
    $dataFwd = $MysqlData -replace '\\', '/'
    $logFwd = $LogDir -replace '\\', '/'
    $tmpFwd = $TmpDir -replace '\\', '/'

    $isMaria = Test-Path (Join-Path $MysqlDir 'bin\mariadb-install-db.exe')
    $collation = if ($isMaria) { 'utf8mb4_unicode_ci' } else { 'utf8mb4_0900_ai_ci' }
    $extra = if ($isMaria) { '' } else { 'mysqlx=0' }

    $ini = @"
[client]
port=$MysqlPort
host=127.0.0.1
default-character-set=utf8mb4

[mysql]
default-character-set=utf8mb4

[mysqld]
basedir="$mysqlFwd"
datadir="$dataFwd"
port=$MysqlPort
bind-address=127.0.0.1
pid-file="$logFwd/mysql.pid"
log-error="$logFwd/mysql-error.log"
tmpdir="$tmpFwd"
character-set-server=utf8mb4
collation-server=$collation
default-storage-engine=InnoDB
max_connections=100
max_allowed_packet=256M
innodb_buffer_pool_size=256M
secure-file-priv=""
$extra
skip-log-bin
"@

    Set-Content -Path $MyIni -Value $ini -Encoding ASCII
}

function Write-RedisConf {
    Ensure-Dir (Join-Path $DataDir 'redis')
    $dataFwd = (Join-Path $DataDir 'redis') -replace '\\', '/'
    $logFwd = (Join-Path $LogDir 'redis.log') -replace '\\', '/'
    $conf = @"
bind 127.0.0.1
protected-mode yes
port 6379
dir "$dataFwd"
dbfilename dump.rdb
save ""
appendonly no
logfile "$logFwd"
"@
    Set-Content -Path $RedisConf -Value $conf -Encoding ASCII
}

function Get-PhpUpstreamName {
    param([string]$Version)
    return ('php_backend_' + ($Version -replace '[^0-9a-zA-Z]', '_'))
}

function Add-NginxServer {
    param(
        [System.Collections.Generic.List[string]]$Lines,
        [string]$Comment,
        [string]$Listen,
        [string]$ServerNames,
        [string]$RootPath,
        [string]$Upstream,
        [System.Collections.IDictionary]$EnvMap = @{},
        [string]$Cert = '',
        [string]$Key = ''
    )
    $rootFwd = $RootPath -replace '\\', '/'
    $Lines.Add("    # $Comment")
    $Lines.Add('    server {')
    $Lines.Add("        listen       $Listen;")
    $Lines.Add("        server_name  $ServerNames;")
    $Lines.Add("        root         `"$rootFwd`";")
    $Lines.Add('        index        index.php index.html;')
    $Lines.Add('')
    if ($Cert) {
        $Lines.Add("        ssl_certificate     `"$Cert`";")
        $Lines.Add("        ssl_certificate_key `"$Key`";")
        $Lines.Add('        ssl_protocols       TLSv1.2 TLSv1.3;')
        $Lines.Add('        ssl_session_cache   shared:SSL:10m;')
        $Lines.Add('')
    }
    $Lines.Add('        location / {')
    $Lines.Add('            try_files $uri $uri/ /index.php?$query_string;')
    $Lines.Add('        }')
    $Lines.Add('')
    $Lines.Add('        location ~ \.php$ {')
    $Lines.Add('            try_files $uri =404;')
    $Lines.Add('            include ../bin/nginx/conf/fastcgi.conf;')
    $Lines.Add("            fastcgi_pass $Upstream;")
    $Lines.Add('            fastcgi_read_timeout 36000s;')
    if ($EnvMap) {
        foreach ($key in $EnvMap.Keys) {
            $value = ([string]$EnvMap[$key]) -replace '[\r\n;]', ''
            $Lines.Add("            fastcgi_param $key `"$value`";")
        }
    }
    $Lines.Add('        }')
    $Lines.Add('')
    $Lines.Add('        location ~ /\.(?!well-known) { deny all; }')
    $Lines.Add('    }')
    $Lines.Add('')
}

function Write-NginxConf {
    $lines = New-Object System.Collections.Generic.List[string]

    $lines.Add('worker_processes  1;')
    $lines.Add('pid logs/nginx.pid;')
    $lines.Add('error_log logs/nginx-error.log warn;')
    $lines.Add('')
    $lines.Add('events {')
    $lines.Add('    worker_connections  1024;')
    $lines.Add('}')
    $lines.Add('')
    $lines.Add('http {')
    $lines.Add('    include       ../bin/nginx/conf/mime.types;')
    $lines.Add('    default_type  application/octet-stream;')
    $lines.Add('')
    $lines.Add('    log_format  main  ''$remote_addr - $remote_user [$time_local] "$request" ''')
    $lines.Add('                      ''$status $body_bytes_sent "$http_referer" ''')
    $lines.Add('                      ''"$http_user_agent"'';')
    $lines.Add('    access_log  logs/nginx-access.log main;')
    $lines.Add('')
    $lines.Add('    sendfile        on;')
    $lines.Add('    keepalive_timeout  65;')
    $lines.Add('    server_tokens off;')
    $lines.Add('    client_max_body_size 2048m;')
    $lines.Add('    server_names_hash_bucket_size 64;')
    $lines.Add('    server_names_hash_max_size 512;')
    $lines.Add('')
    $lines.Add('    client_body_temp_path tmp/nginx/client_body;')
    $lines.Add('    proxy_temp_path       tmp/nginx/proxy;')
    $lines.Add('    fastcgi_temp_path     tmp/nginx/fastcgi;')
    $lines.Add('    uwsgi_temp_path       tmp/nginx/uwsgi;')
    $lines.Add('    scgi_temp_path        tmp/nginx/scgi;')
    $lines.Add('')

    # One upstream per installed PHP version, so two projects can run
    # different versions at the same time.
    foreach ($version in $PhpVersions) {
        $ports = @($PhpPoolPorts[$version])
        if ($ports.Count -eq 0) { continue }
        $lines.Add("    # PHP $version")
        $lines.Add("    upstream $(Get-PhpUpstreamName $version) {")
        foreach ($port in $ports) {
            $lines.Add("        server 127.0.0.1:$port max_fails=2 fail_timeout=10s;")
        }
        $lines.Add('    }')
        $lines.Add('')
    }

    # Legacy name kept for hand-written configs and older projects.
    $lines.Add('    upstream php_backend {')
    foreach ($port in $PhpPorts) {
        $lines.Add("        server 127.0.0.1:$port max_fails=2 fail_timeout=10s;")
    }
    $lines.Add('    }')
    $lines.Add('')

    $panelRoot = Join-Path $WwwDir 'panel'
    $defaultUpstream = Get-PhpUpstreamName $State.phpVersion
    $cert = $SslCert -replace '\\', '/'
    $key = $SslKey -replace '\\', '/'

    Add-NginxServer -Lines $lines -Comment 'Panel' `
        -Listen "${BindAddr}:${HttpPort} default_server" `
        -ServerNames 'localhost 127.0.0.1 _' `
        -RootPath $panelRoot -Upstream $defaultUpstream

    if ($State.ssl) {
        Add-NginxServer -Lines $lines -Comment 'Panel (https)' `
            -Listen "${BindAddr}:${HttpsPort} ssl default_server" `
            -ServerNames 'localhost 127.0.0.1 _' `
            -RootPath $panelRoot -Upstream $defaultUpstream `
            -Cert $cert -Key $key
    }

    foreach ($project in @(Get-ProjectList)) {
        $upstream = Get-PhpUpstreamName $project.PhpVersion
        $names = (@("$($project.Name).localhost", "$($project.Name).test") + @($project.Hosts)) |
            Select-Object -Unique
        Add-NginxServer -Lines $lines -Comment "Project: $($project.Name) [PHP $($project.PhpVersion)]" `
            -Listen "${BindAddr}:${HttpPort}" `
            -ServerNames ($names -join ' ') `
            -RootPath $project.DocumentRoot -Upstream $upstream `
            -EnvMap $project.Env

        if ($State.ssl) {
            Add-NginxServer -Lines $lines -Comment "Project (https): $($project.Name)" `
                -Listen "${BindAddr}:${HttpsPort} ssl" `
                -ServerNames ($names -join ' ') `
                -RootPath $project.DocumentRoot -Upstream $upstream `
                -EnvMap $project.Env -Cert $cert -Key $key
        }
    }

    $lines.Add('}')

    Set-Content -Path $NginxConf -Value ($lines -join "`r`n") -Encoding ASCII
}
function Write-ApacheModPhp {
    $phpFwd = $PhpDir -replace '\\', '/'
    $lines = New-Object System.Collections.Generic.List[string]
    foreach ($dll in @('libcrypto-3-x64.dll', 'libssl-3-x64.dll')) {
        if (Test-Path (Join-Path $PhpDir $dll)) {
            $lines.Add("LoadFile `"$phpFwd/$dll`"")
        }
    }
    $lines.Add("LoadModule php_module `"$phpFwd/php8apache2_4.dll`"")
    $lines.Add("PHPIniDir `"$phpFwd`"")
    $lines.Add('<IfModule mime_module>')
    $lines.Add('    AddType application/x-httpd-php .php')
    $lines.Add('</IfModule>')
    Set-Content -Path $ApacheModPhpConf -Value ($lines -join "`r`n") -Encoding ASCII
}

function Write-ApacheFcgid {
    if (-not (Test-Path $ApacheFcgidDll)) { return $false }

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add('LoadModule fcgid_module modules/mod_fcgid.so')
    $lines.Add('')
    $lines.Add('<IfModule fcgid_module>')
    $lines.Add('    FcgidInitialEnv PHP_FCGI_MAX_REQUESTS 10000')
    $lines.Add('    FcgidMaxRequestLen 2147483648')
    $lines.Add('    FcgidIOTimeout 600')
    $lines.Add('    FcgidBusyTimeout 600')
    $lines.Add('    FcgidIdleTimeout 600')
    $lines.Add('    AddHandler fcgid-script .php')
    $lines.Add('</IfModule>')
    Set-Content -Path $ApacheFcgidConf -Value ($lines -join "`r`n") -Encoding ASCII
    return $true
}

function Get-WindowsShortPath {
    # mod_fcgid on Windows splits the wrapper path on spaces even when it is
    # quoted, so a "Default Project"-style install path needs the 8.3 name.
    param([string]$Path)
    if (-not $Path -or $Path -notmatch '\s') { return $Path }
    if (-not $script:ShortPathCache) { $script:ShortPathCache = @{} }
    if ($script:ShortPathCache.ContainsKey($Path)) { return $script:ShortPathCache[$Path] }
    $result = $Path
    try {
        $fso = New-Object -ComObject Scripting.FileSystemObject
        $short = $fso.GetFile($Path).ShortPath
        if ($short -and $short -notmatch '\s') { $result = $short }
    } catch { }
    $script:ShortPathCache[$Path] = $result
    return $result
}
function Add-ApacheVhost {
    param(
        [System.Collections.Generic.List[string]]$Lines,
        [int]$Port,
        [string]$ServerName,
        [string]$ServerAlias,
        [string]$RootPath,
        [string]$PhpVersion,
        [System.Collections.IDictionary]$EnvMap = @{},
        [switch]$Ssl,
        [string]$Cert = '',
        [string]$Key = ''
    )
    $rootFwd = $RootPath -replace '\\', '/'
    $phpDir = (Join-Path $PhpRoot $PhpVersion) -replace '\\', '/'
$phpCgi = (Get-WindowsShortPath (Join-Path $PhpRoot "$PhpVersion\php-cgi.exe")) -replace '\\', '/'

    $Lines.Add("<VirtualHost *:$Port>")
    $Lines.Add("    ServerName $ServerName")
    if ($ServerAlias) { $Lines.Add("    ServerAlias $ServerAlias") }
    $Lines.Add("    DocumentRoot `"$rootFwd`"")
    $Lines.Add('    DirectoryIndex index.php index.html')
    if ($Ssl) {
        $Lines.Add('    SSLEngine on')
        $Lines.Add("    SSLCertificateFile `"$Cert`"")
        $Lines.Add("    SSLCertificateKeyFile `"$Key`"")
    }
    $Lines.Add("    <Directory `"$rootFwd`">")
    $Lines.Add('        Options +ExecCGI -Indexes')
    $Lines.Add('        AllowOverride All')
    $Lines.Add('        Require all granted')
    $Lines.Add('    </Directory>')

    if ($State.apachePhpMode -eq 'fcgid') {
        $Lines.Add("    FcgidInitialEnv PHPRC `"$phpDir`"")
        if ($EnvMap) {
            foreach ($envKey in $EnvMap.Keys) {
                $envValue = ([string]$EnvMap[$envKey]) -replace '[\r\n"]', ''
                $Lines.Add("    FcgidInitialEnv $envKey `"$envValue`"")
            }
        }
        $Lines.Add("    FcgidWrapper `"$phpCgi`" .php")
    } else {
        $Lines.Add('# per-project PHP needs apachePhpMode=fcgid; running the stack default')
    }

    $Lines.Add('</VirtualHost>')
}

function Write-ApacheVhosts {
    Ensure-Dir $ApacheVhostsDir
    Get-ChildItem $ApacheVhostsDir -Filter '*.conf' -ErrorAction SilentlyContinue | Remove-Item -Force

    $panelRoot = Join-Path $WwwDir 'panel'
    $cert = $SslCert -replace '\\', '/'
    $key = $SslKey -replace '\\', '/'
    $defaultPhp = $State.phpVersion

    $panelLines = New-Object System.Collections.Generic.List[string]
    Add-ApacheVhost -Lines $panelLines -Port $HttpPort `
        -ServerName 'localhost' -ServerAlias '127.0.0.1' `
        -RootPath $panelRoot -PhpVersion $defaultPhp
    if ($State.ssl) {
        $panelLines.Add('')
        Add-ApacheVhost -Lines $panelLines -Port $HttpsPort `
            -ServerName 'localhost' -ServerAlias '127.0.0.1' `
            -RootPath $panelRoot -PhpVersion $defaultPhp `
            -Ssl -Cert $cert -Key $key
    }
    Set-Content -Path (Join-Path $ApacheVhostsDir '00-panel.conf') `
        -Value ($panelLines -join "`r`n") -Encoding ASCII

    foreach ($project in @(Get-ProjectList)) {
        $file = Join-Path $ApacheVhostsDir ("auto-$($project.Name).conf")
        $lines = New-Object System.Collections.Generic.List[string]
        $alias = (@("$($project.Name).localhost", "*.$($project.Name).test") + @($project.Hosts)) |
            Select-Object -Unique

        Add-ApacheVhost -Lines $lines -Port $HttpPort `
            -ServerName "$($project.Name).test" -ServerAlias ($alias -join ' ') `
            -RootPath $project.DocumentRoot -PhpVersion $project.PhpVersion `
            -EnvMap $project.Env

        if ($State.ssl) {
            $lines.Add('')
            Add-ApacheVhost -Lines $lines -Port $HttpsPort `
                -ServerName "$($project.Name).test" -ServerAlias ($alias -join ' ') `
                -RootPath $project.DocumentRoot -PhpVersion $project.PhpVersion `
                -EnvMap $project.Env -Ssl -Cert $cert -Key $key
        }

        Set-Content -Path $file -Value ($lines -join "`r`n") -Encoding ASCII
    }
}
function Write-ApacheConf {
    $template = Join-Path $ApacheDir 'conf\httpd.conf'
    if (-not (Test-Path $template)) { return }

    $apacheFwd = $ApacheDir -replace '\\', '/'
    $wwwFwd = $WwwDir -replace '\\', '/'
    $logFwd = $LogDir -replace '\\', '/'
    $etcFwd = $ApacheEtcDir -replace '\\', '/'

    $content = Get-Content -Path $template -Raw

    $content = $content.Replace('Define SRVROOT "C:/Apache24"', "Define SRVROOT `"$apacheFwd`"")
    $content = $content.Replace('ServerRoot "C:/laragon/bin/apache/httpd-2.4.66-260223-Win64-VS18"', "ServerRoot `"$apacheFwd`"")
    $content = $content -replace '(?m)^Listen\s+80\s*$', "Listen ${BindAddr}:${HttpPort}"
    $content = $content -replace '(?m)^Listen\s+443\s*$', "Listen ${BindAddr}:${HttpsPort}"
    $content = $content.Replace('ServerName Laragon', "ServerName localhost")
    $content = $content.Replace('DocumentRoot "C:/laragon/www"', "DocumentRoot `"$wwwFwd`"")
    $content = $content.Replace('<Directory "C:/laragon/www">', "<Directory `"$wwwFwd`">")
    $content = $content -replace '(?m)^ErrorLog\s+"logs/error_log"\s*$', "ErrorLog `"$logFwd/apache-error.log`""
    $content = $content -replace '(?m)^(\s*)CustomLog\s+"logs/access_log"\s+common\s*$', "`$1CustomLog `"$logFwd/apache-access.log`" common"
    $content = $content.Replace('DirectoryIndex index.html index.php', 'DirectoryIndex index.php index.html')
    $content = $content.Replace('ServerTokens OS', 'ServerTokens Prod')

    # Allow .htaccess in the document root (and only there).
    $directoryPattern = '(?s)(<Directory\s+"' + [regex]::Escape($wwwFwd) + '">.*?</Directory>)'
    $content = [regex]::Replace($content, $directoryPattern, {
        param($match)
        $match.Value -replace '(?m)^(\s*)AllowOverride\s+None\s*$', '$1AllowOverride All'
    })

    $content = $content -replace '(?m)^IncludeOptional\s+"C:/laragon/etc/apache2/alias/\*\.conf"\s*$', ''
    $content = $content -replace '(?m)^IncludeOptional\s+"C:/laragon/etc/apache2/sites-enabled/\*\.conf"\s*$', ''
    $content = $content -replace '(?m)^Include\s+"C:/laragon/etc/apache2/httpd-ssl\.conf"\s*$', ''
    $content = $content -replace '(?m)^Include\s+"C:/laragon/etc/apache2/mod_php\.conf"\s*$', ''

    if ($State.ssl) {
        $content = $content.Replace(
            "Listen ${BindAddr}:${HttpPort}",
            "Listen ${BindAddr}:${HttpPort}`r`nListen ${BindAddr}:${HttpsPort}"
        )
    }

    if ($content -notmatch '(?m)^PidFile\s+') {
        $content = $content.Replace("ServerRoot `"$apacheFwd`"", "ServerRoot `"$apacheFwd`"`r`nPidFile `"$logFwd/apache.pid`"")
    }

    if ($content -notmatch '(?m)^<Directory\s+"') {
        $content += "`r`n<Directory `"$wwwFwd`">`r`n    Options Indexes FollowSymLinks`r`n    AllowOverride All`r`n    Require all granted`r`n</Directory>`r`n"
    }

    $phpModuleConf = 'mod_php.conf'
    if ($State.apachePhpMode -eq 'fcgid' -and (Test-Path $ApacheFcgidConf)) { $phpModuleConf = 'mod_fcgid.conf' }
    $content += "`r`nIncludeOptional `"$etcFwd/sites-enabled/*.conf`"`r`nInclude `"$etcFwd/$phpModuleConf`"`r`n"

    Set-Content -Path $ApacheMainConf -Value $content -Encoding ASCII
}

function Write-AllConfigs {
    foreach ($dir in @(
            $EtcDir, $LogDir, $TmpDir, $DataDir, $SessionDir, $PidDir,
            $ApacheEtcDir, $ApacheVhostsDir, (Join-Path $EtcDir 'ssl'),
            (Join-Path $TmpDir 'nginx'), (Join-Path $TmpDir 'nginx\client_body'),
            (Join-Path $TmpDir 'nginx\proxy'), (Join-Path $TmpDir 'nginx\fastcgi'),
            (Join-Path $TmpDir 'nginx\uwsgi'), (Join-Path $TmpDir 'nginx\scgi'),
            (Join-Path $DataDir 'redis'), (Join-Path $DataDir 'mailpit')
        )) {
        Ensure-Dir $dir
    }

    foreach ($version in $PhpVersions) { Write-PhpIni -Version $version }
    Write-MyIni
    Write-RedisConf
    Write-NginxConf
    Write-ApacheModPhp
    Write-ApacheFcgid | Out-Null
    Write-ApacheVhosts
    Write-ApacheConf
    Save-StackState
}
