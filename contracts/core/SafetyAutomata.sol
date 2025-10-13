// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @notice Empty stub — see SAFETY_AUTOMATA_SPEC.md for future implementation.
contract SafetyAutomata {
    event Paused(bytes32 indexed moduleId, address indexed by);
    event Unpaused(bytes32 indexed moduleId, address indexed by);
    // NOTE: Intentionally no state or logic in DEV29.
}
