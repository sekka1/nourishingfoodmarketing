#!/usr/bin/env pwsh
# Mirror the old WordPress site from the origin server (still running at a fixed
# IP, no longer in DNS) into ./old-site-backup as a permanent reference copy.
# Forces the connection to the IP while sending the real hostname (SNI + Host)
# and ignores the expired cert.
#
#   powershell -ExecutionPolicy Bypass -File scripts\fetch-old-site.ps1
#
$h   = 'www.nourishingfoodmarketing.com'
$ip  = '3.220.214.231'
$root = Join-Path (Split-Path $PSScriptRoot -Parent) 'old-site-backup'

# Pages to capture (add more here any time)
$pages = @(
  '/', '/food-brands-blog/', '/contact/', '/shop/',
  '/marketing-consultant/download-avoid-top-3-marketing-mistakes-guide/',
  '/2020/04/27/the-definitive-guide-to-creating-a-marketing-plan-for-food-and-beverage-brands/',
  '/2020/05/15/why-vc-funding-may-not-be-for-your-food-or-beverage-brand/',
  '/2020/06/07/getting-started-with-ecommerce-for-food-beverage-brands/',
  '/2020/10/07/budgeting-and-planning-sales-and-marketing-distribution-support/',
  '/2021/01/07/top-5-challenges-food-brands-face-when-sourcing-ingredients/',
  '/2021/03/16/discovering-the-marketing-tactics-that-will-help-you-drive-sales-velocities/',
  '/2021/03/23/go-to-market/',
  '/2022/03/22/5-lessons-on-how-to-drive-grocery-velocities-for-your-cpg-brand-shopper-marketing/',
  '/marketing-consultant/marketing-strategy-for-food-brands/',
  '/marketing-consultant/brand-marketing-diagnostic/',
  '/marketing-consultant/brand-dna-workshop-for-food-brands/',
  '/marketing-consultant/brand-dna-workbook-for-food-brands/',
  '/marketing-consultant/the-ultimate-brand-primer-template/'
)

function Fetch($url, $outFile) {
  $dir = Split-Path $outFile -Parent
  if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  curl.exe -s -k --resolve "${h}:443:${ip}" $url -o $outFile
}

Write-Host '==> Downloading HTML pages...'
foreach ($p in $pages) {
  $rel = $p.Trim('/'); if ($rel -eq '') { $rel = 'index' }
  $outFile = Join-Path $root ('html\' + ($rel -replace '/', '\') + '\index.html')
  Write-Host "   $p"
  Fetch "https://$h$p" $outFile
}

Write-Host '==> Extracting asset URLs from the downloaded HTML...'
$assetRe = '(?i)https?://[^"''<> )]+?\.(?:png|jpe?g|gif|svg|webp|css|js|woff2?|ttf|ico)'
$urls = New-Object System.Collections.Generic.HashSet[string]
Get-ChildItem -Recurse -Path (Join-Path $root 'html') -Filter *.html -ErrorAction SilentlyContinue | ForEach-Object {
  foreach ($m in [regex]::Matches([System.IO.File]::ReadAllText($_.FullName), $assetRe)) { [void]$urls.Add($m.Value) }
}
Write-Host ("   found {0} unique asset URLs" -f $urls.Count)

Write-Host '==> Downloading assets from the origin (rewriting Jetpack i*.wp.com URLs back to origin)...'
foreach ($u in $urls) {
  try { $uri = [uri]$u } catch { continue }
  $path = $null
  if ($uri.Host -match 'nourishingfoodmarketing\.com') { $path = $uri.AbsolutePath }
  elseif ($uri.Host -match '^i\d\.wp\.com$' -and $uri.AbsolutePath -match 'nourishingfoodmarketing\.com(/.+)$') { $path = $Matches[1] }
  else { continue }
  $path = ($path -split '\?')[0]
  if ($path -eq '/' -or $path -eq '') { continue }
  $outFile = Join-Path $root ('assets' + ($path -replace '/', '\'))
  if (Test-Path $outFile) { continue }
  Fetch "https://$h$path" $outFile
}

Write-Host ''
Write-Host "Done. Reference copy saved under: $root"
Write-Host '  html\   - original pages (one folder per URL, index.html inside)'
Write-Host '  assets\ - original css / js / images (wp-content, theme, uploads, etc.)'
