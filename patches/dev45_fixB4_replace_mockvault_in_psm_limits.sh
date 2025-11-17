#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Limits.t.sol"

echo "== DEV45 FIX B4: Replace MockVault with MockCollateralVault =="

# 1) Remove old/invalid imports
sed -i '' '/MockVault/d' "$FILE"

# 2) Ensure correct import exists
grep -q 'MockCollateralVault' "$FILE" || sed -i '' '/MockERC20/a\
import {MockCollateralVault} from "../mocks/MockCollateralVault.sol";\
' "$FILE"

# 3) Replace type
sed -i '' 's/MockVault/MockCollateralVault/g' "$FILE"

# 4) Ensure vault variable exists correctly
grep -q "MockCollateralVault public vault" "$FILE" || \
  sed -i '' '/MockERC20 public collateralToken;/a\
    MockCollateralVault public vault;\
' "$FILE"

# 5) In setUp(): add vault = new MockCollateralVault()
sed -i '' '/collateralToken.approve/a\
        vault = new MockCollateralVault();\
' "$FILE"

echo "✓ Replaced MockVault → MockCollateralVault in PSMRegression_Limits"
