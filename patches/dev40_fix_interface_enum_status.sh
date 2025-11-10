#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-40 Fix: align IOracleWatcher return type with Status enum =="

FILE="contracts/interfaces/IOracleWatcher.sol"
TMP="${FILE}.tmp"

cat > "$TMP" <<'SOL'
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
SOL

mv "$TMP" "$FILE"

forge clean && forge build

mkdir -p logs
printf "%s DEV-40 fix: aligned IOracleWatcher interface with Status enum (build ok)\n" "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" >> logs/project.log
echo "✅ Interface return type aligned – build expected to succeed."
