# WinForms theme and small UI helpers for the WampDeck panel.

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

if (-not ('WampDeckDarkTitle' -as [type])) {
    Add-Type @'
using System;
using System.Runtime.InteropServices;
public static class WampDeckDarkTitle {
    [DllImport("dwmapi.dll", PreserveSig = true)]
    private static extern int DwmSetWindowAttribute(IntPtr hwnd, int attr, ref int attrValue, int attrSize);
    public static void Apply(IntPtr hwnd) {
        if (hwnd == IntPtr.Zero) { return; }
        int value = 1;
        if (DwmSetWindowAttribute(hwnd, 20, ref value, 4) != 0) {
            DwmSetWindowAttribute(hwnd, 19, ref value, 4);
        }
    }
}
'@
}

if (-not ('WampDeckMenuRenderer' -as [type])) {
    Add-Type -TypeDefinition @'
using System;
using System.Drawing;
using System.Windows.Forms;

public class WampDeckMenuColorTable : ProfessionalColorTable {
    private Color bg;
    private Color hover;
    private Color border;
    private Color accent;

    public WampDeckMenuColorTable(Color background, Color hoverColor, Color borderColor, Color accentColor) {
        bg = background;
        hover = hoverColor;
        border = borderColor;
        accent = accentColor;
    }

    public override Color MenuItemSelected { get { return hover; } }
    public override Color MenuItemSelectedGradientBegin { get { return hover; } }
    public override Color MenuItemSelectedGradientEnd { get { return hover; } }
    public override Color MenuItemPressedGradientBegin { get { return hover; } }
    public override Color MenuItemPressedGradientMiddle { get { return hover; } }
    public override Color MenuItemPressedGradientEnd { get { return hover; } }
    public override Color MenuItemBorder { get { return border; } }
    public override Color MenuBorder { get { return border; } }
    public override Color ToolStripDropDownBackground { get { return bg; } }
    public override Color ImageMarginGradientBegin { get { return bg; } }
    public override Color ImageMarginGradientMiddle { get { return bg; } }
    public override Color ImageMarginGradientEnd { get { return bg; } }
    public override Color SeparatorDark { get { return border; } }
    public override Color SeparatorLight { get { return border; } }
    public override Color CheckBackground { get { return accent; } }
    public override Color CheckSelectedBackground { get { return accent; } }
    public override Color CheckPressedBackground { get { return accent; } }
    public override Color ButtonSelectedHighlight { get { return hover; } }
    public override Color ButtonSelectedHighlightBorder { get { return border; } }
    public override Color ButtonPressedHighlight { get { return hover; } }
    public override Color ButtonPressedHighlightBorder { get { return border; } }
}

public class WampDeckMenuRenderer : ToolStripProfessionalRenderer {
    private Color bg;
    private Color fg;
    private Color hover;
    private Color border;
    private Color disabled;
    private Color accent;
    private Color onAccent;

    public WampDeckMenuRenderer(Color background, Color foreground, Color hoverColor, Color borderColor, Color disabledColor, Color accentColor, Color onAccentColor)
        : base(new WampDeckMenuColorTable(background, hoverColor, borderColor, accentColor)) {
        bg = background;
        fg = foreground;
        hover = hoverColor;
        border = borderColor;
        disabled = disabledColor;
        accent = accentColor;
        onAccent = onAccentColor;
        RoundedEdges = false;
    }

    protected override void OnRenderToolStripBackground(ToolStripRenderEventArgs e) {
        using (SolidBrush brush = new SolidBrush(bg)) {
            e.Graphics.FillRectangle(brush, e.AffectedBounds);
        }
    }

    protected override void OnRenderToolStripBorder(ToolStripRenderEventArgs e) {
        using (Pen pen = new Pen(border)) {
            e.Graphics.DrawRectangle(pen, 0, 0, e.ToolStrip.Width - 1, e.ToolStrip.Height - 1);
        }
    }

    protected override void OnRenderMenuItemBackground(ToolStripItemRenderEventArgs e) {
        bool active = e.Item.Selected || e.Item.Pressed;
        Color fill = active ? hover : bg;
        using (SolidBrush brush = new SolidBrush(fill)) {
            e.Graphics.FillRectangle(brush, new Rectangle(Point.Empty, e.Item.Size));
        }
        if (active) {
            using (Pen pen = new Pen(border)) {
                e.Graphics.DrawRectangle(pen, 0, 0, e.Item.Width - 1, e.Item.Height - 1);
            }
        }
    }

    protected override void OnRenderItemText(ToolStripItemTextRenderEventArgs e) {
        e.TextColor = e.Item.Enabled ? fg : disabled;
        base.OnRenderItemText(e);
    }

    protected override void OnRenderSeparator(ToolStripSeparatorRenderEventArgs e) {
        int y = e.Item.Height / 2;
        using (Pen pen = new Pen(border)) {
            e.Graphics.DrawLine(pen, 8, y, e.Item.Width - 8, y);
        }
    }

    protected override void OnRenderImageMargin(ToolStripRenderEventArgs e) {
        using (SolidBrush brush = new SolidBrush(bg)) {
            e.Graphics.FillRectangle(brush, e.AffectedBounds);
        }
    }

    protected override void OnRenderArrow(ToolStripArrowRenderEventArgs e) {
        e.ArrowColor = fg;
        base.OnRenderArrow(e);
    }

    protected override void OnRenderItemCheck(ToolStripItemImageRenderEventArgs e) {
        Rectangle r = e.ImageRectangle;
        if (r.Width <= 0 || r.Height <= 0) { r = new Rectangle(2, 2, 16, 16); }
        using (SolidBrush brush = new SolidBrush(accent)) {
            e.Graphics.FillRectangle(brush, r);
        }
        using (Pen pen = new Pen(onAccent, 2f)) {
            e.Graphics.DrawLines(pen, new Point[] {
                new Point(r.Left + 3, r.Top + r.Height / 2),
                new Point(r.Left + r.Width / 2, r.Bottom - 4),
                new Point(r.Right - 3, r.Top + 3)
            });
        }
    }
}
'@ -ReferencedAssemblies System.Windows.Forms, System.Drawing
}

$script:GuiColors = @{
    Background = [System.Drawing.Color]::FromArgb(8, 12, 20)
    Surface    = [System.Drawing.Color]::FromArgb(17, 26, 43)
    SurfaceAlt = [System.Drawing.Color]::FromArgb(24, 36, 56)
    Border     = [System.Drawing.Color]::FromArgb(38, 55, 80)
    Text       = [System.Drawing.Color]::FromArgb(232, 238, 248)
    Muted      = [System.Drawing.Color]::FromArgb(147, 164, 189)
    Accent     = [System.Drawing.Color]::FromArgb(52, 211, 153)
    AccentDark = [System.Drawing.Color]::FromArgb(4, 18, 26)
    Blue       = [System.Drawing.Color]::FromArgb(147, 197, 253)
    Red        = [System.Drawing.Color]::FromArgb(248, 113, 113)
    Yellow     = [System.Drawing.Color]::FromArgb(250, 204, 21)
    Selection  = [System.Drawing.Color]::FromArgb(28, 62, 86)
}

$script:GuiFont = New-Object System.Drawing.Font('Segoe UI', 9)
$script:GuiFontBold = New-Object System.Drawing.Font('Segoe UI', 9, [System.Drawing.FontStyle]::Bold)
$script:GuiFontTitle = New-Object System.Drawing.Font('Segoe UI Semibold', 20)
$script:GuiFontSub = New-Object System.Drawing.Font('Segoe UI', 9)
$script:GuiFontMono = New-Object System.Drawing.Font('Cascadia Mono', 8.5)

function New-FlatButton {
    param(
        [string]$Text,
        [int]$Width = 96,
        [int]$Height = 30,
        [switch]$Primary
    )
    $button = New-Object System.Windows.Forms.Button
    $button.Text = $Text
    $button.Width = $Width
    $button.Height = $Height
    $button.FlatStyle = 'Flat'
    # A subtle border makes the true button size visible; without it the
    # dark buttons blend into the panel and look narrower than the green one.
    $button.FlatAppearance.BorderSize = 1
    $button.FlatAppearance.BorderColor = $script:GuiColors.Border
    $button.Cursor = [System.Windows.Forms.Cursors]::Hand
    $button.Font = $script:GuiFontBold
    if ($Primary) {
        $button.BackColor = $script:GuiColors.Accent
        $button.ForeColor = $script:GuiColors.AccentDark
    } else {
        $button.BackColor = $script:GuiColors.SurfaceAlt
        $button.ForeColor = $script:GuiColors.Text
    }
    return $button
}

function Set-GuiTheme {
    param($Control)
    if ($null -eq $Control) { return }

    if ($Control -is [System.Windows.Forms.MenuStrip] -or
        $Control -is [System.Windows.Forms.ToolStrip] -or
        $Control -is [System.Windows.Forms.StatusStrip]) {
        $Control.BackColor = $script:GuiColors.Surface
        $Control.ForeColor = $script:GuiColors.Text
        $renderer = New-Object WampDeckMenuRenderer -ArgumentList @(
            $script:GuiColors.Surface,
            $script:GuiColors.Text,
            $script:GuiColors.SurfaceAlt,
            $script:GuiColors.Border,
            $script:GuiColors.Muted,
            $script:GuiColors.Accent,
            $script:GuiColors.AccentDark
        )
        $Control.Renderer = $renderer
        [System.Windows.Forms.ToolStripManager]::Renderer = $renderer
    } elseif ($Control -is [System.Windows.Forms.Form]) {
        $Control.BackColor = $script:GuiColors.Background
        $Control.ForeColor = $script:GuiColors.Text
        $Control.Add_HandleCreated({
            param($sender, $eventArgs)
            [WampDeckDarkTitle]::Apply($sender.Handle)
        })
        [WampDeckDarkTitle]::Apply($Control.Handle)
    } elseif ($Control -is [System.Windows.Forms.TabPage]) {
        $Control.BackColor = $script:GuiColors.Background
        $Control.ForeColor = $script:GuiColors.Text
        $Control.UseVisualStyleBackColor = $false
    } elseif ($Control -is [System.Windows.Forms.TabControl]) {
        $Control.BackColor = $script:GuiColors.Background
        $Control.ForeColor = $script:GuiColors.Text
    } elseif ($Control -is [System.Windows.Forms.Panel]) {
        # Panels keep their explicit colour (status cards, tab pages).
    } elseif ($Control -is [System.Windows.Forms.ListView]) {
        $Control.BackColor = $script:GuiColors.Surface
        $Control.ForeColor = $script:GuiColors.Text
        $Control.BorderStyle = 'None'
    } elseif ($Control -is [System.Windows.Forms.TextBox] -or
        $Control -is [System.Windows.Forms.NumericUpDown]) {
        $Control.BackColor = $script:GuiColors.SurfaceAlt
        $Control.ForeColor = $script:GuiColors.Text
        $Control.BorderStyle = 'FixedSingle'
    } elseif ($Control -is [System.Windows.Forms.ComboBox]) {
        $Control.BackColor = $script:GuiColors.SurfaceAlt
        $Control.ForeColor = $script:GuiColors.Text
        $Control.FlatStyle = 'Flat'
        # The drop-down list is painted by Windows, so it ignores BackColor and
        # would show light text on a white list. Draw the rows ourselves.
        if ($Control.DrawMode -ne [System.Windows.Forms.DrawMode]::OwnerDrawFixed) {
            $Control.DrawMode = 'OwnerDrawFixed'
            $Control.Add_DrawItem({
                param($sender, $eventArgs)
                if ($eventArgs.Index -lt 0) { return }
                $selected = (($eventArgs.State -band [System.Windows.Forms.DrawItemState]::Selected) -ne 0)
                $background = if ($selected) { $script:GuiColors.Accent } else { $script:GuiColors.SurfaceAlt }
                $foreground = if ($selected) { $script:GuiColors.AccentDark } else { $script:GuiColors.Text }
                $brush = New-Object System.Drawing.SolidBrush($background)
                $eventArgs.Graphics.FillRectangle($brush, $eventArgs.Bounds)
                $brush.Dispose()
                $text = [string]$sender.Items[$eventArgs.Index]
                $textBounds = New-Object System.Drawing.Rectangle(
                    ($eventArgs.Bounds.Left + 6), $eventArgs.Bounds.Top,
                    ($eventArgs.Bounds.Width - 8), $eventArgs.Bounds.Height)
                $flags = [System.Windows.Forms.TextFormatFlags]::VerticalCenter -bor
                    [System.Windows.Forms.TextFormatFlags]::Left
                [System.Windows.Forms.TextRenderer]::DrawText(
                    $eventArgs.Graphics, $text, $sender.Font, $textBounds, $foreground, $flags)
            })
        }
    } elseif ($Control -is [System.Windows.Forms.Button]) {
        if ($Control.BackColor -eq [System.Drawing.Color]::Empty) {
            $Control.BackColor = $script:GuiColors.SurfaceAlt
            $Control.ForeColor = $script:GuiColors.Text
        }
        $Control.FlatStyle = 'Flat'
        # Keep a 1px border so every button's true width is visible and the
        # four header buttons look the same size, not just the green one.
        $Control.FlatAppearance.BorderSize = 1
        $Control.FlatAppearance.BorderColor = $script:GuiColors.Border
    } elseif ($Control -is [System.Windows.Forms.Label]) {
        if ($Control.ForeColor -eq [System.Drawing.SystemColors]::ControlText) {
            $Control.ForeColor = $script:GuiColors.Text
        }
        if ($Control.BackColor -eq [System.Drawing.SystemColors]::Control) {
            $Control.BackColor = [System.Drawing.Color]::Transparent
        }
    } elseif ($Control -is [System.Windows.Forms.CheckBox]) {
        if ($Control.ForeColor -eq [System.Drawing.SystemColors]::ControlText) {
            $Control.ForeColor = $script:GuiColors.Text
        }
        if ($Control.BackColor -eq [System.Drawing.SystemColors]::Control) {
            $Control.BackColor = [System.Drawing.Color]::Transparent
        }
        $Control.FlatStyle = 'Flat'
    } else {
        $Control.BackColor = $script:GuiColors.Surface
        $Control.ForeColor = $script:GuiColors.Text
    }

    foreach ($child in $Control.Controls) { Set-GuiTheme $child }
}

function Set-ListViewFill {
    param($ListView, [int]$MinWidth = 120)
    if (-not $ListView -or $ListView.Columns.Count -eq 0) { return }
    $otherWidth = 0
    for ($i = 0; $i -lt ($ListView.Columns.Count - 1); $i++) {
        $otherWidth += $ListView.Columns[$i].Width
    }
    $lastWidth = $ListView.ClientSize.Width - $otherWidth - 2
    if ($lastWidth -lt $MinWidth) { $lastWidth = $MinWidth }
    $ListView.Columns[$ListView.Columns.Count - 1].Width = $lastWidth
}

function Update-DarkListHeader {
    param($ListView)
    $info = $ListView.Tag
    if (-not $info) { return }
    $info.HeaderPanel.Width = $ListView.Width
    $x = 0
    for ($i = 0; $i -lt $info.HeaderLabels.Count; $i++) {
        $label = $info.HeaderLabels[$i]
        $label.Left = $x + 8
        $label.Width = [Math]::Max(20, $ListView.Columns[$i].Width - 12)
        $x += $ListView.Columns[$i].Width
    }
}

function Add-DarkListHeader {
    param($ListView, [int]$Height = 26)

    $ListView.HeaderStyle = 'None'

    $header = New-Object System.Windows.Forms.Panel
    $header.Location = New-Object System.Drawing.Point($ListView.Left, $ListView.Top)
    $header.Size = New-Object System.Drawing.Size($ListView.Width, $Height)
    $header.BackColor = $script:GuiColors.SurfaceAlt
    $header.Add_Paint({
        param($sender, $eventArgs)
        $pen = New-Object System.Drawing.Pen($script:GuiColors.Border)
        $eventArgs.Graphics.DrawLine($pen, 0, $sender.Height - 1, $sender.Width, $sender.Height - 1)
        $pen.Dispose()
    })

    $labels = @()
    $x = 0
    foreach ($column in $ListView.Columns) {
        $label = New-Object System.Windows.Forms.Label
        $label.Text = $column.Text
        $label.AutoSize = $false
        $label.Location = New-Object System.Drawing.Point(($x + 8), 0)
        $label.Size = New-Object System.Drawing.Size(($column.Width - 12), $Height)
        $label.TextAlign = 'MiddleLeft'
        $label.BackColor = [System.Drawing.Color]::Transparent
        $label.ForeColor = $script:GuiColors.Muted
        $label.Font = New-Object System.Drawing.Font('Segoe UI', 8.5, [System.Drawing.FontStyle]::Bold)
        $header.Controls.Add($label)
        $labels += $label
        $x += $column.Width
    }

    $ListView.Parent.Controls.Add($header)
    $header.BringToFront()
    $ListView.Top = $ListView.Top + $Height
    $ListView.Height = $ListView.Height - $Height
    $ListView.Tag = @{ HeaderPanel = $header; HeaderLabels = $labels }

    $ListView.Add_Resize({
        param($sender, $eventArgs)
        Set-ListViewFill $sender
        Update-DarkListHeader $sender
    })

    Set-ListViewFill $ListView
    Update-DarkListHeader $ListView
}

function Enable-DarkListView {
    param($ListView)

    $ListView.OwnerDraw = $true
    $ListView.BorderStyle = 'None'
    $ListView.BackColor = $script:GuiColors.Surface
    $ListView.ForeColor = $script:GuiColors.Text

    $ListView.Add_DrawColumnHeader({
        param($sender, $eventArgs)
        $bounds = $eventArgs.Bounds
        $graphics = $eventArgs.Graphics
        $brush = New-Object System.Drawing.SolidBrush($script:GuiColors.SurfaceAlt)
        $graphics.FillRectangle($brush, $bounds)
        $brush.Dispose()
        $pen = New-Object System.Drawing.Pen($script:GuiColors.Border)
        $graphics.DrawLine($pen, $bounds.Left, $bounds.Bottom - 1, $bounds.Right, $bounds.Bottom - 1)
        if ($bounds.Right -lt $sender.ClientRectangle.Right) {
            $graphics.DrawLine($pen, $bounds.Right - 1, $bounds.Top + 5, $bounds.Right - 1, $bounds.Bottom - 6)
        }
        $pen.Dispose()
        $textBounds = New-Object System.Drawing.Rectangle(($bounds.Left + 8), $bounds.Top, ($bounds.Width - 10), ($bounds.Height - 1))
        $flags = [System.Windows.Forms.TextFormatFlags]::VerticalCenter -bor [System.Windows.Forms.TextFormatFlags]::Left
        [System.Windows.Forms.TextRenderer]::DrawText($graphics, $eventArgs.Header.Text, $sender.Font, $textBounds, $script:GuiColors.Muted, $flags)
    })

    $ListView.Add_DrawItem({
        param($sender, $eventArgs)
        $eventArgs.DrawDefault = $false
    })

    $ListView.Add_DrawSubItem({
        param($sender, $eventArgs)
        $bounds = $eventArgs.Bounds
        if ($eventArgs.Item.Selected) {
            $background = $script:GuiColors.Selection
        } elseif (($eventArgs.ItemIndex % 2) -eq 1) {
            $background = $script:GuiColors.SurfaceAlt
        } else {
            $background = $script:GuiColors.Surface
        }
        $brush = New-Object System.Drawing.SolidBrush($background)
        $eventArgs.Graphics.FillRectangle($brush, $bounds)
        $brush.Dispose()
        $textBounds = New-Object System.Drawing.Rectangle(($bounds.Left + 8), $bounds.Top, ($bounds.Width - 10), $bounds.Height)
        $flags = [System.Windows.Forms.TextFormatFlags]::VerticalCenter -bor [System.Windows.Forms.TextFormatFlags]::Left -bor [System.Windows.Forms.TextFormatFlags]::EndEllipsis
        [System.Windows.Forms.TextRenderer]::DrawText($eventArgs.Graphics, $eventArgs.SubItem.Text, $sender.Font, $textBounds, $script:GuiColors.Text, $flags)
    })
}

function Show-GuiError {
    param([string]$Message, [string]$Title = (Get-WampDeckString 'AppTitle'))
    [System.Windows.Forms.MessageBox]::Show($Message, $Title,
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error) | Out-Null
}

function Show-GuiInfo {
    param([string]$Message, [string]$Title = (Get-WampDeckString 'AppTitle'))
    [System.Windows.Forms.MessageBox]::Show($Message, $Title,
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information) | Out-Null
}

function Ask-GuiYesNo {
    param([string]$Message, [string]$Title = (Get-WampDeckString 'AppTitle'))
    $answer = [System.Windows.Forms.MessageBox]::Show($Message, $Title,
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question)
    return ($answer -eq [System.Windows.Forms.DialogResult]::Yes)
}

function Get-StatusText {
    param([bool]$Running)
    if ($Running) { return (Get-WampDeckString 'Running') }
    return (Get-WampDeckString 'Stopped')
}

function New-SectionLabel {
    param([string]$Text)
    $label = New-Object System.Windows.Forms.Label
    $label.Text = $Text
    $label.AutoSize = $true
    $label.ForeColor = $script:GuiColors.Muted
    $label.Font = New-Object System.Drawing.Font('Segoe UI', 8.5, [System.Drawing.FontStyle]::Bold)
    return $label
}
