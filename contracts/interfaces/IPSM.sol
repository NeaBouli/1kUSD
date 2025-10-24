// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title IPSM — Peg Stability Module (finalized interface v1)
/// @notice Read surface for quotes; state-changing swaps with CEI and Safety guards.
/// @dev Errors/events are normative and ABI-locked via abi/locks/PSM.events.json.
interface IPSM {
// -------- Structs --------
struct QuoteOut {
uint256 grossOut;
uint256 fee;
uint256 netOut;
uint8 outDecimals;
}

// -------- Events (normative) --------
event SwapTo1kUSD(address indexed user, address tokenIn, uint256 amountIn, uint256 fee, uint256 netOut, uint256 ts);
event SwapFrom1kUSD(address indexed user, address tokenOut, uint256 amountIn, uint256 fee, uint256 netOut, uint256 ts);
event FeeAccrued(address indexed asset, uint256 amount);

// -------- Errors (normative) --------
error UNSUPPORTED_ASSET();
error PAUSED();
error ORACLE_STALE();
error ORACLE_UNHEALTHY();
error DEVIATION_EXCEEDED();
error CAP_EXCEEDED();
error INSUFFICIENT_LIQUIDITY();
error SLIPPAGE();
error ACCESS_DENIED();
error ZERO_AMOUNT();

// -------- View (pure quote math; prices advisory only) --------
/// @notice Quote 1kUSD out for a given tokenIn amount (no state change).
/// @param tokenIn Asset provided by user.
/// @param amountIn Amount in tokenIn units.
/// @param feeBps Fee in basis points (from ParameterRegistry snapshot).
/// @param tokenInDecimals ERC-20 decimals for tokenIn.
function quoteTo1kUSD(
    address tokenIn,
    uint256 amountIn,
    uint16 feeBps,
    uint8 tokenInDecimals
) external view returns (QuoteOut memory q);

/// @notice Quote tokenOut for a given 1kUSD amount in.
/// @param tokenOut Asset user wants to receive.
/// @param amountIn1k Amount in 1kUSD (18 decimals).
/// @param feeBps Fee in basis points (from ParameterRegistry snapshot).
/// @param tokenOutDecimals ERC-20 decimals for tokenOut.
function quoteFrom1kUSD(
    address tokenOut,
    uint256 amountIn1k,
    uint16 feeBps,
    uint8 tokenOutDecimals
) external view returns (QuoteOut memory q);

// -------- State-changing (CEI) --------
function swapTo1kUSD(
    address tokenIn,
    uint256 amountIn,
    address to,
    uint256 minOut,
    uint256 deadline
) external returns (uint256 netOut);

function swapFrom1kUSD(
    address tokenOut,
    uint256 amountIn1k,
    address to,
    uint256 minOut,
    uint256 deadline
) external returns (uint256 netOut);


}
