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
    address internal unauthorizedCaller = address(0xDEAD);

    bytes32 internal constant MODULE_ID = keccak256("TEST_MODULE");
    uint256 internal sunsetTimestamp;

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

    function testPauseModule_GuardianAfterSunset_Reverts() public {
        vm.warp(sunsetTimestamp);

        vm.prank(guardianAddr);
        vm.expectRevert(SafetyAutomata.GuardianExpired.selector);
        safety.pauseModule(MODULE_ID);
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

    // -----------------------------------------------------------------
    // Guardian grant tests
    // -----------------------------------------------------------------

    function testGrantGuardian_NonAdmin_Reverts() public {
        bytes32 role = safety.ADMIN_ROLE();
        vm.prank(unauthorizedCaller);
        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector,
                unauthorizedCaller,
                role
            )
        );
        safety.grantGuardian(address(0x1234));
    }

    function testGrantGuardian_Admin_Succeeds() public {
        address newGuardian = address(0x1234);
        safety.grantGuardian(newGuardian);

        // New guardian can pause
        vm.prank(newGuardian);
        safety.pauseModule(MODULE_ID);
        assertTrue(safety.isPaused(MODULE_ID));
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
