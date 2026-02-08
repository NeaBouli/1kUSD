// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {PSMLimits} from "../../contracts/psm/PSMLimits.sol";

/// @title PSMLimits_Auth
/// @notice P1 Remediation: misconfiguration tests for PSMLimits
///         Tests exact revert reasons for unauthorized callers and DAO-only setters.
contract PSMLimits_Auth is Test {
    PSMLimits internal limits;

    address internal daoAddr = address(this);
    address internal authorizedCaller = address(0xCAFE);
    address internal unauthorizedCaller = address(0xDEAD);

    function setUp() public {
        limits = new PSMLimits(daoAddr, 1_000_000e18, 100_000e18);
        limits.setAuthorizedCaller(authorizedCaller, true);
    }

    // -----------------------------------------------------------------
    // checkAndUpdate authorization tests
    // -----------------------------------------------------------------

    function testCheckAndUpdate_UnauthorizedCaller_Reverts() public {
        vm.prank(unauthorizedCaller);
        vm.expectRevert(PSMLimits.NOT_AUTHORIZED.selector);
        limits.checkAndUpdate(1e18);
    }

    function testCheckAndUpdate_AuthorizedCaller_Succeeds() public {
        vm.prank(authorizedCaller);
        limits.checkAndUpdate(1e18);
        assertEq(limits.dailyVolumeView(), 1e18);
    }

    function testCheckAndUpdate_DAOCanCall_WithoutWhitelist() public {
        // DAO is not in authorizedCallers but should pass via fallback
        assertFalse(limits.authorizedCallers(daoAddr));
        limits.checkAndUpdate(1e18);
        assertEq(limits.dailyVolumeView(), 1e18);
    }

    // -----------------------------------------------------------------
    // DAO-only setter tests
    // -----------------------------------------------------------------

    function testSetAuthorizedCaller_NonDAO_Reverts() public {
        vm.prank(unauthorizedCaller);
        vm.expectRevert("not DAO");
        limits.setAuthorizedCaller(address(0x1234), true);
    }

    function testSetLimits_NonDAO_Reverts() public {
        vm.prank(unauthorizedCaller);
        vm.expectRevert("not DAO");
        limits.setLimits(500e18, 100e18);
    }

    function testSetAuthorizedCaller_DAO_Succeeds() public {
        address newCaller = address(0x1234);
        limits.setAuthorizedCaller(newCaller, true);
        assertTrue(limits.authorizedCallers(newCaller));
    }

    // -----------------------------------------------------------------
    // Revoke authorization tests
    // -----------------------------------------------------------------

    function testCheckAndUpdate_AfterRevokeAuth_Reverts() public {
        limits.setAuthorizedCaller(authorizedCaller, false);

        vm.prank(authorizedCaller);
        vm.expectRevert(PSMLimits.NOT_AUTHORIZED.selector);
        limits.checkAndUpdate(1e18);
    }
}
