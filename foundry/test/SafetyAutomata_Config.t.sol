// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {SafetyAutomata} from "../../contracts/core/SafetyAutomata.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";

/// @title SafetyAutomata_Config
/// @notice Sprint 1 — misconfiguration tests for SafetyAutomata
///         Tests guardian sunset, pause/resume auth, role grants, state cycle.
contract SafetyAutomata_Config is Test {
    SafetyAutomata internal safety;

    address internal admin = address(this);
    address internal guardianAddr = address(0xCAFE);
    address internal daoAddr = address(0xDA0);
    address internal unauthorizedCaller = address(0xDEAD);

    bytes32 internal constant MODULE_ID = keccak256("TEST_MODULE");
    uint256 internal sunsetTimestamp;

    event Paused(bytes32 indexed moduleId, address indexed by);
    event Resumed(bytes32 indexed moduleId, address indexed by);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function setUp() public {
        vm.warp(1_700_000_000);
        sunsetTimestamp = block.timestamp + 365 days;
        safety = new SafetyAutomata(admin, sunsetTimestamp);
        safety.grantGuardian(guardianAddr);
    }

    // -----------------------------------------------------------------
    // Guardian sunset tests
    // -----------------------------------------------------------------

    function testPauseModule_GuardianBeforeSunset_Succeeds() public {
        vm.prank(guardianAddr);
        safety.pauseModule(MODULE_ID);
        assertTrue(safety.isPaused(MODULE_ID));
    }

    function testPauseModule_GuardianOneSecondBeforeSunset_Succeeds() public {
        vm.warp(sunsetTimestamp - 1);

        vm.prank(guardianAddr);
        safety.pauseModule(MODULE_ID);

        assertTrue(safety.isPaused(MODULE_ID));
    }

    function testPauseModule_GuardianAtSunset_Reverts() public {
        vm.warp(sunsetTimestamp);

        vm.prank(guardianAddr);
        vm.expectRevert(SafetyAutomata.GuardianExpired.selector);
        safety.pauseModule(MODULE_ID);
    }

    function testPauseModule_GuardianAfterSunset_Reverts() public {
        vm.warp(sunsetTimestamp + 1);

        vm.prank(guardianAddr);
        vm.expectRevert(SafetyAutomata.GuardianExpired.selector);
        safety.pauseModule(MODULE_ID);
    }

    function testResumeModule_GuardianBeforeSunset_Reverts() public {
        safety.pauseModule(MODULE_ID);

        vm.prank(guardianAddr);
        vm.expectRevert("ACCESS_DENIED");
        safety.resumeModule(MODULE_ID);
    }

    function testResumeModule_GuardianAfterSunset_Reverts() public {
        safety.pauseModule(MODULE_ID);
        vm.warp(sunsetTimestamp + 1);

        vm.prank(guardianAddr);
        vm.expectRevert("ACCESS_DENIED");
        safety.resumeModule(MODULE_ID);
    }

    // -----------------------------------------------------------------
    // Unauthorized pause/resume tests
    // -----------------------------------------------------------------

    function testPauseModule_Unauthorized_Reverts() public {
        vm.prank(unauthorizedCaller);
        vm.expectRevert("ACCESS_DENIED");
        safety.pauseModule(MODULE_ID);
    }

    function testResumeModule_Unauthorized_Reverts() public {
        // Pause first so resume is meaningful
        safety.pauseModule(MODULE_ID);

        vm.prank(unauthorizedCaller);
        vm.expectRevert("ACCESS_DENIED");
        safety.resumeModule(MODULE_ID);
    }

    // -----------------------------------------------------------------
    // Admin pause/resume succeeds
    // -----------------------------------------------------------------

    function testPauseModule_Admin_Succeeds() public {
        safety.pauseModule(MODULE_ID);
        assertTrue(safety.isPaused(MODULE_ID));
    }

    function testResumeModule_Admin_Succeeds() public {
        safety.pauseModule(MODULE_ID);
        assertTrue(safety.isPaused(MODULE_ID));

        safety.resumeModule(MODULE_ID);
        assertFalse(safety.isPaused(MODULE_ID));
    }

    function testPauseModule_AdminWithGuardianRole_AtSunset_Succeeds() public {
        vm.warp(sunsetTimestamp);

        vm.expectEmit(true, true, false, true, address(safety));
        emit Paused(MODULE_ID, admin);
        safety.pauseModule(MODULE_ID);

        assertTrue(safety.isPaused(MODULE_ID));
    }

    function testPauseModule_AdminWithGuardianRole_AfterSunset_Succeeds() public {
        vm.warp(sunsetTimestamp + 1);

        safety.pauseModule(MODULE_ID);

        assertTrue(safety.isPaused(MODULE_ID));
    }

    function testPauseModule_DaoOnly_AfterSunset_Succeeds() public {
        safety.grantRole(safety.DAO_ROLE(), daoAddr);
        vm.warp(sunsetTimestamp + 1);

        vm.prank(daoAddr);
        safety.pauseModule(MODULE_ID);

        assertTrue(safety.isPaused(MODULE_ID));
    }

    function testPauseModule_DaoWithGuardianRole_AfterSunset_Succeeds() public {
        safety.grantRole(safety.DAO_ROLE(), daoAddr);
        safety.grantGuardian(daoAddr);
        vm.warp(sunsetTimestamp + 1);

        vm.prank(daoAddr);
        safety.pauseModule(MODULE_ID);

        assertTrue(safety.isPaused(MODULE_ID));
    }

    function testResumeModule_DaoWithGuardianRole_AfterSunset_Succeeds() public {
        safety.grantRole(safety.DAO_ROLE(), daoAddr);
        safety.grantGuardian(daoAddr);
        safety.pauseModule(MODULE_ID);
        vm.warp(sunsetTimestamp + 1);

        vm.expectEmit(true, true, false, true, address(safety));
        emit Resumed(MODULE_ID, daoAddr);
        vm.prank(daoAddr);
        safety.resumeModule(MODULE_ID);

        assertFalse(safety.isPaused(MODULE_ID));
    }

    // -----------------------------------------------------------------
    // Guardian grant tests
    // -----------------------------------------------------------------

    function testGrantGuardian_NonAdmin_Reverts() public {
        bytes32 role = safety.ADMIN_ROLE();
        vm.prank(unauthorizedCaller);
        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector, unauthorizedCaller, role
            )
        );
        safety.grantGuardian(address(0x1234));
    }

    function testGrantGuardian_Admin_Succeeds() public {
        address newGuardian = address(0x1234);
        safety.grantGuardian(newGuardian);

        assertTrue(safety.hasGuardianRole(newGuardian));

        // New guardian can pause
        vm.prank(newGuardian);
        safety.pauseModule(MODULE_ID);
        assertTrue(safety.isPaused(MODULE_ID));
    }

    function testGrantGuardian_ZeroAddress_Reverts() public {
        vm.expectRevert(SafetyAutomata.ZeroAddress.selector);
        safety.grantGuardian(address(0));
    }

    function testGrantGuardian_DaoOnly_Reverts() public {
        safety.grantRole(safety.DAO_ROLE(), daoAddr);
        bytes32 adminRole = safety.ADMIN_ROLE();

        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector, daoAddr, adminRole
            )
        );
        vm.prank(daoAddr);
        safety.grantGuardian(address(0x1234));
    }

    function testRevokeGuardian_Admin_SucceedsImmediately() public {
        vm.expectEmit(true, true, true, true, address(safety));
        emit RoleRevoked(safety.GUARDIAN_ROLE(), guardianAddr, admin);
        safety.revokeGuardian(guardianAddr);

        assertFalse(safety.hasGuardianRole(guardianAddr));

        vm.prank(guardianAddr);
        vm.expectRevert("ACCESS_DENIED");
        safety.pauseModule(MODULE_ID);
    }

    function testRevokeGuardian_NonAdmin_Reverts() public {
        bytes32 adminRole = safety.ADMIN_ROLE();
        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector,
                unauthorizedCaller,
                adminRole
            )
        );
        vm.prank(unauthorizedCaller);
        safety.revokeGuardian(guardianAddr);
    }

    function testRevokeGuardian_ZeroAddress_Reverts() public {
        vm.expectRevert(SafetyAutomata.ZeroAddress.selector);
        safety.revokeGuardian(address(0));
    }

    // -----------------------------------------------------------------
    // State integrity tests
    // -----------------------------------------------------------------

    function testIsPaused_PauseResumeCycle() public {
        assertFalse(safety.isPaused(MODULE_ID));

        safety.pauseModule(MODULE_ID);
        assertTrue(safety.isPaused(MODULE_ID));

        safety.resumeModule(MODULE_ID);
        assertFalse(safety.isPaused(MODULE_ID));
    }
}
