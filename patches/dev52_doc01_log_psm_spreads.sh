#!/usr/bin/env bash
set -euo pipefail

LOG="logs/project.log"

echo "== DEV52 DOC01: append DEV-52 PSM spread summary to project.log =="

mkdir -p "$(dirname "$LOG")"

cat <<EOL >> "$LOG"
[DEV-52] $(date -u +"%Y-%m-%dT%H:%M:%SZ") PSM: registry-driven mint/redeem spreads added on top of fees (global + per-token keys, totalBps <= 10_000 invariant); swapTo/From1kUSD now use fee+spread while limits and oracle health gates remain unchanged; all 40 tests green.
EOL

echo "✓ DEV-52 summary appended to $LOG"
