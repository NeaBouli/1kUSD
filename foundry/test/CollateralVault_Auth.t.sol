// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {CollateralVault} from "../../contracts/core/CollateralVault.sol";
import {SafetyAutomata} from "../../contracts/core/SafetyAutomata.sol";
import {ParameterRegistry} from "../../contracts/core/ParameterRegistry.sol";
import {MockERC20} from "./mocks/MockERC20.sol";

/// @title CollateralVault_Auth
/// @notice P1 Remediation: misconfiguration tests for CollateralVault
///         Tests exact revert reasons for unauthorized, unsupported, paused, and insufficient balance.
contract CollateralVault_Auth is Test {
    CollateralVault internal vault;
    SafetyAutomata internal safety;
    ParameterRegistry internal registry;
    MockERC20 internal token;

    address internal admin = address(this);
    address internal authorizedCaller = address(0xCAFE);
    address internal unauthorizedCaller = address(0xDEAD);
    address internal user = address(0xBEEF);

    function setUp() public {
        // Deploy real contracts — no mocks for auth-critical paths
        safety = new SafetyAutomata(admin, block.timestamp + 365 days);
        registry = new ParameterRegistry(admin);
        vault = new CollateralVault(admin, safety, registry);
        token = new MockERC20("USDC", "USDC");

        // Configure: support token + authorize one caller
        vault.setAssetSupported(address(token), true);
        vault.setAuthorizedCaller(authorizedCaller, true);

        // Fund the token to authorized caller for deposit tests
        token.mint(authorizedCaller, 100e18);
        vm.prank(authorizedCaller);
        token.approve(address(vault), type(uint256).max);

        // Also fund vault directly for withdraw tests
        token.mint(address(vault), 50e18);
        // Record the deposit in vault accounting via authorized caller
        vm.prank(authorizedCaller);
        vault.deposit(address(token), authorizedCaller, 50e18);
    }

    // -----------------------------------------------------------------
    // Unauthorized caller tests
    // -----------------------------------------------------------------

    function testDeposit_UnauthorizedCaller_Reverts() public {
        vm.prank(unauthorizedCaller);
        vm.expectRevert(CollateralVault.NOT_AUTHORIZED.selector);
        vault.deposit(address(token), unauthorizedCaller, 1e18);
    }

    function testWithdraw_UnauthorizedCaller_Reverts() public {
        vm.prank(unauthorizedCaller);
        vm.expectRevert(CollateralVault.NOT_AUTHORIZED.selector);
        vault.withdraw(address(token), unauthorizedCaller, 1e18, bytes32("TEST"));
    }

    function testDeposit_AuthorizedCaller_Succeeds() public {
        token.mint(authorizedCaller, 10e18);
        vm.prank(authorizedCaller);
        token.transfer(address(vault), 10e18);

        vm.prank(authorizedCaller);
        vault.deposit(address(token), authorizedCaller, 10e18);
        assertEq(vault.balanceOf(address(token)), 60e18);
    }

    function testWithdraw_AuthorizedCaller_Succeeds() public {
        uint256 balBefore = token.balanceOf(user);
        vm.prank(authorizedCaller);
        vault.withdraw(address(token), user, 5e18, bytes32("TEST"));
        assertEq(token.balanceOf(user) - balBefore, 5e18);
    }

    function testDeposit_AdminCanCall_WithoutWhitelist() public {
        // Admin is not in authorizedCallers but should pass via fallback
        assertFalse(vault.authorizedCallers(admin));
        token.mint(admin, 10e18);
        token.transfer(address(vault), 10e18);
        vault.deposit(address(token), admin, 10e18);
        assertEq(vault.balanceOf(address(token)), 60e18);
    }

    function testWithdraw_AdminCanCall_WithoutWhitelist() public {
        assertFalse(vault.authorizedCallers(admin));
        vault.withdraw(address(token), user, 5e18, bytes32("ADMIN"));
        assertEq(token.balanceOf(user), 5e18);
    }

    // -----------------------------------------------------------------
    // Unsupported asset tests
    // -----------------------------------------------------------------

    function testDeposit_UnsupportedAsset_Reverts() public {
        MockERC20 unsupported = new MockERC20("BAD", "BAD");
        vm.prank(authorizedCaller);
        vm.expectRevert(CollateralVault.ASSET_NOT_SUPPORTED.selector);
        vault.deposit(address(unsupported), authorizedCaller, 1e18);
    }

    function testWithdraw_UnsupportedAsset_Reverts() public {
        MockERC20 unsupported = new MockERC20("BAD", "BAD");
        vm.prank(authorizedCaller);
        vm.expectRevert(CollateralVault.ASSET_NOT_SUPPORTED.selector);
        vault.withdraw(address(unsupported), user, 1e18, bytes32("TEST"));
    }

    function testDeposit_AssetRemovedAfterSupport_Reverts() public {
        // Remove support for previously supported token
        vault.setAssetSupported(address(token), false);

        vm.prank(authorizedCaller);
        vm.expectRevert(CollateralVault.ASSET_NOT_SUPPORTED.selector);
        vault.deposit(address(token), authorizedCaller, 1e18);
    }

    // -----------------------------------------------------------------
    // Paused module tests
    // -----------------------------------------------------------------

    function testDeposit_WhenPaused_Reverts() public {
        // Pause VAULT module via SafetyAutomata
        safety.pauseModule(keccak256("VAULT"));

        token.mint(authorizedCaller, 10e18);
        vm.prank(authorizedCaller);
        vm.expectRevert(CollateralVault.PAUSED.selector);
        vault.deposit(address(token), authorizedCaller, 10e18);
    }

    function testWithdraw_WhenPaused_Reverts() public {
        safety.pauseModule(keccak256("VAULT"));

        vm.prank(authorizedCaller);
        vm.expectRevert(CollateralVault.PAUSED.selector);
        vault.withdraw(address(token), user, 1e18, bytes32("TEST"));
    }

    function testDeposit_AfterResume_Succeeds() public {
        safety.pauseModule(keccak256("VAULT"));
        safety.resumeModule(keccak256("VAULT"));

        token.mint(authorizedCaller, 10e18);
        vm.prank(authorizedCaller);
        token.transfer(address(vault), 10e18);

        vm.prank(authorizedCaller);
        vault.deposit(address(token), authorizedCaller, 10e18);
        assertEq(vault.balanceOf(address(token)), 60e18);
    }

    // -----------------------------------------------------------------
    // Insufficient balance tests
    // -----------------------------------------------------------------

    function testWithdraw_InsufficientBalance_Reverts() public {
        // Vault has 50e18 recorded balance, try to withdraw 100e18
        vm.prank(authorizedCaller);
        vm.expectRevert(CollateralVault.INSUFFICIENT_VAULT_BALANCE.selector);
        vault.withdraw(address(token), user, 100e18, bytes32("TEST"));
    }

    function testWithdraw_ExactBalance_Succeeds() public {
        vm.prank(authorizedCaller);
        vault.withdraw(address(token), user, 50e18, bytes32("TEST"));
        assertEq(vault.balanceOf(address(token)), 0);
        assertEq(token.balanceOf(user), 50e18);
    }

    // -----------------------------------------------------------------
    // Admin config tests
    // -----------------------------------------------------------------

    function testSetAuthorizedCaller_NonAdmin_Reverts() public {
        vm.prank(unauthorizedCaller);
        vm.expectRevert(CollateralVault.ACCESS_DENIED.selector);
        vault.setAuthorizedCaller(address(0x1234), true);
    }

    function testSetAssetSupported_NonAdmin_Reverts() public {
        vm.prank(unauthorizedCaller);
        vm.expectRevert(CollateralVault.ACCESS_DENIED.selector);
        vault.setAssetSupported(address(0x1234), true);
    }

    function testSetAuthorizedCaller_ZeroAddress_Reverts() public {
        vm.expectRevert(CollateralVault.ZERO_ADDRESS.selector);
        vault.setAuthorizedCaller(address(0), true);
    }

    function testSetAssetSupported_ZeroAddress_Reverts() public {
        vm.expectRevert(CollateralVault.ZERO_ADDRESS.selector);
        vault.setAssetSupported(address(0), true);
    }

    // -----------------------------------------------------------------
    // Revoke authorization tests
    // -----------------------------------------------------------------

    function testDeposit_AfterRevokeAuth_Reverts() public {
        vault.setAuthorizedCaller(authorizedCaller, false);

        vm.prank(authorizedCaller);
        vm.expectRevert(CollateralVault.NOT_AUTHORIZED.selector);
        vault.deposit(address(token), authorizedCaller, 1e18);
    }
}
