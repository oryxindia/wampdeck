# Modal dialogs: settings and PHP extensions.

function Show-SettingsDialog {
    param($Owner)

    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'WampDeck settings'
    $form.Size = New-Object System.Drawing.Size(520, 680)
    $form.StartPosition = 'CenterParent'
    $form.FormBorderStyle = 'FixedDialog'
    $form.MaximizeBox = $false
    $form.MinimizeBox = $false
    $form.BackColor = $script:GuiColors.Background
    $form.ForeColor = $script:GuiColors.Text
    $form.Font = $script:GuiFont

    $title = New-Object System.Windows.Forms.Label
    $title.Text = 'Settings'
    $title.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 14)
    $title.AutoSize = $true
    $title.Location = New-Object System.Drawing.Point(24, 18)
    $form.Controls.Add($title)

    $y = 56
    function Add-Field {
        param([string]$Caption, $Control)
        $label = New-Object System.Windows.Forms.Label
        $label.Text = $Caption
        $label.AutoSize = $true
        $label.ForeColor = $script:GuiColors.Muted
        $label.Location = New-Object System.Drawing.Point(26, $y)
        $form.Controls.Add($label)
        $Control.Location = New-Object System.Drawing.Point(28, ($y + 21))
        $form.Controls.Add($Control)
        $script:dialogY = $y + 58
    }

    $httpBox = New-Object System.Windows.Forms.TextBox
    $httpBox.Width = 100
    $httpBox.Text = [string]$State.httpPort
    Add-Field 'HTTP port' $httpBox

    $httpsBox = New-Object System.Windows.Forms.TextBox
    $httpsBox.Width = 100
    $httpsBox.Text = [string]$State.httpsPort
    $y = $script:dialogY
    Add-Field 'HTTPS port' $httpsBox

    $mysqlBox = New-Object System.Windows.Forms.TextBox
    $mysqlBox.Width = 100
    $mysqlBox.Text = [string]$State.mysqlPort
    $y = $script:dialogY
    Add-Field 'MySQL port' $mysqlBox

    $workersBox = New-Object System.Windows.Forms.NumericUpDown
    $workersBox.Width = 80
    $workersBox.Minimum = 1
    $workersBox.Maximum = 16
    $workersBox.Value = [int]$State.phpWorkers
    $y = $script:dialogY
    Add-Field 'PHP workers (FastCGI)' $workersBox

    $bindBox = New-Object System.Windows.Forms.ComboBox
    $bindBox.Width = 300
    $bindBox.DropDownStyle = 'DropDownList'
    $bindBox.Items.AddRange(@('127.0.0.1 - this PC only', '0.0.0.0 - LAN / other devices')) | Out-Null
    if ($State.bind -eq '0.0.0.0') { $bindBox.SelectedIndex = 1 } else { $bindBox.SelectedIndex = 0 }
    $y = $script:dialogY
    Add-Field 'Listen address' $bindBox

    $languageBox = New-Object System.Windows.Forms.ComboBox
    $languageBox.Width = 300
    $languageBox.DropDownStyle = 'DropDownList'
    $languageBox.Font = $script:GuiFont
    $languageBox.Items.AddRange(@($script:WampDeckLanguages | ForEach-Object { [string]$_.Name })) | Out-Null
    $currentLangName = @($script:WampDeckLanguages | Where-Object { [string]$_.Code -eq (Get-WampDeckLanguage) } | ForEach-Object { [string]$_.Name })
    if ($currentLangName.Count -gt 0) { $languageBox.SelectedItem = $currentLangName[0] }
    $y = $script:dialogY
    Add-Field (Get-WampDeckString 'Language') $languageBox

    $y = $script:dialogY + 8
    $checks = @(
        @{ Name = 'ssl';       Text = 'Enable HTTPS (trusted local certificate)' },
        @{ Name = 'mailpit';   Text = 'Mailpit SMTP catcher (127.0.0.1:1025)' },
        @{ Name = 'redis';     Text = 'Redis (127.0.0.1:6379)' },
        @{ Name = 'memcached'; Text = 'Memcached (127.0.0.1:11211)' },
        @{ Name = 'autoStart'; Text = 'Start the stack when this panel opens' },
        @{ Name = 'closeToTray'; Text = 'Close to the notification area (tray)' }
    )
    $boxes = @{}
    foreach ($check in $checks) {
        $box = New-Object System.Windows.Forms.CheckBox
        $box.Text = $check.Text
        $box.AutoSize = $true
        $box.Location = New-Object System.Drawing.Point(28, $y)
        $value = $State[$check.Name]
        if ($null -eq $value) { $value = $false }
        $box.Checked = [bool]$value
        $form.Controls.Add($box)
        $boxes[$check.Name] = $box
        $y += 28
    }

    $save = New-FlatButton -Text 'Save' -Width 110 -Primary
    $save.Location = New-Object System.Drawing.Point(286, 600)
    $form.Controls.Add($save)

    $cancel = New-FlatButton -Text 'Cancel' -Width 100
    $cancel.Location = New-Object System.Drawing.Point(404, 600)
    $form.Controls.Add($cancel)

    $script:settingsDialogResult = $null
    $save.Add_Click({
        $http = 0; $https = 0; $mysql = 0
        if (-not [int]::TryParse($httpBox.Text.Trim(), [ref]$http) -or $http -lt 1 -or $http -gt 65535) {
            Show-GuiError 'HTTP port must be a number between 1 and 65535.'; return
        }
        if (-not [int]::TryParse($httpsBox.Text.Trim(), [ref]$https) -or $https -lt 1 -or $https -gt 65535) {
            Show-GuiError 'HTTPS port must be a number between 1 and 65535.'; return
        }
        if (-not [int]::TryParse($mysqlBox.Text.Trim(), [ref]$mysql) -or $mysql -lt 1 -or $mysql -gt 65535) {
            Show-GuiError 'MySQL port must be a number between 1 and 65535.'; return
        }
        if ($http -eq $https -or $http -eq $mysql -or $https -eq $mysql) {
            Show-GuiError 'HTTP, HTTPS and MySQL need different ports.'; return
        }

        $script:settingsDialogResult = [pscustomobject]@{
            HttpPort    = $http
            HttpsPort   = $https
            MysqlPort   = $mysql
            PhpWorkers  = [int]$workersBox.Value
            Bind        = if ($bindBox.SelectedIndex -eq 1) { '0.0.0.0' } else { '127.0.0.1' }
            Ssl         = $boxes['ssl'].Checked
            Mailpit     = $boxes['mailpit'].Checked
            Redis       = $boxes['redis'].Checked
            Memcached   = $boxes['memcached'].Checked
            AutoStart   = $boxes['autoStart'].Checked
            CloseToTray = $boxes['closeToTray'].Checked
            Language    = if ($languageBox.SelectedIndex -ge 0) { [string]$script:WampDeckLanguages[$languageBox.SelectedIndex].Code } else { [string]$script:WampDeckFallbackLanguage }
        }
        $form.Close()
    })
    $cancel.Add_Click({ $form.Close() })

    Set-GuiTheme $form
    $form.AcceptButton = $save
    $form.CancelButton = $cancel
    $null = $form.ShowDialog($Owner)
    return $script:settingsDialogResult
}

function Show-ExtensionsDialog {
    param($Owner)

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "PHP $($State.phpVersion) extensions"
    $form.Size = New-Object System.Drawing.Size(420, 560)
    $form.StartPosition = 'CenterParent'
    $form.FormBorderStyle = 'FixedDialog'
    $form.MaximizeBox = $false
    $form.MinimizeBox = $false
    $form.BackColor = $script:GuiColors.Background
    $form.ForeColor = $script:GuiColors.Text
    $form.Font = $script:GuiFont

    $title = New-Object System.Windows.Forms.Label
    $title.Text = "PHP $($State.phpVersion) extensions"
    $title.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 13)
    $title.AutoSize = $true
    $title.Location = New-Object System.Drawing.Point(22, 18)
    $form.Controls.Add($title)

    $list = New-Object System.Windows.Forms.CheckedListBox
    $list.Location = New-Object System.Drawing.Point(24, 54)
    $list.Size = New-Object System.Drawing.Size(356, 390)
    $list.CheckOnClick = $true
    $list.BorderStyle = 'FixedSingle'
    $list.BackColor = $script:GuiColors.Surface
    $list.ForeColor = $script:GuiColors.Text
    $extensions = @(Get-PhpExtensions)
    foreach ($ext in $extensions) {
        $index = $list.Items.Add($ext.Name)
        if ($ext.Enabled) { $list.SetItemChecked($index, $true) }
    }
    $form.Controls.Add($list)

    $hint = New-Object System.Windows.Forms.Label
    $hint.Text = 'Changes are written to php.ini. The web server restarts.'
    $hint.ForeColor = $script:GuiColors.Muted
    $hint.AutoSize = $true
    $hint.Location = New-Object System.Drawing.Point(24, 452)
    $form.Controls.Add($hint)

    $ok = New-FlatButton -Text 'Apply' -Width 110 -Primary
    $ok.Location = New-Object System.Drawing.Point(186, 482)
    $form.Controls.Add($ok)

    $cancel = New-FlatButton -Text 'Cancel' -Width 100
    $cancel.Location = New-Object System.Drawing.Point(304, 482)
    $form.Controls.Add($cancel)

    $script:extensionsDialogResult = $null
    $ok.Add_Click({
        $enable = @()
        $disable = @()
        for ($i = 0; $i -lt $list.Items.Count; $i++) {
            $name = [string]$list.Items[$i]
            $checked = $list.GetItemChecked($i)
            $was = @($extensions | Where-Object { $_.Name -eq $name -and $_.Enabled }).Count -gt 0
            if ($checked -and -not $was) { $enable += $name }
            if (-not $checked -and $was) { $disable += $name }
        }
        $script:extensionsDialogResult = [pscustomobject]@{
            Enable  = $enable
            Disable = $disable
        }
        $form.Close()
    })
    $cancel.Add_Click({ $form.Close() })

    Set-GuiTheme $form
    $form.AcceptButton = $ok
    $form.CancelButton = $cancel
    $null = $form.ShowDialog($Owner)
    return $script:extensionsDialogResult
}
