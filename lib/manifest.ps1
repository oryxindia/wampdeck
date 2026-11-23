# .wampdeck.json - per-project environment manifest.
#
# The manifest is optional. A project without one behaves exactly as before:
# it inherits the stack-wide PHP version. A project with one can pin its PHP
# version, document root, extra hostnames, environment variables and the
# commands that ran when it was created.
#
# v1 keys (all optional):
#   schema      integer, currently 1
#   name        project name; must match the folder name when present
#   php         "8.3", "8.3.30", "any"
#   docroot     relative path, e.g. "public"
#   web         "nginx", "apache", "any"  (advisory; doctor reports mismatches)
#   hosts       extra hostnames, e.g. ["api.acme.test"]
#   database    { "name": "acme_blog", "snapshot": "snapshots/acme.sql" }
#   env         { "APP_ENV": "local" }     (passed to PHP as FastCGI params)
#   postCreate  ["composer install"]       (runs once, on create/import only)

$ManifestFile = '.wampdeck.json'
$ManifestSchema = 1

$ManifestKnownKeys = @(
    'schema', 'name', 'php', 'docroot', 'web', 'hosts', 'database', 'env', 'postCreate'
)

function Get-ManifestPath {
    param([string]$ProjectDir)
    return (Join-Path $ProjectDir $ManifestFile)
}

function Resolve-PhpVersionSpec {
    # "8.3" -> the newest installed 8.3.x. "any"/empty -> the stack default.
    param([string]$Spec)
    if (-not $Spec) { return $State.phpVersion }
    $value = $Spec.Trim()
    if (-not $value -or $value -eq 'any' -or $value -eq '*') { return $State.phpVersion }
    $hit = @($PhpVersions | Where-Object { $_ -eq $value -or $_ -like "$value.*" } |
        Select-Object -First 1)
    if ($hit.Count -gt 0) { return $hit[0] }
    return $null
}

function Test-ManifestHostName {
    param([string]$Name)
    if (-not $Name -or $Name.Length -gt 253) { return $false }
    return ($Name -match '^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?(\.[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?)+$')
}

function Test-ManifestRelativePath {
    param([string]$Path)
    if (-not $Path) { return $false }
    if ($Path -match '(^[\\/])' -or $Path -match '^[a-zA-Z]:') { return $false }
    if ($Path -match '(^|[\\/])\.\.([\\/]|$)') { return $false }
    return $true
}

function New-ManifestResult {
    param([string]$Path)
    return [pscustomobject]@{
        Path     = $Path
        Exists   = $false
        Valid    = $false
        Error    = ''
        Warnings = @()
        Data     = $null
    }
}

function Read-WampDeckManifest {
    param([string]$ProjectDir)

    $result = New-ManifestResult -Path (Get-ManifestPath $ProjectDir)
    if (-not (Test-Path $result.Path)) { return $result }
    $result.Exists = $true

    $raw = ''
    try {
        $raw = [System.IO.File]::ReadAllText($result.Path)
    } catch {
        $result.Error = "Could not read the manifest: $($_.Exception.Message)"
        return $result
    }
    if (-not $raw.Trim()) {
        $result.Error = 'The manifest is empty.'
        return $result
    }

    try {
        $json = $raw | ConvertFrom-Json -ErrorAction Stop
    } catch {
        $result.Error = "The manifest is not valid JSON: $($_.Exception.Message)"
        return $result
    }
    if ($json -isnot [pscustomobject]) {
        $result.Error = 'The manifest root must be a JSON object.'
        return $result
    }

    $warnings = New-Object System.Collections.Generic.List[string]
    $keys = @($json.PSObject.Properties.Name)

    foreach ($key in $keys) {
        if ($ManifestKnownKeys -notcontains $key) {
            $warnings.Add("Unknown key '$key' ignored.")
        }
    }

    $schema = $ManifestSchema
    if ($keys -contains 'schema') {
        $parsed = 0
        if ([int]::TryParse([string]$json.schema, [ref]$parsed)) {
            $schema = $parsed
            if ($parsed -gt $ManifestSchema) {
                $warnings.Add("Manifest schema $parsed is newer than this build understands ($ManifestSchema).")
            }
        } else {
            $warnings.Add("'schema' must be an integer; assuming $ManifestSchema.")
        }
    }

    $folder = Split-Path -Leaf $ProjectDir
    $name = $folder
    if ($keys -contains 'name' -and $json.name) {
        $name = [string]$json.name
        if ($name -ne $folder) {
            $warnings.Add("Manifest name '$name' does not match the folder '$folder'.")
            $name = $folder
        }
    }

    $phpSpec = 'any'
    $phpVersion = $State.phpVersion
    $phpPinned = $false
    if ($keys -contains 'php' -and $json.php) {
        $phpSpec = [string]$json.php
        $resolved = Resolve-PhpVersionSpec -Spec $phpSpec
        if ($resolved) {
            $phpVersion = $resolved
            $phpPinned = ($phpSpec -ne 'any' -and $phpSpec -ne '*')
        } else {
            $warnings.Add("PHP '$phpSpec' is not installed; using $($State.phpVersion).")
            $phpSpec = 'any'
        }
    }
    $docRoot = ''
    if ($keys -contains 'docroot' -and $json.docroot) {
        $candidate = [string]$json.docroot
        if (Test-ManifestRelativePath -Path $candidate) {
            $full = Join-Path $ProjectDir $candidate
            if (Test-Path $full) {
                $docRoot = $candidate
            } else {
                $warnings.Add("docroot '$candidate' does not exist; using auto-detection.")
            }
        } else {
            $warnings.Add("docroot '$candidate' must be a relative path inside the project.")
        }
    }

    $web = 'any'
    if ($keys -contains 'web' -and $json.web) {
        $candidate = ([string]$json.web).ToLowerInvariant()
        if (@('nginx', 'apache', 'any') -contains $candidate) {
            $web = $candidate
            if ($candidate -ne 'any' -and $candidate -ne $State.webServer) {
                $warnings.Add("Project asks for $candidate but the stack runs $($State.webServer).")
            }
        } else {
            $warnings.Add("web must be nginx, apache or any; ignoring '$candidate'.")
        }
    }

    $hosts = @()
    if ($keys -contains 'hosts' -and $null -ne $json.hosts) {
        foreach ($entry in @($json.hosts)) {
            if (-not $entry) { continue }
            $hostName = ([string]$entry).Trim().ToLowerInvariant()
            if (Test-ManifestHostName -Name $hostName) {
                if ($hosts -notcontains $hostName) { $hosts += $hostName }
            } else {
                $warnings.Add("Ignoring invalid hostname '$hostName'.")
            }
        }
    }

    $dbName = ''
    $dbSnapshot = ''
    if ($keys -contains 'database' -and $json.database) {
        if ($json.database.name) { $dbName = [string]$json.database.name }
        if ($json.database.snapshot) {
            $candidate = [string]$json.database.snapshot
            if (Test-ManifestRelativePath -Path $candidate) {
                $dbSnapshot = $candidate
            } else {
                $warnings.Add("database.snapshot must be a relative path.")
            }
        }
        if ($dbName -and $dbName -notmatch '^[A-Za-z0-9_]+$') {
            $warnings.Add("database.name '$dbName' should contain only letters, digits and underscores.")
        }
    }

    $envMap = [ordered]@{}
    if ($keys -contains 'env' -and $json.env) {
        foreach ($property in $json.env.PSObject.Properties) {
            if ($property.Name -match '^[A-Za-z_][A-Za-z0-9_]*$') {
                $envMap[$property.Name] = [string]$property.Value
            } else {
                $warnings.Add("Ignoring env name '$($property.Name)'.")
            }
        }
    }

    $postCreate = @()
    if ($keys -contains 'postCreate' -and $null -ne $json.postCreate) {
        foreach ($entry in @($json.postCreate)) {
            if ($entry -and ([string]$entry).Trim()) { $postCreate += ([string]$entry).Trim() }
        }
    }

    $result.Valid = $true
    $result.Warnings = @($warnings)
    $result.Data = [pscustomobject]@{
        Schema     = $schema
        Name       = $name
        PhpSpec    = $phpSpec
        PhpVersion = $phpVersion
        PhpPinned  = $phpPinned
        DocRoot    = $docRoot
        Web        = $web
        Hosts      = @($hosts)
        Database   = [pscustomobject]@{ Name = $dbName; Snapshot = $dbSnapshot }
        Env        = $envMap
        PostCreate = @($postCreate)
    }
    return $result
}

function Get-ProjectPhpVersion {
    param([string]$ProjectDir, [string]$FolderName)
    $manifest = Read-WampDeckManifest -ProjectDir $ProjectDir
    if ($manifest.Valid -and $manifest.Data.PhpPinned) { return $manifest.Data.PhpVersion }
    return $State.phpVersion
}

function Get-ProjectDocRoot {
    param([string]$ProjectDir)
    $manifest = Read-WampDeckManifest -ProjectDir $ProjectDir
    if ($manifest.Valid -and $manifest.Data.DocRoot) {
        return (Join-Path $ProjectDir $manifest.Data.DocRoot)
    }
    return (Get-DocumentRoot $ProjectDir)
}

function New-WampDeckManifest {
    param(
        [string]$ProjectDir,
        [string]$Name,
        [string]$Php = 'any',
        [string]$Web = 'any',
        [string]$DocRoot = '',
        [string]$Database = '',
        [string[]]$Hosts = @()
    )

    $data = [ordered]@{
        schema     = $ManifestSchema
        name       = $Name
        php        = $Php
        docroot    = $DocRoot
        web        = $Web
        hosts      = @($Hosts)
        database   = [ordered]@{ name = $Database; snapshot = '' }
        env        = [ordered]@{ APP_ENV = 'local' }
        postCreate = @()
    }

    # Keep the file readable: drop the keys that carry no information.
    if (-not $DocRoot) { $data.Remove('docroot') }
    if (-not $Database) { $data.Remove('database') }
    if (@($Hosts).Count -eq 0) { $data.Remove('hosts') }

    $json = $data | ConvertTo-Json -Depth 5
    Set-Content -Path (Get-ManifestPath $ProjectDir) -Value $json -Encoding UTF8
    return (Get-ManifestPath $ProjectDir)
}

function Invoke-ManifestPostCreate {
    # Runs the postCreate commands once per project. Never on every start.
    param([string]$ProjectDir, [switch]$Force)

    $marker = Join-Path $ProjectDir '.wampdeck.created'
    if ((Test-Path $marker) -and -not $Force) { return @() }

    $manifest = Read-WampDeckManifest -ProjectDir $ProjectDir
    if (-not $manifest.Valid -or @($manifest.Data.PostCreate).Count -eq 0) {
        Set-Content -Path $marker -Value (Get-Date -Format o) -Encoding ASCII
        return @()
    }

    $phpVersion = $manifest.Data.PhpVersion
    $phpDir = Join-Path $PhpRoot $phpVersion
    $env:PATH = "$phpDir;$BinDir\composer;$BinDir\git\cmd;$BinDir\nodejs;$env:PATH"

    $results = @()
    Push-Location $ProjectDir
    try {
        foreach ($command in $manifest.Data.PostCreate) {
            Write-Step "postCreate: $command"
            $previous = $ErrorActionPreference
            $ErrorActionPreference = 'Continue'
            $output = & powershell.exe -NoProfile -Command $command 2>&1
            $code = $LASTEXITCODE
            $ErrorActionPreference = $previous
            $results += [pscustomobject]@{ Command = $command; ExitCode = $code; Output = @($output) }
            if ($code -ne 0) { break }
        }
    } finally {
        Pop-Location
    }

    if (@($results | Where-Object { $_.ExitCode -ne 0 }).Count -eq 0) {
        Set-Content -Path $marker -Value (Get-Date -Format o) -Encoding ASCII
    }
    return $results
}
function Update-WampDeckManifest {
    # Sets one or more keys, creating the file when the project has none.
    # Keeps the existing keys and their order so a hand-edited manifest stays
    # recognisable.
    param(
        [string]$ProjectDir,
        [System.Collections.IDictionary]$Values
    )

    $path = Get-ManifestPath $ProjectDir
    $data = [ordered]@{}
    if (Test-Path $path) {
        try {
            $json = Get-Content -Path $path -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
        } catch {
            throw "Cannot update .wampdeck.json: $($_.Exception.Message)"
        }
        foreach ($property in $json.PSObject.Properties) {
            $data[$property.Name] = $property.Value
        }
    }
    if (-not $data.Contains('schema')) { $data['schema'] = $ManifestSchema }
    if (-not $data.Contains('name')) { $data['name'] = (Split-Path -Leaf $ProjectDir) }

    foreach ($key in $Values.Keys) {
        $data[$key] = $Values[$key]
    }

    Set-Content -Path $path -Value ($data | ConvertTo-Json -Depth 6) -Encoding UTF8
    return $path
}