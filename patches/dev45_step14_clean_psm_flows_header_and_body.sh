#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Flows.t.sol"

echo "== DEV45 STEP 14: FULL CLEAN HEADER + BODY FIX =="

# 1) Entire file loaded
SRC=$(cat "$FILE")

# 2) Extract the CONTRACT BODY (everything from "contract" onward)
BODY=$(printf "%s" "$SRC" | sed -n '/contract PSMRegression_Flows/,$p')

# --- BUILD CLEAN HEADER ---
HEADER='// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import {PegStabilityModule} from "../../../contracts/core/PegStabilityModule.sol";
import {OneKUSD} from "../../../contracts/core/OneKUSD.sol";
import {IOracleAggregator} from "../../../contracts/interfaces/IOracleAggregator.sol";
import {MockOracleAggregator} from "../mocks/MockOracleAggregator.sol";
import {MockERC20} from "../mocks/MockERC20.sol";
import {MockCollateralVault} from "../mocks/MockCollateralVault.sol";
import {PSMLimits} from "../../../contracts/psm/PSMLimits.sol";
import {ISafetyAutomata} from "../../../contracts/interfaces/ISafetyAutomata.sol";
import {IFeeRouterV2} from "../../../contracts/router/IFeeRouterV2.sol";
'

# 3) REMOVE all illegal imports inside contract body
BODY=$(printf "%s" "$BODY" | sed '/import {MockCollateralVault}/d')

# 4) Write the reconstructed file
printf "%s\n\n%s\n" "$HEADER" "$BODY" > "$FILE"

echo "✓ CLEAN HEADER + BODY REPAIRED"
