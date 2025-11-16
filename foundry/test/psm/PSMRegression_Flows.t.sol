// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import {PegStabilityModule} from "../../../contracts/core/PegStabilityModule.sol";
import {OneKUSD} from "../../../contracts/core/OneKUSD.sol";
import {IOracleAggregator} from "../../../contracts/interfaces/IOracleAggregator.sol";
import {MockOracleAggregator} from "../mocks/MockOracleAggregator.sol";
import {MockERC20} from "../mocks/MockERC20.sol";
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
        // DEV-45: basic wiring of core components for PSM regression flows

        // 1) Oracle mock with healthy 1:1 price
        oracle.setPrice(int256(1e18), 18, true);

        // 2) 1kUSD token (DAO as admin)
        oneKUSD = new OneKUSD(dao);

        // 3) Neutral handles for external modules (wired to address(0) for now)
        vault = CollateralVault(address(0));
        limits = PSMLimits(address(0));
        safety = ISafetyAutomata(address(0));
        feeRouter = IFeeRouterV2(address(0));

        // 4) REAL PSM constructor wiring (neutral external modules)

        psm = new PegStabilityModule(
            dao,
            address(oneKUSD),
            address(vault),     // currently address(0)
            address(safety),    // currently address(0)
            address(limits)     // currently address(0)
        );

        // Set PSM as minter/burner for OneKUSD
        vm.prank(dao);
        oneKUSD.setMinter(address(psm), true);

        vm.prank(dao);
        oneKUSD.setBurner(address(psm), true);

        psm.setOracle(address(oracle));

    }

function testMintFlow_1to1() public {
        // 1) User erhält Collateral
        collateralToken.mint(user, 1000e18);

        // 2) User genehmigt PSM
        vm.prank(user);
        collateralToken.approve(address(psm), type(uint256).max);

        // 3) Oracle Preis steht bereits in setUp() auf 1e18 (1:1)

        // 4) Swap 1000 Collateral -> 1000 1kUSD
        vm.prank(user);
        psm.swapTo1kUSD(address(collateralToken), 1000e18);

        // 5) Prüfung: User hat 1000 1kUSD
        assertEq(oneKUSD.balanceOf(user), 1000e18, "User should receive 1kUSD");

        // Minimal check: PSM sollte Collateral halten
        assertEq(collateralToken.balanceOf(address(psm)), 1000e18);
    }


    




    
    function testPlaceholder() public {
        assertTrue(true);
    }
}
