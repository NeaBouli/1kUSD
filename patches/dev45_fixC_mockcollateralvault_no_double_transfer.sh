#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/mocks/MockCollateralVault.sol"

echo "== DEV45 FIX C: remove internal transferFrom from MockCollateralVault.deposit =="

cat > "$FILE" <<'SOL'
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @notice Lightweight testing vault for DEV-45.
/// In den Regression-Tests übernimmt der PSM den echten ERC20-Transfer
/// direkt in dieses Vault. Die Vault selbst verwaltet nur das Accounting.
contract MockCollateralVault {
    mapping(address => uint256) public balances;

    function deposit(address asset, address from, uint256 amount) external {
        // PSM hat den Token bereits nach `address(this)` transferiert.
        // Wir buchen hier nur das Collateral auf.
        // Parameter bleiben für Interface-Kompatibilität erhalten.
        asset; from; // silence unused warnings
        balances[asset] += amount;
    }

    function withdraw(address asset, address to, uint256 amount, bytes32) external {
        balances[asset] -= amount;
        IERC20(asset).transfer(to, amount);
    }
}
SOL

echo "✓ MockCollateralVault.deposit no longer performs a second transferFrom"
