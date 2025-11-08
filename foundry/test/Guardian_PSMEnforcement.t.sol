// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import "../../contracts/core/SafetyAutomata.sol";
import "../../contracts/core/PegStabilityModule.sol";
import "../../contracts/security/Guardian.sol";

contract Guardian_PSMEnforcementTest is Test {
    SafetyAutomata internal safety;
    Guardian internal guardian;
    PegStabilityModule internal psm;

    address internal dao = address(0xdead);
    address internal oneKUSD = address(0x1111);
    address internal vault = address(0x2222);
    address internal reg   = address(0x3333);

    function setUp() public {
        guardian = new Guardian(dao, block.number + 100_000);
        safety = new SafetyAutomata(dao, block.timestamp + 10000);
        psm = new PegStabilityModule(dao, oneKUSD, vault, address(safety), reg);
    }

    function testPausedPSMBlocksSwap() public {
        bytes32 MODULE_PSM = keccak256("PSM");

        // ensure normal state
        assertFalse(safety.isPaused(MODULE_PSM));

        // pause PSM via guardian
        vm.prank(dao);
        safety.pauseModule(MODULE_PSM);
        assertTrue(safety.isPaused(MODULE_PSM));

        // expect revert when calling swapTo1kUSD while paused
        vm.expectRevert();
        psm.swapTo1kUSD(address(0xBEEF), 1000e18, address(this), 0, 18);
    }
}
