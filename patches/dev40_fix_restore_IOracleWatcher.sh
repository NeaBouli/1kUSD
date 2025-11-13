#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-40 Fix: restore missing IOracleWatcher interface =="

mkdir -p contracts/interfaces

cat > contracts/interfaces/IOracleWatcher.sol <<'SOL'
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title IOracleWatcher
/// @notice Interface for OracleWatcher contracts.
interface IOracleWatcher {
    /// @notice Returns true if the system is currently healthy.
    function isHealthy() external view returns (bool);

    /// @notice Returns the latest health status (Healthy, Paused, or Stale).
    function getStatus() external view returns (uint8);
}
SOL

forge clean && forge build

mkdir -p logs
printf "%s DEV-40 fix: restored missing IOracleWatcher interface (build ok)\n" "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" >> logs/project.log
echo "✅ IOracleWatcher interface restored successfully."
