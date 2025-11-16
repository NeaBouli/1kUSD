#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Flows.t.sol"

echo "== DEV45 STEP 11E: FULL SAFE HEADER RESET =="

# Read file
SRC=$(cat "$FILE")

# Extract the contract body starting from "contract PSMRegression_Flows"
BODY=$(printf "%s\n" "$SRC" | sed -n '/contract PSMRegression_Flows/,$p')

# Build clean header
HEADER='// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import {PegStabilityModule} from "../../../contracts/core/PegStabilityModule.sol";
import {OneKUSD} from "../../../contracts/core/OneKUSD.sol";
import {IOracleAggregator} from "../../../contracts/interfaces/IOracleAggregator.sol";
import {MockOracleAggregator} from "../mocks/MockOracleAggregator.sol";
import {MockERC20} from "../mocks/MockERC20.sol";
import {MockVault} from "../mocks/MockVault.sol";
import {CollateralVault} from "../../../contracts/core/CollateralVault.sol";
import {PSMLimits} from "../../../contracts/psm/PSMLimits.sol";
import {ISafetyAutomata} from "../../../contracts/interfaces/ISafetyAutomata.sol";
import {IFeeRouterV2} from "../../../contracts/router/IFeeRouterV2.sol";

'

# Write new file
printf "%s\n%s\n" "$HEADER" "$BODY" > "$FILE"

echo "✓ FULL HEADER RESET COMPLETE"
