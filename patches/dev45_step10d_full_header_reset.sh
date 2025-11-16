#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Flows.t.sol"

echo "== DEV45 STEP 10D: FULL HEADER RESET =="

# 1) Lösche alles oberhalb des Contract-Beginns
sed -i '' '1,/contract PSMRegression_Flows/{/contract PSMRegression_Flows/!d}' "$FILE"

# 2) Füge perfekten Header vor contract ein
sed -i '' '1i\
// SPDX-License-Identifier: MIT\
pragma solidity ^0.8.24;\
\
import "forge-std/Test.sol";\
\
import {PegStabilityModule} from "../../../contracts/core/PegStabilityModule.sol";\
import {OneKUSD} from "../../../contracts/core/OneKUSD.sol";\
import {IOracleAggregator} from "../../../contracts/interfaces/IOracleAggregator.sol";\
import {MockOracleAggregator} from "../mocks/MockOracleAggregator.sol";\
import {MockERC20} from "../mocks/MockERC20.sol";\
import {CollateralVault} from "../../../contracts/core/CollateralVault.sol";\
import {PSMLimits} from "../../../contracts/psm/PSMLimits.sol";\
import {ISafetyAutomata} from "../../../contracts/interfaces/ISafetyAutomata.sol";\
import {IFeeRouterV2} from "../../../contracts/router/IFeeRouterV2.sol";\
' "$FILE"

echo "✓ HEADER CLEANLY RESET"
