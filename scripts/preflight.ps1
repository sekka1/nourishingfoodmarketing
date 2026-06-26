#!/usr/bin/env pwsh
# Preflight validation (PowerShell) for the Nourishing Food Marketing site.
# Native Windows equivalent of preflight.sh -- no bash required.
#   pwsh scripts/preflight.ps1     (or: powershell -File scripts\preflight.ps1)
Set-Location (Join-Path $PSScriptRoot '..')
$fail = $false

Write-Host "==> 1. SCSS sanity check (_sass + assets)"
# GitHub Pages' old Sass aborts the whole build on a stray control/NUL byte
# or unbalanced braces in any .scss file.
$scss = Get-ChildItem -Recurse -Path _sass, assets -Filter *.scss -ErrorAction SilentlyContinue
foreach ($f in $scss) {
  $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
  $bad = $false
  foreach ($b in $bytes) { if (($b -le 8) -or ($b -eq 11) -or ($b -eq 12) -or (($b -ge 14) -and ($b -le 31))) { $bad = $true; break } }
  if ($bad) { Write-Host "   FAIL: $($f.Name) has control/NUL bytes (will break the Pages build)"; $fail = $true }
  $text = [System.IO.File]::ReadAllText($f.FullName)
  $ob = ([regex]::Matches($text, '{')).Count
  $cb = ([regex]::Matches($text, '}')).Count
  if ($ob -ne $cb) { Write-Host "   FAIL: $($f.Name) unbalanced braces ($ob '{' vs $cb '}')"; $fail = $true }
}
if (-not $fail) { Write-Host "   ok" }

Write-Host "==> 2. Jekyll build"
if (Get-Command bundle -ErrorAction SilentlyContinue) {
  bundle exec jekyll build --quiet
  if ($LASTEXITCODE -ne 0) { Write-Host "   FAIL: jekyll build"; $fail = $true }
} else { Write-Host "   SKIP: bundler not installed (install Ruby + 'bundle install')" }

Write-Host "==> 3. HTMLProofer (internal links + images)"
if ((Get-Command bundle -ErrorAction SilentlyContinue) -and (Test-Path _site)) {
  bundle exec htmlproofer --disable-external --allow-hash-href --allow-missing-href --no-enforce-https --ignore-urls "/apple-touch-icon.png/,/favicon-32x32.png/,/favicon-16x16.png/" _site/
  if ($LASTEXITCODE -ne 0) { Write-Host "   FAIL: htmlproofer"; $fail = $true }
} else { Write-Host "   SKIP: needs bundler + a built _site/" }

Write-Host ""
if ($fail) { Write-Host "PREFLIGHT FAILED -- fix the above before pushing"; exit 1 } else { Write-Host "ALL CHECKS PASSED" }
