// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {TreasuryVault} from "../contracts/core/TreasuryVault.sol";
import {MockERC20} from "./mocks/MockERC20.sol";

contract TreasuryVaultTest is Test {
    TreasuryVault vault;
    MockERC20 token;

    address admin  = address(0xA11CE);
    address dao    = address(0xDA0);
    address user   = address(0xBEEF);
    address sink   = address(0xFEE);

    function setUp() public {
        vault = new TreasuryVault(admin);
        token = new MockERC20("Mock", "MOCK");

        token.mint(address(vault), 10_000e18);

        vm.label(admin, "ADMIN");
        vm.label(dao, "DAO");
        vm.label(user, "USER");
        vm.label(sink, "SINK");
        vm.label(address(vault), "TREASURY");
        vm.label(address(token), "TOKEN");

        // Admin gewährt DAO-Role an dao
        vm.startPrank(admin);
        vault.grantRole(vault.DAO_ROLE(), dao);
        vm.stopPrank();
    }

    function test_sweep_requires_DAO_ROLE() public {
        // USER hat keine DAO_ROLE
        bytes32 role = vault.DAO_ROLE();

        vm.expectRevert(abi.encodeWithSignature(
            "AccessControlUnauthorizedAccount(address,bytes32)", user, role
        ));
        vm.prank(user);
        vault.sweep(address(token), sink, 1e18);
    }

    function test_sweep_transfers_and_emits() public {
        uint256 beforeSink = token.balanceOf(sink);
        uint256 amount = 777e18;

        vm.expectEmit(true, true, true, true);
        emit TreasuryVault.Swept(address(token), sink, amount);

        vm.prank(dao);
        vault.sweep(address(token), sink, amount);

        assertEq(token.balanceOf(sink), beforeSink + amount, "sink should receive amount");
        assertEq(token.balanceOf(address(vault)), 10_000e18 - amount, "vault decreased");
    }
}
