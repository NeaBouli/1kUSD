// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title ISafetyAutomata — pause, caps, and rate-limits registry
interface ISafetyAutomata {
    function isPaused(bytes32 moduleId) external view returns (bool);
    function capOf(address asset) external view returns (uint256);
    function moduleEnabled(bytes32 moduleId) external view returns (bool);
}
