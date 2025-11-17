#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Limits.t.sol"

echo "== DEV45 FIX B5: Replace MockRegistry with ParameterRegistry =="

# 1) Remove any leftover MockRegistry imports or declarations
sed -i '' '/MockRegistry/d' "$FILE"

# 2) Ensure correct import exists
grep -q 'ParameterRegistry' "$FILE" || sed -i '' '/PSMLimits/a\
import {ParameterRegistry} from "../../../contracts/core/ParameterRegistry.sol";\
' "$FILE"

# 3) Replace type in the file
sed -i '' 's/MockRegistry/ParameterRegistry/g' "$FILE"

# 4) Ensure variable exists correctly
grep -q "ParameterRegistry public reg" "$FILE" || \
  sed -i '' '/MockCollateralVault public vault;/a\
    ParameterRegistry public reg;\
' "$FILE"

# 5) Add instantiation inside setUp()
sed -i '' '/vault = new MockCollateralVault()/a\
        reg = new ParameterRegistry(dao);\
' "$FILE"

echo "✓ Replaced MockRegistry → ParameterRegistry in PSMRegression_Limits"
