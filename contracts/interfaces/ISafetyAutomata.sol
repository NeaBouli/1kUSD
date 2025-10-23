// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title ISafetyAutomata — pause, caps, and rate-limits registry (interface)
interface ISafetyAutomata {
    /// @notice Return whether a module is paused (PSM/VAULT/ORACLE/TOKEN/etc.).
    function isPaused(bytes32 moduleId) external view returns (bool);

    /// @notice Return whether a module is enabled (inverse of paused; semantics may evolve).
    function isModuleEnabled(bytes32 moduleId) external view returns (bool);
}
