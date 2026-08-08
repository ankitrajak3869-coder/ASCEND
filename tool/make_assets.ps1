# Ascend brand assets generator.
# Produces the app icon (adaptive foreground) and the native splash logo
# from the current brand tokens. Run from repo root:
#   powershell -ExecutionPolicy Bypass -File tool\make_assets.ps1
#
# Artistic leader: final artwork replaces these generated placeholders;
# sizes, transparency and file names stay contract-stable.

Add-Type -AssemblyName System.Drawing

$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$outDir = Join-Path $root "assets\images"
New-Item -ItemType Directory -Path $outDir -Force | Out-Null

function New-AscendMark([int]$Size, [string]$OutPath, [bool]$WithBackground) {
  $bmp = New-Object System.Drawing.Bitmap($Size, $Size)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.Clear([System.Drawing.Color]::Transparent)

  if ($WithBackground) {
    $rect = New-Object System.Drawing.Rectangle(0, 0, $Size, $Size)
    $bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
      $rect,
      [System.Drawing.Color]::FromArgb(255, 14, 17, 22),
      [System.Drawing.Color]::FromArgb(255, 22, 26, 34),
      45)
    $g.FillRectangle($bg, $rect)
    $bg.Dispose()
  }

  $cx = $Size / 2
  $pad = $Size * 0.24
  $tipY = $Size * 0.14
  $baseY = $Size * 0.86

  # Upward chevron glyph: two blades meeting at the apex.
  $pointL = ,(New-Object 'System.Drawing.PointF' -ArgumentList ([float]$cx, [float]$tipY))
  $pointL += New-Object 'System.Drawing.PointF' -ArgumentList ([float]$pad, [float]$baseY)
  $pointL += New-Object 'System.Drawing.PointF' -ArgumentList ([float]$cx, [float]($Size * 0.56))
  $pointR = ,(New-Object 'System.Drawing.PointF' -ArgumentList ([float]$cx, [float]$tipY))
  $pointR += New-Object 'System.Drawing.PointF' -ArgumentList ([float]$cx, [float]($Size * 0.56))
  $pointR += New-Object 'System.Drawing.PointF' -ArgumentList ([float]($Size - $pad), [float]$baseY)

  $gradRect = New-Object System.Drawing.Rectangle(0, 0, $Size, $Size)
  $gradient = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    $gradRect,
    [System.Drawing.Color]::FromArgb(255, 130, 92, 255),
    [System.Drawing.Color]::FromArgb(255, 34, 211, 238),
    45)

  $g.FillPolygon(
    [System.Drawing.Brush]$gradient,
    [System.Drawing.PointF[]]$pointL)
  $g.FillPolygon(
    [System.Drawing.Brush]$gradient,
    [System.Drawing.PointF[]]$pointR)

  $gradient.Dispose()
  $g.Dispose()
  $bmp.Save($OutPath, [System.Drawing.Imaging.ImageFormat]::Png)
  $bmp.Dispose()
  Write-Host "Wrote: $OutPath"
}

New-AscendMark 1024 (Join-Path $outDir "app_icon_foreground.png") $true
New-AscendMark 512 (Join-Path $outDir "splash_logo.png") $false