// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import {PegStabilityModule} from "../../../contracts/core/PegStabilityModule.sol";
import {OneKUSD} from "../../../contracts/core/OneKUSD.sol";
import {ParameterRegistry} from "../../../contracts/core/ParameterRegistry.sol";
import {MockERC20} from "../mocks/MockERC20.sol";
import {MockCollateralVault} from "../mocks/MockCollateralVault.sol";
import {MockOracleAggregator} from "../mocks/MockOracleAggregator.sol";

/// @title PSMRegression_Fees
/// @notice DEV-48: Verifiziert Fee-Bps Konfiguration über ParameterRegistry (global + per-Token)
///         inkl. Fallback auf lokale mintFeeBps/redeemFeeBps.
contract PSMRegression_Fees is Test {
    PegStabilityModule internal psm;
    OneKUSD internal oneKUSD;
    ParameterRegistry internal registry;
    MockERC20 internal collateralToken;
    MockCollateralVault internal vault;
    MockOracleAggregator internal oracle;

    address internal dao = address(this);
    address internal user = address(0xBEEF);

    // Spiegeln der internen Keys aus PegStabilityModule
    bytes32 internal constant KEY_MINT_FEE_BPS   = keccak256("psm:mintFeeBps");
    bytes32 internal constant KEY_REDEEM_FEE_BPS = keccak256("psm:redeemFeeBps");

    function _mintFeeKey(address token) internal pure returns (bytes32) {
        return keccak256(abi.encode(KEY_MINT_FEE_BPS, token));
    }

    function setUp() public {
        oneKUSD = new OneKUSD(dao);
        registry = new ParameterRegistry(dao);
        collateralToken = new MockERC20("COL", "COL");
        vault = new MockCollateralVault();

        // PSM mit echtem Vault + Registry, Oracle wird explizit auf 1:1 gesetzt.
        psm = new PegStabilityModule(
            dao,
            address(oneKUSD),
            address(vault),
            address(0),
            address(registry)
        );

        oracle = new MockOracleAggregator();
        oracle.setPrice(int256(1e18), 18, true);
        psm.setOracle(address(oracle));

        // PSM darf 1kUSD minten/burnen
        vm.prank(dao);
        oneKUSD.setMinter(address(psm), true);
        vm.prank(dao);
        oneKUSD.setBurner(address(psm), true);

        // User mit Collateral ausstatten + Approve
        collateralToken.mint(user, 1_000e18);
        vm.prank(user);
        collateralToken.approve(address(psm), type(uint256).max);
    }

    /// @notice Globaler Mint-Fee-Eintrag in Registry wird respektiert.
    function testMintUsesGlobalRegistryFee() public {
        // global mintFee = 100 bps (1 %)
        vm.prank(dao);
        registry.setUint(KEY_MINT_FEE_BPS, 100);

        uint256 amountIn = 1_000e18;

        uint256 user1kBefore = oneKUSD.balanceOf(user);
        uint256 supplyBefore = oneKUSD.totalSupply();

        vm.prank(user);
        uint256 out = psm.swapTo1kUSD(
            address(collateralToken),
            amountIn,
            user,
            0,
            block.timestamp + 1 days
        );

        // Fallback-Oracle: 1:1 → notional == amountIn
        uint256 expectedGross = amountIn;
        uint256 expectedFee   = (expectedGross * 100) / 10_000;
        uint256 expectedNet   = expectedGross - expectedFee;

        assertEq(out, expectedNet, "net out must honour registry mintFee");
        assertEq(
            oneKUSD.balanceOf(user) - user1kBefore,
            expectedNet,
            "user 1kUSD delta mismatch"
        );
        assertEq(
            oneKUSD.totalSupply() - supplyBefore,
            expectedNet,
            "totalSupply delta mismatch"
        );
    }

    /// @notice Token-spezifischer Mint-Fee überschreibt den globalen Eintrag.
    function testMintPerTokenOverrideBeatsGlobal() public {
        // global 1 %, per-Token 2 %
        vm.startPrank(dao);
        registry.setUint(KEY_MINT_FEE_BPS, 100);
        registry.setUint(_mintFeeKey(address(collateralToken)), 200);
        vm.stopPrank();

        uint256 amountIn = 1_000e18;

        vm.prank(user);
        uint256 out = psm.swapTo1kUSD(
            address(collateralToken),
            amountIn,
            user,
            0,
            block.timestamp + 1 days
        );

        uint256 expectedGross = amountIn;
        uint256 expectedFee   = (expectedGross * 200) / 10_000;
        uint256 expectedNet   = expectedGross - expectedFee;

        assertEq(out, expectedNet, "per-token mint fee should override global");
    }

    /// @notice Redeem-Fee über Registry reduziert den Token-Out-Betrag deterministisch.
    function testRedeemUsesGlobalRegistryFee() public {
        // global redeemFee = 100 bps (1 %)
        vm.prank(dao);
        registry.setUint(KEY_REDEEM_FEE_BPS, 100);

        // explizit: lokale Fees auf 0 setzen (Mint-Fee soll hier 0 sein)
        vm.prank(dao);
        psm.setFees(0, 0);

        uint256 amountIn = 1_000e18;

        // 1) Erst ohne Mint-Fee 1kUSD minten (nur zum Befüllen des Vaults)
        vm.prank(user);
        uint256 minted = psm.swapTo1kUSD(
            address(collateralToken),
            amountIn,
            user,
            0,
            block.timestamp + 1 days
        );

        // sanity: bei 0 Mint-Fee ≈ 1:1
        assertEq(minted, amountIn, "precondition: zero mint fee expected");

        uint256 collBefore = collateralToken.balanceOf(user);

        // 2) Jetzt mit 1 % Redeem-Fee wieder raus
        vm.prank(user);
        uint256 out = psm.swapFrom1kUSD(
            address(collateralToken),
            minted,
            user,
            0,
            block.timestamp + 1 days
        );

        uint256 expectedGross = minted;
        uint256 expectedFee1k = (expectedGross * 100) / 10_000;
        uint256 expectedNetTokenOut = expectedGross - expectedFee1k; // 1:1 Preis

        assertEq(out, expectedNetTokenOut, "redeem net out must honour registry redeemFee");
        assertEq(
            collateralToken.balanceOf(user) - collBefore,
            expectedNetTokenOut,
            "user collateral delta mismatch"
        );
    }
}
