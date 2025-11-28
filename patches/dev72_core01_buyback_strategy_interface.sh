#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/strategy/IBuybackStrategy.sol"
LOG_FILE="logs/project.log"

echo "== DEV72 CORE01: add IBuybackStrategy interface =="

mkdir -p "$(dirname "$FILE")"

cat <<'SOL' > "$FILE"
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IBuybackStrategy
/// @notice Interface for external strategy modules that compute buyback targets
///         for BuybackVault. This is forward-looking for v0.52+ and is not yet
///         wired into BuybackVault.executeBuyback().
interface IBuybackStrategy {
    /// @notice Describes a single buyback leg for a given asset.
    /// @dev weightBps is expressed in basis points (1e4 = 100%).
    struct BuybackLeg {
        address asset;
        uint256 weightBps;
        bool enabled;
    }

    /// @notice Returns the desired buyback allocation for a given vault and
    ///         amount of available stable.
    /// @param vault Address of the calling BuybackVault.
    /// @param availableStable Amount of 1kUSD available for buyback.
    /// @return legs Array of buyback legs (asset/weight/enabled).
    function planBuyback(address vault, uint256 availableStable)
        external
        view
        returns (BuybackLeg[] memory legs);
}
SOL

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-72] ${timestamp} Strategy: introduced IBuybackStrategy interface (forward-looking, not yet wired into BuybackVault)." >> "$LOG_FILE"

echo "✓ IBuybackStrategy.sol written to $FILE"
echo "✓ Log updated at $LOG_FILE"
echo "== DEV72 CORE01: done =="
