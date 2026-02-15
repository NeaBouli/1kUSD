// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {SafetyAutomata} from "../../contracts/core/SafetyAutomata.sol";

/// @title SafetyAutomataHandler
/// @notice Stateful fuzzing handler for SafetyAutomata. Exercises pause/resume
///         across admin, guardian, and DAO roles with time warps past sunset.
contract SafetyAutomataHandler is Test {
    SafetyAutomata public safety;
    address public admin;
    address public guardian;
    address public daoRole;

    bytes32[] public moduleIds;

    // Ghost state
    mapping(bytes32 => bool) public ghost_paused;
    uint256 public ghost_pauseCount;
    uint256 public ghost_resumeCount;
    uint256 public ghost_guardianPausedAfterSunset;

    constructor(
        SafetyAutomata _safety,
        address _admin,
        address _guardian,
        address _daoRole,
        bytes32[] memory _moduleIds
    ) {
        safety = _safety;
        admin = _admin;
        guardian = _guardian;
        daoRole = _daoRole;
        moduleIds = _moduleIds;
    }

    /// @notice Admin pauses a random module.
    function adminPause(uint256 moduleIdx) public {
        moduleIdx = bound(moduleIdx, 0, moduleIds.length - 1);
        bytes32 modId = moduleIds[moduleIdx];
        vm.prank(admin);
        safety.pauseModule(modId);
        ghost_paused[modId] = true;
        ghost_pauseCount += 1;
    }

    /// @notice Guardian attempts to pause a random module (may fail after sunset).
    function guardianPause(uint256 moduleIdx) public {
        moduleIdx = bound(moduleIdx, 0, moduleIds.length - 1);
        bytes32 modId = moduleIds[moduleIdx];

        vm.prank(guardian);
        try safety.pauseModule(modId) {
            ghost_paused[modId] = true;
            ghost_pauseCount += 1;
            if (block.timestamp >= safety.guardianSunset()) {
                ghost_guardianPausedAfterSunset += 1;
            }
        } catch {
            // Expected: GuardianExpired after sunset
        }
    }

    /// @notice Admin resumes a random module.
    function adminResume(uint256 moduleIdx) public {
        moduleIdx = bound(moduleIdx, 0, moduleIds.length - 1);
        bytes32 modId = moduleIds[moduleIdx];
        vm.prank(admin);
        safety.resumeModule(modId);
        ghost_paused[modId] = false;
        ghost_resumeCount += 1;
    }

    /// @notice DAO resumes a random module.
    function daoResume(uint256 moduleIdx) public {
        moduleIdx = bound(moduleIdx, 0, moduleIds.length - 1);
        bytes32 modId = moduleIds[moduleIdx];
        vm.prank(daoRole);
        safety.resumeModule(modId);
        ghost_paused[modId] = false;
        ghost_resumeCount += 1;
    }

    /// @notice Advance time (may cross guardian sunset boundary).
    function warpTime(uint256 seconds_) public {
        seconds_ = bound(seconds_, 1, 730 days);
        vm.warp(block.timestamp + seconds_);
    }
}

/// @title SafetyAutomata_Invariant
/// @notice Foundry invariant test suite for SafetyAutomata.
///         Verifies pause/resume state machine, guardian sunset enforcement,
///         and isPaused/isModuleEnabled complementarity.
contract SafetyAutomata_Invariant is Test {
    SafetyAutomata internal safety;
    SafetyAutomataHandler internal handler;

    address internal admin = address(this);
    address internal guardianAddr = address(0xCAFE);
    address internal daoAddr = address(0xDA0);

    bytes32 internal constant MOD_A = keccak256("MODULE_A");
    bytes32 internal constant MOD_B = keccak256("MODULE_B");
    bytes32 internal constant MOD_C = keccak256("MODULE_C");

    function setUp() public {
        vm.warp(1_700_000_000);
        uint256 sunsetTimestamp = block.timestamp + 365 days;
        safety = new SafetyAutomata(admin, sunsetTimestamp);
        safety.grantGuardian(guardianAddr);
        safety.grantRole(safety.DAO_ROLE(), daoAddr);
        // Revoke GUARDIAN_ROLE from admin so admin pauses don't fail via
        // the guardian sunset path (admin has both ADMIN + GUARDIAN from constructor)
        safety.revokeRole(safety.GUARDIAN_ROLE(), admin);

        bytes32[] memory mods = new bytes32[](3);
        mods[0] = MOD_A;
        mods[1] = MOD_B;
        mods[2] = MOD_C;

        handler = new SafetyAutomataHandler(
            safety, admin, guardianAddr, daoAddr, mods
        );

        targetContract(address(handler));
    }

    /// @notice isPaused and isModuleEnabled are always complementary.
    function invariant_pausedAndEnabledComplementary() public view {
        assertTrue(
            safety.isPaused(MOD_A) != safety.isModuleEnabled(MOD_A),
            "INV: not complementary MOD_A"
        );
        assertTrue(
            safety.isPaused(MOD_B) != safety.isModuleEnabled(MOD_B),
            "INV: not complementary MOD_B"
        );
        assertTrue(
            safety.isPaused(MOD_C) != safety.isModuleEnabled(MOD_C),
            "INV: not complementary MOD_C"
        );
    }

    /// @notice Ghost pause state matches on-chain state for all modules.
    function invariant_ghostMatchesOnChain() public view {
        assertEq(
            safety.isPaused(MOD_A), handler.ghost_paused(MOD_A),
            "INV: ghost mismatch MOD_A"
        );
        assertEq(
            safety.isPaused(MOD_B), handler.ghost_paused(MOD_B),
            "INV: ghost mismatch MOD_B"
        );
        assertEq(
            safety.isPaused(MOD_C), handler.ghost_paused(MOD_C),
            "INV: ghost mismatch MOD_C"
        );
    }

    /// @notice Guardian can never successfully pause after sunset.
    function invariant_noGuardianPauseAfterSunset() public view {
        assertEq(handler.ghost_guardianPausedAfterSunset(), 0,
            "INV: guardian paused a module after sunset");
    }

    /// @notice Unpaused modules always report isModuleEnabled == true.
    function invariant_unpausedModulesAreEnabled() public view {
        if (!safety.isPaused(MOD_A)) {
            assertTrue(safety.isModuleEnabled(MOD_A), "INV: MOD_A unpaused but not enabled");
        }
        if (!safety.isPaused(MOD_B)) {
            assertTrue(safety.isModuleEnabled(MOD_B), "INV: MOD_B unpaused but not enabled");
        }
        if (!safety.isPaused(MOD_C)) {
            assertTrue(safety.isModuleEnabled(MOD_C), "INV: MOD_C unpaused but not enabled");
        }
    }
}
