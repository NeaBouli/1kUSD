// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface ICollateralVault {
    function isSupportedAsset(address asset) external view returns (bool);
    function addSupportedAsset(address asset) external;
    function deposit(address asset, address from, uint256 amount) external;
    function withdraw(address asset, address to, uint256 amount) external;
}
