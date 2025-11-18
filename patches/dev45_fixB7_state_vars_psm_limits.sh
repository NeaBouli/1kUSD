#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Limits.t.sol"

echo "== DEV45 FIX B7: add missing state vars to PSMRegression_Limits =="

# 1) Imports sicherstellen (idempotent)

grep -q 'import {OneKUSD}' "$FILE" || sed -i '' '/forge-std\/Test.sol/a\
import {OneKUSD} from "../../../contracts/core/OneKUSD.sol";\
' "$FILE"

grep -q 'import {MockERC20}' "$FILE" || sed -i '' '/OneKUSD.sol";/a\
import {MockERC20} from "../mocks/MockERC20.sol";\
' "$FILE"

grep -q 'import {MockCollateralVault}' "$FILE" || sed -i '' '/MockERC20.sol";/a\
import {MockCollateralVault} from "../mocks/MockCollateralVault.sol";\
' "$FILE"

grep -q 'import {ParameterRegistry}' "$FILE" || sed -i '' '/PSMLimits.sol";/a\
import {ParameterRegistry} from "../../../contracts/core/ParameterRegistry.sol";\
' "$FILE"

# 2) State-Variablen nach PSMLimits-Deklaration ergänzen (falls noch nicht vorhanden)

grep -q 'OneKUSD public oneKUSD;' "$FILE" || sed -i '' '/PSMLimits public limits;/a\
    OneKUSD public oneKUSD;\
' "$FILE"

grep -q 'MockERC20 public collateralToken;' "$FILE" || sed -i '' '/OneKUSD public oneKUSD;/a\
    MockERC20 public collateralToken;\
' "$FILE"

grep -q 'MockCollateralVault public vault;' "$FILE" || sed -i '' '/MockERC20 public collateralToken;/a\
    MockCollateralVault public vault;\
' "$FILE"

grep -q 'ParameterRegistry public reg;' "$FILE" || sed -i '' '/MockCollateralVault public vault;/a\
    ParameterRegistry public reg;\
' "$FILE"

echo "✓ Imports and state vars ensured in PSMRegression_Limits"
