# MySQL helper: shell, list, create, drop, import, export.
#
#   .\db.cmd                              interactive shell
#   .\db.cmd -List
#   .\db.cmd -Create myapp_db
#   .\db.cmd -Database myapp_db -Query "SHOW TABLES;"
#   .\db.cmd -Database myapp_db -Import dump.sql
#   .\db.cmd -Database myapp_db -Export dump.sql

param(
    [string]$Query,
    [switch]$List,
    [string]$Create,
    [string]$Drop,
    [string]$Import,
    [string]$Export,
    [string]$Database,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot '..\lib\bootstrap.ps1')

if (-not (Test-TcpPort -Port $MysqlPort)) {
    Write-Err 'Database is not running. Run .\start.cmd first.'
    exit 1
}

$tick = [char]96
$baseArgs = @("--defaults-file=$MyIni", '-u', 'root')

if ($List) {
    & $MysqlCli @baseArgs --table -e 'SHOW DATABASES;'
    exit 0
}

if ($Create) {
    $output = & $MysqlCli @baseArgs -e "CREATE DATABASE IF NOT EXISTS $tick$Create$tick CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>&1
    if ($LASTEXITCODE -ne 0) { Write-Err ($output -join [Environment]::NewLine); exit 1 }
    Write-Ok "database '$Create' ready"
    exit 0
}

if ($Drop) {
    if (-not $Force) {
        Write-Err "Refusing to drop '$Drop' without -Force."
        exit 1
    }
    $output = & $MysqlCli @baseArgs -e "DROP DATABASE IF EXISTS $tick$Drop$tick;" 2>&1
    if ($LASTEXITCODE -ne 0) { Write-Err ($output -join [Environment]::NewLine); exit 1 }
    Write-Ok "database '$Drop' dropped"
    exit 0
}

if (-not $Database -and ($Import -or $Export)) {
    Write-Err 'Use -Database <name> with -Import / -Export.'
    exit 1
}

if ($Import) {
    $path = (Resolve-Path $Import).Path -replace '\\', '/'
    $output = & $MysqlCli @baseArgs $Database -e "source $path" 2>&1
    if ($LASTEXITCODE -ne 0) { Write-Err ($output -join [Environment]::NewLine); exit 1 }
    Write-Ok "imported $Import into $Database"
    exit 0
}

if ($Export) {
    $dump = Join-Path $MysqlDir 'bin\mysqldump.exe'
    if (-not (Test-Path $dump)) { Write-Err 'mysqldump.exe not found.'; exit 1 }
    $target = [System.IO.Path]::GetFullPath($Export)
    Ensure-Dir (Split-Path -Parent $target)
    & $dump @baseArgs --result-file="$target" $Database
    if ($LASTEXITCODE -ne 0) { Write-Err 'export failed'; exit 1 }
    Write-Ok "exported $Database to $target"
    exit 0
}

$shellArgs = @($baseArgs)
if ($Database) { $shellArgs += $Database }
if ($Query) {
    & $MysqlCli @shellArgs --table -e $Query
} else {
    Write-Step 'MySQL shell - type exit to leave (user: root, password: empty)'
    & $MysqlCli @shellArgs
}
