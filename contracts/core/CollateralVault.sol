// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @notice Empty stub — see COLLATERAL_VAULT_SPEC.md for future implementation.
contract CollateralVault {
    event Deposit(address indexed asset, address indexed from, uint256 amount);
    event Withdraw(address indexed asset, address indexed to, uint256 amount, bytes32 reason);
    // NOTE: Intentionally no state or logic in DEV29.
}
