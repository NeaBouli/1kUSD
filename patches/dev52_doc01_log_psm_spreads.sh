#!/usr/bin/env bash
set -euo pipefail

LOG="logs/project.log"

echo "== DEV52 DOC01: append DEV-52 PSM spreads summary to project.log =="

mkdir -p "$(dirname "$LOG")"

cat <<EOL >> "$LOG"
[DEV-52] $(date -u +"%Y-%m-%dT%H:%M:%SZ") PSM: registry-driven mint/redeem spreads (psm:mintSpreadBps/psm:redeemSpreadBps + per-token overrides) added on top of existing fees; fee+spread capped at 10_000 bps; swapTo/From1kUSD now consume totalBps; stack-too-deep resolved by inlining fee+spread; full suite at 40 tests green.
EOL

echo "✓ DEV-52 summary appended to $LOG"
