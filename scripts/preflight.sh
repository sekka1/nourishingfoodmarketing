#!/usr/bin/env bash
# Preflight validation for the Nourishing Food Marketing Jekyll site.
# Run before pushing. Mirrors the GitHub "Test Pages" CI, plus static checks
# that work even when Ruby/bundler is NOT installed locally.
#
#   ./scripts/preflight.sh
#
set -uo pipefail
cd "$(dirname "$0")/.."
fail=0

echo "==> 1a. Text-file integrity (NUL / control bytes)"
while IFS= read -r f; do
  if LC_ALL=C grep -qP '[\x00-\x08\x0B\x0C\x0E-\x1F]' "$f"; then
    echo "   FAIL: $f has NUL/control bytes"; fail=1
  fi
done < <(find . -path ./.git -prune -o -path ./_site -prune -o -path ./vendor -prune -o -path ./node_modules -prune -o -type f \( -name '*.scss' -o -name '*.css' -o -name '*.html' -o -name '*.md' -o -name '*.markdown' -o -name '*.yml' -o -name '*.yaml' -o -name '*.json' -o -name '*.js' -o -name '*.xml' \) -print)
[ "$fail" = 0 ] && echo "   ok"

echo "==> 1b. SCSS brace balance"
b=0
while IFS= read -r f; do
  ob=$(tr -cd '{' < "$f" | wc -c); cb=$(tr -cd '}' < "$f" | wc -c)
  if [ "$ob" != "$cb" ]; then echo "   FAIL: $f unbalanced braces ($ob '{' vs $cb '}')"; fail=1; b=1; fi
done < <(find _sass assets -name '*.scss')
[ "$b" = 0 ] && echo "   ok"

echo "==> 1c. Referenced image/file assets exist on disk"
# Catches HTMLProofer's 'internal image does not exist' without needing a build.
# .css/.js are intentionally excluded (assets/main.css is generated from main.scss).
c=0
while IFS= read -r ref; do
  f="${ref#/}"
  if [ ! -f "$f" ]; then echo "   FAIL: referenced asset missing on disk: $ref"; fail=1; c=1; fi
done < <(grep -rhoE "/?assets/[A-Za-z0-9._/-]+\.(png|jpe?g|gif|svg|webp|ico|pdf|pptx)" \
   --include='*.html' --include='*.md' \
   --exclude-dir=.git --exclude-dir=_site --exclude-dir=vendor --exclude-dir=node_modules \
   --exclude-dir=.github --exclude-dir=.claude \
   --exclude=MIGRATION.md --exclude=README.md \
   . 2>/dev/null | sort -u)
[ "$c" = 0 ] && echo "   ok"

echo "==> 2. Jekyll build"
if command -v bundle >/dev/null 2>&1; then
  bundle exec jekyll build --quiet || { echo "   FAIL: jekyll build"; fail=1; }
else
  echo "   SKIP: bundler not installed (static checks 1a-1c above still ran)"
fi

echo "==> 3. HTMLProofer (internal links + images)"
if command -v bundle >/dev/null 2>&1 && [ -d _site ]; then
  bundle exec htmlproofer --disable-external --allow-hash-href --allow-missing-href \
    --no-enforce-https \
    --ignore-urls "/apple-touch-icon.png/,/favicon-32x32.png/,/favicon-16x16.png/" \
    _site/ || { echo "   FAIL: htmlproofer"; fail=1; }
else
  echo "   SKIP: needs bundler + built _site/  (check 1c approximates the image test)"
fi

echo
if [ "$fail" = 0 ]; then echo "ALL CHECKS PASSED"; else echo "PREFLIGHT FAILED -- fix the above before pushing"; exit 1; fi
