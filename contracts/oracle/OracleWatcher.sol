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
    IOracleAggregator public oracle;
    address public safetyAutomata;

    address public immutable deployer;

    constructor(address _oracle, address _safetyAutomata) {
        deployer = msg.sender;
        oracle = IOracleAggregator(_oracle);
        safetyAutomata = _safetyAutomata;
    }
