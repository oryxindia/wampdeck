# Health checks for a WampDeck install.
#
# Every check returns the same shape so the CLI, the GUI and a future
# "copy diagnostics" button can share one source of truth:
#   Id, Title, Status (pass|warn|fail|skip), Detail, Fix

function New-DoctorCheck {
    param(
        [string]$Id,
        [string]$Title,
        [ValidateSet('pass', 'warn', 'fail', 'skip')][string]$Status,
        [string]$Detail = '',
        [string]$Fix = ''
    )
    return [pscustomobject]@{
        Id     = $Id
        Title  = $Title
        Status = $Status
        Detail = $Detail
        Fix    = $Fix
    }
}

function Get-DoctorPhpIniIssues {
    param([string]$Version)

    $dir = Join-Path $PhpRoot $Version
    $iniPath = Join-Path $dir 'php.ini'
    $issues = @()
    if (-not (Test-Path $iniPath)) {
        return @('php.ini is missing')
    }

    $extDir = Join-Path $dir 'ext'
    foreach ($line in @(Get-Content -Path $iniPath -ErrorAction SilentlyContinue)) {
        if ($line -match '^\s*extension\s*=\s*"?([A-Za-z0-9_]+)"?\s*$') {
            $name = $Matches[1]
            if (-not (Test-Path (Join-Path $extDir "php_$name.dll"))) {
                $issues += "extension=$name has no php_$name.dll"
            }
        }
        if ($line -match '^\s*zend_extension\s*=\s*opcache\s*$') {
            if (-not (Test-Path (Join-Path $extDir 'php_opcache.dll'))) {
                $issues += 'zend_extension=opcache has no php_opcache.dll'
            }
        }
    }
    return $issues
}

function Get-DoctorOpcacheState {
    param([string]$Version)

    $cacheFile = Join-Path $EtcDir 'php-runtime.json'
    if (-not (Test-Path $cacheFile)) { return $null }
    try {
        $raw = Get-Content -Path $cacheFile -Raw -ErrorAction Stop
        if (-not $raw.Trim()) { return $null }
        $data = $raw | ConvertFrom-Json -ErrorAction Stop
        $entry = $data.PSObject.Properties[$Version]
        if (-not $entry) { return $null }
        if ($entry.Value.PSObject.Properties['mode'] -and $entry.Value.mode) { return [string]$entry.Value.mode }
        if ([bool]$entry.Value.ok) { return 'shm' }
        return 'off'
    } catch {
        return $null
    }
}

function Invoke-Doctor {
    param([string]$Project = '')

    $checks = New-Object System.Collections.Generic.List[object]

    # ------------------------------------------------------------ install root
    $probe = Join-Path $Root '.doctor-probe'
    $writable = $false
    try {
        Set-Content -Path $probe -Value 'ok' -Encoding ASCII -ErrorAction Stop
        $writable = ((Get-Content -Path $probe -Raw).Trim() -eq 'ok')
        Remove-Item $probe -Force -ErrorAction SilentlyContinue
    } catch { $writable = $false }
    if ($writable) {
        $checks.Add((New-DoctorCheck 'install-root' 'Install folder is writable' 'pass' $Root))
    } else {
        $checks.Add((New-DoctorCheck 'install-root' 'Install folder is writable' 'fail' $Root `
            'Run WampDeck from a folder your user can write to, e.g. C:\WampDeck'))
    }

    # ------------------------------------------------------------ ports
    $conflicts = @(Get-WampDeckPortConflicts)
    if ($conflicts.Count -eq 0) {
        $checks.Add((New-DoctorCheck 'ports' 'Ports are free' 'pass' "HTTP $HttpPort, MySQL $MysqlPort, PHP pools"))
    } else {
        $detail = ($conflicts | ForEach-Object { "$($_.Port) used by $($_.Name) (pid $($_.Pid))" }) -join '; '
        $checks.Add((New-DoctorCheck 'ports' 'Ports are free' 'fail' $detail `
            'Stop the other program, or change the port in Settings.'))
    }

    # ------------------------------------------------------------ web server
    $webExe = if ($State.webServer -eq 'apache') { $ApacheExe } else { $NginxExe }
    if (-not (Test-Path $webExe)) {
        $checks.Add((New-DoctorCheck 'web-binary' 'Web server is installed' 'fail' $webExe `
            'Run setup again, or reinstall WampDeck.'))
    } else {
        $previous = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        try {
            if ($State.webServer -eq 'apache') {
                $configTest = & $ApacheExe -f $ApacheMainConf -t 2>&1
            } else {
                $configTest = & $NginxExe -p $Root -c 'etc/nginx.conf' -t 2>&1
            }
            $configCode = $LASTEXITCODE
        } catch {
            $configTest = @("$($_.Exception.Message)")
            $configCode = 1
        } finally {
            $ErrorActionPreference = $previous
        }
        if ($configCode -eq 0) {
            $checks.Add((New-DoctorCheck 'web-config' 'Web server config is valid' 'pass' "$($State.webServer) syntax ok"))
        } else {
            $text = ($configTest | Where-Object { $_ -and $_ -notmatch 'CategoryInfo|FullyQualifiedErrorId|^\s*\+' }) -join ' '
            $checks.Add((New-DoctorCheck 'web-config' 'Web server config is valid' 'fail' $text `
                'Run .\refresh.cmd to regenerate the configs.'))
        }
    }

    $status = Get-StackStatus
    if ($status.WebRunning) {
        $checks.Add((New-DoctorCheck 'web-running' 'Web server is running' 'pass' "$($State.webServer) on port $HttpPort"))
    } else {
        $checks.Add((New-DoctorCheck 'web-running' 'Web server is running' 'fail' "$($State.webServer) is not listening on port $HttpPort" `
            'Run .\start.cmd, or wampdeck start'))
    }

    # ------------------------------------------------------------ php pools
    $poolProblems = @()
    foreach ($pool in @($status.PhpPools)) {
        if (-not $pool.Running) {
            $poolProblems += "PHP $($pool.Version) $($pool.Alive)/$($pool.Expected)"
        }
    }
    $expected = @($status.PhpPools | Measure-Object -Property Expected -Sum).Sum
    if ($expected -eq 0) {
        $checks.Add((New-DoctorCheck 'php-pools' 'PHP workers are installed' 'fail' 'No php-cgi.exe was found under bin\php' `
            'Run setup again to install PHP.'))
    } elseif ($poolProblems.Count -eq 0) {
        $detail = (@($status.PhpPools) | ForEach-Object { "$($_.Version): $($_.Alive)/$($_.Expected)" }) -join ', '
        $checks.Add((New-DoctorCheck 'php-pools' 'PHP workers are running' 'pass' $detail))
    } else {
        $checks.Add((New-DoctorCheck 'php-pools' 'PHP workers are running' 'fail' ($poolProblems -join ', ') `
            'Run .\restart.cmd. If it repeats, check logs\php-*.log.'))
    }

    if ($status.PhpSupervisor) {
        $checks.Add((New-DoctorCheck 'php-supervisor' 'PHP supervisor is running' 'pass' 'workers restart within 5 seconds'))
    } else {
        $checks.Add((New-DoctorCheck 'php-supervisor' 'PHP supervisor is running' 'warn' 'not running' `
            'Run .\restart.cmd to start it.'))
    }

    foreach ($version in @($PhpVersions)) {
        $issues = @(Get-DoctorPhpIniIssues -Version $version)
        if ($issues.Count -eq 0) {
            $checks.Add((New-DoctorCheck "php-ini-$version" "PHP $version config" 'pass' 'php.ini matches the extensions on disk'))
        } else {
            $checks.Add((New-DoctorCheck "php-ini-$version" "PHP $version config" 'warn' ($issues -join '; ') `
                'Run .\refresh.cmd, or disable the missing extensions.'))
        }

        $opcache = Get-DoctorOpcacheState -Version $version
        if ($opcache -eq 'file') {
            $checks.Add((New-DoctorCheck "php-opcache-$version" "PHP $version opcache" 'pass' `
                'enabled with file cache fallback (ASLR-safe)'))
        } elseif ($opcache -eq 'off') {
            $checks.Add((New-DoctorCheck "php-opcache-$version" "PHP $version opcache" 'warn' `
                'disabled because this build crashes with opcache' `
                'This is a known issue with some Windows PHP builds. Sites still work, just slower.'))
        }
    }

    # ------------------------------------------------------------ mysql
    if ($status.MysqlRunning) {
        $checks.Add((New-DoctorCheck 'mysql-running' 'MySQL is running' 'pass' "port $MysqlPort"))
        $previous = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        try {
            $ping = & $MysqlCli "--defaults-file=$MyIni" -u root -N -B -e 'SELECT 1;' 2>&1
            $pingCode = $LASTEXITCODE
        } catch {
            $ping = @("$($_.Exception.Message)")
            $pingCode = 1
        } finally {
            $ErrorActionPreference = $previous
        }
        if ($pingCode -eq 0) {
            $checks.Add((New-DoctorCheck 'mysql-login' 'MySQL root login works' 'pass' 'SELECT 1'))
        } else {
            $checks.Add((New-DoctorCheck 'mysql-login' 'MySQL root login works' 'fail' (($ping -join ' ').Trim()) `
                'Run .\db.cmd -Reset to reset the local root password.'))
        }
    } else {
        $checks.Add((New-DoctorCheck 'mysql-running' 'MySQL is running' 'fail' "not listening on port $MysqlPort" `
            'Run .\start.cmd, or check logs\mysql-error.log.'))
    }

    # ------------------------------------------------------------ hosts
    $hosts = Get-HostsStatus
    if ($hosts.Required -eq 0) {
        $checks.Add((New-DoctorCheck 'hosts' 'Hosts file is synced' 'pass' 'no project hostnames yet'))
    } elseif ($hosts.Synced) {
        $checks.Add((New-DoctorCheck 'hosts' 'Hosts file is synced' 'pass' "$($hosts.Present)/$($hosts.Required) names"))
    } else {
        $detail = "$($hosts.Missing.Count) missing: $($hosts.Missing -join ', ')"
        $checks.Add((New-DoctorCheck 'hosts' 'Hosts file is synced' 'warn' $detail `
            'Run .\hosts.cmd -Sync (asks for administrator). .localhost names still work.'))
    }

    # ------------------------------------------------------------ ssl
    if ($State.ssl) {
        $ssl = Get-SslStatus
        if (-not $ssl.HasCert) {
            $checks.Add((New-DoctorCheck 'ssl-cert' 'HTTPS certificate' 'fail' 'certificate missing' `
                'Run .\ssl.cmd -Enable to regenerate it.'))
        } elseif ($ssl.Cert.DaysLeft -lt 0) {
            $checks.Add((New-DoctorCheck 'ssl-cert' 'HTTPS certificate' 'fail' "expired $($ssl.Cert.NotAfter.ToString('yyyy-MM-dd'))" `
                'Run .\ssl.cmd -Enable to regenerate it.'))
        } elseif ($ssl.Cert.DaysLeft -lt 14) {
            $checks.Add((New-DoctorCheck 'ssl-cert' 'HTTPS certificate' 'warn' `
                "expires in $($ssl.Cert.DaysLeft) days ($($ssl.Cert.NotAfter.ToString('yyyy-MM-dd')))" `
                'Run .\ssl.cmd -Enable to regenerate it.'))
        } else {
            $checks.Add((New-DoctorCheck 'ssl-cert' 'HTTPS certificate' 'pass' `
                "valid until $($ssl.Cert.NotAfter.ToString('yyyy-MM-dd')) ($($ssl.Cert.DaysLeft) days)"))
        }
        if ($ssl.Trusted) {
            $checks.Add((New-DoctorCheck 'ssl-trust' 'Local CA is trusted' 'pass' 'CurrentUser Root store'))
        } else {
            $checks.Add((New-DoctorCheck 'ssl-trust' 'Local CA is trusted' 'warn' 'not trusted' `
                'Run .\ssl.cmd -Trust, otherwise the browser shows a warning.'))
        }
    }

    # ------------------------------------------------------------ disk
    try {
        $driveLetter = (Split-Path -Qualifier $Root).TrimEnd(':')
        $drive = Get-PSDrive -Name $driveLetter -ErrorAction Stop
        $freeGb = [math]::Round($drive.Free / 1GB, 1)
        if ($freeGb -lt 2) {
            $checks.Add((New-DoctorCheck 'disk' 'Free disk space' 'warn' "$freeGb GB free" `
                'Snapshots and exports need room. Free some space.'))
        } else {
            $checks.Add((New-DoctorCheck 'disk' 'Free disk space' 'pass' "$freeGb GB free"))
        }
    } catch { }

    # ------------------------------------------------------------ tools
    $toolMap = [ordered]@{
        PHP      = (Join-Path (Join-Path $PhpRoot $State.phpVersion) 'php.exe')
        Composer = $ComposerBat
        Git      = $GitExe
        Node     = $NodeExe
        MySQL    = $MysqlCli
    }
    $missingTools = @($toolMap.Keys | Where-Object { -not (Test-Path $toolMap[$_]) })
    if ($missingTools.Count -eq 0) {
        $checks.Add((New-DoctorCheck 'tools' 'Bundled tools are present' 'pass' ($toolMap.Keys -join ', ')))
    } else {
        $checks.Add((New-DoctorCheck 'tools' 'Bundled tools are present' 'warn' ('missing: ' + ($missingTools -join ', ')) `
            'Run setup again to restore them.'))
    }

    # ------------------------------------------------------------ projects
    $projects = @(Get-ProjectList)
    if ($Project) {
        $projects = @($projects | Where-Object { $_.Name -eq $Project })
    }
    foreach ($item in $projects) {
        $prefix = "project-$($item.Name)"

        if ($item.Manifest.Exists -and -not $item.Manifest.Valid) {
            $checks.Add((New-DoctorCheck "$prefix-manifest" "Project $($item.Name) manifest" 'fail' $item.Manifest.Error `
                "Fix .wampdeck.json in $($item.Folder), or delete it to use the defaults."))
        } elseif (-not $item.Manifest.Exists) {
            $checks.Add((New-DoctorCheck "$prefix-manifest" "Project $($item.Name) manifest" 'pass' 'none, using stack defaults'))
        } elseif (@($item.Manifest.Warnings).Count -gt 0) {
            $checks.Add((New-DoctorCheck "$prefix-manifest" "Project $($item.Name) manifest" 'warn' `
                (@($item.Manifest.Warnings) -join '; ') 'Edit .wampdeck.json to clear the warnings.'))
        } else {
            $checks.Add((New-DoctorCheck "$prefix-manifest" "Project $($item.Name) manifest" 'pass' `
                "PHP $($item.PhpVersion)$(if ($item.PhpPinned) { ' (pinned)' } else { '' })"))
        }

        if (Test-Path $item.DocumentRoot) {
            $hasIndex = (Test-Path (Join-Path $item.DocumentRoot 'index.php')) -or
                (Test-Path (Join-Path $item.DocumentRoot 'index.html'))
            if ($hasIndex) {
                $checks.Add((New-DoctorCheck "$prefix-docroot" "Project $($item.Name) document root" 'pass' $item.DocumentRoot))
            } else {
                $checks.Add((New-DoctorCheck "$prefix-docroot" "Project $($item.Name) document root" 'warn' `
                    "no index.php or index.html in $($item.DocumentRoot)" 'Add an index file, or set docroot in .wampdeck.json.'))
            }
        } else {
            $checks.Add((New-DoctorCheck "$prefix-docroot" "Project $($item.Name) document root" 'fail' `
                "$($item.DocumentRoot) does not exist" 'Recreate the folder, or fix docroot in .wampdeck.json.'))
        }

        $dbName = $item.Manifest.Data.Database.Name
        if ($dbName) {
            $previous = $ErrorActionPreference
            $ErrorActionPreference = 'Continue'
            try {
                $found = & $MysqlCli "--defaults-file=$MyIni" -u root -N -B -e "SHOW DATABASES LIKE '$dbName';" 2>&1
                $dbCode = $LASTEXITCODE
            } catch {
                $found = @()
                $dbCode = 1
            } finally {
                $ErrorActionPreference = $previous
            }
            if ($dbCode -eq 0 -and ("$found".Trim() -eq $dbName)) {
                $checks.Add((New-DoctorCheck "$prefix-db" "Project $($item.Name) database" 'pass' $dbName))
            } elseif ($dbCode -eq 0) {
                $checks.Add((New-DoctorCheck "$prefix-db" "Project $($item.Name) database" 'warn' `
                    "database $dbName does not exist" "Open the panel and create it, or restore a snapshot."))
            }
        }
    }

    if (-not $Project) {
        foreach ($item in $projects) {
            $url = "http://$($item.Name).localhost/"
            # WordPress can spend 20+ s on a first request while it checks
            # wordpress.org; 12 s produced false failures. Allow 30 s so a
            # genuinely dead site still fails but a slow one does not.
            $http = Invoke-Http -Url $url -TimeoutSec 30
            if ($http.Ok) {
                $checks.Add((New-DoctorCheck "http-$($item.Name)" "Project $($item.Name) responds" 'pass' "HTTP $($http.Status) $url"))
            } else {
                $checks.Add((New-DoctorCheck "http-$($item.Name)" "Project $($item.Name) responds" 'fail' "$url - $($http.Content)" `
                    'Check logs\nginx-error.log and the project manifest.'))
            }
        }
    }

    # PowerShell 5.1 on current Windows throws "Argument types do not match"
    # when @() wraps a List[object], so hand back a plain array.
    return $checks.ToArray()
}

function Get-DoctorVerdict {
    param([object[]]$Checks)

    $fail = @($Checks | Where-Object { $_.Status -eq 'fail' }).Count
    $warn = @($Checks | Where-Object { $_.Status -eq 'warn' }).Count
    if ($fail -gt 0) { return 'fail' }
    if ($warn -gt 0) { return 'warn' }
    return 'pass'
}