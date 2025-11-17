// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import {PegStabilityModule} from "../../../contracts/core/PegStabilityModule.sol";
import {OneKUSD} from "../../../contracts/core/OneKUSD.sol";
import {IOracleAggregator} from "../../../contracts/interfaces/IOracleAggregator.sol";
import {MockOracleAggregator} from "../mocks/MockOracleAggregator.sol";
import {MockERC20} from "../mocks/MockERC20.sol";
import {MockCollateralVault} from "../mocks/MockCollateralVault.sol";

/// @title PSMRegression_Flows
/// @notice DEV-45: Basis-Flow-Regression für Collateral -> 1kUSD Swap (keine strikte Betrags-Erwartung, nur Invarianten)
contract PSMRegression_Flows is Test {
    PegStabilityModule internal psm;
    OneKUSD internal oneKUSD;
    MockOracleAggregator internal oracle;
    MockERC20 internal collateralToken;
    MockCollateralVault internal vault;

    address internal dao = address(this);
    address internal user = address(0xBEEF);

    function setUp() public {
        // 1) Oracle mit 1:1-Preis
        oracle = new MockOracleAggregator();
        oracle.setPrice(int256(1e18), 18, true);

        // 2) 1kUSD + Collateral + Vault
        oneKUSD = new OneKUSD(dao);
        collateralToken = new MockERC20("COL", "COL");
        vault = new MockCollateralVault();

        // 3) PSM mit neutraler Safety/Limits, aber echtem Vault
        psm = new PegStabilityModule(
            dao,
            address(oneKUSD),
            address(vault),
            address(0),
            address(0)
        );

        // 4) PSM darf 1kUSD minten/burnen
        vm.prank(dao);
        oneKUSD.setMinter(address(psm), true);
        vm.prank(dao);
        oneKUSD.setBurner(address(psm), true);

        // 5) Oracle an PSM hängen
        psm.setOracle(address(oracle));

        // 6) User mit Collateral ausstatten + Approve für PSM
        collateralToken.mint(user, 1000e18);
        vm.prank(user);
        collateralToken.approve(address(psm), type(uint256).max);
    }

    /// @notice Basis-Flow: prüft, dass Swap nicht reverted und Accounting-Invarianten halten.
    ///         Erwartet NICHT explizit 1000 1kUSD Out – das ist Aufgabe der PSMSwapCore-Tests.
    function testMintFlow_1to1() public {
        uint256 amountIn = 1000e18;

        uint256 user1kBefore = oneKUSD.balanceOf(user);
        uint256 supplyBefore = oneKUSD.totalSupply();
        uint256 totalCollBefore =
            collateralToken.balanceOf(address(psm)) +
            vault.balances(address(collateralToken));

        // Swap Collateral -> 1kUSD
        vm.prank(user);
        uint256 out = psm.swapTo1kUSD(
            address(collateralToken),
            amountIn,
            user,
            0,
            block.timestamp + 1 days
        );

        // Invariante 1: Rückgabewert == Veränderung der User-Balance
        assertEq(
            oneKUSD.balanceOf(user) - user1kBefore,
            out,
            "user 1kUSD delta must equal returned amount"
        );

        // Invariante 2: totalSupply-Differenz == Out
        assertEq(
            oneKUSD.totalSupply() - supplyBefore,
            out,
            "totalSupply delta must equal out"
        );

        // Invariante 3: Gesamtes Collateral (PSM + Vault) steigt um amountIn
        uint256 totalCollAfter =
            collateralToken.balanceOf(address(psm)) +
            vault.balances(address(collateralToken));

        assertEq(
            totalCollAfter - totalCollBefore,
            amountIn,
            "collateral lock delta mismatch"
        );
    }

    function testPlaceholder() public {
        assertTrue(true, "PSMRegression_Flows placeholder");
    }
}
