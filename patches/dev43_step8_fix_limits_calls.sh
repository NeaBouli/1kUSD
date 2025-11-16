#!/usr/bin/env bash
set -euo pipefail

echo "== DEV-43 Step 8: Ensure PSMLimits enforcement calls exist =="

FILE="contracts/core/PegStabilityModule.sol"

echo "• Patching $FILE ..."

# Inject _enforceLimits(tokenIn, amountIn) at start of swapTo1kUSD
if ! grep -q "_enforceLimits(tokenIn, amountIn);" "$FILE"; then
  sed -i '' 's/ function swapTo1kUSD(/ function swapTo1kUSD(\n        )/' "$FILE"
  sed -i '' '/swapTo1kUSD(/a\
        _enforceLimits(tokenIn, amountIn);\
' "$FILE"
fi

# Inject _enforceLimits(tokenOut, amountIn) at start of swapFrom1kUSD
if ! grep -q "_enforceLimits(tokenOut, amountIn);" "$FILE"; then
  sed -i '' 's/ function swapFrom1kUSD(/ function swapFrom1kUSD(\n        )/' "$FILE"
  sed -i '' '/swapFrom1kUSD(/a\
        _enforceLimits(tokenOut, amountIn);\
' "$FILE"
fi

echo "✓ PSMLimits enforcement is now active in both swap functions"
echo "== DEV-43 Step 8 Complete =="
