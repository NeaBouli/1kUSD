// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MockCollateralVault {
    mapping(address => uint256) public balances;

    function deposit(address asset, address from, uint256 amount) external {
        IERC20(asset).transferFrom(from, address(this), amount);
        balances[asset] += amount;
    }

    function withdraw(address asset, address to, uint256 amount, bytes32) external {
        balances[asset] -= amount;
        IERC20(asset).transfer(to, amount);
    }
}
