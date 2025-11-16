#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Limits.t.sol"

echo "== DEV-44 Step 5b: Rewrite PSMRegression_Limits.t.sol =="

cat <<'EOT' > "$FILE"
// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import {PegStabilityModule} from "../../../contracts/core/PegStabilityModule.sol";
import {PSMLimits} from "../../../contracts/psm/PSMLimits.sol";
import {MockOneKUSD} from "../../../contracts/mocks/MockOneKUSD.sol";
import {MockVault} from "../../../contracts/mocks/MockVault.sol";
import {MockRegistry} from "../../../contracts/mocks/MockRegistry.sol";

/// @title PSMRegression_Limits
/// @notice DEV-44: Verifiziert, dass PegStabilityModule PSMLimits korrekt erzwingt.
contract PSMRegression_Limits is Test {
    PegStabilityModule public psm;
    PSMLimits public limits;
    MockOneKUSD public oneKUSD;
    MockVault public vault;
    MockRegistry public reg;

    address public user = address(0xBEEF);

    function setUp() public {
        // einfache Mocks für 1kUSD / Vault / Registry
        oneKUSD = new MockOneKUSD();
        vault = new MockVault();
        reg = new MockRegistry();

        // SafetyAutomata ist für diese Tests irrelevant → address(0)
        psm = new PegStabilityModule(
            address(this),
            address(oneKUSD),
            address(vault),
            address(0),
            address(reg)
        );

        // Limits: dailyCap = 1000, singleTxCap = 500
        limits = new PSMLimits(address(this), 1000, 500);
        psm.setLimits(address(limits));

        // Keine Fees, damit wir uns nur auf Limits konzentrieren
        psm.setFees(0, 0);
    }

    /// ------------------------------------------------------------
    /// 1) singleTxCap: amountIn > singleTxCap revertet
    /// ------------------------------------------------------------
    function testSingleTxLimitReverts() public {
        // singleTxCap = 500 → 600 muss revertieren
        vm.expectRevert(); // "swap too large"
        psm.swapTo1kUSD(address(1), 600, user, 0, block.timestamp);
    }

    /// ------------------------------------------------------------
    /// 2) dailyCap: Summe der Swaps > dailyCap revertet
    /// ------------------------------------------------------------
    function testDailyCapReverts() public {
        // dailyCap = 1000
        // 1) 400 → ok (dailyVolume = 400)
        psm.swapTo1kUSD(address(1), 400, user, 0, block.timestamp);

        // 2) 400 → ok (dailyVolume = 800)
        psm.swapTo1kUSD(address(1), 400, user, 0, block.timestamp);

        // 3) 400 → 800 + 400 = 1200 > 1000 → revert
        vm.expectRevert(); // "swap too large"
        psm.swapTo1kUSD(address(1), 400, user, 0, block.timestamp);
    }

    /// ------------------------------------------------------------
    /// 3) dailyCap Reset nach einem Tag
    /// ------------------------------------------------------------
    function testDailyReset() public {
        // Tag 1: 400 → ok
        psm.swapTo1kUSD(address(1), 400, user, 0, block.timestamp);

        // Tag +1
        vm.warp(block.timestamp + 1 days);

        // neues Tagesvolumen → wieder 400 möglich
        psm.swapTo1kUSD(address(1), 400, user, 0, block.timestamp);
    }
}
EOT

echo "✓ PSMRegression_Limits.t.sol rewritten cleanly"
echo "== DEV-44 Step 5b Complete =="
