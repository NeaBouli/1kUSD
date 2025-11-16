#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/core/PegStabilityModule.sol"

echo "== DEV-44 Step 3: Insert price/decimals helper skeletons =="

# 1) Falls die Skeletons noch nicht existieren, unterhalb von setOracle() einfügen
if ! grep -q "_tokenToStableNotional" "$FILE"; then
  sed -i '' '/function setOracle/a\
\
    // -------------------------------------------------------------\n\
    // 🔧 DEV-44 Price & Decimals Helpers (Skeletons, no logic yet)\n\
    // -------------------------------------------------------------\n\
    /// @notice Convert token amount to 1kUSD notional (18 decimals)\n\
    /// @dev DEV-44: logic added in next step\n\
    function _tokenToStableNotional(\n\
        address token,\n\
        uint256 amountIn\n\
    ) internal view returns (\n\
        uint256 notional1k,\n\
        IOracleAggregator.Price memory p,\n\
        uint8 tokenDecimals\n\
    ) {\n\
        // TODO DEV-44: real math in next step\n\
        notional1k = amountIn; // stub\n\
        tokenDecimals = 18; // stub\n\
        p = oracle.getPrice(token);\n\
    }\n\
\n\
    /// @notice Convert 1kUSD (18 dec) to token amount\n\
    /// @dev DEV-44: logic added in next step\n\
    function _stableToTokenAmount(\n\
        address token,\n\
        uint256 amount1k,\n\
        IOracleAggregator.Price memory p,\n\
        uint8 tokenDecimals\n\
    ) internal pure returns (uint256 amountToken) {\n\
        // TODO DEV-44: real math in next step\n\
        amountToken = amount1k; // stub\n\
    }\n\
\n\
    /// @notice Compute mint-side swap (token → 1kUSD)\n\
    function _computeSwapTo1kUSD(\n\
        address tokenIn,\n\
        uint256 amountIn,\n\
        uint16 feeBps\n\
    ) internal view returns (\n\
        uint256 notional1k,\n\
        uint256 fee1k,\n\
        uint256 net1k\n\
    ) {\n\
        // TODO DEV-44: real math in next step\n\
        notional1k = amountIn;\n\
        fee1k = (notional1k * feeBps) / 10000;\n\
        net1k = notional1k - fee1k;\n\
    }\n\
\n\
    /// @notice Compute redeem-side swap (1kUSD → token)\n\
    function _computeSwapFrom1kUSD(\n\
        address tokenOut,\n\
        uint256 amountIn1k,\n\
        uint16 feeBps\n\
    ) internal view returns (\n\
        uint256 notional1k,\n\
        uint256 fee1k,\n\
        uint256 netTokenOut\n\
    ) {\n\
        // TODO DEV-44: real math in next step\n\
        notional1k = amountIn1k;\n\
        fee1k = (notional1k * feeBps) / 10000;\n\
        netTokenOut = notional1k - fee1k;\n\
    }\n\
' "$FILE"
fi

echo "✓ DEV-44 helper skeletons inserted"
echo "== DEV-44 Step 3 Complete =="
