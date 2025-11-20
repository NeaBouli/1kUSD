#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Spreads.t.sol"

echo "== DEV52 CORE04: write PSMRegression_Spreads (registry-driven spreads) =="

mkdir -p "$(dirname "$FILE")"

cat <<'SOL' > "$FILE"
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Test.sol";

import "../../../contracts/core/PegStabilityModule.sol";
import "../../../contracts/core/ParameterRegistry.sol";
import "../../../contracts/core/SafetyAutomata.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @dev Minimal mint/burn ERC20 used as collateral + 1kUSD stand-in.
contract MockMintableToken is ERC20 {
    constructor(string memory n, string memory s) ERC20(n, s) {
        _mint(msg.sender, 1_000_000e18);
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        _burn(from, amount);
    }
}

/// @dev Vault stub that actually moves collateral from vault -> PSM on withdraw.
contract MockVault {
    function deposit(address, address, uint256) external {}

    function withdraw(address asset, address to, uint256 amount, bytes32) external {
        ERC20(asset).transfer(to, amount);
    }
}

contract PSMRegression_Spreads is Test {
    // --- Core wiring ---
    ParameterRegistry internal registry;
    SafetyAutomata internal safety;
    PegStabilityModule internal psm;
    MockVault internal vault;
    MockMintableToken internal collateralToken;
    MockMintableToken internal oneKUSD;

    address internal dao = address(0xDA0);
    address internal user = address(0xBEEF);

    // --- Spread keys (must mirror PegStabilityModule constants) ---
    bytes32 private constant KEY_MINT_SPREAD_BPS   = keccak256("psm:mintSpreadBps");
    bytes32 private constant KEY_REDEEM_SPREAD_BPS = keccak256("psm:redeemSpreadBps");

    function setUp() public {
        registry = new ParameterRegistry(dao);
        safety = new SafetyAutomata(dao, 0);
        vault = new MockVault();
        oneKUSD = new MockMintableToken("1kUSD", "1KUSD");
        collateralToken = new MockMintableToken("COL", "COL");

        // PSM mit Registry + Safety + Vault, Oracle bleibt auf Fallback (1e18, 18 Decimals)
        psm = new PegStabilityModule(
            dao,
            address(oneKUSD),
            address(vault),
            address(safety),
            address(registry)
        );

        // Default: keine Fees, keine Spreads über Storage
        vm.prank(dao);
        psm.setFees(0, 0);
    }

    // --- Internals: Key-Hilfsfunktionen für per-Token Spreads ---

    function _mintSpreadKey(address token) internal pure returns (bytes32) {
        return keccak256(abi.encode(KEY_MINT_SPREAD_BPS, token));
    }

    function _redeemSpreadKey(address token) internal pure returns (bytes32) {
        return keccak256(abi.encode(KEY_REDEEM_SPREAD_BPS, token));
    }

    function _setMintSpread(address token, uint256 bps) internal {
        vm.prank(dao);
        registry.setUint(_mintSpreadKey(token), bps);
    }

    function _setRedeemSpread(address token, uint256 bps) internal {
        vm.prank(dao);
        registry.setUint(_redeemSpreadKey(token), bps);
    }

    function _fundUserCollateral(uint256 amount) internal {
        collateralToken.mint(user, amount);
        vm.prank(user);
        collateralToken.approve(address(psm), amount);
    }

    // -------------------------------------------------------------
    // 1) Mint-Spreads: Fee=0, Spread>0 → Nettobetrag reduziert
    // -------------------------------------------------------------

    function testMintUsesPerTokenSpreadOnly() public {
        uint256 amountIn = 1_000e18;

        // Sicherstellen: Fees = 0
        vm.prank(dao);
        psm.setFees(0, 0);

        // 1 % Mint-Spread per Token setzen (Fee bleibt 0)
        _setMintSpread(address(collateralToken), 100); // 100 bps = 1 %

        _fundUserCollateral(amountIn);

        vm.prank(user);
        uint256 out = psm.swapTo1kUSD(
            address(collateralToken),
            amountIn,
            user,
            0,
            block.timestamp + 1 days
        );

        uint256 totalBps = 100; // fee(0) + spread(100)
        uint256 expectedNet = amountIn - (amountIn * totalBps) / 10_000;

        assertEq(out, expectedNet, "mint net out must honour per-token spread");
        assertEq(oneKUSD.balanceOf(user), expectedNet, "user 1kUSD balance mismatch (mint spread)");
    }

    // -------------------------------------------------------------
    // 2) Redeem-Spreads: Fee=0, Spread>0 → Nettobetrag reduziert
    // -------------------------------------------------------------

    function testRedeemUsesPerTokenSpreadOnly() public {
        uint256 amountIn = 1_000e18;

        // Sicherstellen: Fees = 0
        vm.prank(dao);
        psm.setFees(0, 0);

        // Phase 1: Mint ohne Fees/Spreads, um Vault zu befüllen
        _fundUserCollateral(amountIn);

        vm.prank(user);
        uint256 minted = psm.swapTo1kUSD(
            address(collateralToken),
            amountIn,
            user,
            0,
            block.timestamp + 1 days
        );

        // sanity: bei 0 fee + 0 spread sollte minted ≈ amountIn (Oracle Fallback 1:1, 18 Decimals)
        assertEq(minted, amountIn, "precondition: 1:1 mint without spreads");

        uint256 collBefore = collateralToken.balanceOf(user);

        // Phase 2: Nur Redeem-Spread aktiv (1 %), Fees bleiben 0
        _setRedeemSpread(address(collateralToken), 100); // 100 bps = 1 %

        vm.prank(user);
        uint256 out = psm.swapFrom1kUSD(
            address(collateralToken),
            minted,
            user,
            0,
            block.timestamp + 1 days
        );

        uint256 totalBps = 100;
        uint256 expectedNetTokenOut = minted - (minted * totalBps) / 10_000;

        assertEq(out, expectedNetTokenOut, "redeem net out must honour per-token redeem spread");
        assertEq(
            collateralToken.balanceOf(user) - collBefore,
            expectedNetTokenOut,
            "user collateral delta mismatch (redeem spread)"
        );
    }
}
SOL

echo "✓ PSMRegression_Spreads written to $FILE"
