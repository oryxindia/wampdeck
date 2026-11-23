# Database snapshots.
#
# A snapshot is a plain mysqldump file stored inside the project
# (snapshots\<date>-<label>.sql) so it travels with the folder and lands in an
# export bundle. The manifest remembers the newest one.

function Get-ProjectDatabaseName {
    param($Project)

    if ($Project.Manifest -and $Project.Manifest.Valid -and $Project.Manifest.Data.Database.Name) {
        return $Project.Manifest.Data.Database.Name
    }
    return ($Project.Name -replace '-', '_')
}

function Get-SnapshotDir {
    param($Project)
    return (Join-Path $Project.Folder 'snapshots')
}

function Get-DbSnapshotFiles {
    param($Project)

    $dir = Get-SnapshotDir $Project
    if (-not (Test-Path $dir)) { return @() }
    return @(Get-ChildItem -Path $dir -Filter '*.sql' -File -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending | ForEach-Object {
            [pscustomobject]@{
                Name    = $_.Name
                Path    = $_.FullName
                Size    = $_.Length
                SizeKb  = [math]::Round($_.Length / 1KB, 1)
                Created = $_.LastWriteTime
            }
        })
}

function Set-ManifestDatabaseSnapshot {
    param(
        [string]$ProjectDir,
        [string]$RelativePath,
        [string]$DatabaseName = ''
    )

    $path = Get-ManifestPath $ProjectDir
    $data = [ordered]@{}
    if (Test-Path $path) {
        try {
            $json = Get-Content -Path $path -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
            foreach ($property in $json.PSObject.Properties) {
                $data[$property.Name] = $property.Value
            }
        } catch {
            return $false
        }
    } else {
        $data['schema'] = $ManifestSchema
        $data['name'] = (Split-Path -Leaf $ProjectDir)
        $data['php'] = 'any'
        $data['web'] = 'any'
    }

    $db = [ordered]@{}
    if ($data.Contains('database') -and $data['database']) {
        foreach ($property in $data['database'].PSObject.Properties) {
            $db[$property.Name] = $property.Value
        }
    }
    if ($DatabaseName) { $db['name'] = $DatabaseName }
    if ($RelativePath) { $db['snapshot'] = $RelativePath }
    $data['database'] = $db

    $json = $data | ConvertTo-Json -Depth 6
    Set-Content -Path $path -Value $json -Encoding UTF8
    return $true
}

function Export-DbDump {
    param(
        [string]$Database,
        [string]$Path,
        # Snapshots carry CREATE DATABASE/USE so a restore can recreate the
        # database. Bundles must not: they are imported into a fresh name.
        [switch]$TablesOnly
    )

    if (-not (Test-Path $MysqlDump)) { throw "mysqldump was not found at $MysqlDump." }
    if (-not (Test-TcpPort -Port $MysqlPort)) { throw 'MySQL is not running. Start the stack first.' }

    $dir = Split-Path -Parent $Path
    if ($dir) { Ensure-Dir $dir }

    $previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $dumpArgs = @(
            "--defaults-file=$MyIni", '-u', 'root',
            '--single-transaction', '--routines', '--events',
            '--default-character-set=utf8mb4'
        )
        if (-not $TablesOnly) { $dumpArgs += '--databases' }
        $dumpArgs += @($Database, "--result-file=$Path")
        $output = & $MysqlDump @dumpArgs 2>&1
        $code = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $previous
    }

    if ($code -ne 0) {
        throw "mysqldump failed for '$Database'.`n$(($output | Where-Object { $_ }) -join [Environment]::NewLine)"
    }
    if (-not (Test-Path $Path)) { throw "mysqldump did not write $Path." }

    $item = Get-Item $Path
    if ($item.Length -eq 0) { throw "mysqldump wrote an empty file for '$Database'." }
    return [pscustomobject]@{ Path = $item.FullName; Size = $item.Length; Database = $Database }
}

function Invoke-MysqlSqlFile {
    # Feeds a .sql file to the mysql client on stdin.
    #
    # Not "mysql -e 'SOURCE file'": the client only recognises SOURCE when it
    # starts a line, so "USE db; SOURCE file" is sent to the server and fails
    # silently. A redirect also keeps paths with spaces working, and stdin
    # bypasses PowerShell's text encoding so UTF-8 data survives.
    param(
        [string]$Path,
        [string]$Database = ''
    )

    if (-not $Path) { throw 'A .sql file is required.' }
    if (-not (Test-Path $Path)) { throw "SQL file not found: $Path" }
    if (-not (Test-Path $MysqlCli)) { throw "mysql client was not found at $MysqlCli." }
    if (-not (Test-TcpPort -Port $MysqlPort)) { throw 'MySQL is not running. Start the stack first.' }

    Ensure-Dir $TmpDir
    $errorFile = Join-Path $TmpDir ('mysql-' + [guid]::NewGuid().ToString('N').Substring(0, 8) + '.err')
    $argumentLine = "`"--defaults-file=$MyIni`" -u root"
    if ($Database) { $argumentLine += " $Database" }

    try {
        $process = Start-Process -FilePath $MysqlCli -ArgumentList $argumentLine `
            -RedirectStandardInput $Path -RedirectStandardError $errorFile `
            -WindowStyle Hidden -PassThru -Wait
        $message = ''
        if (Test-Path $errorFile) {
            $message = (Get-Content -Path $errorFile -Raw -ErrorAction SilentlyContinue)
        }
        if ($process.ExitCode -ne 0) {
            $detail = (@($message -split "`r?`n") | Where-Object { $_ }) -join [Environment]::NewLine
            throw "mysql could not import '$([IO.Path]::GetFileName($Path))'.`n$detail"
        }
        return $true
    } finally {
        Remove-Item $errorFile -Force -ErrorAction SilentlyContinue
    }
}

function Import-DbDump {
    param(
        [string]$Path,
        # Dumps made with -TablesOnly have no CREATE DATABASE/USE, so the
        # caller names the target database instead.
        [string]$Database = ''
    )

    return (Invoke-MysqlSqlFile -Path $Path -Database $Database)
}
function New-DbSnapshot {
    param(
        $Project,
        [string]$Label = '',
        [switch]$PassThru
    )

    $database = Get-ProjectDatabaseName -Project $Project
    $dir = Get-SnapshotDir $Project
    Ensure-Dir $dir

    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $safeLabel = ''
    if ($Label) {
        $safeLabel = '-' + (($Label -replace '[^A-Za-z0-9_-]', '-') -replace '-+', '-').Trim('-')
    }
    $fileName = "$stamp$safeLabel.sql"
    $path = Join-Path $dir $fileName

    $dump = Export-DbDump -Database $database -Path $path
    Set-ManifestDatabaseSnapshot -ProjectDir $Project.Folder -RelativePath "snapshots/$fileName" -DatabaseName $database | Out-Null

    $result = [pscustomobject]@{
        Project  = $Project.Name
        Database = $database
        Name     = $fileName
        Path     = $dump.Path
        Size     = $dump.Size
        SizeKb   = [math]::Round($dump.Size / 1KB, 1)
    }
    if ($PassThru) { return $result }
    return $result
}

function Restore-DbSnapshot {
    param(
        $Project,
        [string]$Path,
        [switch]$NoBackup
    )

    if (-not $Path) { throw 'A snapshot file is required.' }
    if (-not (Test-Path $Path)) {
        $candidate = Join-Path (Get-SnapshotDir $Project) $Path
        if (Test-Path $candidate) { $Path = $candidate }
        else { throw "Snapshot not found: $Path" }
    }

    $backup = $null
    if (-not $NoBackup) {
        try { $backup = New-DbSnapshot -Project $Project -Label 'before-restore' } catch { $backup = $null }
    }

    Import-DbDump -Path $Path | Out-Null
    return [pscustomobject]@{
        Project = $Project.Name
        Path    = (Resolve-Path $Path).Path
        Backup  = $(if ($backup) { $backup.Path } else { '' })
    }
}

function Remove-DbSnapshot {
    param($Project, [string]$Path)

    if (-not (Test-Path $Path)) {
        $candidate = Join-Path (Get-SnapshotDir $Project) $Path
        if (Test-Path $candidate) { $Path = $candidate } else { throw "Snapshot not found: $Path" }
    }
    Remove-Item $Path -Force
    return $true
}