// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title PSM (Peg Stability Module) — Stub for DEV-31 integration tests
/// @notice Minimal placeholder implementing interface hooks required by tests.
contract PSM {
    address public dao;
    bool public paused;
    address public lastToken;
    uint256 public lastAmount;

    constructor(address _dao) {
        dao = _dao;
    }

    function pause() external {
        paused = true;
    }

    function unpause() external {
        paused = false;
    }

    /// @notice Stub for test compatibility — mimics swap entry point
    function swapCollateralForStable(address token, uint256 amountIn) external {
        require(!paused, "paused");
        lastToken = token;
        lastAmount = amountIn;
    }
}
