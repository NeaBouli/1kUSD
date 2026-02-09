// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {OneKUSD} from "../../contracts/core/OneKUSD.sol";

/// @title OneKUSD_Config
/// @notice Sprint 1 — misconfiguration tests for OneKUSD token
///         Tests mint/burn auth, pause gates, admin setters, zero-address guards.
contract OneKUSD_Config is Test {
    OneKUSD internal oneKUSD;

    address internal admin = address(this);
    address internal minter = address(0xCAFE);
    address internal burner = address(0xBBBB);
    address internal user = address(0xBEEF);
    address internal unauthorizedCaller = address(0xDEAD);

    function setUp() public {
        oneKUSD = new OneKUSD(admin);

        // Configure roles
        oneKUSD.setMinter(minter, true);
        oneKUSD.setBurner(burner, true);

        // Mint tokens to user for burn/transfer tests
        oneKUSD.setMinter(admin, true);
        oneKUSD.mint(user, 1000e18);
        oneKUSD.setMinter(admin, false);
    }

    // -----------------------------------------------------------------
    // Unauthorized mint/burn tests
    // -----------------------------------------------------------------

    function testMint_NonMinter_Reverts() public {
        vm.prank(unauthorizedCaller);
        vm.expectRevert(OneKUSD.ACCESS_DENIED.selector);
        oneKUSD.mint(user, 1e18);
    }

    function testBurn_NonBurner_Reverts() public {
        vm.prank(unauthorizedCaller);
        vm.expectRevert(OneKUSD.ACCESS_DENIED.selector);
        oneKUSD.burn(user, 1e18);
    }

    // -----------------------------------------------------------------
    // Paused state tests
    // -----------------------------------------------------------------

    function testMint_WhenPaused_Reverts() public {
        oneKUSD.pause();

        vm.prank(minter);
        vm.expectRevert(OneKUSD.PAUSED.selector);
        oneKUSD.mint(user, 1e18);
    }

    function testBurn_WhenPaused_Reverts() public {
        oneKUSD.pause();

        vm.prank(burner);
        vm.expectRevert(OneKUSD.PAUSED.selector);
        oneKUSD.burn(user, 1e18);
    }

    function testTransfer_WhenPaused_Succeeds() public {
        oneKUSD.pause();

        // Transfers are never paused
        vm.prank(user);
        oneKUSD.transfer(unauthorizedCaller, 10e18);
        assertEq(oneKUSD.balanceOf(unauthorizedCaller), 10e18);
    }

    // -----------------------------------------------------------------
    // Non-admin config setter tests
    // -----------------------------------------------------------------

    function testSetMinter_NonAdmin_Reverts() public {
        vm.prank(unauthorizedCaller);
        vm.expectRevert(OneKUSD.ACCESS_DENIED.selector);
        oneKUSD.setMinter(address(0x1234), true);
    }

    function testSetBurner_NonAdmin_Reverts() public {
        vm.prank(unauthorizedCaller);
        vm.expectRevert(OneKUSD.ACCESS_DENIED.selector);
        oneKUSD.setBurner(address(0x1234), true);
    }

    function testSetAdmin_NonAdmin_Reverts() public {
        vm.prank(unauthorizedCaller);
        vm.expectRevert(OneKUSD.ACCESS_DENIED.selector);
        oneKUSD.setAdmin(unauthorizedCaller);
    }

    function testPause_NonAdmin_Reverts() public {
        vm.prank(unauthorizedCaller);
        vm.expectRevert(OneKUSD.ACCESS_DENIED.selector);
        oneKUSD.pause();
    }

    function testUnpause_NonAdmin_Reverts() public {
        oneKUSD.pause();

        vm.prank(unauthorizedCaller);
        vm.expectRevert(OneKUSD.ACCESS_DENIED.selector);
        oneKUSD.unpause();
    }

    // -----------------------------------------------------------------
    // Zero address validation tests
    // -----------------------------------------------------------------

    function testSetMinter_ZeroAddress_Reverts() public {
        vm.expectRevert(OneKUSD.ZERO_ADDRESS.selector);
        oneKUSD.setMinter(address(0), true);
    }

    function testMint_ZeroRecipient_Reverts() public {
        vm.prank(minter);
        vm.expectRevert(OneKUSD.ZERO_ADDRESS.selector);
        oneKUSD.mint(address(0), 1e18);
    }

    // -----------------------------------------------------------------
    // Positive path and balance guard tests
    // -----------------------------------------------------------------

    function testMint_AuthorizedMinter_Succeeds() public {
        uint256 balBefore = oneKUSD.balanceOf(user);

        vm.prank(minter);
        oneKUSD.mint(user, 100e18);

        assertEq(oneKUSD.balanceOf(user) - balBefore, 100e18);
    }

    function testBurn_InsufficientBalance_Reverts() public {
        // User has 1000e18, try to burn 2000e18
        vm.prank(burner);
        vm.expectRevert(OneKUSD.INSUFFICIENT_BALANCE.selector);
        oneKUSD.burn(user, 2000e18);
    }
}
