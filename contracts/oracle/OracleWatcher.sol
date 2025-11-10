pragma solidity ^0.8.30;

import { IOracleAggregator } from "../interfaces/IOracleAggregator.sol";

/// @title OracleWatcher (DEV-40 Scaffold)
/// @notice Lightweight watcher stub that will subscribe to OracleAggregator state
///         and expose a clean "healthy / paused / stale" view for off-chain consumers.
/// @dev Implementation will be added in DEV-40 steps without changing this interface.
interface IOracleWatcher {
    /// @notice Returns true if the oracle path is considered operational.
    /// @notice Updates internal health cache based on oracle and safety modules.
    function updateHealth() external {
        bool operational = true;
        bool paused = false;

        // External calls wrapped in try/catch to avoid hard reverts.
        try oracle.isOperational() returns (bool ok) {
            operational = ok;
        } catch {}

        (bool success, bytes memory data) = safetyAutomata.staticcall(
            abi.encodeWithSignature("isPaused(uint8)", 1)
        );
        if (success && data.length >= 32) {
            paused = abi.decode(data, (bool));
        }

        if (paused) {
            _health.status = Status.Paused;
        } else if (!operational) {
            _health.status = Status.Stale;
        } else {
            _health.status = Status.Healthy;
        }

        _health.lastUpdate = block.timestamp;
        _health.cached = true;
        emit HealthUpdated(_health.status, _health.lastUpdate);
        // and update local flags in later steps.
    }

    /// @notice Manual refresh (alias for updateHealth) for external triggers.
    function refreshState() external {
        updateHealth();
    }

    /// @inheritdoc IOracleWatcher
    function isHealthy() external view returns (bool) {
        // Default to true until cache is explicitly updated in later steps.
        if (!_health.cached) return true;
        return _health.status == Status.Healthy;
    }

    /// @notice Returns the last known Status (Healthy/Paused/Stale).

    }


/// @title OracleWatcher
/// @notice Monitors Oracle and SafetyAutomata states
contract OracleWatcher is IOracleWatcher {

    /// @notice Operational state classification
    enum Status { Healthy, Paused, Stale }

    struct HealthState {
        Status status;
        uint256 lastUpdate;
        bool cached;
    }

    IOracleAggregator public oracle;
    ISafetyAutomata public safetyAutomata;
    HealthState private _health;

    function getStatus() external view returns (OracleWatcher.Status) {
        return _health.status;
    }

    /// @notice Returns the unix timestamp of the last updateHealth/refreshState.
    function lastUpdate() external view returns (uint256) {
        return _health.lastUpdate;
    }

    /// @notice Returns true if a health value has been cached.
    function hasCache() external view returns (bool) {
        return _health.cached;
    }
}
