# WampDeck v2 configuration and state.
# Every script dot-sources this file, then lib\common.ps1.

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$WampDeckVersion = '2.0.0'

$BinDir      = Join-Path $Root 'bin'
$EtcDir      = Join-Path $Root 'etc'
$LogDir      = Join-Path $Root 'logs'
$TmpDir      = Join-Path $Root 'tmp'
$DataDir     = Join-Path $Root 'data'
$WwwDir      = Join-Path $Root 'www'
$DownloadDir = Join-Path $TmpDir 'downloads'
$PidDir      = Join-Path $LogDir 'pids'
$SessionDir  = Join-Path $TmpDir 'sessions'

$StateFile = Join-Path $EtcDir 'stack.json'

$DefaultState = [ordered]@{
    webServer  = 'nginx'
    phpVersion = '8.3.30'
    language   = 'en'
    layout     = 'ltr'
    languageSelected = $false
    httpPort   = 80
    httpsPort  = 443
    bind       = '127.0.0.1'
    mysqlPort  = 3306
    phpWorkers = 4
    ssl        = $false
    autoStart  = $false
    closeToTray = $true
    mailpit    = $false
    apachePhpMode = 'fcgid'
    redis      = $false
    memcached  = $false
}

$State = [ordered]@{}
foreach ($key in $DefaultState.Keys) { $State[$key] = $DefaultState[$key] }


if (Test-Path $StateFile) {
    try {
        $loaded = Get-Content $StateFile -Raw | ConvertFrom-Json
        foreach ($property in $loaded.PSObject.Properties) {
            if ($State.Contains($property.Name)) { $State[$property.Name] = $property.Value }
        }
    } catch { }
}

# Language chosen in the installer wizard (Inno Setup writes this file).
# Applied after stack.json so the installer choice wins on upgrade too.
$installerLanguageFile = Join-Path $EtcDir 'language.txt'
if (Test-Path $installerLanguageFile) {
    $chosen = ([IO.File]::ReadAllText($installerLanguageFile)).Trim()
    if ($chosen) {
        $State['language'] = $chosen
        $State['layout'] = if ($chosen -eq 'ar') { 'rtl' } else { 'ltr' }
        $State['languageSelected'] = $true
    }
}
# ---------------------------------------------------------------- versions
$PhpRoot = Join-Path $BinDir 'php'
$PhpVersions = @(
    Get-ChildItem $PhpRoot -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match '^\d+\.\d+\.\d+$' } |
        Sort-Object Name -Descending |
        Select-Object -ExpandProperty Name
)
if ($PhpVersions.Count -eq 0) { $PhpVersions = @('8.3.30') }
if ($PhpVersions -notcontains $State.phpVersion) { $State.phpVersion = $PhpVersions[0] }

$PhpDir = Join-Path $PhpRoot $State.phpVersion
$PhpExe = Join-Path $PhpDir 'php.exe'
$PhpCgi = Join-Path $PhpDir 'php-cgi.exe'
$PhpIni = Join-Path $PhpDir 'php.ini'

$MysqlDir   = Join-Path $BinDir 'mysql'
$Mysqld     = Join-Path $MysqlDir 'bin\mysqld.exe'
$MysqlCli   = Join-Path $MysqlDir 'bin\mysql.exe'
$MysqlAdmin = Join-Path $MysqlDir 'bin\mysqladmin.exe'
$MysqlDump  = Join-Path $MysqlDir 'bin\mysqldump.exe'
$MysqlData  = Join-Path $DataDir 'mysql'

# ---------------------------------------------------------------- web servers
$NginxDir  = Join-Path $BinDir 'nginx'
$NginxExe  = Join-Path $NginxDir 'nginx.exe'
$NginxConf = Join-Path $EtcDir 'nginx.conf'

$ApacheDir       = Join-Path $BinDir 'apache'
$ApacheExe       = Join-Path $ApacheDir 'bin\httpd.exe'
$ApacheEtcDir    = Join-Path $EtcDir 'apache'
$ApacheVhostsDir = Join-Path $ApacheEtcDir 'sites-enabled'
$ApacheMainConf  = Join-Path $ApacheEtcDir 'httpd.conf'
$ApacheModPhpConf = Join-Path $ApacheEtcDir 'mod_php.conf'
$ApacheFcgidConf  = Join-Path $ApacheEtcDir 'mod_fcgid.conf'
$ApacheFcgidDll   = Join-Path $ApacheDir 'modules\mod_fcgid.so'

$MyIni     = Join-Path $EtcDir 'my.ini'
$RedisConf = Join-Path $EtcDir 'redis.conf'

# ---------------------------------------------------------------- ssl
$SslDir    = Join-Path $EtcDir 'ssl'
$SslCert   = Join-Path $SslDir 'server.crt'
$SslKey    = Join-Path $SslDir 'server.key'
$SslCaCert = Join-Path $SslDir 'ca.crt'
$SslCaKey  = Join-Path $SslDir 'ca.key'

# ---------------------------------------------------------------- tools
$NodeExe      = Join-Path $BinDir 'nodejs\node.exe'
$NpmCmd       = Join-Path $BinDir 'nodejs\npm.cmd'
$PythonExe    = Join-Path $BinDir 'python\python.exe'
$GitExe       = Join-Path $BinDir 'git\cmd\git.exe'
$GitBash      = Join-Path $BinDir 'git\bin\bash.exe'
$ComposerBat  = Join-Path $BinDir 'composer\composer.bat'
$ComposerPhar = Join-Path $BinDir 'composer\composer.phar'
$HeidiExe     = Join-Path $BinDir 'heidisql\heidisql.exe'
$MailpitExe   = Join-Path $BinDir 'mailpit\mailpit.exe'
$RedisExe     = Join-Path $BinDir 'redis\redis-server.exe'
$RedisCli     = Join-Path $BinDir 'redis\redis-cli.exe'
$MemcachedExe = Join-Path $BinDir 'memcached\memcached.exe'
$NgrokExe     = Join-Path $BinDir 'ngrok\ngrok.exe'
$CmderExe     = Join-Path $BinDir 'cmder\Cmder.exe'
$NotepadExe   = Join-Path $BinDir 'notepad++\notepad++.exe'
$CronicalExe  = Join-Path $BinDir 'cronical\Cronical.exe'

$OpenSslExe = Join-Path $BinDir 'git\usr\bin\openssl.exe'
if (-not (Test-Path $OpenSslExe)) { $OpenSslExe = (Get-Command openssl.exe -ErrorAction SilentlyContinue).Source }
$CertUtil = Join-Path $env:SystemRoot 'System32\certutil.exe'

# ---------------------------------------------------------------- runtime
$HttpPort  = [int]$State.httpPort
$HttpsPort = [int]$State.httpsPort
$BindAddr  = [string]$State.bind
$MysqlPort = [int]$State.mysqlPort
$WebServer = [string]$State.webServer

# Each installed PHP version gets its own block of FastCGI ports, so two
# projects can run different versions at the same time. Versions are sorted
# newest first, so the default version keeps the 9000 block and existing
# configs stay valid after an upgrade.
$PhpPortBlockSize = 10
$PhpPoolPorts = [ordered]@{}
$poolIndex = 0
foreach ($version in $PhpVersions) {
    $base = 9000 + ($poolIndex * $PhpPortBlockSize)
    $ports = @()
    for ($i = 0; $i -lt [int]$State.phpWorkers; $i++) { $ports += ($base + $i) }
    $PhpPoolPorts[$version] = $ports
    $poolIndex++
}
$PhpPorts = @($PhpPoolPorts[$State.phpVersion])
if ($PhpPorts.Count -eq 0) { $PhpPorts = @(9000) }

$Prefix = ($Root -replace '\\', '/') + '/'

if ($HttpPort -eq 80) { $PanelUrl = 'http://localhost' }
else { $PanelUrl = "http://localhost:$HttpPort" }

if ($HttpsPort -eq 443) { $PanelUrlHttps = 'https://localhost' }
else { $PanelUrlHttps = "https://localhost:$HttpsPort" }

$StartupDir = [Environment]::GetFolderPath('Startup')
$StartupShortcut = Join-Path $StartupDir 'WampDeck.lnk'
