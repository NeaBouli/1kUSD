// SPDX-License-Identifier: MIT
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
        // --- Oracle ---
        oracle = new MockOracleAggregator();
        oracle.setPrice(int256(1e18), 18, true);

        // --- Vault / Limits / Safety (neutral for test) ---
        limits = PSMLimits(address(0));
        safety = ISafetyAutomata(address(0));

        // --- Token ---
        oneKUSD = new OneKUSD(dao);
        oneKUSD.setMinter(address(dao), true);
        oneKUSD.setBurner(address(dao), true);

        // --- PSM ---
        psm = new PegStabilityModule(
            dao,
            address(oneKUSD),
            address(vault),
            address(safety),
            address(limits)
        );

        // authorize PSM
        vm.prank(dao);
        oneKUSD.setMinter(address(psm), true);
        vm.prank(dao);
        oneKUSD.setBurner(address(psm), true);

        psm.setOracle(address(oracle));
    }

    function testMintFlow_1to1() public {
        // new collateral token instance
        MockERC20 collateralToken = new MockERC20("COL", "COL");
import {MockVault} from "../mocks/MockVault.sol";

        // mint 1000 collateral to user
        collateralToken.mint(user, 1000e18);

        // user approves PSM
        vm.prank(user);
        collateralToken.approve(address(psm), type(uint256).max);

        // perform swap
        vm.prank(user);
        psm.swapTo1kUSD(address(collateralToken), 1000e18, user, 0, block.timestamp + 1 days);

        // user should receive 1000 1kUSD
        assertEq(oneKUSD.balanceOf(user), 1000e18);

        // PSM should now hold 1000 collateral
        assertEq(collateralToken.balanceOf(address(psm)), 1000e18);
    }

    function testPlaceholder() public {
        assertTrue(true);
    }
}
