#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/core/PegStabilityModule.sol"

echo "== DEV47 CORE01: wire token decimals via ParameterRegistry in PSM =="

# 1) Helper-Konstanten + Funktionen direkt nach dem Internal-Helpers-Header einfügen
sed -i '' '/\/\/ 🔧 Internal helpers — price & normalization/a\
    // DEV-47: token-decimals lookup via ParameterRegistry (token-spezifisch).\
    bytes32 private constant KEY_TOKEN_DECIMALS = keccak256("psm:tokenDecimals");\
\
    function _tokenDecimalsKey(address token) internal pure returns (bytes32) {\
        return keccak256(abi.encode(KEY_TOKEN_DECIMALS, token));\
    }\
\
    function _getTokenDecimals(address token) internal view returns (uint8) {\
        // Fallback: keine Registry hinterlegt → 18 Decimals.\
        if (address(registry) == address(0)) {\
            return 18;\
        }\
        uint256 raw = registry.getUint(_tokenDecimalsKey(token));\
        if (raw == 0) {\
            // Fallback für nicht konfigurierte Assets: 18 Decimals.\
            return 18;\
        }\
        require(raw <= type(uint8).max, "PSM: bad tokenDecimals");\
        return uint8(raw);\
    }\
\
' "$FILE"

# 2) swapTo1kUSD: harte 18-Decimals durch Registry-Lookup ersetzen
sed -i '' 's/uint8 tokenInDecimals = 18;/uint8 tokenInDecimals = _getTokenDecimals(tokenIn);/' "$FILE"

# 3) swapFrom1kUSD: dito für tokenOut
sed -i '' 's/uint8 tokenOutDecimals = 18;/uint8 tokenOutDecimals = _getTokenDecimals(tokenOut);/' "$FILE"

echo "✓ DEV47 CORE01: PSM reads token decimals from ParameterRegistry with 18-dec fallback"
