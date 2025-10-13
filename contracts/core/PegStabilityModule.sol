// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @notice Empty stub — see PSM_SPEC.md and RATE_LIMITS_SPEC.md for future implementation.
contract PegStabilityModule {
    event SwapTo1kUSD(address indexed user, address indexed tokenIn, uint256 amountIn, uint256 fee, uint256 minted, uint256 ts);
    event SwapFrom1kUSD(address indexed user, address indexed tokenOut, uint256 amountIn, uint256 fee, uint256 paidOut, uint256 ts);
    // NOTE: Intentionally no state or logic in DEV29.
}
