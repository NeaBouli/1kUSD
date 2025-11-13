// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title TreasuryVault — Stub contract for DEV Guardian tests
/// @notice Minimal version with deposit logic placeholder
contract TreasuryVault {
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

    /// @notice Stub for collateral deposit (Guardian test compatibility)
    function depositCollateral(address token, uint256 amount) external {
        require(!paused, "paused");
        lastToken = token;
        lastAmount = amount;
    }
}
