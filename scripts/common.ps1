# Small helpers shared by every script.

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

function Write-Step {
    param([string]$Message)
    Write-Host "  $Message" -ForegroundColor DarkGray
}

function Write-Ok {
    param([string]$Message)
    Write-Host "  [ok] $Message" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Host "  [!!] $Message" -ForegroundColor Yellow
}

function Write-Err {
    param([string]$Message)
    Write-Host "  [xx] $Message" -ForegroundColor Red
}

function Get-StackProcesses {
    param([string]$ExePath)
    $full = [System.IO.Path]::GetFullPath($ExePath)
    Get-Process -ErrorAction SilentlyContinue | Where-Object {
        try { $_.Path -and [System.IO.Path]::GetFullPath($_.Path) -eq $full } catch { $false }
    }
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

function Invoke-Http {
    param([string]$Url, [int]$TimeoutSec = 10)
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
    }
}
