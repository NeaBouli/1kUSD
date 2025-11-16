#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Limits.t.sol"

echo "== DEV-44 Step 5: Fix type declarations in PSMRegression_Limits =="

# Replace type declarations
sed -i '' 's/OneKUSD /MockOneKUSD /' "$FILE"
sed -i '' 's/CollateralVault /MockVault /' "$FILE"
sed -i '' 's/ParameterRegistry /MockRegistry /' "$FILE"

echo "✓ Type declarations updated to MockOneKUSD, MockVault, MockRegistry"
echo "== Complete =="
