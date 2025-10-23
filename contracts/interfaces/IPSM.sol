// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title IPSM — Peg Stability Module (interface)
/// @notice Read-only quotes are available; swaps may be unimplemented in early phases.
interface IPSM {
    /// @notice Mint 1kUSD by depositing a supported token.
    /// @dev MUST enforce CEI, oracle/safety guards, and mirror quote semantics.
    function swapTo1kUSD(
        address tokenIn,
        uint256 amountIn,
        address to,
        uint256 minOut,
        uint256 deadline
    ) external returns (uint256 amountOut);

    /// @notice Redeem 1kUSD into a supported token.
    function swapFrom1kUSD(
        address tokenOut,
        uint256 amountIn,
        address to,
        uint256 minOut,
        uint256 deadline
    ) external returns (uint256 amountOut);

    /// @notice Pure read-only quotes, MUST equal execution results under same snapshot.
    function quoteTo1kUSD(address tokenIn, uint256 amountIn)
        external
        view
        returns (uint256 grossOut, uint256 fee, uint256 netOut);

    function quoteFrom1kUSD(address tokenOut, uint256 amountIn)
        external
        view
        returns (uint256 grossOut, uint256 fee, uint256 netOut);
}
