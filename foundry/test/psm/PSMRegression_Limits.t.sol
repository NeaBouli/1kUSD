// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {PegStabilityModule} from "../../../contracts/core/PegStabilityModule.sol";
import {PSMLimits} from "../../../contracts/psm/PSMLimits.sol";
import {OneKUSD} from "../../../contracts/core/OneKUSD.sol";
import {CollateralVault} from "../../../contracts/core/CollateralVault.sol";
import {ISafetyAutomata} from "../../../contracts/interfaces/ISafetyAutomata.sol";
import {ParameterRegistry} from "../../../contracts/core/ParameterRegistry.sol";

/// @title PSMRegression_Limits — DEV-44 extended regression tests
contract PSMRegression_Limits is Test {
    PegStabilityModule psm;
    PSMLimits limits;
    OneKUSD oneKUSD;
    CollateralVault vault;
    ISafetyAutomata auto_;
    ParameterRegistry reg;

    address user = address(0xBEEF);

    function setUp() public {
        // deploy very light mocks
        oneKUSD = new OneKUSD();
        vault = new CollateralVault();
        reg = new ParameterRegistry();
        auto_ = ISafetyAutomata(address(0)); // not used in these tests

        psm = new PegStabilityModule(
            address(this),
            address(oneKUSD),
            address(vault),
            address(auto_),
            address(reg)
        );

        // limits: dailyCap=1000, singleTxCap=500
        limits = new PSMLimits(address(this), 1000, 500);
        psm.setLimits(address(limits));
    }

    /// ------------------------------------------------------------
    /// 1) singleTxCap revert
    /// ------------------------------------------------------------
    function testSingleTxLimitReverts() public {
        // amountIn > singleTxCap (=500)
        vm.expectRevert();
        psm.swapTo1kUSD(address(1), 600, user, 0, block.timestamp);
    }

    /// ------------------------------------------------------------
    /// 2) dailyCap revert
    /// ------------------------------------------------------------
    function testDailyCapReverts() public {
        // 2 swaps à 600 → each violates caps
        vm.expectRevert();
        psm.swapTo1kUSD(address(1), 600, user, 0, block.timestamp);

        // smaller swaps: accumulate volume 400 + 400 → 800 total
        psm.swapTo1kUSD(address(1), 400, user, 0, block.timestamp);
        vm.expectRevert(); // 400 + 400 + 400 = 1200 (dailyCap=1000)
        psm.swapTo1kUSD(address(1), 400, user, 0, block.timestamp);
    }

    /// ------------------------------------------------------------
    /// 3) daily reset after 1 day
    /// ------------------------------------------------------------
    function testDailyReset() public {
        // first day volume = 400
        psm.swapTo1kUSD(address(1), 400, user, 0, block.timestamp);

        // jump 1 day forward
        vm.warp(block.timestamp + 1 days);

        // should work again because volume resets
        psm.swapTo1kUSD(address(1), 400, user, 0, block.timestamp);
    }
}
