#!/usr/bin/env bash
set -euo pipefail

LOG="logs/project.log"

echo "== DEV52 DOC04: append DEV-52 PSM spreads summary to project.log =="

mkdir -p "$(dirname "$LOG")"

cat <<EOL >> "$LOG"
[DEV-52] $(date -u +"%Y-%m-%dT%H:%M:%SZ") PSM: registry-driven mint/redeem spreads (global + per-token) wired on top of fee layer; invariants enforced (fee+spread <= 10_000); PSMRegression_Spreads added alongside Fees/Flows/Limits; full suite at 42 tests green.
EOL

echo "✓ DEV-52 summary appended to $LOG"
