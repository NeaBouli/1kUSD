// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import {SafetyAutomata} from "../../contracts/core/SafetyAutomata.sol";
import {Guardian} from "../../contracts/security/Guardian.sol";

contract Guardian_IntegrationTest is Test {
    SafetyAutomata internal safety;
    Guardian internal guardian;

    address internal admin = makeAddr("admin");
    address internal dao = makeAddr("dao");
    address internal firstOperator = makeAddr("firstOperator");
    address internal secondOperator = makeAddr("secondOperator");
    bytes32 internal constant ORACLE_MODULE = keccak256("ORACLE");
    uint256 internal sunset;

    function setUp() public {
        sunset = block.timestamp + 30 days;

        vm.prank(admin);
        safety = new SafetyAutomata(admin, sunset);
        guardian = new Guardian(dao, sunset);

        vm.startPrank(dao);
        guardian.setSafetyAutomata(safety);
        guardian.setOperator(firstOperator);
        vm.stopPrank();

        vm.startPrank(admin);
        safety.grantRole(safety.DAO_ROLE(), dao);
        safety.grantGuardian(address(guardian));
        vm.stopPrank();
    }

    function testRoleMatrixAndDirectResumeLifecycle() public {
        assertTrue(safety.hasGuardianRole(address(guardian)));
        assertFalse(safety.hasRole(safety.ADMIN_ROLE(), address(guardian)));
        assertFalse(safety.hasRole(safety.DAO_ROLE(), address(guardian)));

        vm.prank(firstOperator);
        guardian.pauseOracle();
        assertTrue(safety.isPaused(ORACLE_MODULE));

        vm.prank(dao);
        safety.resumeModule(ORACLE_MODULE);
        assertFalse(safety.isPaused(ORACLE_MODULE));
    }

    function testOperatorRotationRevokesOldOperator() public {
        vm.prank(dao);
        guardian.setOperator(secondOperator);

        vm.prank(firstOperator);
        vm.expectRevert(Guardian.NotOperator.selector);
        guardian.pauseOracle();

        vm.prank(secondOperator);
        guardian.pauseOracle();
        assertTrue(safety.isPaused(ORACLE_MODULE));
    }

    function testRevocationStopsPauseBeforeSunset() public {
        vm.prank(admin);
        safety.revokeGuardian(address(guardian));

        vm.prank(firstOperator);
        vm.expectRevert("ACCESS_DENIED");
        guardian.pauseOracle();
    }

    function testGuardianPauseOneSecondBeforeSunsetSucceeds() public {
        vm.warp(sunset - 1);

        vm.prank(firstOperator);
        guardian.pauseOracle();

        assertTrue(safety.isPaused(ORACLE_MODULE));
    }

    function testGuardianPauseAtSunsetRevertsButDaoStillOperates() public {
        vm.warp(sunset);

        vm.prank(firstOperator);
        vm.expectRevert(Guardian.GuardianExpired.selector);
        guardian.pauseOracle();

        vm.prank(dao);
        safety.pauseModule(ORACLE_MODULE);
        assertTrue(safety.isPaused(ORACLE_MODULE));

        vm.prank(dao);
        safety.resumeModule(ORACLE_MODULE);
        assertFalse(safety.isPaused(ORACLE_MODULE));
    }
}
