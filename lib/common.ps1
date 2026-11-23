# Shared helpers for WampDeck v2.

function Test-TcpPort {
    param(
        [int]$Port,
        [string]$Target = '127.0.0.1',
        [int]$TimeoutMs = 400
    )
    $client = New-Object System.Net.Sockets.TcpClient
    try {
        $async = $client.BeginConnect($Target, $Port, $null, $null)
        if (-not $async.AsyncWaitHandle.WaitOne($TimeoutMs)) { return $false }
        $client.EndConnect($async)
        return $true
    } catch {
        return $false
    } finally {
        try { $client.Close() } catch { }
    }
}

function Wait-TcpPort {
    param(
        [int]$Port,
        [int]$Seconds = 20,
        [string]$Target = '127.0.0.1'
    )
    $deadline = (Get-Date).AddSeconds($Seconds)
    while ((Get-Date) -lt $deadline) {
        if (Test-TcpPort -Port $Port -Target $Target) { return $true }
        Start-Sleep -Milliseconds 400
    }
    return (Test-TcpPort -Port $Port -Target $Target)
}

function Write-Step { param([string]$Message) Write-Host "  $Message" -ForegroundColor DarkGray }
function Write-Ok { param([string]$Message) Write-Host "  [ok] $Message" -ForegroundColor Green }
function Write-Warn { param([string]$Message) Write-Host "  [!!] $Message" -ForegroundColor Yellow }
function Write-Err { param([string]$Message) Write-Host "  [xx] $Message" -ForegroundColor Red }

function Ensure-Dir {
    param([string]$Path)
    if (-not (Test-Path $Path)) { New-Item -ItemType Directory -Force -Path $Path | Out-Null }
}

function Test-Admin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-ProcessPath {
    param($Process, [string]$ExePath)
    if (-not $Process) { return $false }
    try {
        $actual = [System.IO.Path]::GetFullPath($Process.Path)
        $expected = [System.IO.Path]::GetFullPath($ExePath)
        return $actual.Equals($expected, [System.StringComparison]::OrdinalIgnoreCase)
    } catch {
        return $false
    }
}

function Get-PortProcess {
    param([int]$Port)
    $connection = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue |
        Select-Object -First 1
    if (-not $connection) { return $null }
    return Get-Process -Id $connection.OwningProcess -ErrorAction SilentlyContinue
}

function Get-StackProcesses {
    param([string]$ExePath)
    $full = [System.IO.Path]::GetFullPath($ExePath)
    $exeName = [System.IO.Path]::GetFileNameWithoutExtension($ExePath)
    # Get-Process with no -Name enumerates every process on the system (~330 ms)
    # and Get-StackStatus calls this repeatedly every 3 s, freezing the UI.
    # Query by name via CIM instead; match on ExecutablePath when available and
    # fall back to the name alone for elevated processes whose path is hidden.
    $result = @()
    foreach ($proc in @(Get-CimInstance Win32_Process -Filter "Name = '$exeName.exe'" -ErrorAction SilentlyContinue)) {
        if ($proc.ExecutablePath) {
            try { if ([System.IO.Path]::GetFullPath($proc.ExecutablePath) -ne $full) { continue } } catch { continue }
        }
        $p = Get-Process -Id $proc.ProcessId -ErrorAction SilentlyContinue
        if ($p) { $result += $p }
    }
    return $result
}

function Save-StackState {
    $State | ConvertTo-Json -Depth 5 | Set-Content -Path $StateFile -Encoding ASCII
}

function Set-StackSetting {
    param([string]$Name, $Value)
    $State[$Name] = $Value
    Save-StackState
}

function Get-HostUrl {
    param(
        [string]$HostName,
        [int]$Port,
        [string]$Scheme = 'http'
    )
    if (($Scheme -eq 'http' -and $Port -eq 80) -or ($Scheme -eq 'https' -and $Port -eq 443)) {
        return "${Scheme}://${HostName}"
    }
    return "${Scheme}://${HostName}:$Port"
}

function Get-ProjectUrl {
    param([string]$Name)
    return (Get-HostUrl -HostName "$Name.localhost" -Port $HttpPort)
}

function Get-ProjectTestUrl {
    param([string]$Name)
    return (Get-HostUrl -HostName "$Name.test" -Port $HttpPort)
}

function Get-ProjectHttpsUrl {
    param([string]$Name)
    return (Get-HostUrl -HostName "$Name.test" -Port $HttpsPort -Scheme 'https')
}

function Get-DocumentRoot {
    param([string]$ProjectDir)
    $public = Join-Path $ProjectDir 'public'
    if (Test-Path (Join-Path $public 'index.php')) { return $public }
    return $ProjectDir
}

function Get-ProjectList {
    $result = @()
    if (-not (Test-Path $WwwDir)) { return @() }
    foreach ($dir in (Get-ChildItem -Path $WwwDir -Directory -ErrorAction SilentlyContinue | Sort-Object Name)) {
        if ($dir.Name -eq 'panel' -or $dir.Name.StartsWith('.')) { continue }

        $manifest = Read-WampDeckManifest -ProjectDir $dir.FullName
        $docRoot = Get-DocumentRoot $dir.FullName
        $phpVersion = $State.phpVersion
        $phpPinned = $false
        $envMap = @{}
        $extraHosts = @()

        if ($manifest.Valid) {
            if ($manifest.Data.DocRoot) { $docRoot = Join-Path $dir.FullName $manifest.Data.DocRoot }
            if ($manifest.Data.PhpPinned) {
                $phpVersion = $manifest.Data.PhpVersion
                $phpPinned = $true
            }
            $envMap = $manifest.Data.Env
            $extraHosts = @($manifest.Data.Hosts)
        }

        $hosts = @("$($dir.Name).localhost", "$($dir.Name).test")
        foreach ($extra in $extraHosts) {
            if ($hosts -notcontains $extra) { $hosts += $extra }
        }

        $result += [pscustomobject]@{
            Name         = $dir.Name
            Folder       = $dir.FullName
            DocumentRoot = $docRoot
            UsesPublic   = ($docRoot -ne $dir.FullName)
            Url          = (Get-ProjectUrl $dir.Name)
            TestUrl      = (Get-ProjectTestUrl $dir.Name)
            HttpsUrl     = (Get-ProjectHttpsUrl $dir.Name)
            PhpVersion   = $phpVersion
            PhpPinned    = $phpPinned
            Manifest     = $manifest
            Env          = $envMap
            Hosts        = $hosts
        }
    }
    return $result
}

function Invoke-Http {
    param(
        [string]$Url,
        [int]$TimeoutSec = 10,
        [switch]$SkipCertificateCheck
    )
    $previous = [Net.ServicePointManager]::ServerCertificateValidationCallback
    if ($SkipCertificateCheck) {
        [Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
    }
    try {
        $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec $TimeoutSec
        return [pscustomobject]@{
            Ok      = $true
            Status  = [int]$response.StatusCode
            Content = $response.Content
        }
    } catch {
        return [pscustomobject]@{
            Ok      = $false
            Status  = 0
            Content = $_.Exception.Message
        }
    } finally {
        [Net.ServicePointManager]::ServerCertificateValidationCallback = $previous
    }
}

function Wait-Http {
    param(
        [string]$Url,
        [int]$Seconds = 20,
        [switch]$SkipCertificateCheck
    )
    $deadline = (Get-Date).AddSeconds($Seconds)
    while ((Get-Date) -lt $deadline) {
        $result = Invoke-Http -Url $Url -TimeoutSec 3 -SkipCertificateCheck:$SkipCertificateCheck
        if ($result.Ok) { return $true }
        Start-Sleep -Milliseconds 500
    }
    return $false
}

function Get-ExeVersion {
    param([string]$Exe, [string]$Arguments = '--version')
    if (-not (Test-Path $Exe)) { return '' }
    try {
        $output = & $Exe $Arguments 2>&1 | Select-Object -First 1
        return [string]$output
    } catch {
        return ''
    }
}

function Start-HiddenProcess {
    param(
        [string]$FilePath,
        [string[]]$Arguments = @(),
        [string]$WorkingDirectory = $Root,
        [string]$StdOut,
        [string]$StdErr
    )
    $params = @{
        FilePath         = $FilePath
        WorkingDirectory = $WorkingDirectory
        WindowStyle      = 'Hidden'
        PassThru         = $true
    }
    if ($Arguments.Count -gt 0) { $params.ArgumentList = $Arguments }
    if ($StdOut) { $params.RedirectStandardOutput = $StdOut }
    if ($StdErr) { $params.RedirectStandardError = $StdErr }
    return (Start-Process @params)
}

function Get-ProjectByName {
    param([string]$Name)
    $all = @(Get-ProjectList)
    return ($all | Where-Object { $_.Name -eq $Name } | Select-Object -First 1)
}

function Start-DetachedProcess {
    # WMI launches the process without inheriting this console, so the calling
    # PowerShell can exit immediately (Apache keeps child processes alive).
    param(
        [string]$FilePath,
        [string]$Arguments = '',
        [string]$WorkingDirectory = $Root
    )
    $commandLine = "`"$FilePath`" $Arguments"
    $startup = ([wmiclass]'Win32_ProcessStartup').CreateInstance()
    $startup.ShowWindow = 0
    $result = ([wmiclass]'Win32_Process').Create($commandLine, $WorkingDirectory, $startup)
    if ($result.ReturnValue -ne 0) {
        throw "Could not start $FilePath (WMI code $($result.ReturnValue))."
    }
    return [int]$result.ProcessId
}
