// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import {PegStabilityModule} from "../../../contracts/core/PegStabilityModule.sol";
import {OneKUSD} from "../../../contracts/core/OneKUSD.sol";
import {ParameterRegistry} from "../../../contracts/core/ParameterRegistry.sol";
import {PSMLimits} from "../../../contracts/psm/PSMLimits.sol";

import {MockERC20} from "../mocks/MockERC20.sol";
import {MockOracleAggregator} from "../mocks/MockOracleAggregator.sol";
import {MockCollateralVault} from "../mocks/MockCollateralVault.sol";


contract PSMRegression_Limits is Test {
    PegStabilityModule public psm;
    PSMLimits public limits;
    OneKUSD public oneKUSD;
    MockERC20 public collateralToken;
    MockCollateralVault public vault;
    ParameterRegistry public reg;
    address public dao = address(this);

    address public user = address(0xBEEF);

    function setUp() public {
        // Core PSM wiring for limit regression tests

        // 1) OneKUSD and core infra
        oneKUSD = new OneKUSD(dao);
        vault = new MockCollateralVault();
        reg = new ParameterRegistry(dao);

        // 2) PegStabilityModule with real vault/registry, no safety automata
        psm = new PegStabilityModule(
            dao,
            address(oneKUSD),
            address(vault),
            address(0),
            address(reg)
        );

        // 3) Allow PSM to mint/burn 1kUSD
        vm.prank(dao);
        oneKUSD.setMinter(address(psm), true);
        vm.prank(dao);
        oneKUSD.setBurner(address(psm), true);

        // 4) Collateral token and approvals
        collateralToken = new MockERC20("COL", "COL");
        collateralToken.mint(user, 10_000e18);
        vm.prank(user);
        collateralToken.approve(address(psm), type(uint256).max);

        // 5) Limits: dailyCap = 1000, singleTxCap = 500
        limits = new PSMLimits(address(this), 1000, 500);
        psm.setLimits(address(limits));

        // 6) No fees — isolate limit behaviour
        psm.setFees(0, 0);
    }

    /// ------------------------------------------------------------
    /// 1) singleTxCap: amountIn > singleTxCap revertet
    /// ------------------------------------------------------------
    function testSingleTxLimitReverts() public {
        // singleTxCap = 500 → 600 muss revertieren
        vm.expectRevert(); // "swap too large"
        vm.prank(user);
        psm.swapTo1kUSD(address(collateralToken), 600, user, 0, block.timestamp);
    }

    /// ------------------------------------------------------------
    /// 2) dailyCap: Summe der Swaps > dailyCap revertet
    /// ------------------------------------------------------------
    function testDailyCapReverts() public {
        // dailyCap = 1000
        // 1) 400 → ok (dailyVolume = 400)
        vm.prank(user);
        psm.swapTo1kUSD(address(collateralToken), 400, user, 0, block.timestamp);

        // 2) 400 → ok (dailyVolume = 800)
        vm.prank(user);
        psm.swapTo1kUSD(address(collateralToken), 400, user, 0, block.timestamp);

        // 3) 400 → 800 + 400 = 1200 > 1000 → revert
        vm.expectRevert(); // "swap too large"
        vm.prank(user);
        psm.swapTo1kUSD(address(collateralToken), 400, user, 0, block.timestamp);
    }

    /// ------------------------------------------------------------
    /// 3) dailyCap Reset nach einem Tag
    /// ------------------------------------------------------------
    function testDailyReset() public {
        // Tag 1: 400 → ok
        vm.prank(user);
        psm.swapTo1kUSD(address(collateralToken), 400, user, 0, block.timestamp);

        // Tag +1
        vm.warp(block.timestamp + 1 days);

        // neues Tagesvolumen → wieder 400 möglich
        vm.prank(user);
        psm.swapTo1kUSD(address(collateralToken), 400, user, 0, block.timestamp);
    }
}
