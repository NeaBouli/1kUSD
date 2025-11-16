#!/usr/bin/env bash
set -euo pipefail

echo "== DEV-43 Step 6: Add SafetyAutomata + PSMLimits enforcement to PSM =="

FILE="contracts/core/PegStabilityModule.sol"

echo "• Patching $FILE ..."

# 1. Modifier + MODULE constant
if ! grep -q "MODULE_PSM" "$FILE"; then
  sed -i '' '/contract PegStabilityModule/a\
    bytes32 public constant MODULE_PSM = keccak256("PSM");\
\
    modifier whenNotSafetyPaused() {\
        require(!safetyAutomata.isPaused(MODULE_PSM), "PSM: paused by SafetyAutomata");\
        _;\
    }\
' "$FILE"
fi

# 2. Insert limits enforcement + oracle plumbing stub
if ! grep -q "_enforceLimits" "$FILE"; then
  sed -i '' '/constructor/a\
\
    function _enforceLimits(address token, uint256 amount) internal {\
        uint256 notional = amount; /* stub – DEV-44 real math */\
        limits.checkAndUpdate(notional);\
    }\
' "$FILE"
fi

# 3. Add whenNotSafetyPaused modifier to swapTo1kUSD + swapFrom1kUSD
sed -i '' 's/function swapTo1kUSD(/function swapTo1kUSD(\n        whenNotSafetyPaused/' "$FILE"
sed -i '' 's/function swapFrom1kUSD(/function swapFrom1kUSD(\n        whenNotSafetyPaused/' "$FILE"

# 4. Insert limit enforcement calls at start of swaps
if ! grep -q "_enforceLimits" "$FILE"; then
  sed -i '' 's/swapTo1kUSD(/_enforceLimits(tokenIn, amountIn);\n        swapTo1kUSD(/' "$FILE"
  sed -i '' 's/swapFrom1kUSD(/_enforceLimits(tokenOut, amountIn);\n        swapFrom1kUSD(/' "$FILE"
fi

echo "✓ SafetyAutomata + PSMLimits enforcement added"
echo "== DEV-43 Step 6 Complete =="
