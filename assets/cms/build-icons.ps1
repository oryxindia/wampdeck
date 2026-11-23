# Build the small PNG icons the WampDeck header uses for the CMS quick-install
# strip. Source art lives next to this script; the output goes to icons\.
#
#   powershell -ExecutionPolicy Bypass -File .\build-icons.ps1
#
# Only needed when the source art changes. The generated PNGs are committed,
# so a normal build never runs Chrome.

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$outDir = Join-Path $here 'icons'
New-Item -ItemType Directory -Path $outDir -Force | Out-Null
$temp = Join-Path $env:TEMP ('wampdeck-icons-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
New-Item -ItemType Directory -Path $temp -Force | Out-Null

$chrome = @(
    (Join-Path ${env:ProgramFiles} 'Google\Chrome\Application\chrome.exe'),
    (Join-Path ${env:ProgramFiles(x86)} 'Google\Chrome\Application\chrome.exe'),
    (Join-Path $env:LOCALAPPDATA 'Google\Chrome\Application\chrome.exe')
) | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
if (-not $chrome) { throw 'Chrome was not found; it is only needed to rasterize the SVG sources.' }

function Get-ContentBounds {
    param([System.Drawing.Bitmap]$Bitmap, [int]$Threshold = 8)
    $minX = $Bitmap.Width; $minY = $Bitmap.Height; $maxX = -1; $maxY = -1
    for ($y = 0; $y -lt $Bitmap.Height; $y++) {
        for ($x = 0; $x -lt $Bitmap.Width; $x++) {
            if ($Bitmap.GetPixel($x, $y).A -le $Threshold) { continue }
            if ($x -lt $minX) { $minX = $x }
            if ($x -gt $maxX) { $maxX = $x }
            if ($y -lt $minY) { $minY = $y }
            if ($y -gt $maxY) { $maxY = $y }
        }
    }
    if ($maxX -lt 0) { throw 'The rendered icon is completely transparent.' }
    return [System.Drawing.Rectangle]::new($minX, $minY, ($maxX - $minX + 1), ($maxY - $minY + 1))
}

function Save-Icon {
    param(
        [System.Drawing.Bitmap]$Source,
        [string]$Path,
        [int]$CanvasWidth = 64,
        [int]$CanvasHeight = 64,
        [int]$MaxWidth = 52,
        [int]$MaxHeight = 52
    )
    $bounds = Get-ContentBounds $Source
    $scale = [Math]::Min(($MaxWidth / $bounds.Width), ($MaxHeight / $bounds.Height))
    $width = [int][Math]::Round($bounds.Width * $scale)
    $height = [int][Math]::Round($bounds.Height * $scale)

    $canvas = New-Object System.Drawing.Bitmap $CanvasWidth, $CanvasHeight, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($canvas)
    try {
        $graphics.Clear([System.Drawing.Color]::Transparent)
        $graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceOver
        $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        $attributes = New-Object System.Drawing.Imaging.ImageAttributes
        $attributes.SetWrapMode([System.Drawing.Drawing2D.WrapMode]::TileFlipXY)
        $destination = [System.Drawing.Rectangle]::new(
            [int](($CanvasWidth - $width) / 2), [int](($CanvasHeight - $height) / 2), $width, $height)
        $graphics.DrawImage($Source, $destination, $bounds.X, $bounds.Y, $bounds.Width, $bounds.Height,
            [System.Drawing.GraphicsUnit]::Pixel, $attributes)
        $attributes.Dispose()
    } finally {
        $graphics.Dispose()
    }
    $canvas.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    $canvas.Dispose()
    Write-Host ("  {0}  {1} bytes" -f (Split-Path -Leaf $Path), (Get-Item $Path).Length)
}

function Render-Svg {
    param([string]$SvgPath, [int]$ContentWidth, [int]$ContentHeight)
    $pageWidth = $ContentWidth + 24
    $pageHeight = $ContentHeight + 24
    $uri = ([System.Uri]$SvgPath).AbsoluteUri
    $html = @"
<!doctype html><html><head><meta charset="utf-8"><style>
html,body{margin:0;padding:0;width:${pageWidth}px;height:${pageHeight}px;background:transparent;overflow:hidden}
img{position:absolute;left:12px;top:12px;width:${ContentWidth}px;height:${ContentHeight}px}
</style></head><body><img src="$uri"></body></html>
"@
    $htmlPath = Join-Path $temp ('page-' + [guid]::NewGuid().ToString('N') + '.html')
    $pngPath = [System.IO.Path]::ChangeExtension($htmlPath, '.png')
    Set-Content -LiteralPath $htmlPath -Value $html -Encoding UTF8
    $profile = Join-Path $temp ('profile-' + [guid]::NewGuid().ToString('N').Substring(0, 6))
    $arguments = @(
        '--headless=new', '--disable-gpu', '--hide-scrollbars', '--no-first-run',
        '--no-default-browser-check', '--force-device-scale-factor=1',
        '--default-background-color=00000000',
        "--user-data-dir=$profile",
        "--window-size=$pageWidth,$pageHeight",
        "--screenshot=$pngPath",
        ([System.Uri]$htmlPath).AbsoluteUri
    )
    $process = Start-Process -FilePath $chrome -ArgumentList $arguments -Wait -PassThru -WindowStyle Hidden
    if (-not (Test-Path -LiteralPath $pngPath)) { throw "Chrome did not render $SvgPath (exit $($process.ExitCode))." }
    return [System.Drawing.Bitmap]::FromFile($pngPath)
}

try {
    Write-Host 'Rendering SVG marks...'
    $square = @(
        @{ Id = 'drupal';      File = 'drupal.svg';      Size = 112 },
        @{ Id = 'wordpress';   File = 'wordpress.svg';   Size = 112 },
        @{ Id = 'typo3';       File = 'typo3.svg';       Size = 112 },
        @{ Id = 'joomla';      File = 'joomla.svg';      Size = 112 },
        @{ Id = 'processwire'; File = 'processwire.svg'; Size = 112 },
        @{ Id = 'grav';        File = 'grav.svg';        Size = 112 }
    )
    foreach ($item in $square) {
        $bitmap = Render-Svg (Join-Path $here $item.File) $item.Size $item.Size
        try { Save-Icon $bitmap (Join-Path $outDir ($item.Id + '.png')) }
        finally { $bitmap.Dispose() }
    }

    # Twill's mark is a wordmark; keep its aspect ratio instead of squeezing it
    # into a square tile.
    $twill = Render-Svg (Join-Path $here 'twill-wordmark.svg') 300 117
    try { Save-Icon $twill (Join-Path $outDir 'twill.png') -CanvasWidth 70 -CanvasHeight 28 -MaxWidth 68 -MaxHeight 26 }
    finally { $twill.Dispose() }

    # Concrete CMS ships an avatar: a white hand on a dark rounded tile. Keep
    # the hand and drop the tile so it matches the other glyphs.
    Write-Host 'Keying Concrete CMS...'
    $source = [System.Drawing.Bitmap]::FromFile((Join-Path $here 'concretecms.png'))
    try {
        $keyed = New-Object System.Drawing.Bitmap $source.Width, $source.Height, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        for ($y = 0; $y -lt $source.Height; $y++) {
            for ($x = 0; $x -lt $source.Width; $x++) {
                $pixel = $source.GetPixel($x, $y)
                $luminance = (0.299 * $pixel.R) + (0.587 * $pixel.G) + (0.114 * $pixel.B)
                # The avatar background tops out around luminance 80; the hand
                # is pure white. A narrow ramp keeps the antialiased edge but
                # drops the tile completely.
                $alpha = [int][Math]::Max(0, [Math]::Min(255, (($luminance - 80) / 80) * 255))
                $keyed.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($alpha, 255, 255, 255))
            }
        }
        Save-Icon $keyed (Join-Path $outDir 'concrete.png')
        $keyed.Dispose()
    } finally { $source.Dispose() }

    # Winter CMS is already a transparent snowflake; normalize its padding.
    $winter = [System.Drawing.Bitmap]::FromFile((Join-Path $here 'wintercms.png'))
    try { Save-Icon $winter (Join-Path $outDir 'winter.png') -MaxWidth 56 -MaxHeight 56 }
    finally { $winter.Dispose() }

    Write-Host ("Done: {0}" -f $outDir)
} finally {
    Remove-Item -LiteralPath $temp -Recurse -Force -ErrorAction SilentlyContinue
}
