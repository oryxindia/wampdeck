# WampDeck first-run language picker.
# Runs once after installation. Chooses UI language and fixes the layout
# (Arabic = RTL). Changing language later in Settings only changes text.
param([switch]$Force)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
. (Join-Path $root 'config.ps1')
. (Join-Path $root 'lib\common.ps1')
. (Join-Path $root 'lib\i18n.ps1')
. (Join-Path $root 'lib\i18n-extra.ps1')

if ((-not $Force) -and $State['languageSelected']) { exit 0 }

# Languages with complete translations in phase 1.
$choices = @($script:CompleteLanguages)

$form = New-Object System.Windows.Forms.Form
$form.Text = 'WampDeck - ' + (Get-WampDeckString 'FirstRunTitle' -Language 'en')
$form.Size = New-Object System.Drawing.Size(520, 250)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.BackColor = [System.Drawing.Color]::FromArgb(11,17,30)
$form.ForeColor = [System.Drawing.Color]::White

$label = New-Object System.Windows.Forms.Label
$label.Text = Get-WampDeckString 'FirstRunTitle' -Language 'en'
$label.Location = New-Object System.Drawing.Point(22, 20)
$label.AutoSize = $true
$label.Font = New-Object System.Drawing.Font('Segoe UI', 13, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($label)

$hint = New-Object System.Windows.Forms.Label
$hint.Text = Get-WampDeckString 'FirstRunHint' -Language 'en'
$hint.Location = New-Object System.Drawing.Point(22, 56)
$hint.AutoSize = $true
$form.Controls.Add($hint)

$combo = New-Object System.Windows.Forms.ComboBox
$combo.Location = New-Object System.Drawing.Point(22, 82)
$combo.Size = New-Object System.Drawing.Size(456, 30)
$combo.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$languageCodes = @()
foreach ($entry in $choices) { [void]$combo.Items.Add([string]$entry.Name); $languageCodes += [string]$entry.Code }
$current = [string]$State['language']
for ($i = 0; $i -lt $choices.Count; $i++) { if ($choices[$i].Code -eq $current) { $combo.SelectedIndex = $i } }
if ($combo.SelectedIndex -lt 0) { $combo.SelectedIndex = 0 }
$form.Controls.Add($combo)

$note = New-Object System.Windows.Forms.Label
$note.Text = Get-WampDeckString 'FirstRunRtlNote' -Language 'en'
$note.Location = New-Object System.Drawing.Point(22, 120)
$note.Size = New-Object System.Drawing.Size(456, 42)
$form.Controls.Add($note)

$ok = New-Object System.Windows.Forms.Button
$ok.Text = 'OK'
$ok.Size = New-Object System.Drawing.Size(130, 34)
$ok.Location = New-Object System.Drawing.Point(170, 170)
$ok.FlatStyle = 'Flat'
$ok.BackColor = [System.Drawing.Color]::FromArgb(46,204,113)
$ok.ForeColor = [System.Drawing.Color]::FromArgb(10,20,14)
$ok.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.Controls.Add($ok)
$form.AcceptButton = $ok

if ($form.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) { exit 0 }
$code = [string]$languageCodes[$combo.SelectedIndex]
$State['language'] = $code
$State['layout'] = if ($code -eq 'ar') { 'rtl' } else { 'ltr' }
$State['languageSelected'] = $true
Save-StackState
Write-Host ('Language set to ' + $code + ', layout ' + $State['layout'])
