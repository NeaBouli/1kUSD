#!/usr/bin/env bash
set -euo pipefail

FILE="README.md"

echo "== DEV61 DOC01: link BuybackVault docs from README =="

cat <<'EOL' >> "$FILE"

## Treasury Buybacks / BuybackVault

- **Architecture plan:** `docs/architecture/buybackvault_plan.md`
- **Contract:** `contracts/core/BuybackVault.sol`
- **Tests:** `foundry/test/BuybackVault.t.sol`

The BuybackVault is a DAO-controlled custody vault for 1kUSD and the buyback asset.
It is guarded by the SafetyAutomata pause module and is designed to later plug into
on-chain buyback execution strategies (DEX/auction), while already providing
a clear, test-covered custody layer for Treasury buyback funds.
EOL

echo "✓ BuybackVault section appended to $FILE"
