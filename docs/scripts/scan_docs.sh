#!/usr/bin/env sh
set -eu
echo "🔎 1kUSD Docs Watchdog"

ERR=0
check() { [ -f "$1" ] || { echo "ERR missing: $1"; ERR=1; }; }

check "mkdocs.yml"
check "docs/index.md"

# Optional root README (warn only)
if [ ! -f "README.md" ]; then
  echo "WARN root README missing (ok for MkDocs)"
fi

# Gentle hints (no awk/regex features)
if grep -qiE '^\s*-\s*/index\.md' mkdocs.yml 2>/dev/null; then
  echo "WARN nav references '/index.md' explicitly (could cause CDN issues)"
fi

[ "$ERR" -eq 0 ] && echo "OK watchdog passed" || echo "ERR watchdog failed"
exit "$ERR"
