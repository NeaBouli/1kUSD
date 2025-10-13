// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title IPSM — Peg-Stability-Module interface (1:1 swaps with fees/guards)
interface IPSM {
    function swapTo1kUSD(address tokenIn, uint256 amountIn, address to, uint256 minOut, uint256 deadline) external returns (uint256 amountOut);
    function swapFrom1kUSD(address tokenOut, uint256 amountIn, address to, uint256 minOut, uint256 deadline) external returns (uint256 amountOut);

    // Views / quotes
    function quoteTo1kUSD(address tokenIn, uint256 amountIn) external view returns (uint256 grossOut, uint256 fee, uint256 netOut);
    function quoteFrom1kUSD(address tokenOut, uint256 amountIn) external view returns (uint256 grossOut, uint256 fee, uint256 netOut);
}
