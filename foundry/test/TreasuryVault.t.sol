// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

// Minimal vault mock
contract Vault {
    address public dao;
    event VaultSweep(address indexed token, address indexed to, uint256 amount);
    constructor(address _dao){ dao = _dao; }
    function sweep(address token, address to, uint256 amount) external {
        require(msg.sender == dao, "DAO_ONLY");
        emit VaultSweep(token, to, amount);
    }
}

contract TreasuryVaultTest is Test {
    Vault vault;
    address dao = address(0xD00);

    function setUp() public { vault = new Vault(dao); }

    function test_only_dao_can_sweep() public {
        vm.expectRevert(bytes("DAO_ONLY"));
        vault.sweep(address(0), address(this), 1);
        vm.prank(dao);
        vault.sweep(address(0), address(this), 1);
    }
}
