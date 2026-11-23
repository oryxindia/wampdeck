# Panel behaviour: background jobs, refresh, service/project actions.

function Open-Url {
    param([string]$Url)
    try { Start-Process $Url } catch { Show-GuiError "Could not open $Url`n$($_.Exception.Message)" }
}

function ConvertTo-ProcessArgument {
    param([string]$Value)

    # Windows argument quoting for ProcessStartInfo.Arguments. Windows
    # PowerShell 5.1 has no ArgumentList collection, so paths and values with
    # spaces or quotes must be escaped here.
    if ($null -eq $Value) { return '""' }
    if ($Value.Length -gt 0 -and $Value -notmatch '[\s"]') { return $Value }

    $builder = New-Object System.Text.StringBuilder
    [void]$builder.Append('"')
    $backslashes = 0
    foreach ($character in $Value.ToCharArray()) {
        if ($character -eq '\') {
            $backslashes++
            continue
        }
        if ($character -eq '"') {
            [void]$builder.Append('\' * (($backslashes * 2) + 1))
            [void]$builder.Append('"')
            $backslashes = 0
            continue
        }
        if ($backslashes -gt 0) {
            [void]$builder.Append('\' * $backslashes)
            $backslashes = 0
        }
        [void]$builder.Append($character)
    }
    if ($backslashes -gt 0) { [void]$builder.Append('\' * ($backslashes * 2)) }
    [void]$builder.Append('"')
    return $builder.ToString()
}

function Start-GuiScript {
    param(
        [string]$ScriptName,
        [string[]]$Arguments = @(),
        [string]$Label = 'Working...'
    )
    if ($script:bgProcess -and -not $script:bgProcess.HasExited) {
        Show-GuiInfo 'Another WampDeck task is still running. Wait for it to finish.'
        return $false
    }
    $scriptPath = Join-Path $Root "scripts\$ScriptName"
    if (-not (Test-Path $scriptPath)) {
        Show-GuiError "Missing script: $scriptPath"
        return $false
    }

    $out = Join-Path $LogDir 'gui-out.log'
    $err = Join-Path $LogDir 'gui-err.log'
    try {
        Remove-Item $out, $err -Force -ErrorAction Stop
    } catch {
        # A previous process can leave a handle on the shared log files. Fall
        # back to a per-job name instead of failing to start the task.
        $stamp = Get-Date -Format 'yyyyMMdd-HHmmss-fff'
        $out = Join-Path $LogDir ("gui-out-{0}.log" -f $stamp)
        $err = Join-Path $LogDir ("gui-err-{0}.log" -f $stamp)
    }

    $argList = @(
        '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', (ConvertTo-ProcessArgument $scriptPath)
    ) + @($Arguments | ForEach-Object { ConvertTo-ProcessArgument ([string]$_) })

    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = 'powershell.exe'
    $startInfo.Arguments = ($argList -join ' ')
    $startInfo.WorkingDirectory = $Root
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $startInfo
    try {
        if (-not $process.Start()) { throw 'The background process did not start.' }
    } catch {
        Show-GuiError "Could not start $ScriptName`n$($_.Exception.Message)"
        return $false
    }

    # Start-Process -PassThru with redirected output does not expose ExitCode
    # on Windows PowerShell 5.1. System.Diagnostics.Process does, and these
    # asynchronous reads keep a chatty child from blocking on a full pipe.
    $script:bgOutTask = $process.StandardOutput.ReadToEndAsync()
    $script:bgErrTask = $process.StandardError.ReadToEndAsync()

    $script:bgProcess = $process
    $script:bgOut = $out
    $script:bgErr = $err
    $script:bgLabel = $Label
    $script:bgTimer.Start()
    Set-UiBusy $true $Label
    return $true
}

function Set-UiBusy {
    param([bool]$Busy, [string]$Message = 'Ready')
    if ($script:startButton) { $script:startButton.Enabled = -not $Busy }
    if ($script:stopButton) { $script:stopButton.Enabled = -not $Busy }
    if ($script:restartButton) { $script:restartButton.Enabled = -not $Busy }
    if ($script:busyLabel) { $script:busyLabel.Text = $Message }
    if ($script:form) {
        $script:form.Cursor = if ($Busy) { [System.Windows.Forms.Cursors]::WaitCursor } else { [System.Windows.Forms.Cursors]::Default }
    }
    [System.Windows.Forms.Application]::DoEvents()
}

function Sync-StackState {
    $statePath = Join-Path $EtcDir 'stack.json'
    if (Test-Path $statePath) {
        try {
            $saved = Get-Content -Path $statePath -Raw | ConvertFrom-Json
            foreach ($property in $saved.PSObject.Properties) {
                $State[$property.Name] = $property.Value
            }
        } catch { }
    }

    $script:PhpPorts = @()
    for ($i = 0; $i -lt [int]$State.phpWorkers; $i++) { $script:PhpPorts += (9000 + $i) }
    $script:HttpPort = [int]$State.httpPort
    $script:HttpsPort = [int]$State.httpsPort
    $script:MysqlPort = [int]$State.mysqlPort
    $script:BindAddr = [string]$State.bind
    $script:PhpDir = Join-Path $PhpRoot $State.phpVersion
    $script:PhpExe = Join-Path $script:PhpDir 'php.exe'
    $script:PhpCgi = Join-Path $script:PhpDir 'php-cgi.exe'
    $script:PhpIni = Join-Path $script:PhpDir 'php.ini'
    $script:closeToTray = [bool]$State.closeToTray
}

function Complete-BgJob {
    $process = $script:bgProcess
    if (-not $process) { return }
    $process.Refresh()
    if (-not $process.HasExited) { return }

    $code = 0
    try { $code = [int]$process.ExitCode } catch { $code = 0 }
    $script:bgProcess = $null
    $script:bgTimer.Stop()
    Set-UiBusy $false 'Ready'
    Sync-StackState

    # Flush the asynchronous stream reads before the output files are tailed.
    try {
        if ($script:bgOutTask) { [System.IO.File]::WriteAllText($script:bgOut, [string]$script:bgOutTask.Result) }
    } catch { }
    try {
        if ($script:bgErrTask) { [System.IO.File]::WriteAllText($script:bgErr, [string]$script:bgErrTask.Result) }
    } catch { }
    $script:bgOutTask = $null
    $script:bgErrTask = $null
    try { $process.Dispose() } catch { }

    $tail = @()
    foreach ($path in @($script:bgOut, $script:bgErr)) {
        if (Test-Path $path) { $tail += @(Get-Content $path -Tail 25 -ErrorAction SilentlyContinue) }
    }
    $tail = @($tail | Where-Object { $_ -and $_.Trim() })

    Refresh-Ui
    Refresh-Projects

    $pendingCms = $script:pendingCmsResultFile
    $script:pendingCmsResultFile = $null

    if ($code -ne 0) {
        # A failed CMS install must not leave a credentials file behind, and
        # the project should not open as if it succeeded.
        $script:pendingOpenProject = $null
        if ($pendingCms) { Remove-Item -LiteralPath $pendingCms -Force -ErrorAction SilentlyContinue }
        $message = "WampDeck task failed (exit $code)."
        if ($tail.Count -gt 0) { $message += "`r`n`r`n" + ($tail -join "`r`n") }
        Show-GuiError $message
        return
    }

    if ($tail.Count -gt 0 -and $script:busyLabel) {
        $script:busyLabel.Text = [string]$tail[-1]
    }

    if ($script:pendingOpenProject) {
        $name = $script:pendingOpenProject
        $script:pendingOpenProject = $null
        $project = Get-ProjectByName $name
        if ($project) { Open-Url $project.Url }
    }

    if ($pendingCms -and (Test-Path -LiteralPath $pendingCms)) {
        try {
            $payload = Get-Content -LiteralPath $pendingCms -Raw -ErrorAction Stop | ConvertFrom-Json
            if ($payload.cms) { Show-CmsResultDialog $script:form $payload.cms }
        } catch {
            Show-GuiError "The CMS was installed, but its setup details could not be read.`n$($_.Exception.Message)"
        } finally {
            Remove-Item -LiteralPath $pendingCms -Force -ErrorAction SilentlyContinue
        }
    }
}

function Refresh-Ui {
    try { $status = Get-StackStatus } catch { return }
    $script:lastStatus = $status

    if ($script:cardPhpValue) {
        $script:cardPhpValue.Text = ((Get-WampDeckString 'Php') + " " + $State.phpVersion)
        $script:cardPhpDetail.Text = "$($status.PhpAlive)/$($status.PhpExpected) FastCGI workers"
    }
    if ($script:cardWebValue) {
        $script:cardWebValue.Text = (Get-WampDeckString 'WebServer')
        $script:cardWebDetail.Text = "port $HttpPort" + $(if ($State.ssl) { "  +  https $HttpsPort" } else { '' })
    }
    if ($script:cardDbValue) {
        $script:cardDbValue.Text = if ($status.MysqlRunning) { ((Get-WampDeckString 'MySql') + ' 8.4') } else { (Get-WampDeckString 'Database') }
        $script:cardDbDetail.Text = "port $MysqlPort, root / empty"
    }
    if ($script:cardToolsValue) {
        $enabled = @()
        if ($State.mailpit) { $enabled += 'Mailpit' }
        if ($State.redis) { $enabled += 'Redis' }
        if ($State.memcached) { $enabled += 'Memcached' }
        $script:cardToolsValue.Text = if ($enabled.Count -eq 1) { '1 service' } elseif ($enabled.Count) { "$($enabled.Count) services" } else { 'Optional services' }
        $script:cardToolsDetail.Text = if ($enabled.Count) { $enabled -join ', ' } else { 'enable from Settings' }
    }

    if ($script:headerBadge) {
        $online = $status.WebRunning -and $status.MysqlRunning
        $script:headerBadge.Text = if ($online) { (Get-WampDeckString 'Online') } else { (Get-WampDeckString 'Offline') }
        $script:headerBadge.ForeColor = if ($online) { $script:GuiColors.Accent } else { $script:GuiColors.Red }
    }

    if ($script:statusHosts) {
        try { $hosts = Get-HostsStatus } catch { $hosts = $null }
        if ($hosts) {
            $script:statusHosts.Text = if ($hosts.Synced) { "hosts: synced ($($hosts.Present))" } else { "hosts: missing $($hosts.Missing.Count)" }
            $script:statusHosts.ForeColor = if ($hosts.Synced) { $script:GuiColors.Accent } else { $script:GuiColors.Yellow }
        }
    }
    if ($script:statusSsl) {
        $script:statusSsl.Text = if ($State.ssl) {
            if (Test-CaTrusted) { (Get-WampDeckString 'SslOn') } else { (Get-WampDeckString 'SslOnCaUntrusted') }
        } else { (Get-WampDeckString 'SslOff') }
        $script:statusSsl.ForeColor = if ($State.ssl -and (Test-CaTrusted)) { $script:GuiColors.Accent } elseif ($State.ssl) { $script:GuiColors.Yellow } else { $script:GuiColors.Muted }
    }

    Refresh-ServiceRows $status
    Update-MenuChecks

    if ($script:trayIcon) {
        $any = $status.WebRunning -or $status.MysqlRunning
        $script:trayIcon.Text = if ($any) { 'WampDeck - running' } else { 'WampDeck - stopped' }
    }
}

function Refresh-Projects {
    if (-not $script:projectList) { return }
    $script:projectList.BeginUpdate()
    $script:projectList.Items.Clear()
    $projects = @(Get-ProjectList)
    foreach ($project in $projects) {
        $item = New-Object System.Windows.Forms.ListViewItem($project.Name)
        $php = [string]$project.PhpVersion
        if ($project.PhpPinned) { $php += ' *' }
        $item.SubItems.Add($php) | Out-Null
        $item.SubItems.Add($project.Url) | Out-Null
        $item.SubItems.Add($project.TestUrl) | Out-Null
        $item.SubItems.Add($project.Folder) | Out-Null
        $item.Tag = $project
        $script:projectList.Items.Add($item) | Out-Null
    }
    $script:projectList.EndUpdate()
    if ($script:projectCountLabel) {
        $lang = Get-WampDeckLanguage
        $key = if ($projects.Count -eq 1) { 'ProjectCount' } else { 'ProjectCountPlural' }
        $script:projectCountLabel.Text = (Get-WampDeckString $key -Language $lang -Format $projects.Count)
    }
}

function Update-ProjectPhpMenuChecks {
    if (-not $script:projectPhpMenuItems) { return }
    $current = 'any'
    if ($script:projectList -and $script:projectList.SelectedItems.Count -gt 0) {
        $project = $script:projectList.SelectedItems[0].Tag
        if ($project.PhpPinned) { $current = [string]$project.PhpVersion }
    }
    foreach ($key in @($script:projectPhpMenuItems.Keys)) {
        $script:projectPhpMenuItems[$key].Checked = ($key -eq $current)
    }
}

function Set-SelectedProjectPhp {
    # Pins the selected project to one PHP version, or back to the default.
    param([string]$Spec)

    if (-not $script:projectList -or $script:projectList.SelectedItems.Count -eq 0) { return }
    $project = $script:projectList.SelectedItems[0].Tag

    try {
        Update-WampDeckManifest -ProjectDir $project.Folder -Values @{ php = $Spec } | Out-Null
        Write-AllConfigs
        if ((Get-StackStatus).WebRunning) { Reload-WebServer | Out-Null }
        Refresh-Projects
        $updated = Get-ProjectByName $project.Name
        Show-GuiInfo ((Get-WampDeckString 'ProjectPhpChanged') -f $updated.Name, $updated.PhpVersion)
    } catch {
        Show-GuiError $_.Exception.Message
    }
}

function Initialize-ServiceRows {
    if (-not $script:serviceList) { return }
    $script:serviceList.Items.Clear()
    $webName = if ($State.webServer -eq 'apache') { 'Apache' } else { 'nginx' }
    $rows = @(
        @{ Key = 'mysql'; Name = 'MySQL 8.4'; Port = "$MysqlPort"; Core = $true },
        @{ Key = 'php'; Name = "PHP $($State.phpVersion)"; Port = "9000-$($PhpPorts[-1])"; Core = $true },
        @{ Key = 'web'; Name = $webName; Port = "$HttpPort"; Core = $true },
        @{ Key = 'mailpit'; Name = 'Mailpit'; Port = '1025 / 8025'; Core = $false },
        @{ Key = 'redis'; Name = 'Redis'; Port = '6379'; Core = $false },
        @{ Key = 'memcached'; Name = 'Memcached'; Port = '11211'; Core = $false }
    )
    foreach ($row in $rows) {
        $item = New-Object System.Windows.Forms.ListViewItem($row.Name)
        $item.SubItems.Add($row.Port) | Out-Null
        $item.SubItems.Add('stopped') | Out-Null
        $item.SubItems.Add($(if ($row.Core) { 'always' } else { 'off' })) | Out-Null
        $item.Tag = $row
        $script:serviceList.Items.Add($item) | Out-Null
    }
}

function Refresh-ServiceRows {
    param($Status)
    if (-not $script:serviceList) { return }

    $webName = if ($State.webServer -eq 'apache') { 'Apache' } else { 'nginx' }
    foreach ($item in $script:serviceList.Items) {
        $row = $item.Tag
        if (-not $row) { continue }
        switch ($row.Key) {
            'mysql' { $running = $Status.MysqlRunning }
            'php' { $running = ($Status.PhpAlive -eq $Status.PhpExpected) }
            'web' { $running = $Status.WebRunning }
            'mailpit' { $running = $Status.MailpitRunning }
            'redis' { $running = $Status.RedisRunning }
            'memcached' { $running = $Status.MemcachedRunning }
            default { $running = $false }
        }
        if ($row.Key -eq 'php') {
            $item.SubItems[0].Text = "PHP $($State.phpVersion)"
            $item.SubItems[1].Text = "9000-$($script:PhpPorts[-1])"
        }
        if ($row.Key -eq 'web') {
            $item.SubItems[0].Text = $webName
            $item.SubItems[1].Text = "$HttpPort"
        }
        $item.SubItems[2].Text = Get-StatusText $running
        $item.SubItems[2].ForeColor = if ($running) { $script:GuiColors.Accent } else { $script:GuiColors.Red }
        if ($row.Core) {
            $item.SubItems[3].Text = 'always'
        } else {
            $item.SubItems[3].Text = if ($State[$row.Key]) { 'on' } else { 'off' }
        }
    }
}

function Get-SelectedServiceKey {
    if (-not $script:serviceList -or $script:serviceList.SelectedItems.Count -eq 0) { return $null }
    return [string]$script:serviceList.SelectedItems[0].Tag.Key
}

function Start-ServiceByKey {
    param([string]$Key)
    try {
        switch ($Key) {
            'mysql' { Start-MysqlService | Out-Null }
            'php' { Start-PhpWorkers | Out-Null }
            'web' { Start-WebServer | Out-Null }
            'mailpit' { Start-MailpitService | Out-Null }
            'redis' { Start-RedisService | Out-Null }
            'memcached' { Start-MemcachedService | Out-Null }
        }
        Refresh-Ui
    } catch {
        Show-GuiError $_.Exception.Message
    }
}

function Stop-ServiceByKey {
    param([string]$Key)
    try {
        switch ($Key) {
            'mysql' { Stop-MysqlService | Out-Null }
            'php' { Stop-PhpWorkers | Out-Null }
            'web' { Stop-WebServer | Out-Null }
            'mailpit' { Stop-MailpitService | Out-Null }
            'redis' { Stop-RedisService | Out-Null }
            'memcached' { Stop-MemcachedService | Out-Null }
        }
        Refresh-Ui
    } catch {
        Show-GuiError $_.Exception.Message
    }
}

function Start-SelectedService {
    $key = Get-SelectedServiceKey
    if (-not $key) { return }
    Set-UiBusy $true (Get-WampDeckString 'StartingService')
    Start-ServiceByKey $key
    Set-UiBusy $false 'Ready'
}

function Stop-SelectedService {
    $key = Get-SelectedServiceKey
    if (-not $key) { return }
    Set-UiBusy $true (Get-WampDeckString 'StoppingService')
    Stop-ServiceByKey $key
    Set-UiBusy $false 'Ready'
}

function Toggle-StartupService {
    $key = Get-SelectedServiceKey
    if (-not $key) { return }
    if ($key -in @('mysql', 'php', 'web')) { return }
    $State[$key] = -not [bool]$State[$key]
    Save-StackState
    Refresh-Ui
}

function Start-StackAction {
    $conflicts = @(Get-WampDeckPortConflicts)
    if ($conflicts.Count -gt 0) {
        $choice = Show-PortConflictDialog $script:form $conflicts
        if ($choice -eq 'settings') { Show-SettingsAction; return }
        if ($choice -ne 'retry') { return }
        $conflicts = @(Get-WampDeckPortConflicts)
        if ($conflicts.Count -gt 0) {
            Show-GuiError 'The ports are still busy. Stop the other program or change the ports.'
            return
        }
    }
    Start-GuiScript -ScriptName 'start.ps1' -Label (Get-WampDeckString 'StartingTheStack') | Out-Null
}

function Stop-StackAction {
    Start-GuiScript -ScriptName 'stop.ps1' -Label (Get-WampDeckString 'StoppingTheStack') | Out-Null
}

function Restart-StackAction {
    Start-GuiScript -ScriptName 'restart.ps1' -Label (Get-WampDeckString 'RestartingTheStack') | Out-Null
}

function Show-SettingsAction {
    $result = Show-SettingsDialog $script:form
    if (-not $result) { return }

    $oldHttp = [int]$State.httpPort
    $oldHttps = [int]$State.httpsPort
    $oldMysql = [int]$State.mysqlPort
    $oldWorkers = [int]$State.phpWorkers
    $oldBind = [string]$State.bind
    $oldSsl = [bool]$State.ssl

    $State.httpPort = $result.HttpPort
    $State.httpsPort = $result.HttpsPort
    $State.mysqlPort = $result.MysqlPort
    $State.phpWorkers = $result.PhpWorkers
    $State.bind = $result.Bind
    $State.ssl = $result.Ssl
    $State.mailpit = $result.Mailpit
    $State.redis = $result.Redis
    $State.memcached = $result.Memcached
    $State.autoStart = $result.AutoStart
    $State.closeToTray = $result.CloseToTray
    $script:closeToTray = [bool]$result.CloseToTray
    Save-StackState
    if ($result.Language) { Set-WampDeckLanguage -Code ([string]$result.Language) }
    Update-GuiLanguageTexts

    try {
        Write-AllConfigs
        if ($State.ssl -and -not (Test-SslCertificate)) {
            Initialize-Ssl -SkipTrust | Out-Null
        }
    } catch {
        Show-GuiError "Settings saved, but config generation failed.`n$($_.Exception.Message)"
        return
    }

    # Refresh the path/port variables used by the running panel. These must be
    # script scope, otherwise the timer keeps using the old values.
    $script:PhpPorts = @()
    for ($i = 0; $i -lt [int]$State.phpWorkers; $i++) { $script:PhpPorts += (9000 + $i) }
    $script:HttpPort = [int]$State.httpPort
    $script:HttpsPort = [int]$State.httpsPort
    $script:MysqlPort = [int]$State.mysqlPort
    $script:BindAddr = [string]$State.bind
    $script:PhpDir = Join-Path $PhpRoot $State.phpVersion
    $script:PhpExe = Join-Path $script:PhpDir 'php.exe'
    $script:PhpCgi = Join-Path $script:PhpDir 'php-cgi.exe'
    $script:PhpIni = Join-Path $script:PhpDir 'php.ini'

    Refresh-Ui
    if ($State.ssl -and -not (Test-CaTrusted)) {
        Show-GuiInfo 'HTTPS is enabled. Run Settings -> SSL -> Trust CA once and confirm the Windows security dialog.'
    }

    $running = (Get-StackStatus)
    if ($running.WebRunning -or $running.MysqlRunning) {
        $restart = Ask-GuiYesNo 'Restart the stack now to apply the new ports and services?'
        if ($restart) { Restart-StackAction }
    }
}

function Show-ExtensionsAction {
    $result = Show-ExtensionsDialog $script:form
    if (-not $result) { return }
    if ($result.Enable.Count -eq 0 -and $result.Disable.Count -eq 0) { return }

    try {
        if ($result.Enable.Count -gt 0) { Set-PhpExtensions -Enable $result.Enable | Out-Null }
        if ($result.Disable.Count -gt 0) { Set-PhpExtensions -Disable $result.Disable | Out-Null }
    } catch {
        Show-GuiError $_.Exception.Message
        return
    }

    $status = Get-StackStatus
    if ($status.WebRunning) {
        Start-GuiScript -ScriptName 'reload.ps1' -Label 'Reloading PHP...' | Out-Null
    } else {
        Show-GuiInfo "php.ini updated for PHP $($State.phpVersion)."
    }
}

function Create-ProjectAction {
    $result = Show-ProjectDialog $script:form
    if (-not $result) { return }
    # Panel jobs never elevate: an invisible UAC prompt would block the
    # background task. .localhost works immediately; .test domains are added
    # later from Tools -> Sync hosts.
    $arguments = @('-Name', $result.Name, '-Type', $result.Type, '-NoHosts')
    if ($result.Open) { $script:pendingOpenProject = $result.Name }
    Start-GuiScript -ScriptName 'new.ps1' -Arguments $arguments -Label "Creating $($result.Name)..." | Out-Null
}

function Create-CmsAction {
    param([string]$PresetCms = '')

    $result = Show-CmsDialog $script:form -PresetCms $PresetCms
    if (-not $result) { return }

    try {
        if (-not (Test-TcpPort -Port $MysqlPort)) {
            # A CMS install needs MySQL. One-click flow: start MySQL ourselves
            # instead of stopping with "start the stack first". Only MySQL is
            # required here (no web server), so this is quick and safe.
            Set-UiBusy $true 'Starting MySQL...'
            try {
                Start-MysqlService | Out-Null
            } finally {
                Set-UiBusy $false
            }
            if (-not (Test-TcpPort -Port $MysqlPort)) {
                Show-GuiError 'MySQL could not be started. Check logs\mysql-error.log and try again.'
                return
            }
        }
    } catch {
        Show-GuiError $_.Exception.Message
        return
    }

    # new.ps1 writes the generated credentials to this file. The panel reads
    # it once and deletes it, so the password never stays in a log file.
    Ensure-Dir $TmpDir
    Get-ChildItem -LiteralPath $TmpDir -Filter 'cms-result-*.json' -ErrorAction SilentlyContinue |
        Remove-Item -Force -ErrorAction SilentlyContinue
    $resultFile = Join-Path $TmpDir ("cms-result-{0}-{1}.json" -f $result.Name, [guid]::NewGuid().ToString('N'))
    # -NoHosts keeps the background job from raising an invisible UAC prompt.
    $arguments = @('-Name', $result.Name, '-Cms', $result.Cms, '-ResultFile', $resultFile, '-NoHosts')
    if ($result.AdminUser) { $arguments += @('-AdminUser', $result.AdminUser) }
    if ($result.AdminEmail) { $arguments += @('-AdminEmail', $result.AdminEmail) }
    if ($result.AdminPassword) { $arguments += @('-AdminPassword', $result.AdminPassword) }

    $entry = Resolve-WampDeckCms $result.Cms
    $started = Start-GuiScript -ScriptName 'new.ps1' -Arguments $arguments -Label "Installing $($entry.Name) in $($result.Name)..."
    if (-not $started) { return }

    $script:pendingCmsResultFile = $resultFile
    if ($result.Open) { $script:pendingOpenProject = $result.Name }
}

function Delete-SelectedProject {
    if (-not $script:projectList -or $script:projectList.SelectedItems.Count -eq 0) { return }
    $project = $script:projectList.SelectedItems[0].Tag
    if (-not (Ask-GuiYesNo "Delete the folder www\$($project.Name) and everything inside it?" 'Delete project')) { return }
    try {
        Remove-Item -LiteralPath $project.Folder -Recurse -Force
        Write-AllConfigs
        try {
            if ((Get-StackStatus).WebRunning) { Reload-WebServer | Out-Null }
        } catch { }
        Refresh-Projects
        Refresh-Ui
    } catch {
        Show-GuiError "Could not delete the project.`n$($_.Exception.Message)"
    }
}

function Open-SelectedProject {
    if (-not $script:projectList -or $script:projectList.SelectedItems.Count -eq 0) { return }
    Open-Url $script:projectList.SelectedItems[0].Tag.Url
}

function Open-SelectedFolder {
    if (-not $script:projectList -or $script:projectList.SelectedItems.Count -eq 0) { return }
    Start-Process explorer.exe $script:projectList.SelectedItems[0].Tag.Folder
}

function Deploy-SelectedProject {
    # Runs the deploy pre-check for the selected CMS project and opens a
    # readable report in Notepad, so the user does not have to use the CLI.
    if (-not $script:projectList -or $script:projectList.SelectedItems.Count -eq 0) {
        Show-GuiInfo 'Select a project in the list first.'
        return
    }
    $project = $script:projectList.SelectedItems[0].Tag
    try {
        $parsed = [pscustomobject]@{ Positional = @('deploy', $project.Name); Options = @{ json = $true } }
        $raw = @(Invoke-CliDeploy -Parsed $parsed)
        $jsonText = @($raw | Where-Object { $_ -is [string] -and $_ -match '^\s*\{' } | Select-Object -First 1)[0]
        if (-not $jsonText) { throw 'The deploy pre-check returned no report.' }
        $data = $jsonText | ConvertFrom-Json

        $report = New-Object System.Collections.Generic.List[string]
        $report.Add("WampDeck deploy pre-check - $($data.project)")
        $report.Add('')
        foreach ($c in $data.checks) {
            $tag = switch ($c.status) { 'pass' { '[ok]' } 'warn' { '[warn]' } 'fail' { '[fail]' } default { '[skip]' } }
            $report.Add(("  {0,-7} {1,-26} {2}" -f $tag, $c.title, $c.detail))
            if ($c.fix -and $c.status -ne 'pass') { $report.Add(('           -> ' + $c.fix)) }
        }
        $report.Add('')
        $report.Add('VPS deployment checklist')
        foreach ($line in $data.checklist) { $report.Add($line) }
        $fail = @($data.checks | Where-Object { $_.status -eq 'fail' }).Count
        $warn = @($data.checks | Where-Object { $_.status -eq 'warn' }).Count
        $pass = @($data.checks | Where-Object { $_.status -eq 'pass' }).Count
        $report.Add('')
        $report.Add("  $pass passed, $warn warnings, $fail failed")

        $reportPath = Join-Path $LogDir ("deploy-$($project.Name).txt")
        Set-Content -Path $reportPath -Value ($report -join "`r`n") -Encoding UTF8
        Start-Process notepad.exe -ArgumentList "`"$reportPath`""
    } catch {
        Show-GuiError "Deploy pre-check failed.`n$($_.Exception.Message)"
    }
}

function Open-SelectedTerminal {
    if (-not $script:projectList -or $script:projectList.SelectedItems.Count -eq 0) {
        try { Open-Terminal } catch { Show-GuiError $_.Exception.Message }
        return
    }
    try {
        Open-Terminal -Path $script:projectList.SelectedItems[0].Tag.Folder
    } catch {
        Show-GuiError $_.Exception.Message
    }
}

function Update-MenuChecks {
    if ($script:autoStartMenuItem) {
        $script:autoStartMenuItem.Checked = [bool]$State.autoStart
    }
    if ($script:startupMenuItem) {
        $script:startupMenuItem.Checked = Test-Path $StartupShortcut
    }
    if ($script:sslEnableItem) { $script:sslEnableItem.Checked = [bool]$State.ssl }
    if ($script:sslDisableItem) { $script:sslDisableItem.Checked = -not [bool]$State.ssl }
    if ($script:phpMenuItems) {
        foreach ($entry in $script:phpMenuItems.GetEnumerator()) {
            $entry.Value.Checked = ($entry.Key -eq $State.phpVersion)
        }
    }
    if ($script:webMenuItems) {
        foreach ($entry in $script:webMenuItems.GetEnumerator()) {
            $entry.Value.Checked = ($entry.Key -eq $State.webServer)
        }
    }
    if ($script:languageMenuItems) {
        $currentLanguage = Get-WampDeckLanguage
        foreach ($entry in $script:languageMenuItems.GetEnumerator()) {
            $entry.Value.Checked = ($entry.Key -eq $currentLanguage)
        }
    }
}

function New-AutoStartShortcut {
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($StartupShortcut)
    $launcher = Join-Path $Root 'WampDeck.exe'
    if (Test-Path -LiteralPath $launcher) {
        $shortcut.TargetPath = $launcher
        $shortcut.Arguments = '-Tray'
        $shortcut.IconLocation = "$launcher,0"
    } else {
        $shortcut.TargetPath = 'powershell.exe'
        $shortcut.Arguments = "-Sta -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$Root\panel.ps1`" -Tray"
        $shortcut.IconLocation = "$env:SystemRoot\System32\shell32.dll,21"
    }
    $shortcut.WorkingDirectory = $Root
    $shortcut.Description = 'WampDeck local development stack'
    $shortcut.Save()
}

function Toggle-AutoStart {
    try {
        if (Test-Path $StartupShortcut) {
            Remove-Item $StartupShortcut -Force
            Show-GuiInfo 'WampDeck will no longer start with Windows.'
        } else {
            New-AutoStartShortcut
            Show-GuiInfo 'WampDeck will start with Windows (in the notification area).'
        }
        Update-MenuChecks
    } catch {
        Show-GuiError "Could not update the startup shortcut.`n$($_.Exception.Message)"
    }
}

function Show-About {
    $version = @(Get-ToolVersions | ForEach-Object { "$($_.Name): $($_.Version)" }) -join "`r`n"
    $text = @"
WampDeck
Portable PHP development stack
$Root

PHP $($State.phpVersion)  |  $($State.webServer)  |  MySQL on $MysqlPort

Website:  https://wampdeck.com
Company:  https://oryxindia.in

$version
"@
    Show-GuiInfo $text 'About WampDeck'
}
