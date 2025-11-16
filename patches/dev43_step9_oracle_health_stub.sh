#!/usr/bin/env bash
set -euo pipefail

echo "== DEV-43 Step 9: Add Oracle health/stale gate (stub) =="

FILE="contracts/core/PegStabilityModule.sol"

echo "• Patching $FILE ..."

# Inject _requireOracleHealthy if missing
if ! grep -q "_requireOracleHealthy" "$FILE"; then
  sed -i '' '/constructor/a\
\
    function _requireOracleHealthy(address token) internal view {\
        /* DEV-43 stub: only health check, no price math yet */\
        (, bool healthy, bool stale, ) = oracle.getPrice(token);\
        require(healthy, "PSM: oracle unhealthy");\
        require(!stale, "PSM: oracle price stale");\
    }\
' "$FILE"
fi

# Add call into swapTo1kUSD
if ! grep -q "_requireOracleHealthy(tokenIn);" "$FILE"; then
  sed -i '' '/swapTo1kUSD(/a\
        _requireOracleHealthy(tokenIn);\
' "$FILE"
fi

# Add call into swapFrom1kUSD
if ! grep -q "_requireOracleHealthy(tokenOut);" "$FILE"; then
  sed -i '' '/swapFrom1kUSD(/a\
        _requireOracleHealthy(tokenOut);\
' "$FILE"
fi

echo "✓ Oracle health enforcement added (stub)"
echo "== DEV-43 Step 9 Complete =="
