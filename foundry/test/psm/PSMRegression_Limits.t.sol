// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import {PegStabilityModule} from "../../../contracts/core/PegStabilityModule.sol";
import {OneKUSD} from "../../../contracts/core/OneKUSD.sol";
import {MockOracleAggregator} from "../mocks/MockOracleAggregator.sol";
import {MockERC20} from "../mocks/MockERC20.sol";
import {MockCollateralVault} from "../mocks/MockCollateralVault.sol";
import {PSMLimits} from "../../../contracts/psm/PSMLimits.sol";
import {ParameterRegistry} from "../../../contracts/core/ParameterRegistry.sol";


contract PSMRegression_Limits is Test {
    PegStabilityModule public psm;
    PSMLimits public limits;
import {ParameterRegistry} from "../../../contracts/core/ParameterRegistry.sol";
    MockERC20 collateralToken;

    address public user = address(0xBEEF);

    function setUp() public {
        // einfache Mocks für 1kUSD / Vault / Registry

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
import {ParameterRegistry} from "../../../contracts/core/ParameterRegistry.sol";
        collateralToken = new MockERC20("COL", "COL");
        collateralToken.mint(user, 1000e18);
        vm.prank(user);
        collateralToken.approve(address(psm), type(uint256).max);
        vault = new MockCollateralVault();
        reg = new ParameterRegistry(dao);
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
        psm.swapTo1kUSD(address(collateralToken), 600, user, 0, block.timestamp);
    }

    /// ------------------------------------------------------------
    /// 2) dailyCap: Summe der Swaps > dailyCap revertet
    /// ------------------------------------------------------------
    function testDailyCapReverts() public {
        // dailyCap = 1000
        // 1) 400 → ok (dailyVolume = 400)
        psm.swapTo1kUSD(address(collateralToken), 400, user, 0, block.timestamp);

        // 2) 400 → ok (dailyVolume = 800)
        psm.swapTo1kUSD(address(collateralToken), 400, user, 0, block.timestamp);

        // 3) 400 → 800 + 400 = 1200 > 1000 → revert
        vm.expectRevert(); // "swap too large"
        psm.swapTo1kUSD(address(collateralToken), 400, user, 0, block.timestamp);
    }

    /// ------------------------------------------------------------
    /// 3) dailyCap Reset nach einem Tag
    /// ------------------------------------------------------------
    function testDailyReset() public {
        // Tag 1: 400 → ok
        psm.swapTo1kUSD(address(collateralToken), 400, user, 0, block.timestamp);

        // Tag +1
        vm.warp(block.timestamp + 1 days);

        // neues Tagesvolumen → wieder 400 möglich
        psm.swapTo1kUSD(address(collateralToken), 400, user, 0, block.timestamp);
    }
}
