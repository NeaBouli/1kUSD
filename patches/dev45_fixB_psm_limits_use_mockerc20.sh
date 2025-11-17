#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Limits.t.sol"

echo "== DEV45 FIX B: Patch PSMRegression_Limits to use MockERC20 instead of address(1) =="

# Insert import if missing
grep -q "MockERC20" "$FILE" || sed -i '' '/PSMLimits/a\
import {MockERC20} from "../mocks/MockERC20.sol";\
' "$FILE"

# Insert token variable
grep -q "MockERC20 collateralToken;" "$FILE" || sed -i '' '/PSMLimits public limits;/a\
    MockERC20 collateralToken;\
' "$FILE"

# In setUp: instantiate token + mint + approve
sed -i '' '/limits = new PSMLimits(a
ddress(dao));/a\
        collateralToken = new MockERC20("COL", "COL");\
        collateralToken.mint(user, 1000e18);\
        vm.prank(user);\
        collateralToken.approve(address(psm), type(uint256).max);\
' "$FILE"

# Replace all address(1) with address(collateralToken)
sed -i '' 's/address(1)/address(collateralToken)/g' "$FILE"

echo "✓ PSMRegression_Limits updated to use MockERC20"
