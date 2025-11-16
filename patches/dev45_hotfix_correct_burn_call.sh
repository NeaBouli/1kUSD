#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/core/PegStabilityModule.sol"

echo "== DEV-45 Hotfix: Replace invalid burnFrom() with correct burn() =="

# Replace burnFrom with correct OneKUSD.burn(from, amount)
sed -i '' 's/burnFrom(from, amount1k)/burn(from, amount1k)/' "$FILE"

echo "✓ Corrected: oneKUSD.burn(from, amount1k)"
echo "== Complete =="
