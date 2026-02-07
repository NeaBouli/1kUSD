// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./MockERC20.sol";

/// @notice Minimaler Test-Vault für PSM End-to-End-Regressionstests.
///         Er hält Collateral intern und führt deposit/withdraw real aus.
contract MockVault {
    mapping(address => uint256) public balances;

    function deposit(address asset, address from, uint256 amount) external {
        MockERC20(asset).transferFrom(from, address(this), amount);
        balances[asset] += amount;
    }

    function withdraw(address asset, address to, uint256 amount, bytes32) external {
        balances[asset] -= amount;
        MockERC20(asset).transfer(to, amount);
    }
}
