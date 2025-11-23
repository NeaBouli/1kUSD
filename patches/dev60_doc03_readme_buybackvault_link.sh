#!/usr/bin/env bash
set -euo pipefail

FILE="README.md"

echo "== DEV60 DOC03: link BuybackVault plan from README =="

cat <<'EOL' >> "$FILE"

## Buyback & Treasury Vault

- **BuybackVault Architektur & Plan:** \`docs/architecture/buybackvault_plan.md\`
  - Enthält Zielbild, Rollenmodell (DAO / Treasury / Safety) und aktuellen Implementierungsstatus (DEV-60: Core-Skeleton + Access-/Pause-Tests).
EOL

echo "✓ BuybackVault section appended to $FILE"
