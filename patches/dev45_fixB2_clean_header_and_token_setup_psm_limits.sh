#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Limits.t.sol"

echo "== DEV45 FIX B2: Clean header + configure MockERC20 collateral token =="

# 1) Body ab 'contract PSMRegression_Limits' extrahieren
BODY=$(sed -n '/contract PSMRegression_Limits/,$p' "$FILE")

# 2) Neuer sauberer Header mit allen benötigten Imports
HEADER='// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import {PegStabilityModule} from "../../../contracts/core/PegStabilityModule.sol";
import {OneKUSD} from "../../../contracts/core/OneKUSD.sol";
import {MockOracleAggregator} from "../mocks/MockOracleAggregator.sol";
import {MockERC20} from "../mocks/MockERC20.sol";
import {MockCollateralVault} from "../mocks/MockCollateralVault.sol";
import {PSMLimits} from "../../../contracts/psm/PSMLimits.sol";
'

# 3) Stray-Imports im Body entfernen (alte MockERC20-Imports)
BODY=$(printf "%s\n" "$BODY" | sed '/import {MockERC20}/d')

# 4) File neu zusammenbauen
printf "%s\n\n%s\n" "$HEADER" "$BODY" > "$FILE"

# 5) collateralToken-Variable sicherstellen (direkt nach PSMLimits-Deklaration)
grep -q "MockERC20 collateralToken;" "$FILE" || \
  sed -i '' '/PSMLimits public limits;/a\
    MockERC20 public collateralToken;\
' "$FILE"

# 6) In setUp: MockERC20 anlegen, user befüllen, approve setzen
sed -i '' '/limits = new PSMLimits(/a\
        collateralToken = new MockERC20("COL", "COL");\
        collateralToken.mint(user, 1000e18);\
        vm.prank(user);\
        collateralToken.approve(address(psm), type(uint256).max);\
' "$FILE"

# 7) Alle address(1)-Verwendungen auf address(collateralToken) umbiegen
sed -i '' 's/address(1)/address(collateralToken)/g' "$FILE"

echo "✓ PSMRegression_Limits header and collateral token wiring fixed"
