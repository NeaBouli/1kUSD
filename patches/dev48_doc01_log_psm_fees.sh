#!/usr/bin/env bash
set -euo pipefail

LOG="logs/project.log"

echo "== DEV48 DOC01: append DEV-48 PSM fee-registry summary to project.log =="

mkdir -p "$(dirname "$LOG")"

cat <<EOL >> "$LOG"
[DEV-48] $(date -u +"%Y-%m-%dT%H:%M:%SZ") PSM: mint/redeem fees now resolved via ParameterRegistry (global psm:mintFeeBps/psm:redeemFeeBps + per-token overrides) with safe fallback to local storage; PSMRegression_Fees covers global+per-token mint fees and global redeem fees; full suite at 36 tests green.
EOL

echo "✓ DEV-48 summary appended to $LOG"
