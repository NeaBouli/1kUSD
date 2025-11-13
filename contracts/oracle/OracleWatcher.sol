pragma solidity ^0.8.30;

import { IOracleAggregator } from "../interfaces/IOracleAggregator.sol";
import { ISafetyAutomata } from "../interfaces/ISafetyAutomata.sol";
import { IOracleWatcher } from "../interfaces/IOracleWatcher.sol";

/// @title OracleWatcher
/// @notice Monitors Oracle and SafetyAutomata health state and reports operational status.
contract OracleWatcher is IOracleWatcher {

    IOracleAggregator public oracle;
    ISafetyAutomata public safetyAutomata;

    event HealthUpdated(Status status, uint256 timestamp);


    struct HealthState {
        Status status;
        uint256 lastUpdate;
        bool cached;
    }

    HealthState private _health;

    constructor(IOracleAggregator _oracle, ISafetyAutomata _safety) {
        oracle = _oracle;
        safetyAutomata = _safety;
        _health.status = Status.Healthy;
        _health.cached = false;
        _health.lastUpdate = block.timestamp;
    }

    function updateHealth() public {
        bool operational = false;
        bool paused = false;

        try oracle.isOperational() returns (bool ok) {
            operational = ok;
        } catch {}

        (bool success, bytes memory data) = address(safetyAutomata).staticcall(
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
    }

    function refreshState() external {
        updateHealth();
    }

    function isHealthy() external view returns (bool) {
        if (!_health.cached) return true;
        return _health.status == Status.Healthy;
    }

    function getStatus() external view returns (Status) {
        return _health.status;
    }
}
