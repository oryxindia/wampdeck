# WampDeck control panel - native WinForms GUI.
#
#   .\panel.cmd
#   powershell -Sta -ExecutionPolicy Bypass -File .\panel.ps1
#   powershell -Sta -ExecutionPolicy Bypass -File .\panel.ps1 -Tray

param([switch]$Tray)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib\bootstrap.ps1')
. (Join-Path $PSScriptRoot 'lib\gui.ps1')
. (Join-Path $PSScriptRoot 'lib\gui-dialogs.ps1')
. (Join-Path $PSScriptRoot 'lib\gui-settings.ps1')
. (Join-Path $PSScriptRoot 'lib\gui-panel.ps1')
. (Join-Path $PSScriptRoot 'lib\i18n.ps1')

[System.Windows.Forms.Application]::EnableVisualStyles()
[System.Windows.Forms.Application]::SetCompatibleTextRenderingDefault($false)

# ---------------------------------------------------------------- single instance
# The mutex is created before the form exists, so a double launch during
# startup still cannot open a second panel. The named event asks the
# running instance to bring its window back (also from the tray).
$instanceRoot = $Root.TrimEnd('\').ToLowerInvariant()
$sha1 = [System.Security.Cryptography.SHA1]::Create()
try {
    $hashBytes = $sha1.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($instanceRoot))
} finally {
    $sha1.Dispose()
}
$instanceId = ([System.BitConverter]::ToString($hashBytes) -replace '-', '').Substring(0, 16)
$script:activateEvent = New-Object System.Threading.EventWaitHandle($false, [System.Threading.EventResetMode]::AutoReset, "Local\WampDeckActivate_$instanceId")
$createdNew = $false
$script:instanceMutex = New-Object System.Threading.Mutex($true, "Local\WampDeckPanel_$instanceId", [ref]$createdNew)
if (-not $createdNew) {
    if (-not $Tray) {
        try { [void]$script:activateEvent.Set() } catch { }
    }
    $script:activateEvent.Dispose()
    $script:instanceMutex.Dispose()
    return
}

$script:closeToTray = [bool]$State.closeToTray
$script:exiting = $false
$script:bgProcess = $null
$script:lastStatus = $null
$script:pendingOpenProject = $null
$script:pendingCmsResultFile = $null
$script:toolTips = @()
$script:cmsActiveTile = ''
$script:phpMenuItems = @{}
$script:webMenuItems = @{}
$script:iconBitmap = $null

# ---------------------------------------------------------------- icon
function New-WampDeckIcon {
    $bitmap = New-Object System.Drawing.Bitmap 32, 32
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.Clear([System.Drawing.Color]::FromArgb(8, 12, 20))
    $brush = New-Object System.Drawing.SolidBrush($script:GuiColors.Accent)
    $font = New-Object System.Drawing.Font('Segoe UI', 19, [System.Drawing.FontStyle]::Bold)
    $graphics.DrawString('W', $font, $brush, -3, -2)
    $graphics.Dispose()
    $brush.Dispose()
    $script:iconBitmap = $bitmap
    return [System.Drawing.Icon]::FromHandle($bitmap.GetHicon())
}

$script:appIcon = New-WampDeckIcon
# Prefer the real .ico file for the window/taskbar icon. Windows shows the
# process icon (PowerShell) in the taskbar when the Form only carries a
# runtime-generated bitmap icon, so load the shipped .ico when it exists.
$iconPath = Join-Path $Root 'assets\wampdeck.ico'
if (Test-Path -LiteralPath $iconPath) {
    try { $script:appIcon = New-Object System.Drawing.Icon -ArgumentList $iconPath } catch { }
}

# The panel runs inside powershell.exe. Windows groups taskbar buttons by
# AppUserModelID, so without an explicit one it shows the PowerShell icon
# instead of the WampDeck icon. Register a WampDeck id for this process.
try {
    Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class WampDeckAppId {
    [DllImport("shell32.dll", CharSet = CharSet.Unicode)]
    public static extern void SetCurrentProcessExplicitAppUserModelID([MarshalAs(UnmanagedType.LPWStr)] string appID);
}
'@
    [WampDeckAppId]::SetCurrentProcessExplicitAppUserModelID('OryxIndia.WampDeck.Panel')
} catch { }

# ---------------------------------------------------------------- form
$form = New-Object System.Windows.Forms.Form
$form.Text = Get-WampDeckString 'AppTitle'
$form.ClientSize = New-Object System.Drawing.Size(940, 668)
$form.MinimumSize = New-Object System.Drawing.Size(900, 620)
$form.StartPosition = 'CenterScreen'
$form.Icon = $script:appIcon
$form.BackColor = $script:GuiColors.Background
$form.ForeColor = $script:GuiColors.Text
$form.Font = $script:GuiFont
$script:form = $form

function Show-ProHubWindow {
    param([int]$Tab = 0)
    $map = @('health','backups','xdebug','git','mailpit','more')
    $name = $map[0]
    if ($Tab -ge 0 -and $Tab -lt $map.Count) { $name = $map[$Tab] }
    try { Show-ProWindow -Name $name } catch { Show-GuiError $_.Exception.Message }
}
function Start-ProHub { Show-ProWindow -Name health }
function Exit-WampDeck {
    $script:exiting = $true
    if ($script:trayIcon) { $script:trayIcon.Visible = $false }
    $form.Close()
    [System.Windows.Forms.Application]::Exit()
}

$script:menuItemRegistry = @{}
$script:tabTextItems = @{}

function Add-MenuItem {
    param(
        $Menu,
        [string]$Text,
        [scriptblock]$OnClick,
        $Shortcut = $null,
        [switch]$Checkable,
        [string]$Name
    )
    $item = New-Object System.Windows.Forms.ToolStripMenuItem -ArgumentList $Text
    if ($null -ne $Shortcut) { $item.ShortcutKeys = $Shortcut }
    if (-not $Checkable) { $item.CheckOnClick = $false }
    if ($OnClick) { $item.Add_Click($OnClick) }
    [void]$Menu.DropDownItems.Add($item)
    if ($Name) { $script:menuItemRegistry[$Name] = $item }
    return $item
}

function Add-MenuSeparator {
    param($Menu)
    [void]$Menu.DropDownItems.Add((New-Object System.Windows.Forms.ToolStripSeparator))
}

function Set-MenuItemText {
    param([string]$Name, [string]$Text)
    $item = $script:menuItemRegistry[$Name]
    if ($item) { $item.Text = $Text }
}

function Update-GuiLanguageTexts {
    $lang = Get-WampDeckLanguage
    if ($script:form) { $script:form.Text = Get-WampDeckString 'AppTitle' -Language $lang }
    if ($script:subtitle) { $script:subtitle.Text = Get-WampDeckString 'AppSubtitle' -Language $lang }
    if ($script:terminalButton) {
        $script:terminalButton.Text = Get-WampDeckString 'Terminal' -Language $lang
        if ($script:terminalTip) { $script:terminalTip.SetToolTip($script:terminalButton, (Get-WampDeckString 'TerminalHint' -Language $lang)) }
    }
    if ($script:startButton) { $script:startButton.Text = Get-WampDeckString 'Start' -Language $lang }
    if ($script:stopButton) { $script:stopButton.Text = Get-WampDeckString 'Stop' -Language $lang }
    if ($script:restartButton) { $script:restartButton.Text = Get-WampDeckString 'Restart' -Language $lang }
    if ($script:busyLabel) { $script:busyLabel.Text = Get-WampDeckString 'Ready' -Language $lang }
    if ($script:projectTabButton) { $script:projectTabButton.Text = Get-WampDeckString 'TabProjects' -Language $lang }
    if ($script:servicesTabButton) { $script:servicesTabButton.Text = Get-WampDeckString 'TabServices' -Language $lang }
    if ($script:toolsTabButton) { $script:toolsTabButton.Text = Get-WampDeckString 'TabTools' -Language $lang }
    if ($script:servicesHint) { $script:servicesHint.Text = Get-WampDeckString 'ServicesHint' -Language $lang }
    if ($script:projectHint) { $script:projectHint.Text = Get-WampDeckString 'WwwHint' -Language $lang }
    Set-MenuItemText -Name 'stackStart' -Text (Get-WampDeckString 'StartStack' -Language $lang)
    Set-MenuItemText -Name 'stackStop' -Text (Get-WampDeckString 'StopStack' -Language $lang)
    Set-MenuItemText -Name 'stackRestart' -Text (Get-WampDeckString 'RestartStack' -Language $lang)
    Set-MenuItemText -Name 'stackOpenPanel' -Text (Get-WampDeckString 'OpenPanelInBrowser' -Language $lang)
    Set-MenuItemText -Name 'stackOpenWww' -Text (Get-WampDeckString 'OpenWwwFolder' -Language $lang)
    Set-MenuItemText -Name 'stackOpenLogs' -Text (Get-WampDeckString 'OpenLogsFolder' -Language $lang)
    Set-MenuItemText -Name 'stackTerminal' -Text (Get-WampDeckString 'TerminalInWww' -Language $lang)
    Set-MenuItemText -Name 'stackQuit' -Text (Get-WampDeckString 'Quit' -Language $lang)
    Set-MenuItemText -Name 'projectNew' -Text (Get-WampDeckString 'NewProject' -Language $lang)
    Set-MenuItemText -Name 'projectOpen' -Text (Get-WampDeckString 'OpenInBrowser' -Language $lang)
    Set-MenuItemText -Name 'projectOpenTest' -Text (Get-WampDeckString 'OpenTestUrl' -Language $lang)
    Set-MenuItemText -Name 'projectOpenFolder' -Text (Get-WampDeckString 'OpenFolder' -Language $lang)
    Set-MenuItemText -Name 'projectOpenTerminal' -Text (Get-WampDeckString 'OpenTerminalHere' -Language $lang)
    Set-MenuItemText -Name 'projectCopyUrl' -Text (Get-WampDeckString 'CopyLocalUrl' -Language $lang)
    Set-MenuItemText -Name 'projectDelete' -Text (Get-WampDeckString 'DeleteProject' -Language $lang)
    Set-MenuItemText -Name 'projectPhp' -Text (Get-WampDeckString 'ProjectPhpVersion' -Language $lang)
    if ($script:projectPhpDefaultItem) {
        $script:projectPhpDefaultItem.Text = ((Get-WampDeckString 'ProjectPhpDefault' -Language $lang) -f $State.phpVersion)
    }
    Set-MenuItemText -Name 'projectRefresh' -Text (Get-WampDeckString 'RefreshProjects' -Language $lang)
    Set-MenuItemText -Name 'toolsHeidi' -Text (Get-WampDeckString 'HeidiSql' -Language $lang)
    Set-MenuItemText -Name 'toolsMailpit' -Text (Get-WampDeckString 'MailpitInbox' -Language $lang)
    Set-MenuItemText -Name 'toolsAdminer' -Text (Get-WampDeckString 'Adminer' -Language $lang)
    Set-MenuItemText -Name 'toolsPhpinfo' -Text (Get-WampDeckString 'Phpinfo' -Language $lang)
    Set-MenuItemText -Name 'toolsTerminal' -Text (Get-WampDeckString 'TerminalInWww' -Language $lang)
    Set-MenuItemText -Name 'toolsNotepad' -Text (Get-WampDeckString 'Notepad' -Language $lang)
    Set-MenuItemText -Name 'toolsNgrokStart' -Text (Get-WampDeckString 'NgrokStart' -Language $lang)
    Set-MenuItemText -Name 'toolsNgrokStop' -Text (Get-WampDeckString 'NgrokStop' -Language $lang)
    Set-MenuItemText -Name 'toolsCronical' -Text (Get-WampDeckString 'Cronical' -Language $lang)
    Set-MenuItemText -Name 'toolsSyncHosts' -Text (Get-WampDeckString 'SyncHosts' -Language $lang)
    Set-MenuItemText -Name 'toolsEditHosts' -Text (Get-WampDeckString 'EditHosts' -Language $lang)
    Set-MenuItemText -Name 'toolsCerts' -Text (Get-WampDeckString 'CertificatesFolder' -Language $lang)
    Set-MenuItemText -Name 'menuSettings' -Text (Get-WampDeckString 'Settings' -Language $lang)
    Set-MenuItemText -Name 'menuPhpExt' -Text (Get-WampDeckString 'PhpExtensions' -Language $lang)
    Set-MenuItemText -Name 'menuPhpVersion' -Text ((Get-WampDeckString 'Php' -Language $lang) + ' ' + $State.phpVersion)
    Set-MenuItemText -Name 'menuWebServer' -Text ((Get-WampDeckString 'WebServer' -Language $lang) + ' ' + $State.webServer)
    Set-MenuItemText -Name 'menuHttpsEnable' -Text (Get-WampDeckString 'EnableHttps' -Language $lang)
    Set-MenuItemText -Name 'menuHttpsDisable' -Text (Get-WampDeckString 'DisableHttps' -Language $lang)
    Set-MenuItemText -Name 'menuHttpsTrust' -Text (Get-WampDeckString 'TrustCert' -Language $lang)
    Set-MenuItemText -Name 'menuHttpsRegen' -Text (Get-WampDeckString 'RegenerateCert' -Language $lang)
    Set-MenuItemText -Name 'menuStartWithWindows' -Text (Get-WampDeckString 'StartWithWindows' -Language $lang)
    Set-MenuItemText -Name 'menuRefreshConfigs' -Text (Get-WampDeckString 'RefreshConfigs' -Language $lang)
    Set-MenuItemText -Name 'menuAbout' -Text (Get-WampDeckString 'About' -Language $lang)
    Set-MenuItemText -Name 'menuReadme' -Text (Get-WampDeckString 'Readme' -Language $lang)
    Set-MenuItemText -Name 'menuOpenInstall' -Text (Get-WampDeckString 'OpenInstallFolder' -Language $lang)
    Set-MenuItemText -Name 'menuTopStack' -Text (Get-WampDeckString 'Stack' -Language $lang)
    Set-MenuItemText -Name 'menuTopProject' -Text (Get-WampDeckString 'Project' -Language $lang)
    Set-MenuItemText -Name 'menuTopTools' -Text (Get-WampDeckString 'Tools' -Language $lang)
    Set-MenuItemText -Name 'menuTopSettings' -Text (Get-WampDeckString 'Settings' -Language $lang)
    Set-MenuItemText -Name 'menuTopHelp' -Text (Get-WampDeckString 'Help' -Language $lang)
    Set-MenuItemText -Name 'menuLanguage' -Text (Get-WampDeckString 'Language' -Language $lang)
    if ($script:tabTextItems) {
        foreach ($key in @($script:tabTextItems.Keys)) {
            $script:tabTextItems[$key].Text = Get-WampDeckString $key -Language $lang
        }
    }
}

$menuStrip = New-Object System.Windows.Forms.MenuStrip
$menuStrip.Dock = 'Top'
$menuStrip.Font = $script:GuiFont
$form.Controls.Add($menuStrip)

$stackMenu = New-Object System.Windows.Forms.ToolStripMenuItem -ArgumentList (Get-WampDeckString 'Stack')
$projectMenu = New-Object System.Windows.Forms.ToolStripMenuItem -ArgumentList (Get-WampDeckString 'Project')
$toolsMenu = New-Object System.Windows.Forms.ToolStripMenuItem -ArgumentList (Get-WampDeckString 'Tools')
$settingsMenu = New-Object System.Windows.Forms.ToolStripMenuItem -ArgumentList (Get-WampDeckString 'Settings')
$helpMenu = New-Object System.Windows.Forms.ToolStripMenuItem -ArgumentList (Get-WampDeckString 'Help')
$proInstalled = ((Test-Path (Join-Path $Root 'pro\license.dat')) -and (Test-Path (Join-Path $Root 'pro\wampdeck-pro-hub.ps1')))
if ($proInstalled) {
    try { . (Join-Path $Root 'pro\wampdeck-pro-windows.ps1') } catch { }
    $proMenu = New-Object System.Windows.Forms.ToolStripMenuItem -ArgumentList 'Pro'
    $proMenu.ForeColor = [System.Drawing.Color]::FromArgb(255, 197, 66)
    $proTabs = @(
    @{ Label = 'PHP Frameworks...'; Name = 'frameworks' },
        @{ Label = 'Health Dashboard...'; Name = 'health' },
    @{ Label = 'Backups & Schedule...'; Name = 'backups' },
    @{ Label = 'Xdebug Toggle...'; Name = 'xdebug' },
    @{ Label = 'Git Tools...'; Name = 'git' },
    @{ Label = 'Mailpit Pro - captured mail...'; Name = 'mailpit' },
    @{ Label = 'Add-ons, Vault & Team...'; Name = 'more' }
)
    foreach ($entry in $proTabs) {
        $mi = New-Object System.Windows.Forms.ToolStripMenuItem -ArgumentList $entry.Label
        $winName = [string]$entry.Name
        $clickBlock = { param($sender, $e) Show-ProWindow -Name $winName }.GetNewClosure()
        $mi.Add_Click($clickBlock)
        [void]$proMenu.DropDownItems.Add($mi)
    }
    [void]$proMenu.DropDownItems.Add((New-Object System.Windows.Forms.ToolStripSeparator))
    $backupNow = New-Object System.Windows.Forms.ToolStripMenuItem -ArgumentList 'Run backup now'
    $backupNow.Add_Click({
        try { Invoke-ProBackup -Keep 7; [System.Windows.Forms.MessageBox]::Show('Backup completed.', 'WampDeck Pro') }
        catch { Show-GuiError $_.Exception.Message }
    })
    [void]$proMenu.DropDownItems.Add($backupNow)
    $licenceItem = New-Object System.Windows.Forms.ToolStripMenuItem -ArgumentList 'Licence info...'
    $licenceItem.Add_Click({
        $l = Test-ProLicense
        $text = if ($l.Valid) { "Plan: $($l.Plan)`r`nSerial: $($l.Serial)`r`nSeats: $($l.Seats)`r`nExpires: $(if (-not $l.Expires) { 'lifetime' } else { $l.Expires.ToString('yyyy-MM-dd') })" } else { "Not valid: $($l.Reason)" }
        [System.Windows.Forms.MessageBox]::Show($text, 'WampDeck Pro licence')
    })
    [void]$proMenu.DropDownItems.Add($licenceItem)
}
foreach ($item in @($stackMenu, $projectMenu, $toolsMenu)) {
    [void]$menuStrip.Items.Add($item)
}
if ($proInstalled) { [void]$menuStrip.Items.Add($proMenu) }
foreach ($item in @($settingsMenu, $helpMenu)) {
    [void]$menuStrip.Items.Add($item)
}
$script:menuItemRegistry['menuTopStack'] = $stackMenu
$script:menuItemRegistry['menuTopProject'] = $projectMenu
$script:menuItemRegistry['menuTopTools'] = $toolsMenu
$script:menuItemRegistry['menuTopSettings'] = $settingsMenu
$script:menuItemRegistry['menuTopHelp'] = $helpMenu

# ---------------------------------------------------------------- menus
function Open-Folder {
    param([string]$Path)
    Start-Process -FilePath 'explorer.exe' -ArgumentList "`"$Path`""
}

$null = Add-MenuItem $stackMenu (Get-WampDeckString 'StartStack') { Start-StackAction } ([System.Windows.Forms.Keys]::F5) -Name 'stackStart'
$null = Add-MenuItem $stackMenu (Get-WampDeckString 'StopStack') { Stop-StackAction } ([System.Windows.Forms.Keys]::Shift -bor [System.Windows.Forms.Keys]::F5) -Name 'stackStop'
$null = Add-MenuItem $stackMenu (Get-WampDeckString 'RestartStack') { Restart-StackAction } ([System.Windows.Forms.Keys]::Control -bor [System.Windows.Forms.Keys]::F5) -Name 'stackRestart'
Add-MenuSeparator $stackMenu
$null = Add-MenuItem $stackMenu (Get-WampDeckString 'OpenPanelInBrowser') { Open-Url $PanelUrl } -Name 'stackOpenPanel'
$null = Add-MenuItem $stackMenu (Get-WampDeckString 'OpenWwwFolder') { Open-Folder $WwwDir } -Name 'stackOpenWww'
$null = Add-MenuItem $stackMenu (Get-WampDeckString 'OpenLogsFolder') { Open-Folder $LogDir } -Name 'stackOpenLogs'
$null = Add-MenuItem $stackMenu (Get-WampDeckString 'TerminalInWww') { try { Open-Terminal } catch { Show-GuiError $_.Exception.Message } } -Name 'stackTerminal'
Add-MenuSeparator $stackMenu
$null = Add-MenuItem $stackMenu (Get-WampDeckString 'Quit') { Exit-WampDeck } -Name 'stackQuit'

$null = Add-MenuItem $projectMenu (Get-WampDeckString 'NewProject') { Create-ProjectAction } ([System.Windows.Forms.Keys]::Control -bor [System.Windows.Forms.Keys]::N) -Name 'projectNew'
$null = Add-MenuItem $projectMenu 'Install CMS...' { Create-CmsAction } ([System.Windows.Forms.Keys]::Control -bor [System.Windows.Forms.Keys]::Shift -bor [System.Windows.Forms.Keys]::N) -Name 'projectCms'

$null = Add-MenuItem $projectMenu 'Deploy pre-check...' { Deploy-SelectedProject } -Name 'projectDeploy'
$null = Add-MenuItem $projectMenu (Get-WampDeckString 'OpenInBrowser') { Open-SelectedProject } -Name 'projectOpen'
$null = Add-MenuItem $projectMenu (Get-WampDeckString 'OpenTestUrl') {
    if ($script:projectList -and $script:projectList.SelectedItems.Count -gt 0) {
        Open-Url $script:projectList.SelectedItems[0].Tag.TestUrl
    }
} -Name 'projectOpenTest'
$null = Add-MenuItem $projectMenu (Get-WampDeckString 'OpenFolder') { Open-SelectedFolder } -Name 'projectOpenFolder'
$null = Add-MenuItem $projectMenu (Get-WampDeckString 'OpenTerminalHere') { Open-SelectedTerminal } -Name 'projectOpenTerminal'
$null = Add-MenuItem $projectMenu (Get-WampDeckString 'CopyLocalUrl') {
    if ($script:projectList -and $script:projectList.SelectedItems.Count -gt 0) {
        [System.Windows.Forms.Clipboard]::SetText([string]$script:projectList.SelectedItems[0].Tag.Url)
    }
} -Name 'projectCopyUrl'
$null = Add-MenuItem $projectMenu (Get-WampDeckString 'DeleteProject') { Delete-SelectedProject } -Name 'projectDelete'
Add-MenuSeparator $projectMenu
$null = Add-MenuItem $projectMenu (Get-WampDeckString 'RefreshProjects') { Refresh-Projects } -Name 'projectRefresh'

$null = Add-MenuItem $toolsMenu (Get-WampDeckString 'HeidiSql') { try { Open-HeidiSql } catch { Show-GuiError $_.Exception.Message } } -Name 'toolsHeidi'
$null = Add-MenuItem $toolsMenu (Get-WampDeckString 'MailpitInbox') { Open-Mailpit } -Name 'toolsMailpit'
$null = Add-MenuItem $toolsMenu (Get-WampDeckString 'Adminer') { Open-Url "$PanelUrl/tools/adminer.php" } -Name 'toolsAdminer'
$null = Add-MenuItem $toolsMenu (Get-WampDeckString 'Phpinfo') { Open-Url "$PanelUrl/info.php" } -Name 'toolsPhpinfo'
Add-MenuSeparator $toolsMenu
$null = Add-MenuItem $toolsMenu (Get-WampDeckString 'TerminalInWww') { try { Open-Terminal } catch { Show-GuiError $_.Exception.Message } } ([System.Windows.Forms.Keys]::Control -bor [System.Windows.Forms.Keys]::Alt -bor [System.Windows.Forms.Keys]::T) -Name 'toolsTerminal'
$null = Add-MenuItem $toolsMenu (Get-WampDeckString 'Notepad') { try { Open-Notepad } catch { Show-GuiError $_.Exception.Message } } -Name 'toolsNotepad'
Add-MenuSeparator $toolsMenu
$null = Add-MenuItem $toolsMenu (Get-WampDeckString 'NgrokStart') {
    try {
        $url = Start-NgrokTunnel
        if ($url) { Show-GuiInfo "Public URL:`r`n$url" 'ngrok' }
        else { Show-GuiInfo (Get-WampDeckString 'NgrokNoToken') 'ngrok' }
    } catch { Show-GuiError $_.Exception.Message }
} -Name 'toolsNgrokStart'
$null = Add-MenuItem $toolsMenu (Get-WampDeckString 'NgrokStop') { Stop-NgrokTunnel } -Name 'toolsNgrokStop'
$null = Add-MenuItem $toolsMenu (Get-WampDeckString 'Cronical') { try { Start-Cronical } catch { Show-GuiError $_.Exception.Message } } -Name 'toolsCronical'
Add-MenuSeparator $toolsMenu
$null = Add-MenuItem $toolsMenu (Get-WampDeckString 'SyncHosts') { Start-GuiScript -ScriptName 'hosts.ps1' -Arguments @('-Sync') -Label (Get-WampDeckString 'HostsSyncing') | Out-Null } -Name 'toolsSyncHosts'
$null = Add-MenuItem $toolsMenu (Get-WampDeckString 'EditHosts') { Start-GuiScript -ScriptName 'hosts.ps1' -Arguments @('-Open') -Label (Get-WampDeckString 'HostsOpening') | Out-Null } -Name 'toolsEditHosts'
$null = Add-MenuItem $toolsMenu (Get-WampDeckString 'CertificatesFolder') { Open-Folder $SslDir } -Name 'toolsCerts'

$null = Add-MenuItem $settingsMenu (Get-WampDeckString 'Settings') { Show-SettingsAction } -Name 'menuSettings'
$null = Add-MenuItem $settingsMenu (Get-WampDeckString 'PhpExtensions') { Show-ExtensionsAction } -Name 'menuPhpExt'
Add-MenuSeparator $settingsMenu

# Quick language switch: Settings -> Language -> <language>
$languageMenu = New-Object System.Windows.Forms.ToolStripMenuItem -ArgumentList (Get-WampDeckString 'Language')
$script:menuItemRegistry['menuLanguage'] = $languageMenu
$script:languageMenuItems = @{}
foreach ($entry in $script:WampDeckLanguages) {
    $langItem = New-Object System.Windows.Forms.ToolStripMenuItem -ArgumentList ([string]$entry.Name)
    $langItem.Tag = [string]$entry.Code
    $langItem.Add_Click({
        param($sender, $eventArgs)
        try {
            Set-WampDeckLanguage -Code ([string]$sender.Tag) | Out-Null
            Update-GuiLanguageTexts
            Update-MenuChecks
        } catch {
            Show-GuiError $_.Exception.Message
        }
    })
    [void]$languageMenu.DropDownItems.Add($langItem)
    $script:languageMenuItems[[string]$entry.Code] = $langItem
}
[void]$settingsMenu.DropDownItems.Add($languageMenu)
Add-MenuSeparator $settingsMenu

$phpSubmenu = New-Object System.Windows.Forms.ToolStripMenuItem -ArgumentList 'PHP version'
foreach ($version in $PhpVersions) {
    $versionItem = New-Object System.Windows.Forms.ToolStripMenuItem -ArgumentList "PHP $version"
    $versionItem.Tag = $version
    $versionItem.Add_Click({
        param($sender, $eventArgs)
        $target = [string]$sender.Tag
        if ($target -eq $State.phpVersion) { return }
        Start-GuiScript -ScriptName 'switch.ps1' -Arguments @('-Php', $target) -Label "Switching to PHP $target..." | Out-Null
    })
    [void]$phpSubmenu.DropDownItems.Add($versionItem)
    $script:phpMenuItems[$version] = $versionItem
}
[void]$settingsMenu.DropDownItems.Add($phpSubmenu)

$webSubmenu = New-Object System.Windows.Forms.ToolStripMenuItem -ArgumentList 'Web server'
foreach ($server in @('nginx', 'apache')) {
    $label = if ($server -eq 'apache') { 'Apache' } else { 'nginx' }
    $serverItem = New-Object System.Windows.Forms.ToolStripMenuItem -ArgumentList $label
    $serverItem.Tag = $server
    $serverItem.Add_Click({
        param($sender, $eventArgs)
        $target = [string]$sender.Tag
        if ($target -eq $State.webServer) { return }
        Start-GuiScript -ScriptName 'switch.ps1' -Arguments @('-Web', $target) -Label "Switching to $target..." | Out-Null
    })
    [void]$webSubmenu.DropDownItems.Add($serverItem)
    $script:webMenuItems[$server] = $serverItem
}
[void]$settingsMenu.DropDownItems.Add($webSubmenu)
Add-MenuSeparator $settingsMenu

$httpsMenu = New-Object System.Windows.Forms.ToolStripMenuItem -ArgumentList 'HTTPS'
$script:sslEnableItem = Add-MenuItem $httpsMenu (Get-WampDeckString 'EnableHttps') { Start-GuiScript -ScriptName 'ssl.ps1' -Arguments @('-Enable') -Label (Get-WampDeckString 'EnablingHttps') | Out-Null } -Name 'menuHttpsEnable'
$script:sslDisableItem = Add-MenuItem $httpsMenu (Get-WampDeckString 'DisableHttps') { Start-GuiScript -ScriptName 'ssl.ps1' -Arguments @('-Disable') -Label (Get-WampDeckString 'DisablingHttps') | Out-Null } -Name 'menuHttpsDisable'
$null = Add-MenuItem $httpsMenu (Get-WampDeckString 'TrustCert') { Start-GuiScript -ScriptName 'ssl.ps1' -Arguments @('-Trust') -Label (Get-WampDeckString 'WaitingForTrust') | Out-Null } -Name 'menuHttpsTrust'
$null = Add-MenuItem $httpsMenu (Get-WampDeckString 'RegenerateCert') { Start-GuiScript -ScriptName 'ssl.ps1' -Arguments @('-Reset') -Label (Get-WampDeckString 'RegeneratingCert') | Out-Null } -Name 'menuHttpsRegen'
[void]$settingsMenu.DropDownItems.Add($httpsMenu)
Add-MenuSeparator $settingsMenu

$script:autoStartMenuItem = Add-MenuItem $settingsMenu (Get-WampDeckString 'StartStackWhenPanelOpens') {
    $State.autoStart = -not [bool]$State.autoStart
    Save-StackState
    Update-MenuChecks
}
$script:startupMenuItem = Add-MenuItem $settingsMenu (Get-WampDeckString 'StartWithWindows') { Toggle-AutoStart } -Name 'menuStartWithWindows'
Add-MenuSeparator $settingsMenu
$null = Add-MenuItem $settingsMenu (Get-WampDeckString 'RefreshConfigs') { Start-GuiScript -ScriptName 'refresh.ps1' -Arguments @('-NoHosts') -Label (Get-WampDeckString 'RefreshConfigs') | Out-Null } -Name 'menuRefreshConfigs'

$null = Add-MenuItem $helpMenu (Get-WampDeckString 'About') { Show-About } -Name 'menuAbout'
$null = Add-MenuItem $helpMenu 'WampDeck website' { Open-Url 'https://wampdeck.com' } -Name 'menuWebsite'
$null = Add-MenuItem $helpMenu 'Oryx India website' { Open-Url 'https://oryxindia.in' } -Name 'menuCompany'
$null = Add-MenuItem $helpMenu (Get-WampDeckString 'Readme') { try { Open-Notepad -Path (Join-Path $Root 'README.md') } catch { Show-GuiError $_.Exception.Message } } -Name 'menuReadme'
$null = Add-MenuItem $helpMenu (Get-WampDeckString 'OpenInstallFolder') { Open-Folder $Root } -Name 'menuOpenInstall'

# ---------------------------------------------------------------- header
$logo = New-Object System.Windows.Forms.Label
$logo.Text = 'W'
$logo.Font = New-Object System.Drawing.Font('Segoe UI', 20, [System.Drawing.FontStyle]::Bold)
$logo.ForeColor = $script:GuiColors.AccentDark
$logo.BackColor = $script:GuiColors.Accent
$logo.TextAlign = 'MiddleCenter'
$logo.Location = New-Object System.Drawing.Point(24, 30)
$logo.Size = New-Object System.Drawing.Size(48, 48)
$form.Controls.Add($logo)

$title = New-Object System.Windows.Forms.Label
$title.Text = 'WampDeck'
$title.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 19)
$title.ForeColor = $script:GuiColors.Text
$title.AutoSize = $true
$title.Location = New-Object System.Drawing.Point(86, 26)
$form.Controls.Add($title)

$subtitle = New-Object System.Windows.Forms.Label
$subtitle.Text = Get-WampDeckString 'AppSubtitle'
$subtitle.ForeColor = $script:GuiColors.Muted
$subtitle.AutoSize = $true
$subtitle.Location = New-Object System.Drawing.Point(88, 62)
$form.Controls.Add($subtitle)

# Badges are real Label controls hosted in the menu strip. ToolStripLabel lets
# the menu renderer override ForeColor, so the ONLINE/PRO colours were lost.
$script:headerBadge = New-Object System.Windows.Forms.Label
$script:headerBadge.Name = 'headerBadge'
$script:headerBadge.Text = 'CHECKING'
$script:headerBadge.Font = New-Object System.Drawing.Font('Consolas', 9, [System.Drawing.FontStyle]::Bold)
$script:headerBadge.ForeColor = $script:GuiColors.Muted
$script:headerBadge.BackColor = $menuStrip.BackColor
$script:headerBadge.AutoSize = $true
$script:headerBadge.Padding = New-Object System.Windows.Forms.Padding(0, 0, 8, 0)
$headerHost = New-Object System.Windows.Forms.ToolStripControlHost($script:headerBadge)
$headerHost.Alignment = [System.Windows.Forms.ToolStripItemAlignment]::Right
$menuStrip.Items.Add($headerHost) | Out-Null

# Paid add-on badge - visible only when Pro and a licence are installed.
$script:proBadge = New-Object System.Windows.Forms.Label
$script:proBadge.Name = 'proBadge'
$script:proBadge.Text = 'PRO'
$script:proBadge.Font = New-Object System.Drawing.Font('Consolas', 9, [System.Drawing.FontStyle]::Bold)
$script:proBadge.ForeColor = [System.Drawing.Color]::FromArgb(255, 197, 66)
$script:proBadge.BackColor = $menuStrip.BackColor
$script:proBadge.AutoSize = $true
$script:proBadge.Padding = New-Object System.Windows.Forms.Padding(0, 0, 8, 0)
$proHost = New-Object System.Windows.Forms.ToolStripControlHost($script:proBadge)
$proHost.Alignment = [System.Windows.Forms.ToolStripItemAlignment]::Right
$proHost.Visible = ((Test-Path (Join-Path $Root 'pro\license.dat')) -and (Test-Path (Join-Path $Root 'pro\lib\ProValidator.dll')))
$menuStrip.Items.Add($proHost) | Out-Null


$script:terminalButton = New-FlatButton -Text (Get-WampDeckString 'Terminal') -Width 100 -Height 34
$script:terminalButton.Location = New-Object System.Drawing.Point(480, 68)
$script:terminalButton.ForeColor = $script:GuiColors.Accent
$script:terminalButton.FlatAppearance.BorderSize = 1
$script:terminalButton.FlatAppearance.BorderColor = $script:GuiColors.Accent
$script:terminalButton.Add_Click({ try { Open-Terminal } catch { Show-GuiError $_.Exception.Message } })
$form.Controls.Add($script:terminalButton)
$script:terminalTip = New-Object System.Windows.Forms.ToolTip
$script:terminalTip.SetToolTip($script:terminalButton, (Get-WampDeckString 'TerminalHint'))
$script:toolTips += $script:terminalTip

$script:startButton = New-FlatButton -Text (Get-WampDeckString 'Start') -Width 100 -Height 34 -Primary
$script:startButton.Location = New-Object System.Drawing.Point(588, 68)
$form.Controls.Add($script:startButton)
$script:startButton.Add_Click({ Start-StackAction })

$script:stopButton = New-FlatButton -Text (Get-WampDeckString 'Stop') -Width 100 -Height 34
$script:stopButton.Location = New-Object System.Drawing.Point(708, 68)
$form.Controls.Add($script:stopButton)
$script:stopButton.Add_Click({ Stop-StackAction })

$script:restartButton = New-FlatButton -Text (Get-WampDeckString 'Restart') -Width 100 -Height 34
$script:restartButton.Location = New-Object System.Drawing.Point(816, 68)
$form.Controls.Add($script:restartButton)
$script:restartButton.Add_Click({ Restart-StackAction })

# ---------------------------------------------------------------- CMS quick launch
# The nine supported CMS marks occupy the blank header strip, between the product
# title and the Online/Offline badge. A single click opens the install dialog
# prefilled with that CMS, so a user who already decided on WordPress hits the
# WordPress mark and lands straight in the WordPress install flow.
function New-CmsLaunchTile {
    param([string]$CmsId, [int]$X, [int]$Y, [int]$TileWidth, [int]$TileHeight, [int]$MarkHeight)

    $entry = Resolve-WampDeckCms $CmsId
    $imagePath = Join-Path (Join-Path $Root 'assets\cms\icons') ("$CmsId.png")
    if (-not (Test-Path -LiteralPath $imagePath)) { return $null }

    # Load the mark from a memory copy, NOT Image.FromFile. FromFile keeps an
    # exclusive handle on the PNG for the Image's whole lifetime, which locks
    # the file and makes a beta upgrade fail with DeleteFile failed; code 32.
    # A MemoryStream copy releases the file immediately.
    $bytes = [System.IO.File]::ReadAllBytes($imagePath)
    $stream = New-Object System.IO.MemoryStream -ArgumentList @(, $bytes)
    $markImage = [System.Drawing.Image]::FromStream($stream)
    $stream.Dispose()

    # PictureBox with Zoom renders all nine transparent PNG marks correctly.
    # Button.Image with Flat style drops some alpha icons on Windows PowerShell
    # 5.1, so the tile uses a PictureBox and handles hover itself.
    $tile = New-Object System.Windows.Forms.PictureBox
    $tile.Name = "cmsTile_$CmsId"
    $tile.Tag = $CmsId
    $tile.Size = New-Object System.Drawing.Size($TileWidth, $TileHeight)
    $tile.Location = New-Object System.Drawing.Point($X, $Y)
    $tile.Image = $markImage
    $tile.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::Zoom
    $tile.BackColor = [System.Drawing.Color]::Transparent
    $tile.Cursor = [System.Windows.Forms.Cursors]::Hand
    $tile.Add_MouseEnter({ param($sender, $eventArgs) $sender.BackColor = $script:GuiColors.SurfaceAlt })
    $tile.Add_MouseLeave({ param($sender, $eventArgs) $sender.BackColor = [System.Drawing.Color]::Transparent })
    $tile.Add_Click({ Create-CmsAction -PresetCms $CmsId })
    $form.Controls.Add($tile)

    $tip = New-Object System.Windows.Forms.ToolTip
    $tip.SetToolTip($tile, ("{0} - click to install" -f $entry.Name))
    # Keep the tooltip inside the WampDeck window: the CMS strip is close to
    # the right edge, so the default placement pushes the text outside the
    # frame. Reposition on Popup to stay below the tile and within the form.
    $tip.Add_Popup({
        param($sender, $e)
        $screenPos = $tile.PointToScreen([System.Drawing.Point]::Empty)
        $formRight = $form.Right
        $x = $screenPos.X
        if (($x + 190) -gt $formRight) { $x = $formRight - 190 }
        if ($x -lt $form.Left) { $x = $form.Left + 4 }
        $e.ToolTipLocation = New-Object System.Drawing.Point($x, ($screenPos.Y + $TileHeight + 4))
    })
    $script:toolTips += $tip

    return $tile
}

$script:cmsLaunchOrder = @(
    @{ Id = 'wordpress';     Width = 34 },
    @{ Id = 'joomla';        Width = 34 },
    @{ Id = 'drupal';        Width = 34 },
    @{ Id = 'typo3';         Width = 34 },
    @{ Id = 'craftcms';      Width = 34 },
    @{ Id = 'statamic';      Width = 34 },
    @{ Id = 'octobercms';    Width = 34 },
    @{ Id = 'processwire';   Width = 34 },
    @{ Id = 'concrete';      Width = 34 },
    @{ Id = 'grav';          Width = 34 },
    @{ Id = 'winter';        Width = 34 },
    @{ Id = 'twill';         Width = 66 }
)
$cmsLaunchClusterWidth = [int](($script:cmsLaunchOrder | ForEach-Object { $_.Width } | Measure-Object -Sum).Sum) + (8 * 8)
$script:cmsLaunchX = 916 - $cmsLaunchClusterWidth
foreach ($cmsLaunch in @($script:cmsLaunchOrder)) {
    $null = New-CmsLaunchTile -CmsId $cmsLaunch.Id -X $script:cmsLaunchX -Y 27 -TileWidth $cmsLaunch.Width -TileHeight 32 -MarkHeight 24
    $script:cmsLaunchX += ($cmsLaunch.Width + 8)
}

# ---------------------------------------------------------------- cards
function New-StatusCard {
    param([string]$Caption, [int]$X)

    $panel = New-Object System.Windows.Forms.Panel
    $panel.Location = New-Object System.Drawing.Point($X, 104)
    $panel.Size = New-Object System.Drawing.Size(216, 88)
    $panel.BackColor = $script:GuiColors.Surface
    $panel.Add_Paint({
        param($sender, $eventArgs)
        $pen = New-Object System.Drawing.Pen($script:GuiColors.Border, 1)
        $eventArgs.Graphics.DrawRectangle($pen, 0, 0, $sender.Width - 1, $sender.Height - 1)
        $pen.Dispose()
    })
    $form.Controls.Add($panel)

    $captionLabel = New-Object System.Windows.Forms.Label
    $captionLabel.Text = $Caption.ToUpperInvariant()
    $captionLabel.Font = New-Object System.Drawing.Font('Segoe UI', 7.5, [System.Drawing.FontStyle]::Bold)
    $captionLabel.ForeColor = $script:GuiColors.Muted
    $captionLabel.AutoSize = $true
    $captionLabel.Location = New-Object System.Drawing.Point(14, 10)
    $panel.Controls.Add($captionLabel)

    $value = New-Object System.Windows.Forms.Label
    $value.Text = '...'
    $value.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 12)
    $value.ForeColor = $script:GuiColors.Text
    $value.Location = New-Object System.Drawing.Point(13, 30)
    $value.Size = New-Object System.Drawing.Size(192, 26)
    $panel.Controls.Add($value)

    $detail = New-Object System.Windows.Forms.Label
    $detail.Text = ''
    $detail.Font = New-Object System.Drawing.Font('Segoe UI', 8)
    $detail.ForeColor = $script:GuiColors.Muted
    $detail.Location = New-Object System.Drawing.Point(14, 58)
    $detail.Size = New-Object System.Drawing.Size(188, 20)
    $panel.Controls.Add($detail)

    return [pscustomobject]@{ Value = $value; Detail = $detail }
}

$phpCard = New-StatusCard -Caption (Get-WampDeckString 'Php') -X 24
$script:cardPhpValue = $phpCard.Value
$script:cardPhpDetail = $phpCard.Detail

$webCard = New-StatusCard -Caption (Get-WampDeckString 'WebServer') -X 252
$script:cardWebValue = $webCard.Value
$script:cardWebDetail = $webCard.Detail

$dbCard = New-StatusCard -Caption (Get-WampDeckString 'Database') -X 480
$script:cardDbValue = $dbCard.Value
$script:cardDbDetail = $dbCard.Detail

$toolsCard = New-StatusCard -Caption (Get-WampDeckString 'ExtraServices') -X 708
$script:cardToolsValue = $toolsCard.Value
$script:cardToolsDetail = $toolsCard.Detail

# ---------------------------------------------------------------- tabs
$tabBar = New-Object System.Windows.Forms.Panel
$tabBar.Location = New-Object System.Drawing.Point(24, 200)
$tabBar.Size = New-Object System.Drawing.Size(892, 44)
$tabBar.BackColor = $script:GuiColors.Background
$form.Controls.Add($tabBar)

$tabBar.Add_Paint({
    param($sender, $eventArgs)
    $pen = New-Object System.Drawing.Pen($script:GuiColors.Border)
    $eventArgs.Graphics.DrawLine($pen, 0, $sender.Height - 1, $sender.Width, $sender.Height - 1)
    $pen.Dispose()
})

$script:tabPages = @()
$script:tabButtons = @()

function New-TabButton {
    param([string]$Text, [int]$X)
    $button = New-FlatButton -Text $Text -Width 104 -Height 34
    $button.Location = New-Object System.Drawing.Point($X, 2)
    $button.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 9.5)
    $button.TextAlign = 'MiddleCenter'
    $button.BackColor = $script:GuiColors.Background
    $button.ForeColor = $script:GuiColors.Muted
    $tabBar.Controls.Add($button)
    return $button
}

function New-PagePanel {
    $panel = New-Object System.Windows.Forms.Panel
    $panel.Location = New-Object System.Drawing.Point(24, 244)
    $panel.Size = New-Object System.Drawing.Size(892, 388)
    $panel.BackColor = $script:GuiColors.Background
    $panel.Visible = $false
    $panel.Add_Paint({
        param($sender, $eventArgs)
        $pen = New-Object System.Drawing.Pen($script:GuiColors.Border)
        $eventArgs.Graphics.DrawRectangle($pen, 0, 0, $sender.Width - 1, $sender.Height - 1)
        $pen.Dispose()
    })
    $form.Controls.Add($panel)
    return $panel
}

function Show-PageTab {
    param([int]$Index)
    for ($i = 0; $i -lt $script:tabPages.Count; $i++) {
        $selected = ($i -eq $Index)
        $script:tabPages[$i].Visible = $selected
        $button = $script:tabButtons[$i]
        $button.BackColor = if ($selected) { $script:GuiColors.Surface } else { $script:GuiColors.Background }
        $button.ForeColor = if ($selected) { $script:GuiColors.Text } else { $script:GuiColors.Muted }
    }
    $script:tabUnderline.Left = 14 + ($Index * 110)
}

$projectTab = New-PagePanel
$servicesTab = New-PagePanel
$toolsTab = New-PagePanel
$script:tabPages = @($projectTab, $servicesTab, $toolsTab)

$projectTabButton = New-TabButton (Get-WampDeckString 'TabProjects') 0
$servicesTabButton = New-TabButton (Get-WampDeckString 'TabServices') 110
$toolsTabButton = New-TabButton (Get-WampDeckString 'TabTools') 220
$script:tabButtons = @($projectTabButton, $servicesTabButton, $toolsTabButton)

$projectTabButton.Add_Click({ Show-PageTab 0 })
$servicesTabButton.Add_Click({ Show-PageTab 1 })
$toolsTabButton.Add_Click({ Show-PageTab 2 })

$script:tabUnderline = New-Object System.Windows.Forms.Panel
$script:tabUnderline.Size = New-Object System.Drawing.Size(76, 3)
$script:tabUnderline.BackColor = $script:GuiColors.Accent
$script:tabUnderline.Location = New-Object System.Drawing.Point(14, 39)
$tabBar.Controls.Add($script:tabUnderline)

Show-PageTab 0

function Add-TabButton {
    param(
        $Page,
        [string]$Text,
        [int]$X,
        [int]$Y,
        [int]$Width,
        [scriptblock]$OnClick,
        [switch]$Primary
    )
    $button = New-FlatButton -Text $Text -Width $Width -Height 32 -Primary:$Primary
    $button.Location = New-Object System.Drawing.Point($X, $Y)
    if ($OnClick) { $button.Add_Click($OnClick) }
    $Page.Controls.Add($button)
    return $button
}

# ---------------------------------------------------------------- projects
$script:projectList = New-Object System.Windows.Forms.ListView
$script:projectList.Location = New-Object System.Drawing.Point(12, 12)
$script:projectList.Size = New-Object System.Drawing.Size(860, 300)
$script:projectList.View = 'Details'
$script:projectList.FullRowSelect = $true
$script:projectList.MultiSelect = $false
$script:projectList.HideSelection = $false
[void]$script:projectList.Columns.Add('Project', 130)
[void]$script:projectList.Columns.Add('PHP', 95)
[void]$script:projectList.Columns.Add('Local URL', 195)
[void]$script:projectList.Columns.Add('.test URL', 195)
[void]$script:projectList.Columns.Add('Folder', 245)
Enable-DarkListView $script:projectList
$projectTab.Controls.Add($script:projectList)
Add-DarkListHeader $script:projectList

$script:tabTextItems['TabNewProject'] = Add-TabButton $projectTab (Get-WampDeckString 'TabNewProject') 12 322 110 { Create-ProjectAction } -Primary
$script:tabTextItems['TabOpen'] = Add-TabButton $projectTab (Get-WampDeckString 'TabOpen') 132 322 90 { Open-SelectedProject }
$script:tabTextItems['TabTestUrl'] = Add-TabButton $projectTab (Get-WampDeckString 'TabTestUrl') 230 322 100 {
    if ($script:projectList -and $script:projectList.SelectedItems.Count -gt 0) {
        Open-Url $script:projectList.SelectedItems[0].Tag.TestUrl
    }
}
$script:tabTextItems['TabFolder'] = Add-TabButton $projectTab (Get-WampDeckString 'TabFolder') 338 322 90 { Open-SelectedFolder }
$script:tabTextItems['TabCopyUrl'] = Add-TabButton $projectTab (Get-WampDeckString 'TabCopyUrl') 436 322 100 {
    if ($script:projectList -and $script:projectList.SelectedItems.Count -gt 0) {
        [System.Windows.Forms.Clipboard]::SetText([string]$script:projectList.SelectedItems[0].Tag.Url)
    }
}
$script:tabTextItems['TabDelete'] = Add-TabButton $projectTab (Get-WampDeckString 'TabDelete') 544 322 90 { Delete-SelectedProject }
$script:tabTextItems['TabRefresh'] = Add-TabButton $projectTab (Get-WampDeckString 'TabRefresh') 642 322 90 { Refresh-Projects }
$script:tabTextItems['TabTerminal'] = Add-TabButton $projectTab (Get-WampDeckString 'TabTerminal') 740 322 100 { Open-SelectedTerminal }

$projectHint = New-Object System.Windows.Forms.Label
$projectHint.Text = (Get-WampDeckString 'WwwHint')
$projectHint.ForeColor = $script:GuiColors.Muted
$projectHint.Font = New-Object System.Drawing.Font('Segoe UI', 8)
$projectHint.AutoSize = $true
$projectHint.Location = New-Object System.Drawing.Point(14, 368)
$projectTab.Controls.Add($projectHint)

$script:projectCountLabel = New-Object System.Windows.Forms.Label
$script:projectCountLabel.Text = '0 projects'
$script:projectCountLabel.ForeColor = $script:GuiColors.Muted
$script:projectCountLabel.Font = New-Object System.Drawing.Font('Segoe UI', 8)
$script:projectCountLabel.AutoSize = $true
$script:projectCountLabel.Location = New-Object System.Drawing.Point(760, 368)
$projectTab.Controls.Add($script:projectCountLabel)

$script:projectList.Add_DoubleClick({ Open-SelectedProject })

# PHP version submenu for one project (per-project pinning).
$projectPhpMenu = New-Object System.Windows.Forms.ToolStripMenuItem -ArgumentList (Get-WampDeckString 'ProjectPhpVersion')
$script:menuItemRegistry['projectPhp'] = $projectPhpMenu
$script:projectPhpMenuItems = @{}

$defaultPhpItem = New-Object System.Windows.Forms.ToolStripMenuItem -ArgumentList ((Get-WampDeckString 'ProjectPhpDefault') -f $State.phpVersion)
$defaultPhpItem.Tag = 'any'
$defaultPhpItem.Add_Click({ param($sender, $eventArgs) Set-SelectedProjectPhp -Spec 'any' })
[void]$projectPhpMenu.DropDownItems.Add($defaultPhpItem)
$script:projectPhpMenuItems['any'] = $defaultPhpItem
$script:projectPhpDefaultItem = $defaultPhpItem

foreach ($version in $PhpVersions) {
    $phpVersionItem = New-Object System.Windows.Forms.ToolStripMenuItem -ArgumentList "PHP $version"
    $phpVersionItem.Tag = $version
    $phpVersionItem.Add_Click({
        param($sender, $eventArgs)
        $exact = [string]$sender.Tag
        $short = (@($exact -split '\.')[0..1] -join '.')
        Set-SelectedProjectPhp -Spec $short
    })
    [void]$projectPhpMenu.DropDownItems.Add($phpVersionItem)
    $script:projectPhpMenuItems[$version] = $phpVersionItem
}

$projectContext = New-Object System.Windows.Forms.ContextMenuStrip
foreach ($entry in @(
        @{ Text = 'Install CMS...'; Action = { Create-CmsAction } },
        @{ Text = '-'; Action = $null },
        @{ Text = 'Open in browser'; Action = { Open-SelectedProject } },
        @{ Text = 'Open .test URL'; Action = {
                if ($script:projectList -and $script:projectList.SelectedItems.Count -gt 0) {
                    Open-Url $script:projectList.SelectedItems[0].Tag.TestUrl
                }
            } },
        @{ Text = 'Open folder'; Action = { Open-SelectedFolder } },
        @{ Text = 'Open terminal here'; Action = { Open-SelectedTerminal } },
        @{ Text = 'Copy local URL'; Action = {
                if ($script:projectList -and $script:projectList.SelectedItems.Count -gt 0) {
                    [System.Windows.Forms.Clipboard]::SetText([string]$script:projectList.SelectedItems[0].Tag.Url)
                }
            } },
        @{ Text = '-'; Action = $null },
        @{ Text = 'php-version'; Action = $null },
        @{ Text = 'Delete project'; Action = { Delete-SelectedProject } }
    )) {
    if ($entry.Text -eq '-') {
        [void]$projectContext.Items.Add((New-Object System.Windows.Forms.ToolStripSeparator))
        continue
    }
    if ($entry.Text -eq 'php-version') {
        [void]$projectContext.Items.Add($projectPhpMenu)
        continue
    }
    $contextItem = New-Object System.Windows.Forms.ToolStripMenuItem -ArgumentList $entry.Text
    $contextItem.Add_Click($entry.Action)
    [void]$projectContext.Items.Add($contextItem)
}
$script:projectList.ContextMenuStrip = $projectContext
$projectContext.Add_Opening({
    $projectContext.Renderer = $menuStrip.Renderer
    Update-ProjectPhpMenuChecks
})

# ---------------------------------------------------------------- services
$script:serviceList = New-Object System.Windows.Forms.ListView
$script:serviceList.Location = New-Object System.Drawing.Point(12, 12)
$script:serviceList.Size = New-Object System.Drawing.Size(860, 270)
$script:serviceList.View = 'Details'
$script:serviceList.FullRowSelect = $true
$script:serviceList.MultiSelect = $false
$script:serviceList.HideSelection = $false
[void]$script:serviceList.Columns.Add('Service', 240)
[void]$script:serviceList.Columns.Add('Port', 180)
[void]$script:serviceList.Columns.Add('Status', 140)
[void]$script:serviceList.Columns.Add('Startup', 120)
Enable-DarkListView $script:serviceList
$servicesTab.Controls.Add($script:serviceList)
Add-DarkListHeader $script:serviceList

$null = Add-TabButton $servicesTab 'Start' 12 292 100 { Start-SelectedService } -Primary
$null = Add-TabButton $servicesTab 'Stop' 120 292 100 { Stop-SelectedService }
$null = Add-TabButton $servicesTab 'Start all' 228 292 100 { Start-StackAction }
$null = Add-TabButton $servicesTab 'Stop all' 336 292 100 { Stop-StackAction }
$null = Add-TabButton $servicesTab 'Toggle startup' 444 292 140 { Toggle-StartupService }

$servicesHint = New-Object System.Windows.Forms.Label
$servicesHint.Text = (Get-WampDeckString 'ServicesHint')
$servicesHint.ForeColor = $script:GuiColors.Muted
$servicesHint.Font = New-Object System.Drawing.Font('Segoe UI', 8)
$servicesHint.AutoSize = $true
$servicesHint.Location = New-Object System.Drawing.Point(14, 338)
$servicesTab.Controls.Add($servicesHint)

$script:serviceList.Add_DoubleClick({
    if ($script:serviceList.SelectedItems.Count -eq 0) { return }
    $item = $script:serviceList.SelectedItems[0]
    if ($item.SubItems[2].Text -eq 'running') { Stop-SelectedService } else { Start-SelectedService }
})

$serviceContext = New-Object System.Windows.Forms.ContextMenuStrip
foreach ($text in @('Start', 'Stop', 'Toggle startup')) {
    $contextItem = New-Object System.Windows.Forms.ToolStripMenuItem -ArgumentList $text
    switch ($text) {
        'Start' { $contextItem.Add_Click({ Start-SelectedService }) }
        'Stop' { $contextItem.Add_Click({ Stop-SelectedService }) }
        'Toggle startup' { $contextItem.Add_Click({ Toggle-StartupService }) }
    }
    [void]$serviceContext.Items.Add($contextItem)
}
$script:serviceList.ContextMenuStrip = $serviceContext

# ---------------------------------------------------------------- tools
function New-ToolButton {
    param([string]$Text, [int]$X, [int]$Y, [scriptblock]$OnClick, [string]$Hint = '')

    $button = New-FlatButton -Text $Text -Width 200 -Height 58
    $button.Location = New-Object System.Drawing.Point($X, $Y)
    $button.TextAlign = 'MiddleLeft'
    $button.Padding = New-Object System.Windows.Forms.Padding(14, 0, 0, 0)
    if ($Hint) {
        $tip = New-Object System.Windows.Forms.ToolTip
        $tip.SetToolTip($button, $Hint)
        $script:toolTips += $tip
    }
    $button.Add_Click($OnClick)
    $toolsTab.Controls.Add($button)
    return $button
}

$null = New-ToolButton "HeidiSQL`r`nDatabase client" 14 14 {
    try { Open-HeidiSql } catch { Show-GuiError $_.Exception.Message }
} 'Open HeidiSQL on 127.0.0.1, user root, empty password'
$null = New-ToolButton "Mailpit inbox`r`nCaptured mail" 225 14 { Open-Mailpit } 'Open the Mailpit web inbox'
$null = New-ToolButton "Adminer`r`nWeb database" 436 14 { Open-Url "$PanelUrl/tools/adminer.php" } 'Manage MySQL in the browser'
$null = New-ToolButton "phpinfo()`r`nPHP settings" 647 14 { Open-Url "$PanelUrl/info.php" } 'Show the loaded PHP configuration'

$null = New-ToolButton ">_  Terminal`r`nCmder in www" 14 84 {
    try { Open-Terminal } catch { Show-GuiError $_.Exception.Message }
} 'Open a terminal in www with PHP, Composer, Git, Node and MySQL ready'
$null = New-ToolButton "Notepad++`r`nText editor" 225 84 {
    try { Open-Notepad } catch { Show-GuiError $_.Exception.Message }
} 'Open Notepad++'
$null = New-ToolButton "Composer`r`nVersion check" 436 84 {
    try {
        $env:PATH = "$PhpDir;$BinDir\composer;$env:PATH"
        $version = & $ComposerBat --version 2>&1 | Select-Object -First 1
        Show-GuiInfo "Composer`r`n$version" 'Composer'
    } catch { Show-GuiError $_.Exception.Message }
} 'Check the bundled Composer'
$null = New-ToolButton "Cronical`r`nTask scheduler" 647 84 {
    try { Start-Cronical } catch { Show-GuiError $_.Exception.Message }
} 'Open the Cronical scheduler'

$null = New-ToolButton "ngrok tunnel`r`nPublic HTTPS URL" 14 154 {
    try {
        $url = Start-NgrokTunnel
        if ($url) { Show-GuiInfo "Public URL:`r`n$url" 'ngrok' }
        else { Show-GuiInfo 'ngrok started, but no public URL yet. Add your authtoken first.' 'ngrok' }
    } catch { Show-GuiError $_.Exception.Message }
} 'Expose the local web server through ngrok'
$null = New-ToolButton "Stop ngrok`r`nClose the tunnel" 225 154 { Stop-NgrokTunnel } 'Stop the ngrok tunnel'
$null = New-ToolButton "Hosts file`r`nEdit with UAC" 436 154 {
    Start-GuiScript -ScriptName 'hosts.ps1' -Arguments @('-Open') -Label 'Opening the hosts file...' | Out-Null
} 'Open the Windows hosts file as administrator'
$null = New-ToolButton "Certificates`r`nSSL files" 647 154 { Open-Folder $SslDir } 'Open the local CA and server certificate folder'

$null = New-ToolButton "Refresh configs`r`nRebuild vhosts" 14 224 {
    Start-GuiScript -ScriptName 'refresh.ps1' -Arguments @('-NoHosts') -Label 'Refreshing configs...' | Out-Null
} 'Regenerate nginx/Apache/PHP configs and reload'
$null = New-ToolButton "Logs folder`r`nOpen logs" 225 224 { Open-Folder $LogDir } 'Open the log folder'
$null = New-ToolButton "www folder`r`nProjects" 436 224 { Open-Folder $WwwDir } 'Open the projects folder'
$null = New-ToolButton "About`r`nVersions" 647 224 { Show-About } 'Show bundled tool versions'

# ---------------------------------------------------------------- status bar
$statusStrip = New-Object System.Windows.Forms.StatusStrip
$statusStrip.SizingGrip = $false
$statusStrip.Font = New-Object System.Drawing.Font('Segoe UI', 8)
$form.Controls.Add($statusStrip)

$script:statusHosts = New-Object System.Windows.Forms.ToolStripStatusLabel
$script:statusHosts.Text = (Get-WampDeckString 'HostsChecking')
$script:statusHosts.ForeColor = $script:GuiColors.Muted
[void]$statusStrip.Items.Add($script:statusHosts)

$null = $statusStrip.Items.Add((New-Object System.Windows.Forms.ToolStripStatusLabel -ArgumentList '  |  '))

$script:statusSsl = New-Object System.Windows.Forms.ToolStripStatusLabel
$script:statusSsl.Text = (Get-WampDeckString 'SslChecking')
$script:statusSsl.ForeColor = $script:GuiColors.Muted
[void]$statusStrip.Items.Add($script:statusSsl)

$script:busyLabel = New-Object System.Windows.Forms.ToolStripStatusLabel
$script:busyLabel.Text = (Get-WampDeckString 'Ready')
$script:busyLabel.Spring = $true
$script:busyLabel.TextAlign = 'MiddleRight'
$script:busyLabel.ForeColor = $script:GuiColors.Muted
[void]$statusStrip.Items.Add($script:busyLabel)

# Website link in the status bar - professional software always shows where
# to find the product and the company.
$script:websiteLink = New-Object System.Windows.Forms.ToolStripStatusLabel
$script:websiteLink.Text = 'wampdeck.com'
$script:websiteLink.ForeColor = $script:GuiColors.Accent
$script:websiteLink.IsLink = $true
$script:websiteLink.ToolTipText = 'Open https://wampdeck.com'
$script:websiteLink.Add_Click({ Open-Url 'https://wampdeck.com' })
[void]$statusStrip.Items.Add($script:websiteLink)

# ---------------------------------------------------------------- tray
function Show-PanelWindow {
    if ($script:exiting) { return }
    # Re-apply the WampDeck icon right before showing so the taskbar button is
    # always the WampDeck logo, never a fallback to the process icon.
    $form.Icon = $script:appIcon
    $form.Show()
    $form.WindowState = 'Normal'
    $form.ShowInTaskbar = $true
    $form.Activate()
    $form.BringToFront()
}

$script:trayIcon = New-Object System.Windows.Forms.NotifyIcon
$script:trayIcon.Icon = $script:appIcon
$script:trayIcon.Text = (Get-WampDeckString 'AppTitle')
$script:trayIcon.Visible = $true

$trayMenu = New-Object System.Windows.Forms.ContextMenuStrip
$trayOpen = New-Object System.Windows.Forms.ToolStripMenuItem -ArgumentList 'Open WampDeck'
$trayOpen.Add_Click({ Show-PanelWindow })
[void]$trayMenu.Items.Add($trayOpen)

$trayStart = New-Object System.Windows.Forms.ToolStripMenuItem -ArgumentList 'Start stack'
$trayStart.Add_Click({ Start-StackAction })
[void]$trayMenu.Items.Add($trayStart)

$trayStop = New-Object System.Windows.Forms.ToolStripMenuItem -ArgumentList 'Stop stack'
$trayStop.Add_Click({ Stop-StackAction })
[void]$trayMenu.Items.Add($trayStop)

$trayRestart = New-Object System.Windows.Forms.ToolStripMenuItem -ArgumentList 'Restart stack'
$trayRestart.Add_Click({ Restart-StackAction })
[void]$trayMenu.Items.Add($trayRestart)

[void]$trayMenu.Items.Add((New-Object System.Windows.Forms.ToolStripSeparator))

$trayPanel = New-Object System.Windows.Forms.ToolStripMenuItem -ArgumentList 'Open panel in browser'
$trayPanel.Add_Click({ Open-Url $PanelUrl })
[void]$trayMenu.Items.Add($trayPanel)

$trayTerminal = New-Object System.Windows.Forms.ToolStripMenuItem -ArgumentList 'Terminal in www'
$trayTerminal.Add_Click({ try { Open-Terminal } catch { Show-GuiError $_.Exception.Message } })
[void]$trayMenu.Items.Add($trayTerminal)

$trayNew = New-Object System.Windows.Forms.ToolStripMenuItem -ArgumentList 'New project...'
$trayNew.Add_Click({ Create-ProjectAction })
[void]$trayMenu.Items.Add($trayNew)

$trayCms = New-Object System.Windows.Forms.ToolStripMenuItem -ArgumentList 'Install CMS...'
$trayCms.Add_Click({ Create-CmsAction })
[void]$trayMenu.Items.Add($trayCms)

[void]$trayMenu.Items.Add((New-Object System.Windows.Forms.ToolStripSeparator))

$trayExit = New-Object System.Windows.Forms.ToolStripMenuItem -ArgumentList 'Quit'
$trayExit.Add_Click({ Exit-WampDeck })
[void]$trayMenu.Items.Add($trayExit)

$script:trayIcon.ContextMenuStrip = $trayMenu
$script:trayIcon.Add_DoubleClick({ Show-PanelWindow })

# ---------------------------------------------------------------- events
$form.Add_FormClosing({
    param($sender, $eventArgs)
    if (-not $script:exiting -and $script:closeToTray) {
        $eventArgs.Cancel = $true
        $sender.Hide()
        $script:trayIcon.ShowBalloonTip(1500, (Get-WampDeckString 'AppTitle'), (Get-WampDeckString 'TrayBalloon'), [System.Windows.Forms.ToolTipIcon]::Info)
    }
})
$form.Add_FormClosed({
    if ($script:activateEvent) { $script:activateEvent.Dispose() }
    [System.Windows.Forms.Application]::Exit()
})

$script:refreshTimer = New-Object System.Windows.Forms.Timer
$script:refreshTimer.Interval = 3000
$script:refreshTimer.Add_Tick({ Refresh-Ui })

$script:bgTimer = New-Object System.Windows.Forms.Timer
$script:bgTimer.Interval = 500
$script:bgTimer.Add_Tick({
    if ($script:activateEvent -and $script:activateEvent.WaitOne(0)) { Show-PanelWindow }
    Complete-BgJob
})

# ---------------------------------------------------------------- start
Set-GuiTheme $form
# A ContextMenuStrip is not a child control, so the theme walk never reaches
# it. Give it the same renderer as the menu bar, otherwise it pops up white.
$projectContext.Renderer = $menuStrip.Renderer
$projectContext.BackColor = $script:GuiColors.Surface
$projectContext.ForeColor = $script:GuiColors.Text
$serviceContext.Renderer = $menuStrip.Renderer
$serviceContext.BackColor = $script:GuiColors.Surface
$serviceContext.ForeColor = $script:GuiColors.Text
$trayMenu.Renderer = $menuStrip.Renderer
$trayMenu.BackColor = $script:GuiColors.Surface
$trayMenu.ForeColor = $script:GuiColors.Text
Initialize-ServiceRows
Refresh-Projects
Refresh-Ui

# Keep the WampDeck window icon authoritative right before the window shows,
# so the taskbar button never falls back to the process icon (PowerShell).
$form.Icon = $script:appIcon
$form.ShowInTaskbar = -not $Tray
$form.Show()
if ($Tray) {
    $form.Hide()
    $form.ShowInTaskbar = $false
}

$script:refreshTimer.Start()
$script:bgTimer.Start()

if ($State.autoStart) {
    Start-StackAction
}

[System.Windows.Forms.Application]::Run()






