#!/usr/bin/env pwsh
# Preflight validation (PowerShell) for the Nourishing Food Marketing site.
# Native Windows equivalent of preflight.sh -- no bash required.
#   powershell -ExecutionPolicy Bypass -File scripts\preflight.ps1
Set-Location (Join-Path $PSScriptRoot '..')
$fail = $false

function Test-ControlBytes($path) {
  $bytes = [System.IO.File]::ReadAllBytes($path)
  foreach ($b in $bytes) { if (($b -le 8) -or ($b -eq 11) -or ($b -eq 12) -or (($b -ge 14) -and ($b -le 31))) { return $true } }
  return $false
}

Write-Host "==> 1a. Text-file integrity (NUL / control bytes)"
$exts1 = '*.scss','*.css','*.html','*.md','*.markdown','*.yml','*.yaml','*.json','*.js','*.xml'
$textFiles = Get-ChildItem -Recurse -File -Include $exts1 -ErrorAction SilentlyContinue |
  Where-Object { $_.FullName -notmatch '\\(\.git|_site|vendor|node_modules|old-site-backup)\\' }
foreach ($f in $textFiles) {
  if (Test-ControlBytes $f.FullName) { Write-Host "   FAIL: $($f.Name) has NUL/control bytes"; $fail = $true }
}
if (-not $fail) { Write-Host "   ok" }

Write-Host "==> 1b. SCSS brace balance"
$bFail = $false
foreach ($f in (Get-ChildItem -Recurse -Path _sass, assets -Filter *.scss -ErrorAction SilentlyContinue)) {
  $text = [System.IO.File]::ReadAllText($f.FullName)
  $ob = ([regex]::Matches($text, '{')).Count
  $cb = ([regex]::Matches($text, '}')).Count
  if ($ob -ne $cb) { Write-Host "   FAIL: $($f.Name) unbalanced braces ($ob '{' vs $cb '}')"; $fail = $true; $bFail = $true }
}
if (-not $bFail) { Write-Host "   ok" }

Write-Host "==> 1c. Referenced image/file assets exist on disk"
# Catches HTMLProofer's 'internal image does not exist' without a build.
$pattern = '/?assets/[A-Za-z0-9._/-]+\.(png|jpg|jpeg|gif|svg|webp|ico|pdf|pptx)'
$contentFiles = Get-ChildItem -Recurse -File -Include *.html,*.md -ErrorAction SilentlyContinue |
  Where-Object { $_.FullName -notmatch '\\(\.git|_site|vendor|node_modules|\.github|\.claude|old-site-backup)\\' -and $_.Name -notin @('MIGRATION.md','README.md') }
$refs = New-Object System.Collections.Generic.HashSet[string]
foreach ($cf in $contentFiles) {
  foreach ($m in [regex]::Matches([System.IO.File]::ReadAllText($cf.FullName), $pattern)) { [void]$refs.Add($m.Value) }
}
$cFail = $false
foreach ($ref in $refs) {
  $rel = $ref.TrimStart('/')
  if (-not (Test-Path -LiteralPath $rel)) { Write-Host "   FAIL: referenced asset missing on disk: $ref"; $fail = $true; $cFail = $true }
}
if (-not $cFail) { Write-Host "   ok" }

Write-Host "==> 2. Jekyll build"
if (Get-Command bundle -ErrorAction SilentlyContinue) {
  bundle exec jekyll build --quiet
  if ($LASTEXITCODE -ne 0) { Write-Host "   FAIL: jekyll build"; $fail = $true }
} else { Write-Host "   SKIP: bundler not installed (static checks 1a-1c above still ran)" }

Write-Host "==> 3. HTMLProofer (internal links + images)"
if ((Get-Command bundle -ErrorAction SilentlyContinue) -and (Test-Path _site)) {
  bundle exec htmlproofer --disable-external --allow-hash-href --allow-missing-href --no-enforce-https --ignore-urls "/apple-touch-icon.png/,/favicon-32x32.png/,/favicon-16x16.png/" _site/
  if ($LASTEXITCODE -ne 0) { Write-Host "   FAIL: htmlproofer"; $fail = $true }
} else { Write-Host "   SKIP: needs bundler + built _site/  (check 1c approximates the image test)" }

Write-Host ""
if ($fail) { Write-Host "PREFLIGHT FAILED -- fix the above before pushing"; exit 1 } else { Write-Host "ALL CHECKS PASSED" }
