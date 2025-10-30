#!/usr/bin/env bash
set -euo pipefail
echo "🔎 1kUSD Docs Watchdog"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

ERR=0
warn(){ echo "WARN $*"; }
fail(){ echo "ERR  $*"; ERR=1; }
have(){ command -v "$1" >/dev/null 2>&1; }

# Required core files
[[ -f "mkdocs.yml" ]] || fail "missing: mkdocs.yml"
[[ -f "docs/index.md" ]] || fail "missing: docs/index.md"

# Root README is optional
[[ -f "README.md" ]] || warn "root README missing (okay for MkDocs)"

# Home duplication hint in mkdocs.yml (rudimentary)
if have awk; then
  HOME_COUNT="$(awk '/nav:/{f=1} f&&/Home:|Start:|Index:/{c++} END{print c+0}' mkdocs.yml || true)"
  [[ "${HOME_COUNT:-0}" -le 1 ]] || warn "mkdocs.yml may contain multiple Home/Start entries"
fi

# Explicit '/index.md' reference can cause CDN quirks
grep -Eqs '^\s*-\s*/index\.md' mkdocs.yml && warn "explicit '/index.md' in nav may cause 404/CDN issues"

# Result
[[ $ERR -eq 0 ]] && echo "OK watchdog passed" || echo "ERR watchdog failed"
exit $ERR
