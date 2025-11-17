#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Flows.t.sol"

echo "== DEV45 STEP 12D: Full clean repair of PSMRegression_Flows.t.sol =="

cat <<'SOL' > "$FILE"
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import {PegStabilityModule} from "../../../contracts/core/PegStabilityModule.sol";
import {OneKUSD} from "../../../contracts/core/OneKUSD.sol";
import {IOracleAggregator} from "../../../contracts/interfaces/IOracleAggregator.sol";
import {MockOracleAggregator} from "../mocks/MockOracleAggregator.sol";
import {MockERC20} from "../mocks/MockERC20.sol";
import {MockVault} from "../mocks/MockVault.sol";

/// @title PSMRegression_Flows
/// @notice DEV-45: E2E-Regression für den Mint-Pfad (Collateral -> 1kUSD)
contract PSMRegression_Flows is Test {
    PegStabilityModule internal psm;
    OneKUSD internal oneKUSD;
    MockOracleAggregator internal oracle;
    MockERC20 internal collateralToken;
    MockVault internal vault;

    address internal dao = address(this);
    address internal user = address(0xBEEF);

    function setUp() public {
        // 1) Oracle mit gesundem 1:1-Preis
        oracle = new MockOracleAggregator();
        oracle.setPrice(int256(1e18), 18, true);

        // 2) Core-Token + Collateral + Vault
        oneKUSD = new OneKUSD(dao);
        collateralToken = new MockERC20("COL", "COL");
        vault = new MockVault();

        // 3) Realer PSM-Konstruktor, neutrale Safety/Registry
        psm = new PegStabilityModule(
            dao,
            address(oneKUSD),
            address(vault),
            address(0),
            address(0)
        );

        // 4) PSM als Minter/Burner für 1kUSD freischalten
        vm.prank(dao);
        oneKUSD.setMinter(address(psm), true);
        vm.prank(dao);
        oneKUSD.setBurner(address(psm), true);

        // 5) Oracle an PSM hängen
        psm.setOracle(address(oracle));

        // 6) User mit Collateral ausstatten + Approve
        collateralToken.mint(user, 1000e18);
        vm.prank(user);
        collateralToken.approve(address(psm), type(uint256).max);
    }

    /// @notice Basis-Flow: 1:1-Mint mit Fee-Behandlung + Debug-Logs
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

        // Debug-Ausgabe
        emit log_named_uint("DEBUG_user1k_before", user1kBefore);
        emit log_named_uint("DEBUG_user1k_after", oneKUSD.balanceOf(user));
        emit log_named_uint("DEBUG_psm_1k_balance", oneKUSD.balanceOf(address(psm)));
        emit log_named_uint("DEBUG_totalSupply_before", supplyBefore);
        emit log_named_uint("DEBUG_totalSupply_after", oneKUSD.totalSupply());
        emit log_named_uint("DEBUG_dao_1k_balance", oneKUSD.balanceOf(dao));

        uint256 mintFeeBps = psm.mintFeeBps();
        uint256 expectedNotional = amountIn;
        uint256 expectedFee = (expectedNotional * mintFeeBps) / 10_000;
        uint256 expectedNet = expectedNotional - expectedFee;

        // Rückgabewert == Nettobetrag
        assertEq(out, expectedNet, "net 1kUSD out mismatch");

        // User-Balance steigt um Nettobetrag
        assertEq(
            oneKUSD.balanceOf(user) - user1kBefore,
            expectedNet,
            "user 1kUSD delta mismatch"
        );

        // totalSupply steigt exakt um Nettobetrag
        assertEq(
            oneKUSD.totalSupply() - supplyBefore,
            expectedNet,
            "totalSupply delta mismatch"
        );

        // Gesamtes Collateral (PSM + Vault) steigt um amountIn
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
SOL

echo "✓ DEV45 STEP 12D: PSMRegression_Flows.t.sol repaired cleanly"
