#!/usr/bin/env bash
# Preflight validation for the Nourishing Food Marketing Jekyll site.
# Run before pushing. Catches the failure modes that break the GitHub
# Pages deploy (which uses an old, strict Sass via the github-pages gem).
#
#   ./scripts/preflight.sh
#
set -uo pipefail
cd "$(dirname "$0")/.."
fail=0

echo "==> 1a. Text-file integrity (NUL / control bytes)"
# Some editors/tools don't truncate properly and leave NUL padding when a
# file is shrunk. A NUL in a .scss aborts the whole Pages build; in other
# files it silently corrupts content. Scan all text sources.
while IFS= read -r f; do
  if LC_ALL=C grep -qP '[\x00-\x08\x0B\x0C\x0E-\x1F]' "$f"; then
    echo "   FAIL: $f has NUL/control bytes"; fail=1
  fi
done < <(find . -path ./.git -prune -o -path ./_site -prune -o -path ./vendor -prune -o -path ./node_modules -prune -o -type f \( -name '*.scss' -o -name '*.css' -o -name '*.html' -o -name '*.md' -o -name '*.markdown' -o -name '*.yml' -o -name '*.yaml' -o -name '*.json' -o -name '*.js' -o -name '*.xml' \) -print)
[ "$fail" = 0 ] && echo "   ok"

echo "==> 1b. SCSS brace balance"
while IFS= read -r f; do
  ob=$(tr -cd '{' < "$f" | wc -c); cb=$(tr -cd '}' < "$f" | wc -c)
  if [ "$ob" != "$cb" ]; then echo "   FAIL: $f unbalanced braces ($ob '{' vs $cb '}')"; fail=1; fi
done < <(find _sass assets -name '*.scss')
[ "$fail" = 0 ] && echo "   ok"

echo "==> 2. Jekyll build"
if command -v bundle >/dev/null 2>&1; then
  bundle exec jekyll build --quiet || { echo "   FAIL: jekyll build"; fail=1; }
else
  echo "   SKIP: bundler not installed (run 'bundle install' locally to enable)"
fi

echo "==> 3. HTMLProofer (internal links + images)"
if command -v bundle >/dev/null 2>&1 && [ -d _site ]; then
  bundle exec htmlproofer --disable-external --allow-hash-href --allow-missing-href \
    --no-enforce-https \
    --ignore-urls "/apple-touch-icon.png/,/favicon-32x32.png/,/favicon-16x16.png/" \
    _site/ || { echo "   FAIL: htmlproofer"; fail=1; }
else
  echo "   SKIP: needs bundler + a built _site/"
fi

echo
if [ "$fail" = 0 ]; then echo "ALL CHECKS PASSED"; else echo "PREFLIGHT FAILED -- fix the above before pushing"; exit 1; fi
