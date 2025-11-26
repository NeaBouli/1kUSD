#!/usr/bin/env bash
set -euo pipefail

FILE="README.md"

echo "== DEV61 DOC02: link BuybackVault architecture from README =="

cat <<'EOL' >> "$FILE"

### Buyback Vault

- Architecture & design notes: \`docs/architecture/buybackvault_plan.md\`
- Status: MVP integrated with PSM via \`executeBuybackPSM\`, guarded by \`SafetyAutomata\` (bytes32 moduleId) und \`onlyDAO\`.

EOL

echo "✓ DEV61 DOC02: BuybackVault section appended to README"
