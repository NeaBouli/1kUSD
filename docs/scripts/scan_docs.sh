#!/usr/bin/env bash
set -euo pipefail
echo "🔎 1kUSD Docs Watchdog"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

ERR=0
check(){ [[ -f "$1" ]] || { echo "ERR missing: $1"; ERR=1; }; }

check "mkdocs.yml"
check "docs/index.md"
check "README.md" || echo "WARN root README missing (ok if intentional)"

[[ $ERR -eq 0 ]] && echo "OK watchdog passed" || echo "ERR watchdog failed"
exit $ERR
