// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {ParameterRegistry} from "../../contracts/core/ParameterRegistry.sol";

/// @title ParameterRegistry_Config
/// @notice Sprint 1 — misconfiguration tests for ParameterRegistry
///         Tests admin-only setters and zero-address guard.
contract ParameterRegistry_Config is Test {
    ParameterRegistry internal registry;

    address internal admin = address(this);
    address internal unauthorizedCaller = address(0xDEAD);

    bytes32 internal constant TEST_KEY = keccak256("test:param");

    function setUp() public {
        registry = new ParameterRegistry(admin);
    }

    // -----------------------------------------------------------------
    // Non-admin setter tests
    // -----------------------------------------------------------------

    function testSetUint_NonAdmin_Reverts() public {
        vm.prank(unauthorizedCaller);
        vm.expectRevert(ParameterRegistry.ACCESS_DENIED.selector);
        registry.setUint(TEST_KEY, 42);
    }

    function testSetAddress_NonAdmin_Reverts() public {
        vm.prank(unauthorizedCaller);
        vm.expectRevert(ParameterRegistry.ACCESS_DENIED.selector);
        registry.setAddress(TEST_KEY, address(0x1234));
    }

    function testSetBool_NonAdmin_Reverts() public {
        vm.prank(unauthorizedCaller);
        vm.expectRevert(ParameterRegistry.ACCESS_DENIED.selector);
        registry.setBool(TEST_KEY, true);
    }

    function testSetAdmin_NonAdmin_Reverts() public {
        vm.prank(unauthorizedCaller);
        vm.expectRevert(ParameterRegistry.ACCESS_DENIED.selector);
        registry.setAdmin(address(0x1234));
    }

    // -----------------------------------------------------------------
    // Zero address validation
    // -----------------------------------------------------------------

    function testSetAdmin_ZeroAddress_Reverts() public {
        vm.expectRevert(ParameterRegistry.ZERO_ADDRESS.selector);
        registry.setAdmin(address(0));
    }

    // -----------------------------------------------------------------
    // Admin setter succeeds + readback
    // -----------------------------------------------------------------

    function testSetUint_Admin_Succeeds() public {
        registry.setUint(TEST_KEY, 42);
        assertEq(registry.getUint(TEST_KEY), 42);
    }

    function testSetAddress_Admin_Succeeds() public {
        address val = address(0x1234);
        registry.setAddress(TEST_KEY, val);
        assertEq(registry.getAddress(TEST_KEY), val);
    }

    function testSetBool_Admin_Succeeds() public {
        registry.setBool(TEST_KEY, true);
        assertTrue(registry.getBool(TEST_KEY));
    }
}
