#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Flows.t.sol"

echo "== DEV45: FULL SAFE REBUILD OF PSMRegression_Flows.t.sol =="

cat <<'EOT' > "$FILE"
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import {PegStabilityModule} from "../../../contracts/core/PegStabilityModule.sol";
import {OneKUSD} from "../../../contracts/core/OneKUSD.sol";
import {IOracleAggregator} from "../../../contracts/interfaces/IOracleAggregator.sol";
import {MockOracleAggregator} from "../../mocks/MockOracleAggregator.sol";
import {CollateralVault} from "../../../contracts/core/CollateralVault.sol";
import {PSMLimits} from "../../../contracts/psm/PSMLimits.sol";
import {ISafetyAutomata} from "../../../contracts/interfaces/ISafetyAutomata.sol";
import {IFeeRouterV2} from "../../../contracts/router/IFeeRouterV2.sol";

/// @title PSMRegression_Flows
/// @notice Clean rebuilt skeleton for DEV-45 PSM regression flow tests.
contract PSMRegression_Flows is Test {
    PegStabilityModule internal psm;
    OneKUSD internal oneKUSD;
    MockOracleAggregator internal oracle;
    CollateralVault internal vault;
    PSMLimits internal limits;
    ISafetyAutomata internal safety;
    IFeeRouterV2 internal feeRouter;

    address internal dao = address(this);
    address internal user = address(0xBEEF);
    address internal collateral = address(0xCA11);

    function setUp() public {
        // placeholder; concrete wiring follows in next DEV-45 steps
        oracle = new MockOracleAggregator();
        oracle.setPrice(int256(1e18), 18, true);
    }

    function testPlaceholder() public {
        assertTrue(true);
    }
}
EOT

echo "✓ Rebuilt PSMRegression_Flows.t.sol cleanly"
