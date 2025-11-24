#!/usr/bin/env bash
set -euo pipefail

LOG="logs/project.log"

echo "== DEV61 DOC02: log BuybackVault integration =="

cat <<'EOL' >> "$LOG"
[DEV-60/61] 2025-11-23T20:00:00Z BuybackVault: core custody vault for 1kUSD+asset added with DAO-only access and SafetyAutomata pause-gate; BuybackVault plan documented under docs/architecture/buybackvault_plan.md and wired into README Treasury Buybacks section as part of the Economic Layer extension.
EOL

echo "✓ BuybackVault integration logged to $LOG"
