#!/usr/bin/env bash
set -euo pipefail

FILE="README.md"

echo "== DEV63 DOC01: link BuybackVault plan and tests from README =="

cat <<'EOL' >> "$FILE"

## Buyback Vault

Das BuybackVault-Modul bildet die Brücke zwischen Treasury-Stablecoins und dem Asset,
das langfristig zurückgekauft werden soll (z. B. 1kUSD LP-Token oder Governance-Token).

- **Architekturplan:** \`docs/architecture/buybackvault_plan.md\`
- **Implementierungsstatus:** Stage A (Custody & Safety) implementiert, Stage B/C (Swap-Routing & Automatisierung) geplant.
- **Regression-Tests:** \`foundry/test/BuybackVault.t.sol\` (Constructor-Guards, DAO-only, Pause-Hooks, Balance-Views)

EOL

echo "✓ BuybackVault section appended to $FILE"
