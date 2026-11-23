# Bundled developer tools: launchers and version info.

function Open-HeidiSql {
    param([string]$Database = '')
    if (-not (Test-Path $HeidiExe)) { throw 'HeidiSQL is not installed.' }
    $arguments = @('-h', '127.0.0.1', '-P', "$MysqlPort", '-u', 'root')
    if ($Database) { $arguments += @('-d', $Database) }
    Start-Process -FilePath $HeidiExe -ArgumentList $arguments -WorkingDirectory (Join-Path $BinDir 'heidisql') | Out-Null
}

function Open-Mailpit {
    Start-Process "http://127.0.0.1:$MailpitUiPort"
}

function Get-TerminalPathEntries {
    $candidates = @(
        $PhpDir,
        (Join-Path $MysqlDir 'bin'),
        (Join-Path $BinDir 'composer'),
        (Join-Path $BinDir 'nodejs'),
        (Join-Path $BinDir 'python'),
        (Join-Path $BinDir 'python\Scripts'),
        (Join-Path $BinDir 'git\cmd'),
        (Join-Path $BinDir 'git\bin'),
        (Join-Path $BinDir 'git\usr\bin'),
        (Join-Path $BinDir 'cmder\vendor\bin')
    )
    return @($candidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -Unique)
}

# Opens a Cmder window (Laragon style) with the bundled PHP, MySQL, Composer,
# Git, Node and Python tools ahead of the normal PATH. Falls back to a plain
# PowerShell window when Cmder is missing.
function Open-Terminal {
    param([string]$Path = $WwwDir)

    if (-not (Test-Path -LiteralPath $Path)) { $Path = $WwwDir }
    if (-not (Test-Path -LiteralPath $Path)) { $Path = $Root }

    $prefix = @(Get-TerminalPathEntries) -join ';'
    $oldPath = $env:PATH
    $oldRoot = $env:WAMPDECK_ROOT
    try {
        if ($prefix) { $env:PATH = "$prefix;$oldPath" }
        $env:WAMPDECK_ROOT = $Root
        if (Test-Path -LiteralPath $CmderExe) {
            Start-Process -FilePath $CmderExe -ArgumentList @('/START', "`"$Path`"") `
                -WorkingDirectory (Join-Path $BinDir 'cmder') | Out-Null
        } else {
            Start-Process -FilePath 'powershell.exe' `
                -ArgumentList @('-NoExit', '-NoLogo', '-ExecutionPolicy', 'Bypass') `
                -WorkingDirectory $Path | Out-Null
        }
    } finally {
        $env:PATH = $oldPath
        if ($null -eq $oldRoot) {
            Remove-Item Env:\WAMPDECK_ROOT -ErrorAction SilentlyContinue
        } else {
            $env:WAMPDECK_ROOT = $oldRoot
        }
    }
}

function Open-Cmder {
    param([string]$Path = $WwwDir)
    Open-Terminal -Path $Path
}

function Open-Notepad {
    param([string]$Path = '')
    if (-not (Test-Path $NotepadExe)) { throw 'Notepad++ is not installed.' }
    if ($Path) {
        Start-Process -FilePath $NotepadExe -ArgumentList @("`"$Path`"") | Out-Null
    } else {
        Start-Process -FilePath $NotepadExe | Out-Null
    }
}

function Start-Cronical {
    if (-not (Test-Path $CronicalExe)) { throw 'Cronical is not installed.' }
    Start-Process -FilePath $CronicalExe -ArgumentList @('--console') `
        -WorkingDirectory (Join-Path $BinDir 'cronical') | Out-Null
}

function Start-NgrokTunnel {
    param([int]$Port = $HttpPort)
    if (-not (Test-Path $NgrokExe)) { throw 'ngrok is not installed.' }
    if (@(Get-StackProcesses $NgrokExe).Count -gt 0) {
        return (Get-NgrokUrl)
    }
    Start-Process -FilePath $NgrokExe -ArgumentList @('http', "$Port", '--log', "`"$(Join-Path $LogDir 'ngrok.log')`"") `
        -WorkingDirectory (Join-Path $BinDir 'ngrok') -WindowStyle Hidden | Out-Null
    Start-Sleep -Seconds 2
    return (Get-NgrokUrl)
}

function Get-NgrokUrl {
    $result = Invoke-Http -Url 'http://127.0.0.1:4040/api/tunnels' -TimeoutSec 5
    if (-not $result.Ok) { return '' }
    try {
        $json = $result.Content | ConvertFrom-Json
        $tunnel = @($json.tunnels) | Select-Object -First 1
        if ($tunnel) { return [string]$tunnel.public_url }
    } catch { }
    return ''
}

function Stop-NgrokTunnel {
    foreach ($process in @(Get-StackProcesses $NgrokExe)) {
        Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
    }
}

function Open-Panel {
    Start-Process $PanelUrl
}

function Get-ToolVersions {
    $items = @(
        @{ Name = 'PHP 8.3';  Exe = (Join-Path $PhpRoot '8.3.30\php.exe'); Args = '-v' },
        @{ Name = 'PHP 8.2';  Exe = (Join-Path $PhpRoot '8.2.12\php.exe'); Args = '-v' },
        @{ Name = 'Apache';   Exe = $ApacheExe;        Args = '-v' },
        @{ Name = 'nginx';    Exe = $NginxExe;         Args = '-v' },
        @{ Name = 'MySQL';    Exe = $Mysqld;           Args = '--version' },
        @{ Name = 'Node';     Exe = $NodeExe;          Args = '--version' },
        @{ Name = 'Python';   Exe = $PythonExe;        Args = '--version' },
        @{ Name = 'Git';      Exe = $GitExe;           Args = '--version' },
        @{ Name = 'Composer'; Exe = $ComposerBat;      Args = '--version' },
        @{ Name = 'Mailpit';  Exe = $MailpitExe;       Args = 'version' },
        @{ Name = 'Redis';    Exe = $RedisExe;         Args = '--version' },
        @{ Name = 'Memcached'; Exe = $MemcachedExe;    Args = '-h' },
        @{ Name = 'ngrok';    Exe = $NgrokExe;         Args = 'version' }
    )

    $result = @()
    foreach ($item in $items) {
        if (-not (Test-Path $item.Exe)) { continue }
        $output = ''
        try {
            $output = [string](& $item.Exe $item.Args.Split(' ') 2>&1 | Select-Object -First 1)
        } catch { }
        $result += [pscustomobject]@{ Name = $item.Name; Version = $output.Trim() }
    }
    return $result
}
