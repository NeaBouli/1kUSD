// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { IOracleAggregator } from "../core/OracleAggregator.sol";

/// @title OracleWatcher (DEV-40 Scaffold)
/// @notice Lightweight watcher stub that will subscribe to OracleAggregator state
///         and expose a clean "healthy / paused / stale" view for off-chain consumers.
/// @dev Implementation will be added in DEV-40 steps without changing this interface.
interface IOracleWatcher {
    /// @notice Returns true if the oracle path is considered operational.
    /// @notice Updates internal health cache based on oracle and safety modules.
    function updateHealth() external {
        // Placeholder: will query oracle.isOperational() and safety.isPaused()
        // and update local flags in later steps.
    }

    /// @notice Manual refresh (alias for updateHealth) for external triggers.
    function refreshState() external {
        // Placeholder: may be used by off-chain agents or DAO
    }

    function isHealthy() external view returns (bool);
}

contract OracleWatcher is IOracleWatcher {
    // Placeholder: will be wired to OracleAggregator in subsequent steps
    IOracleAggregator public oracle;

    /// @notice Possible states derived from OracleAggregator and SafetyAutomata.
    enum Status { Healthy, Paused, Stale }

    struct HealthState {
        Status status;
        uint256 lastUpdate;
        bool cached;
    }

    HealthState internal _health;
    address public safetyAutomata;

    address public immutable deployer;

    constructor(address _oracle, address _safetyAutomata) {
        deployer = msg.sender;
        oracle = IOracleAggregator(_oracle);
        safetyAutomata = _safetyAutomata;
    }
