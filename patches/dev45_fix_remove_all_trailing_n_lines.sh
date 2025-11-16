#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Flows.t.sol"

echo "== DEV-45 Full Cleanup: Remove all trailing 'n' artifact lines =="

# Entferne jede Zeile, die *genau* mit 'n' endet
sed -i '' '/n$/d' "$FILE"

echo "✓ Removed all lines ending with 'n'"
echo "== Complete =="
