// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title IVault — custody for stable reserves with protocol-scoped reasons
interface IVault {
    function deposit(address asset, address from, uint256 amount) external;
    function withdraw(address asset, address to, uint256 amount, bytes32 reason) external;

    function balanceOf(address asset) external view returns (uint256);
    function isAssetSupported(address asset) external view returns (bool);
}
