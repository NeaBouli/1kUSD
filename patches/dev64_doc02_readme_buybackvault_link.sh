#!/usr/bin/env bash
set -euo pipefail

README="README.md"
LOG="logs/project.log"

echo "== DEV64 DOC02: link BuybackVault docs from README and log execution plan =="

cat <<'EOL' >> "$README"

### BuybackVault

- Core contract: `contracts/core/BuybackVault.sol`
- Tests: `foundry/test/BuybackVault.t.sol`
- Execution plan (Stage B/C): `docs/architecture/buybackvault_execution.md`
EOL

cat <<'EOL' >> "$LOG"
[DEV-60/64] 2025-11-23T10:15:00Z BuybackVault: Stage A core (custody + DAO-only fund/withdraw + pause hooks) implemented with regression tests; Stage B/C Execution Plan documented in docs/architecture/buybackvault_execution.md for PSM-routed buybacks and future multi-route extensions.
EOL

echo "✓ README updated with BuybackVault references"
echo "✓ DEV-60/64 BuybackVault work logged to $LOG"
