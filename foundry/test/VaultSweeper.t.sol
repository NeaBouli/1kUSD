// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../contracts/vault/VaultSweeper.sol";

contract VaultSweeperTest is Test {
    VaultSweeper sweeper;
    address dao = address(0xDA0);
    address token = address(0xCAFE);
    address receiver = address(0xBEEF);

    // Dummy ERC20 simulation
    mapping(address => uint256) internal balances;

    event VaultSwept(address indexed token, uint256 amount, address indexed to);
    event CollateralWhitelisted(address indexed token, bool allowed);

    function setUp() public {
        sweeper = new VaultSweeper(dao);
    }

    function testOnlyDAOCanSweep() public {
        vm.expectRevert("not DAO");
        sweeper.sweep(token, 10, receiver);
    }

    function testDAOCanSweepEmitsEvent() public {
        vm.prank(dao);
        vm.expectEmit(true, true, true, true);
        emit VaultSwept(token, 10, receiver);
        sweeper.sweep(token, 10, receiver);
    }

    function testZeroAmountReverts() public {
        vm.prank(dao);
        vm.expectRevert("amount=0");
        sweeper.sweep(token, 0, receiver);
    }

    function testProtectedCollateralReverts() public {
        vm.prank(dao);
        sweeper.setCollateralWhitelist(token, true);
        vm.prank(dao);
        vm.expectRevert("protected");
        sweeper.sweep(token, 5, receiver);
    }

    function testWhitelistToggleEvent() public {
        vm.prank(dao);
        vm.expectEmit(true, false, false, true);
        emit CollateralWhitelisted(token, true);
        sweeper.setCollateralWhitelist(token, true);
    }
}
