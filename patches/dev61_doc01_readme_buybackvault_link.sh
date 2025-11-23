#!/usr/bin/env bash
set -euo pipefail

FILE="README.md"

echo "== DEV61 DOC01: link BuybackVault plan from README =="

cat <<'EOL' >> "$FILE"

## Treasury Buybacks

- **BuybackVault Plan & Debug Notes:** `docs/architecture/buybackvault_plan.md`
EOL

echo "✓ BuybackVault plan section appended to $FILE"
