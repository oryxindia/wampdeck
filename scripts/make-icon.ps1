# Builds assets\wampdeck.ico used by WampDeck.exe and the tray icon.
#
#   .\scripts\make-icon.ps1

param([string]$Output)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
if (-not $Output) { $Output = Join-Path $root 'assets\wampdeck.ico' }
$outputDir = Split-Path -Parent $Output
if (-not (Test-Path -LiteralPath $outputDir)) {
    New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
}

Add-Type -AssemblyName System.Drawing

$sizes = @(16, 24, 32, 48, 64, 128, 256)
$frames = @()

foreach ($size in $sizes) {
    $bitmap = New-Object System.Drawing.Bitmap $size, $size
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    $graphics.Clear([System.Drawing.Color]::FromArgb(8, 12, 20))

    $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(52, 211, 153), [Math]::Max(1, [int]($size * 0.04)))
    $graphics.DrawRectangle($pen, 1, 1, ($size - 3), ($size - 3))
    $pen.Dispose()

    $fontSize = [Math]::Max(8, [int]($size * 0.68))
    $font = New-Object System.Drawing.Font('Segoe UI', $fontSize, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
    $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(52, 211, 153))
    $format = New-Object System.Drawing.StringFormat
    $format.Alignment = [System.Drawing.StringAlignment]::Center
    $format.LineAlignment = [System.Drawing.StringAlignment]::Center

    $rect = New-Object System.Drawing.RectangleF(0, 0, $size, ($size + ($size * 0.06)))
    $graphics.DrawString('W', $font, $brush, $rect, $format)

    $stream = New-Object System.IO.MemoryStream
    $bitmap.Save($stream, [System.Drawing.Imaging.ImageFormat]::Png)
    $frames += ,$stream.ToArray()

    $stream.Dispose()
    $format.Dispose()
    $brush.Dispose()
    $font.Dispose()
    $graphics.Dispose()
    $bitmap.Dispose()
}

$outputStream = New-Object System.IO.MemoryStream
$writer = New-Object System.IO.BinaryWriter($outputStream)
$writer.Write([UInt16]0)                  # reserved
$writer.Write([UInt16]1)                  # type: icon
$writer.Write([UInt16]$sizes.Count)       # image count

$offset = 6 + (16 * $sizes.Count)
for ($i = 0; $i -lt $sizes.Count; $i++) {
    $size = $sizes[$i]
    $data = $frames[$i]
    $dimension = if ($size -ge 256) { 0 } else { $size }
    $writer.Write([byte]$dimension)
    $writer.Write([byte]$dimension)
    $writer.Write([byte]0)                # palette
    $writer.Write([byte]0)                # reserved
    $writer.Write([UInt16]1)              # color planes
    $writer.Write([UInt16]32)             # bits per pixel
    $writer.Write([UInt32]$data.Length)
    $writer.Write([UInt32]$offset)
    $offset += $data.Length
}

foreach ($data in $frames) { $writer.Write($data) }
$writer.Flush()
[System.IO.File]::WriteAllBytes($Output, $outputStream.ToArray())
$writer.Dispose()
$outputStream.Dispose()

Write-Host "wrote $Output ($($sizes -join ', ') px)" -ForegroundColor Green
