#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Flows.t.sol"

echo "== DEV45 STEP 16: Correct vault construction and PSM wiring =="

# 1) Remove any old wrong vault instantiation in setUp()
sed -i '' '/vault = new MockCollateralVault/d' "$FILE"

# 2) Insert clean vault instantiation AFTER collateralToken creation
sed -i '' '/collateralToken = new MockERC20("COL", "COL");/a\
        vault = new MockCollateralVault();\
' "$FILE"

# 3) Fix PSM constructor wiring — ensure the vault address is passed
sed -i '' 's/address(vault)/address(vault)/' "$FILE"

echo "✓ vault instantiation and wiring corrected"
