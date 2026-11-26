# Project bundles: hand a project to a client, a teammate, or another machine.
#
# A bundle is a zip with the project files, a fresh database dump and a small
# wampdeck-bundle.json that records the PHP version, hostnames and database
# name. Import reverses it and writes a .wampdeck.json in the new folder.

$BundleFormat = 'wampdeck-bundle'
$BundleFormatVersion = 1
$BundleExcludeDirs = @('node_modules', '.git', 'snapshots')
$BundleExcludeFiles = @('database.sql', 'wampdeck-bundle.json')

function Copy-TreeFast {
    # robocopy handles vendor\ with tens of thousands of files far faster than
    # Copy-Item, and it reports progress-free batch output we can ignore.
    param(
        [string]$Source,
        [string]$Destination,
        [string[]]$ExcludeDirs = @(),
        [string[]]$ExcludeFiles = @()
    )

    Ensure-Dir $Destination
    $arguments = @("`"$Source`"", "`"$Destination`"", '/E', '/NFL', '/NDL', '/NJH', '/NJS', '/NP', '/R:1', '/W:1')
    if ($ExcludeDirs.Count -gt 0) { $arguments += '/XD'; $arguments += ($ExcludeDirs | ForEach-Object { "`"$_`"" }) }
    if ($ExcludeFiles.Count -gt 0) { $arguments += '/XF'; $arguments += ($ExcludeFiles | ForEach-Object { "`"$_`"" }) }

    $previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $output = & robocopy @arguments 2>&1
        $code = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $previous
    }
    if ($code -ge 8) {
        throw "Could not copy the project files.`n$(($output | Select-Object -Last 12) -join [Environment]::NewLine)"
    }
    return $true
}

function Get-BundleDefaultPath {
    param($Project)
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $dir = Join-Path $Root 'exports'
    Ensure-Dir $dir
    return (Join-Path $dir "$($Project.Name)-$stamp.zip")
}

function Export-ProjectBundle {
    param(
        $Project,
        [string]$OutPath = '',
        [switch]$NoDatabase
    )

    if (-not $Project) { throw 'Project not found.' }
    if (-not (Test-Path $Project.Folder)) { throw "Project folder not found: $($Project.Folder)" }
    if (-not $OutPath) { $OutPath = Get-BundleDefaultPath -Project $Project }
    $outDir = Split-Path -Parent $OutPath
    if ($outDir) { Ensure-Dir $outDir }

    $stage = Join-Path $TmpDir ("bundle-" + [guid]::NewGuid().ToString('N').Substring(0, 8))
    Ensure-Dir $stage

    try {
        Copy-TreeFast -Source $Project.Folder -Destination $stage `
            -ExcludeDirs $BundleExcludeDirs -ExcludeFiles $BundleExcludeFiles | Out-Null

        $databaseName = Get-ProjectDatabaseName -Project $Project
        $hasDatabase = $false
        if (-not $NoDatabase) {
            $dumpPath = Join-Path $stage 'database.sql'
            try {
                Export-DbDump -Database $databaseName -Path $dumpPath -TablesOnly | Out-Null
                $hasDatabase = $true
            } catch {
                Remove-Item $dumpPath -Force -ErrorAction SilentlyContinue
            }
        }

        # Record the version the project asked for ("8.2"), not the exact
        # build ("8.2.12"): the other machine may have a different patch.
        $phpVersion = $Project.PhpVersion
        $phpSpec = $phpVersion
        if ($Project.Manifest -and $Project.Manifest.Valid) {
            $manifestPhp = [string]$Project.Manifest.Data.PhpSpec
            if ($manifestPhp -and $manifestPhp -ne 'any') { $phpSpec = $manifestPhp }
        }
        $meta = [ordered]@{
            format        = $BundleFormat
            formatVersion = $BundleFormatVersion
            name          = $Project.Name
            php           = $phpSpec
            phpResolved   = $phpVersion
            web           = $(if ($Project.Manifest -and $Project.Manifest.Valid) { $Project.Manifest.Data.Web } else { 'any' })
            # Only custom hostnames travel. The name-based pair is rebuilt on
            # import, so a renamed copy does not hijack the source project.
            hosts         = @($Project.Hosts | Where-Object {
                $_ -ne "$($Project.Name).localhost" -and $_ -ne "$($Project.Name).test"
            })
            database      = [ordered]@{
                name = $databaseName
                file = $(if ($hasDatabase) { 'database.sql' } else { '' })
            }
            created       = (Get-Date).ToString('o')
            wampdeck      = $WampDeckVersion
        }
        Set-Content -Path (Join-Path $stage 'wampdeck-bundle.json') `
            -Value ($meta | ConvertTo-Json -Depth 5) -Encoding UTF8

        if (Test-Path $OutPath) { Remove-Item $OutPath -Force }
        Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction SilentlyContinue
        [System.IO.Compression.ZipFile]::CreateFromDirectory($stage, $OutPath,
            [System.IO.Compression.CompressionLevel]::Optimal, $false)

        $item = Get-Item $OutPath
        return [pscustomobject]@{
            Project  = $Project.Name
            Path     = $item.FullName
            Size     = $item.Length
            SizeMb   = [math]::Round($item.Length / 1MB, 1)
            Database = $(if ($hasDatabase) { $databaseName } else { '' })
            Php      = $phpSpec
            PhpResolved = $phpVersion
        }
    } finally {
        if (Test-Path $stage) { Remove-Item $stage -Recurse -Force -ErrorAction SilentlyContinue }
    }
}

function Read-BundleMetadata {
    param([string]$Folder)

    $path = Join-Path $Folder 'wampdeck-bundle.json'
    if (-not (Test-Path $path)) { return $null }
    try {
        return (Get-Content -Path $path -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop)
    } catch {
        return $null
    }
}

function Import-ProjectBundle {
    param(
        [string]$Path,
        [string]$Name = '',
        [string]$Php = '',
        [switch]$Force,
        [switch]$NoHosts,
        [switch]$AllowScripts
    )

    if (-not (Test-Path $Path)) { throw "Bundle not found: $Path" }

    $stage = Join-Path $TmpDir ("import-" + [guid]::NewGuid().ToString('N').Substring(0, 8))
    Ensure-Dir $stage

    try {
        $item = Get-Item $Path
        if ($item.PSIsContainer) {
            Copy-TreeFast -Source $item.FullName -Destination $stage | Out-Null
        } else {
            Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction SilentlyContinue
            try {
                [System.IO.Compression.ZipFile]::ExtractToDirectory($item.FullName, $stage)
            } catch {
                throw "Could not read the bundle zip: $($_.Exception.Message)"
            }
        }

        $meta = Read-BundleMetadata -Folder $stage
        if (-not $Name) {
            if ($meta -and $meta.name) { $Name = [string]$meta.name }
            else { $Name = ($item.BaseName -replace '[^a-z0-9-]', '-').ToLowerInvariant() }
        }
        $Name = $Name.Trim().ToLowerInvariant()
        if ($Name -notmatch '^[a-z0-9][a-z0-9-]{0,30}$') {
            throw "Project name '$Name' must be lowercase letters, digits or hyphens (max 31 chars)."
        }
        if ($Name -eq 'panel') { throw "'panel' is reserved." }

        $target = Join-Path $WwwDir $Name
        if (Test-Path $target) {
            $existing = @(Get-ChildItem $target -Force)
            if ($existing.Count -gt 0 -and -not $Force) {
                throw "Folder www\$Name already exists and is not empty. Use -Force or pick another name."
            }
        }
        Ensure-Dir $target

        # The source manifest describes the source project (old name, old
        # database). Keep it out of the target and write a fresh one below.
        $importExcludeFiles = @($BundleExcludeFiles) + '.wampdeck.json'
        Copy-TreeFast -Source $stage -Destination $target `
            -ExcludeFiles $importExcludeFiles | Out-Null
        Remove-Item (Join-Path $target 'wampdeck-bundle.json') -Force -ErrorAction SilentlyContinue

        # Database
        $databaseName = $Name -replace '-', '_'
        $bundleDatabase = ''
        if ($meta -and $meta.database -and $meta.database.file) { $bundleDatabase = [string]$meta.database.file }
        $dumpPath = Join-Path $stage 'database.sql'
        if (-not $bundleDatabase -or -not (Test-Path $dumpPath)) {
            $dumpPath = $null
        }

        $databaseImported = $false
        if ($dumpPath) {
            if (-not (Test-TcpPort -Port $MysqlPort)) { throw 'MySQL is not running. Start the stack, then import again.' }
            New-ProjectDatabase -Name $Name | Out-Null
            try {
                Import-DbDump -Path $dumpPath -Database $databaseName | Out-Null
            } catch {
                throw "The bundle database dump could not be imported.`n$($_.Exception.Message)"
            }
            $databaseImported = $true
        }

        # PHP version: explicit flag, then the bundle, then the stack default.
        $phpSpec = 'any'
        if ($Php) { $phpSpec = $Php }
        elseif ($meta -and $meta.php) { $phpSpec = [string]$meta.php }
        $resolved = Resolve-PhpVersionSpec -Spec $phpSpec
        if (-not $resolved) {
            $phpSpec = 'any'
            $resolved = $State.phpVersion
        }

        # Custom hosts only make sense when the name is unchanged; otherwise
        # they would point at the original project.
        $hosts = @()
        if ($meta -and $meta.hosts -and [string]$meta.name -eq $Name) {
            $hosts = @($meta.hosts | Where-Object { $_ })
        }

        $docRoot = ''
        if (Test-Path (Join-Path $target 'public\index.php')) { $docRoot = 'public' }

        New-WampDeckManifest -ProjectDir $target -Name $Name -Php $phpSpec -Web 'any' `
            -DocRoot $docRoot -Database $databaseName -Hosts $hosts | Out-Null

        Write-AllConfigs
        try {
            if ((Get-StackStatus).WebRunning) { Reload-WebServer | Out-Null }
        } catch { }

        $hostsSynced = $false
        if (-not $NoHosts) {
            try { $hostsSynced = Invoke-HostsSyncElevated } catch { $hostsSynced = $false }
        }

        $postCreate = @()
        $importManifest = Read-WampDeckManifest -ProjectDir $target
        $hasScripts = ($importManifest.Valid -and @($importManifest.Data.PostCreate).Count -gt 0)
        if ($hasScripts -and -not $AllowScripts) {
            Write-Host "  warning: bundle contains postCreate scripts - skipped." -ForegroundColor DarkYellow
            Write-Host "  re-run with --allow-scripts only if you trust the bundle." -ForegroundColor DarkGray
        } elseif ($hasScripts) {
            $postCreate = @(Invoke-ManifestPostCreate -ProjectDir $target)
        }

        $project = Get-ProjectByName $Name
        return [pscustomobject]@{
            Name             = $Name
            Folder           = $target
            Php              = $resolved
            Database         = $databaseName
            DatabaseImported = $databaseImported
            HostsSynced      = $hostsSynced
            Url              = $(if ($project) { $project.Url } else { Get-ProjectUrl $Name })
            TestUrl          = $(if ($project) { $project.TestUrl } else { Get-ProjectTestUrl $Name })
            PostCreate       = $postCreate
        }
    } finally {
        if (Test-Path $stage) { Remove-Item $stage -Recurse -Force -ErrorAction SilentlyContinue }
    }
}