// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title IVault — Collateral Vault (interface)
/// @notice Holds external ERC-20 assets; accounts balances and pending fees per asset.
interface IVault {
    /// @notice Deposit an asset into the vault (PSM or user path).
    function deposit(address asset, address from, uint256 amount) external;

    /// @notice Withdraw an asset from the vault (PSM redeem or treasury sweep).
    /// @param reason semantic tag (e.g., "PSM_REDEEM", "TREASURY_SPEND")
    function withdraw(address asset, address to, uint256 amount, bytes32 reason) external;

    /// @notice Current vault balance for an asset (token decimals).
    function balanceOf(address asset) external view returns (uint256);

    /// @notice Whether an asset is supported by the vault.
    function isAssetSupported(address asset) external view returns (bool);
}
