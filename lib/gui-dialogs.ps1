# Modal dialogs: new project, CMS install, port conflicts.

function Show-ProjectDialog {
    param($Owner)

    $script:projectDialogResult = $null
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'New project'
    $form.Size = New-Object System.Drawing.Size(460, 330)
    $form.StartPosition = 'CenterParent'
    $form.FormBorderStyle = 'FixedDialog'
    $form.MaximizeBox = $false
    $form.MinimizeBox = $false
    $form.BackColor = $script:GuiColors.Background
    $form.ForeColor = $script:GuiColors.Text
    $form.Font = $script:GuiFont

    $title = New-Object System.Windows.Forms.Label
    $title.Text = 'Create a project'
    $title.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 14)
    $title.AutoSize = $true
    $title.Location = New-Object System.Drawing.Point(24, 20)
    $form.Controls.Add($title)

    $sub = New-Object System.Windows.Forms.Label
    $sub.Text = 'The folder is created inside www\ and gets a .localhost / .test URL.'
    $sub.ForeColor = $script:GuiColors.Muted
    $sub.AutoSize = $true
    $sub.Location = New-Object System.Drawing.Point(26, 54)
    $form.Controls.Add($sub)

    $nameLabel = New-Object System.Windows.Forms.Label
    $nameLabel.Text = 'Name'
    $nameLabel.AutoSize = $true
    $nameLabel.ForeColor = $script:GuiColors.Muted
    $nameLabel.Location = New-Object System.Drawing.Point(26, 92)
    $form.Controls.Add($nameLabel)

    $nameBox = New-Object System.Windows.Forms.TextBox
    $nameBox.Location = New-Object System.Drawing.Point(28, 113)
    $nameBox.Width = 386
    $nameBox.Font = New-Object System.Drawing.Font('Consolas', 10)
    $form.Controls.Add($nameBox)

    $hint = New-Object System.Windows.Forms.Label
    $hint.Text = 'lowercase letters, digits and dashes'
    $hint.ForeColor = $script:GuiColors.Muted
    $hint.AutoSize = $true
    $hint.Location = New-Object System.Drawing.Point(28, 139)
    $form.Controls.Add($hint)

    $typeLabel = New-Object System.Windows.Forms.Label
    $typeLabel.Text = 'Type'
    $typeLabel.AutoSize = $true
    $typeLabel.ForeColor = $script:GuiColors.Muted
    $typeLabel.Location = New-Object System.Drawing.Point(26, 170)
    $form.Controls.Add($typeLabel)

    $typeBox = New-Object System.Windows.Forms.ComboBox
    $typeBox.Location = New-Object System.Drawing.Point(28, 191)
    $typeBox.Width = 386
    $typeBox.DropDownStyle = 'DropDownList'
    $typeBox.Items.AddRange(@('Blank PHP project', 'WordPress', 'Laravel')) | Out-Null
    $typeBox.SelectedIndex = 0
    $form.Controls.Add($typeBox)

    $openBox = New-Object System.Windows.Forms.CheckBox
    $openBox.Text = 'Open in the browser after creating'
    $openBox.Checked = $true
    $openBox.AutoSize = $true
    $openBox.Location = New-Object System.Drawing.Point(28, 230)
    $form.Controls.Add($openBox)

    $create = New-FlatButton -Text 'Create' -Width 110 -Primary
    $create.Location = New-Object System.Drawing.Point(196, 266)
    $form.Controls.Add($create)

    $cancel = New-FlatButton -Text 'Cancel' -Width 100
    $cancel.Location = New-Object System.Drawing.Point(314, 266)
    $form.Controls.Add($cancel)

    $result = $null

    $create.Add_Click({
        $name = $nameBox.Text.Trim().ToLowerInvariant()
        if ($name -notmatch '^[a-z0-9][a-z0-9-]{0,30}$') {
            Show-GuiError 'Use lowercase letters, digits or dashes (max 31 characters).'
            return
        }
        if ($name -eq 'panel') {
            Show-GuiError "'panel' is reserved."
            return
        }
        $types = @('blank', 'wordpress', 'laravel')
        $script:projectDialogResult = [pscustomobject]@{
            Name = $name
            Type = $types[$typeBox.SelectedIndex]
            Open = $openBox.Checked
        }
        $form.Close()
    })
    $cancel.Add_Click({ $form.Close() })
    $nameBox.Add_KeyDown({
        param($sender, $event)
        if ($event.KeyCode -eq [System.Windows.Forms.Keys]::Enter) { $create.PerformClick() }
    })

    Set-GuiTheme $form
    $form.AcceptButton = $create
    $form.CancelButton = $cancel
    $null = $form.ShowDialog($Owner)
    return $script:projectDialogResult
}

function Show-PortConflictDialog {
    param($Owner, $Conflicts)

    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Port conflict'
    $form.Size = New-Object System.Drawing.Size(600, 380)
    $form.StartPosition = 'CenterParent'
    $form.FormBorderStyle = 'FixedDialog'
    $form.MaximizeBox = $false
    $form.MinimizeBox = $false
    $form.BackColor = $script:GuiColors.Background
    $form.ForeColor = $script:GuiColors.Text
    $form.Font = $script:GuiFont

    $title = New-Object System.Windows.Forms.Label
    $title.Text = 'Some ports are already taken'
    $title.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 14)
    $title.AutoSize = $true
    $title.Location = New-Object System.Drawing.Point(22, 18)
    $form.Controls.Add($title)

    $sub = New-Object System.Windows.Forms.Label
    $sub.Text = 'Stop the other program, or change the WampDeck ports in Settings.'
    $sub.ForeColor = $script:GuiColors.Muted
    $sub.AutoSize = $true
    $sub.Location = New-Object System.Drawing.Point(24, 50)
    $form.Controls.Add($sub)

    $list = New-Object System.Windows.Forms.ListView
    $list.Location = New-Object System.Drawing.Point(24, 82)
    $list.Size = New-Object System.Drawing.Size(536, 210)
    $list.View = 'Details'
    $list.FullRowSelect = $true
    $list.GridLines = $false
    $list.Columns.Add('Port', 80) | Out-Null
    $list.Columns.Add('Process', 160) | Out-Null
    $list.Columns.Add('PID', 80) | Out-Null
    $list.Columns.Add('Path', 380) | Out-Null
    foreach ($conflict in @($Conflicts)) {
        $item = New-Object System.Windows.Forms.ListViewItem([string]$conflict.Port)
        $item.SubItems.Add([string]$conflict.Name) | Out-Null
        $item.SubItems.Add([string]$conflict.Pid) | Out-Null
        $item.SubItems.Add([string]$conflict.Path) | Out-Null
        $list.Items.Add($item) | Out-Null
    }
    $form.Controls.Add($list)
    Enable-DarkListView $list
    Add-DarkListHeader $list

    $retry = New-FlatButton -Text 'Retry' -Width 100 -Primary
    $retry.Location = New-Object System.Drawing.Point(240, 306)
    $form.Controls.Add($retry)

    $settings = New-FlatButton -Text 'Settings' -Width 100
    $settings.Location = New-Object System.Drawing.Point(350, 306)
    $form.Controls.Add($settings)

    $cancel = New-FlatButton -Text 'Cancel' -Width 100
    $cancel.Location = New-Object System.Drawing.Point(460, 306)
    $form.Controls.Add($cancel)

    $script:portDialogResult = 'cancel'
    $retry.Add_Click({ $script:portDialogResult = 'retry'; $form.Close() })
    $settings.Add_Click({ $script:portDialogResult = 'settings'; $form.Close() })
    $cancel.Add_Click({ $form.Close() })

    Set-GuiTheme $form
    $form.CancelButton = $cancel
    $null = $form.ShowDialog($Owner)
    return $script:portDialogResult
}

function Show-CmsDialog {
    param($Owner, [string]$PresetCms = '')

    $script:cmsDialogResult = $null
    $script:cmsDialogCatalog = @(Get-WampDeckCmsCatalog)
    $catalog = $script:cmsDialogCatalog

    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Install a CMS'
    $form.Size = New-Object System.Drawing.Size(536, 470)
    $form.StartPosition = 'CenterParent'
    $form.FormBorderStyle = 'FixedDialog'
    $form.MaximizeBox = $false
    $form.MinimizeBox = $false
    $form.BackColor = $script:GuiColors.Background
    $form.ForeColor = $script:GuiColors.Text
    $form.Font = $script:GuiFont

    $title = New-Object System.Windows.Forms.Label
    $title.Text = 'Install a CMS'
    $title.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 14)
    $title.AutoSize = $true
    $title.Location = New-Object System.Drawing.Point(24, 20)
    $form.Controls.Add($title)

    $sub = New-Object System.Windows.Forms.Label
    $sub.Text = 'The CMS is downloaded and installed silently into a new project in www\.'
    $sub.ForeColor = $script:GuiColors.Muted
    $sub.AutoSize = $true
    $sub.Location = New-Object System.Drawing.Point(26, 54)
    $form.Controls.Add($sub)

    $nameLabel = New-Object System.Windows.Forms.Label
    $nameLabel.Text = 'Project name'
    $nameLabel.AutoSize = $true
    $nameLabel.ForeColor = $script:GuiColors.Muted
    $nameLabel.Location = New-Object System.Drawing.Point(26, 88)
    $form.Controls.Add($nameLabel)

    $nameBox = New-Object System.Windows.Forms.TextBox
    $nameBox.Location = New-Object System.Drawing.Point(28, 107)
    $nameBox.Width = 440
    $nameBox.Font = New-Object System.Drawing.Font('Consolas', 10)
    $form.Controls.Add($nameBox)

    $cmsLabel = New-Object System.Windows.Forms.Label
    $cmsLabel.Text = 'CMS'
    $cmsLabel.AutoSize = $true
    $cmsLabel.ForeColor = $script:GuiColors.Muted
    $cmsLabel.Location = New-Object System.Drawing.Point(26, 142)
    $form.Controls.Add($cmsLabel)

    $cmsBox = New-Object System.Windows.Forms.ComboBox
    $cmsBox.Location = New-Object System.Drawing.Point(28, 161)
    $cmsBox.Width = 440
    $cmsBox.DropDownStyle = 'DropDownList'
    $cmsBox.Items.AddRange(@($catalog | ForEach-Object { "$($_.Name) - $($_.Category)" })) | Out-Null
    $form.Controls.Add($cmsBox)

    if ($PresetCms) {
        # A CMS launch tile (header quick-install strip) hands us its CMS; pick
        # the matching catalog entry so the install dialog opens prefilled with
        # that CMS and the suggested project name instead of the default.
        $presetEntry = Resolve-WampDeckCms $PresetCms
        $presetIndex = -1
        for ($index = 0; $index -lt $catalog.Count; $index++) {
            if ($catalog[$index].Id -eq $presetEntry.Id) { $presetIndex = $index; break }
        }
        if ($presetIndex -ge 0) { $cmsBox.SelectedIndex = $presetIndex }
    }

    $statusLabel = New-Object System.Windows.Forms.Label
    $statusLabel.AutoSize = $false
    $statusLabel.Size = New-Object System.Drawing.Size(440, 32)
    $statusLabel.Location = New-Object System.Drawing.Point(28, 191)
    $statusLabel.ForeColor = $script:GuiColors.Muted
    $form.Controls.Add($statusLabel)

    $userLabel = New-Object System.Windows.Forms.Label
    $userLabel.Text = 'Admin user'
    $userLabel.AutoSize = $true
    $userLabel.ForeColor = $script:GuiColors.Muted
    $userLabel.Location = New-Object System.Drawing.Point(26, 230)
    $form.Controls.Add($userLabel)

    $userBox = New-Object System.Windows.Forms.TextBox
    $userBox.Location = New-Object System.Drawing.Point(28, 249)
    $userBox.Width = 208
    $form.Controls.Add($userBox)

    $emailLabel = New-Object System.Windows.Forms.Label
    $emailLabel.Text = 'Admin email'
    $emailLabel.AutoSize = $true
    $emailLabel.ForeColor = $script:GuiColors.Muted
    $emailLabel.Location = New-Object System.Drawing.Point(260, 230)
    $form.Controls.Add($emailLabel)

    $emailBox = New-Object System.Windows.Forms.TextBox
    $emailBox.Location = New-Object System.Drawing.Point(262, 249)
    $emailBox.Width = 206
    $form.Controls.Add($emailBox)

    $passwordLabel = New-Object System.Windows.Forms.Label
    $passwordLabel.Text = 'Admin password'
    $passwordLabel.AutoSize = $true
    $passwordLabel.ForeColor = $script:GuiColors.Muted
    $passwordLabel.Location = New-Object System.Drawing.Point(26, 286)
    $form.Controls.Add($passwordLabel)

    $passBox = New-Object System.Windows.Forms.TextBox
    $passBox.Location = New-Object System.Drawing.Point(28, 305)
    $passBox.Width = 440
    $passBox.UseSystemPasswordChar = $true
    $form.Controls.Add($passBox)

    $passwordHint = New-Object System.Windows.Forms.Label
    $passwordHint.Text = 'Leave the user, email and password blank to use admin / admin@<name>.test / a generated password.'
    $passwordHint.ForeColor = $script:GuiColors.Muted
    $passwordHint.AutoSize = $true
    $passwordHint.Location = New-Object System.Drawing.Point(28, 331)
    $form.Controls.Add($passwordHint)

    $openBox = New-Object System.Windows.Forms.CheckBox
    $openBox.Text = 'Open the site in the browser when the install finishes'
    $openBox.Checked = $true
    $openBox.AutoSize = $true
    $openBox.Location = New-Object System.Drawing.Point(28, 358)
    $form.Controls.Add($openBox)

    $create = New-FlatButton -Text 'Install' -Width 110 -Primary
    $create.Location = New-Object System.Drawing.Point(196, 392)
    $form.Controls.Add($create)

    $cancel = New-FlatButton -Text 'Cancel' -Width 100
    $cancel.Location = New-Object System.Drawing.Point(314, 392)
    $form.Controls.Add($cancel)

    $cmsBox.Add_SelectedIndexChanged({
        if ($cmsBox.SelectedIndex -lt 0) { return }
        $entry = $script:cmsDialogCatalog[$cmsBox.SelectedIndex]
        if (-not $nameBox.Text.Trim()) { $nameBox.Text = $entry.Id }
        if ($entry.Verified) {
            $statusLabel.Text = 'Verified recipe - the install path and admin login were tested.'
            $statusLabel.ForeColor = $script:GuiColors.Accent
        } else {
            $statusLabel.Text = "Experimental recipe - check logs\cms-$($entry.Id).log after the install."
            $statusLabel.ForeColor = $script:GuiColors.Yellow
        }
    })

    $create.Add_Click({
        $name = $nameBox.Text.Trim().ToLowerInvariant()
        if ($name -notmatch '^[a-z0-9][a-z0-9-]{0,30}$') {
            Show-GuiError 'Use lowercase letters, digits or dashes (max 31 characters).'
            return
        }
        if ($name -eq 'panel') {
            Show-GuiError "'panel' is reserved."
            return
        }
        if ($cmsBox.SelectedIndex -lt 0) {
            Show-GuiError 'Pick a CMS.'
            return
        }

        $user = $userBox.Text.Trim()
        $email = $emailBox.Text.Trim()
        $password = $passBox.Text
        if ($user -and $user -notmatch '^[A-Za-z0-9][A-Za-z0-9._-]{1,31}$') {
            Show-GuiError 'Admin user must be 2-32 letters, digits, dots, dashes or underscores.'
            return
        }
        if ($email -and $email -notmatch '^[^@\s]+@[^@\s]+\.[^@\s]+$') {
            Show-GuiError "Admin email '$email' is not valid."
            return
        }
        if ($password -and $password.Length -lt 8) {
            Show-GuiError 'Admin password must be at least 8 characters.'
            return
        }

        $entry = $script:cmsDialogCatalog[$cmsBox.SelectedIndex]
        $script:cmsDialogResult = [pscustomobject]@{
            Name          = $name
            Cms           = $entry.Id
            AdminUser     = $user
            AdminEmail    = $email
            AdminPassword = $password
            Open          = $openBox.Checked
        }
        $form.Close()
    })
    $cancel.Add_Click({ $form.Close() })
    $nameBox.Add_KeyDown({
        param($sender, $event)
        if ($event.KeyCode -eq [System.Windows.Forms.Keys]::Enter) { $create.PerformClick() }
    })

    # Show WordPress first: it is the verified recipe most people want.
    # A preset CMS coming from a launch tile wins over the default selection.
    if (-not $PresetCms) {
        $defaultIndex = 0
        for ($index = 0; $index -lt $catalog.Count; $index++) {
            if ($catalog[$index].Id -eq 'wordpress') { $defaultIndex = $index; break }
        }
        $cmsBox.SelectedIndex = $defaultIndex
        $nameBox.Text = $catalog[$defaultIndex].Id
    }

    Set-GuiTheme $form
    $form.AcceptButton = $create
    $form.CancelButton = $cancel
    $null = $form.ShowDialog($Owner)
    return $script:cmsDialogResult
}

function Show-CmsResultDialog {
    param($Owner, $Result)

    if (-not $Result) { return }

    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'CMS installed'
    $form.Size = New-Object System.Drawing.Size(676, 500)
    $form.StartPosition = 'CenterParent'
    $form.FormBorderStyle = 'FixedDialog'
    $form.MaximizeBox = $false
    $form.MinimizeBox = $false
    $form.BackColor = $script:GuiColors.Background
    $form.ForeColor = $script:GuiColors.Text
    $form.Font = $script:GuiFont

    $title = New-Object System.Windows.Forms.Label
    $title.Text = "$($Result.CmsName) is ready"
    $title.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 14)
    $title.AutoSize = $true
    $title.Location = New-Object System.Drawing.Point(24, 20)
    $form.Controls.Add($title)

    $sub = New-Object System.Windows.Forms.Label
    $sub.Text = "$($Result.Category) - www\$($Result.Name)"
    $sub.ForeColor = $script:GuiColors.Muted
    $sub.AutoSize = $true
    $sub.Location = New-Object System.Drawing.Point(26, 54)
    $form.Controls.Add($sub)

    $details = New-Object System.Windows.Forms.TextBox
    $details.Multiline = $true
    $details.ReadOnly = $true
    $details.ScrollBars = 'Vertical'
    $details.WordWrap = $false
    $details.Font = New-Object System.Drawing.Font('Consolas', 9.5)
    $details.Location = New-Object System.Drawing.Point(28, 86)
    $details.Size = New-Object System.Drawing.Size(600, 236)
    $form.Controls.Add($details)

    $docRoot = if ($Result.DocRoot) { [string]$Result.DocRoot } else { '(project root)' }
    $details.Text = (@(
        "Site        $($Result.Url)"
        "Admin URL   $($Result.AdminUrl)"
        "User        $($Result.AdminUser)"
        "Password    $($Result.AdminPassword)"
        "Email       $($Result.AdminEmail)"
        "Folder      $($Result.Folder)"
        "Database    $($Result.Database)"
        "Docroot     $docRoot"
        "Log         $($Result.Log)"
    ) -join "`r`n")

    $copyPassword = New-FlatButton -Text 'Copy password' -Width 140
    $copyPassword.Location = New-Object System.Drawing.Point(28, 340)
    $form.Controls.Add($copyPassword)

    $copyAll = New-FlatButton -Text 'Copy all' -Width 100
    $copyAll.Location = New-Object System.Drawing.Point(178, 340)
    $form.Controls.Add($copyAll)

    $openAdmin = New-FlatButton -Text 'Open admin' -Width 110 -Primary
    $openAdmin.Location = New-Object System.Drawing.Point(288, 340)
    $form.Controls.Add($openAdmin)

    $close = New-FlatButton -Text 'Close' -Width 100
    $close.Location = New-Object System.Drawing.Point(408, 340)
    $form.Controls.Add($close)

    if (-not $Result.Verified) {
        $note = New-Object System.Windows.Forms.Label
        $note.Text = 'Experimental recipe - check the log before using this site for real work.'
        $note.ForeColor = $script:GuiColors.Yellow
        $note.AutoSize = $true
        $note.Location = New-Object System.Drawing.Point(28, 386)
        $form.Controls.Add($note)
    }

    $copyPassword.Add_Click({
        if ($Result.AdminPassword) {
            [System.Windows.Forms.Clipboard]::SetText([string]$Result.AdminPassword)
        }
    })
    $copyAll.Add_Click({
        [System.Windows.Forms.Clipboard]::SetText([string]$details.Text)
    })
    $openAdmin.Add_Click({
        try { Start-Process ([string]$Result.AdminUrl) } catch { Show-GuiError $_.Exception.Message }
    })
    $close.Add_Click({ $form.Close() })

    Set-GuiTheme $form
    $form.CancelButton = $close
    $null = $form.ShowDialog($Owner)
}
