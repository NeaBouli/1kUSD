#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Flows.t.sol"

echo "== DEV45 FIX A: Reinstate approve(user -> PSM) =="

sed -i '' '/collateralToken.mint(user, 1000e18);/a\
        vm.prank(user);\
        collateralToken.approve(address(psm), type(uint256).max);\
' "$FILE"

echo "✓ Approve restored in PSMRegression_Flows"
