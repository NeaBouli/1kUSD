#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/core/PegStabilityModule.sol"

echo "== DEV48 CORE01: wire PSM fees via ParameterRegistry =="

# 1) Fee-Key-Constants + Helper vor _computeSwapTo1kUSD einfügen
sed -i '' '/\/\/\/ @notice Compute mint-side swap (token → 1kUSD) in notional terms./i\
    // DEV-48: fee-Bps lookup via ParameterRegistry (global + per-token) with local fallback.\
    bytes32 private constant KEY_MINT_FEE_BPS = keccak256("psm:mintFeeBps");\
    bytes32 private constant KEY_REDEEM_FEE_BPS = keccak256("psm:redeemFeeBps");\
\
    function _mintFeeKey(address token) internal pure returns (bytes32) {\
        return keccak256(abi.encode(KEY_MINT_FEE_BPS, token));\
    }\
\
    function _redeemFeeKey(address token) internal pure returns (bytes32) {\
        return keccak256(abi.encode(KEY_REDEEM_FEE_BPS, token));\
    }\
\
    function _getMintFeeBps(address token) internal view returns (uint16) {\
        uint256 raw;\
        if (address(registry) != address(0)) {\
            raw = registry.getUint(_mintFeeKey(token));\
            if (raw == 0) {\
                raw = registry.getUint(KEY_MINT_FEE_BPS);\
            }\
            if (raw > 0) {\
                require(raw <= 10_000, "PSM: bad mintFeeBps");\
                return uint16(raw);\
            }\
        }\
        raw = mintFeeBps;\
        require(raw <= 10_000, "PSM: bad mintFeeBps(local)");\
        return uint16(raw);\
    }\
\
    function _getRedeemFeeBps(address token) internal view returns (uint16) {\
        uint256 raw;\
        if (address(registry) != address(0)) {\
            raw = registry.getUint(_redeemFeeKey(token));\
            if (raw == 0) {\
                raw = registry.getUint(KEY_REDEEM_FEE_BPS);\
            }\
            if (raw > 0) {\
                require(raw <= 10_000, "PSM: bad redeemFeeBps");\
                return uint16(raw);\
            }\
        }\
        raw = redeemFeeBps;\
        require(raw <= 10_000, "PSM: bad redeemFeeBps(local)");\
        return uint16(raw);\
    }\
\
' "$FILE"

# 2) swapTo1kUSD: Registry-Helper statt direktem mintFeeBps cast
sed -i '' 's/_computeSwapTo1kUSD(tokenIn, amountIn, uint16(mintFeeBps), tokenInDecimals);/_computeSwapTo1kUSD(tokenIn, amountIn, _getMintFeeBps(tokenIn), tokenInDecimals);/' "$FILE"

# 3) swapFrom1kUSD: Registry-Helper statt direktem redeemFeeBps cast
sed -i '' 's/_computeSwapFrom1kUSD(tokenOut, amountIn1k, uint16(redeemFeeBps), tokenOutDecimals);/_computeSwapFrom1kUSD(tokenOut, amountIn1k, _getRedeemFeeBps(tokenOut), tokenOutDecimals);/' "$FILE"

echo "✓ DEV48 CORE01: PSM fees now resolved via ParameterRegistry + local fallback"
