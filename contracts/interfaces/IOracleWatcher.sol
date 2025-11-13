// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title IOracleWatcher
/// @notice Interface for OracleWatcher contracts.
interface IOracleWatcher {
    /// @notice Operational health state classification.
    enum Status { Healthy, Paused, Stale }

    /// @notice Returns true if the system is currently healthy.
    function isHealthy() external view returns (bool);

    /// @notice Returns the latest health status (Healthy, Paused, or Stale).
    function getStatus() external view returns (Status);
}
