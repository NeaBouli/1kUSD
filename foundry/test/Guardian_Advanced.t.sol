// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import {SafetyAutomata} from "../../contracts/core/SafetyAutomata.sol";
import {Guardian} from "../../contracts/security/Guardian.sol";

contract Guardian_AdvancedTest is Test {
    SafetyAutomata internal safety;
    Guardian internal guardian;

    address internal admin = makeAddr("admin");
    address internal dao = makeAddr("dao");
    address internal stranger = makeAddr("stranger");
    uint256 internal sunset;

    function setUp() public {
        sunset = block.timestamp + 30 days;

        vm.prank(admin);
        safety = new SafetyAutomata(admin, sunset);
        guardian = new Guardian(dao, sunset);
    }

    function testSetSafetyAutomata_Dao_Succeeds() public {
        vm.prank(dao);
        guardian.setSafetyAutomata(safety);

        assertEq(address(guardian.safety()), address(safety));
    }

    function testSetSafetyAutomata_NonDao_Reverts() public {
        vm.prank(stranger);
        vm.expectRevert(Guardian.NotDAO.selector);
        guardian.setSafetyAutomata(safety);
    }

    function testSetSafetyAutomata_ZeroAddress_Reverts() public {
        vm.prank(dao);
        vm.expectRevert(Guardian.ZeroAddress.selector);
        guardian.setSafetyAutomata(SafetyAutomata(address(0)));
    }

    function testSetSafetyAutomata_SunsetMismatch_Reverts() public {
        vm.prank(admin);
        SafetyAutomata mismatchedSafety = new SafetyAutomata(admin, sunset + 1);

        vm.prank(dao);
        vm.expectRevert(Guardian.SunsetMismatch.selector);
        guardian.setSafetyAutomata(mismatchedSafety);
    }

    function testLegacySelfRegisterCannotEscalate() public {
        vm.prank(dao);
        guardian.setSafetyAutomata(safety);

        vm.prank(dao);
        vm.expectRevert(Guardian.GuardianNotRegistered.selector);
        guardian.selfRegister();

        assertFalse(safety.hasGuardianRole(address(guardian)));
    }

    function testLegacySelfRegisterValidatesDirectRegistration() public {
        vm.prank(dao);
        guardian.setSafetyAutomata(safety);

        vm.prank(admin);
        safety.grantGuardian(address(guardian));

        vm.prank(dao);
        guardian.selfRegister();

        assertTrue(safety.hasGuardianRole(address(guardian)));
    }

    function testLegacyResumeRequiresDirectSafetyCall() public {
        vm.prank(dao);
        guardian.setSafetyAutomata(safety);

        vm.prank(dao);
        vm.expectRevert(Guardian.DirectResumeRequired.selector);
        guardian.resumeOracle();
    }

    function testLegacyResumeWithoutSafety_Reverts() public {
        vm.prank(dao);
        vm.expectRevert(Guardian.SafetyNotSet.selector);
        guardian.resumeOracle();
    }
}
