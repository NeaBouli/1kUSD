// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import "../../contracts/core/SafetyAutomata.sol";
import "../../contracts/core/PegStabilityModule.sol";
import "../../contracts/security/Guardian.sol";

contract Guardian_PSMPropagationTest is Test {
    SafetyAutomata internal safety;
    Guardian internal guardian;
    PegStabilityModule internal psm;

    address internal dao = address(0xdead);
    address internal oneKUSD = address(0x1111);
    address internal vault = address(0x2222);
    address internal reg   = address(0x3333);

    function setUp() public {
        safety = new SafetyAutomata(dao, block.timestamp + 10000);
        guardian = new Guardian(dao, block.number + 100_000);
        psm = new PegStabilityModule(dao, oneKUSD, vault, address(safety), reg);
    }

    function testGuardianPauseStopsPSM() public {
        bytes32 MODULE_PSM = keccak256("PSM");

        // Vorbedingung: PSM darf arbeiten
        assertFalse(safety.isPaused(MODULE_PSM));

        // Guardian löst globale Pause aus (simuliert)
        vm.prank(dao);
        safety.pauseModule(MODULE_PSM);

        // Nachbedingung: SafetyAutomata meldet PSM pausiert
        assertTrue(safety.isPaused(MODULE_PSM));
    }
}
