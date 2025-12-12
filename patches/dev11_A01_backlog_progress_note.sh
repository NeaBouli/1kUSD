#!/bin/bash
set -e

echo "== DEV-11 A01: append backlog progress note =="

BACKLOG="docs/dev/DEV11_Implementation_Backlog_SolidityTrack_r1.md"
if [ -f "$BACKLOG" ]; then
  cat <<'EOT' >> "$BACKLOG"

## Progress – DEV-11 A01 (per-operation treasury cap)

- Implemented `maxBuybackSharePerOpBps` in `BuybackVault` (Phase A, per-operation treasury cap).
- Behaviour: when the cap is set > 0, any single buyback that would consume more than this share of the dedicated treasury reverts.
- Tests: to be added in a follow-up DEV-11 A01 tests task.
EOT
else
  echo "Backlog file not found: $BACKLOG"
fi

LOG_FILE="logs/project.log"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-11 A01] ${timestamp} Recorded progress note for per-op treasury cap (code merged, tests pending)" >> "$LOG_FILE"

echo "== DEV-11 A01 backlog progress note done =="
