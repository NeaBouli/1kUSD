// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { IOracleAggregator } from "../core/OracleAggregator.sol";

/// @title OracleWatcher (DEV-40 Scaffold)
/// @notice Lightweight watcher stub that will subscribe to OracleAggregator state
///         and expose a clean "healthy / paused / stale" view for off-chain consumers.
/// @dev Implementation will be added in DEV-40 steps without changing this interface.
interface IOracleWatcher {
    /// @notice Returns true if the oracle path is considered operational.
    function isHealthy() external view returns (bool);
}

contract OracleWatcher is IOracleWatcher {
    // Placeholder: will be wired to OracleAggregator in subsequent steps
    address public immutable deployer;

    constructor() {
        deployer = msg.sender;
    }

    /// @inheritdoc IOracleWatcher
    function isHealthy() external pure returns (bool) {
        // Stub: will read from OracleAggregator / SafetyAutomata later
        return true;
    }
}
