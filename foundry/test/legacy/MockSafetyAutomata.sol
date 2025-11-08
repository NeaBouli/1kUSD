// SPDX-License-Identifier: MIT
// ============================================================
// 🕰️  DEPRECATED MOCK – kept only for historical reference
// Replaced by inline MockSafety in OracleAggregator.t.sol
// Migration Date: 2025-11-03 (DEV-36)
// ============================================================

pragma solidity ^0.8.20;

contract MockSafetyAutomata {
    bool public paused;

    function isPaused() external view returns (bool) {
        return paused;
    }

    function pause() external {
        paused = true;
    }
}
