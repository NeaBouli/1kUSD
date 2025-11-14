// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title IPSMEvents — unified Peg Stability Module event interface
interface IPSMEvents {
    /// @notice emitted when a swap operation is executed
    event PSMSwapExecuted(
        address indexed user,
        address indexed tokenIn,
        uint256 amountIn,
        uint256 timestamp
    );

    /// @notice emitted when fees are routed to FeeRouter
    event PSMFeesRouted(
        address indexed token,
        uint256 amount,
        uint256 timestamp
    );
}
