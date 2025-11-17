#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Limits.t.sol"

echo "== DEV45 FIX B6: FULL CLEAN HEADER REBUILD for PSMRegression_Limits =="

# 1) Extract contract body
BODY=$(sed -n '/contract PSMRegression_Limits/,$p' "$FILE")

# 2) Build clean header
HEADER='// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import {PegStabilityModule} from "../../../contracts/core/PegStabilityModule.sol";
import {OneKUSD} from "../../../contracts/core/OneKUSD.sol";
import {ParameterRegistry} from "../../../contracts/core/ParameterRegistry.sol";
import {PSMLimits} from "../../../contracts/psm/PSMLimits.sol";

import {MockERC20} from "../mocks/MockERC20.sol";
import {MockOracleAggregator} from "../mocks/MockOracleAggregator.sol";
import {MockCollateralVault} from "../mocks/MockCollateralVault.sol";
'

# 3) Remove ANY stray imports inside body
BODY=$(printf "%s" "$BODY" | sed '/import {/d')

# 4) Rebuild file
printf "%s\n\n%s\n" "$HEADER" "$BODY" > "$FILE"

echo "✓ Step 1: Clean header fully rebuilt"

# 5) Ensure required variables (collateralToken, vault, reg) exist
grep -q "MockERC20 collateralToken" "$FILE" || \
  sed -i '' '/PSMLimits public limits;/a\
    MockERC20 public collateralToken;\
' "$FILE"

grep -q "MockCollateralVault public vault" "$FILE" || \
  sed -i '' '/MockERC20 public collateralToken;/a\
    MockCollateralVault public vault;\
' "$FILE"

grep -q "ParameterRegistry public reg" "$FILE" || \
  sed -i '' '/MockCollateralVault public vault;/a\
    ParameterRegistry public reg;\
' "$FILE"

echo "✓ Step 2: Variables restored"

# 6) Fix setUp Section — add instantiation
sed -i '' '/psm = new PegStabilityModule/a\
        collateralToken = new MockERC20("COL","COL");\
        collateralToken.mint(user, 1000e18);\
        vm.prank(user);\
        collateralToken.approve(address(psm), type(uint256).max);\
        vault = new MockCollateralVault();\
        reg = new ParameterRegistry(dao);\
' "$FILE"

# 7) Replace any remaining address(1)
sed -i '' 's/address(1)/address(collateralToken)/g' "$FILE"

echo "✓ Step 3: setUp() rebuilt and address(1) removed"
