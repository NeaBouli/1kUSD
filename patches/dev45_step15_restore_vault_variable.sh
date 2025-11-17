#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Flows.t.sol"

echo "== DEV45 STEP 15: RESTORE vault STATE VARIABLE + SETUP FIX =="

# 1) Remove ANY existing wrong vault lines
sed -i '' '/MockVault/d' "$FILE"
sed -i '' '/MockCollateralVault internal/d' "$FILE"
sed -i '' '/vault = new MockCollateralVault/d' "$FILE"

# 2) Insert clean vault state variable after collateralToken declaration
sed -i '' '/MockERC20 internal collateralToken;/a\
    MockCollateralVault internal vault;\
' "$FILE"

# 3) Fix instantiation in setUp()  
sed -i '' 's/collateralToken = new MockERC20("COL", "COL");/&\
        vault = new MockCollateralVault();/' "$FILE"

echo "✓ vault state variable + setUp() restored"
