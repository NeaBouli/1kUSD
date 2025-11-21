#!/usr/bin/env bash
set -euo pipefail

LOG="logs/project.log"

echo "== DEV52 DOC01: append DEV-52 PSM spreads summary to project.log =="

mkdir -p "$(dirname "$LOG")"

cat <<EOL >> "$LOG"
[DEV-52] $(date -u +"%Y-%m-%dT%H:%M:%SZ") PSM: registry-driven mint/redeem spreads (global + per-token) layered on top of feeBps; spreads applied via _getMintSpreadBps/_getRedeemSpreadBps with 10_000 bps cap; PSMRegression_Spreads verifies mint+redeem netOut honour configured spreads; full suite 42 tests green.
EOL

echo "✓ DEV-52 spreads summary appended to $LOG"
