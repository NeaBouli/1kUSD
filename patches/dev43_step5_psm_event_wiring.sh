#!/usr/bin/env bash
set -euo pipefail

echo "== DEV-43 Step 5: Add IPSMEvents wiring into PegStabilityModule =="

# Patch PegStabilityModule.sol to import IPSMEvents and extend interface
apply_patch() {
  local file="contracts/core/PegStabilityModule.sol"

  echo "• Patching $file ..."

  # Insert import if missing
  if ! grep -q "IPSMEvents" "$file"; then
    sed -i '' 's|import {IPSM}|import {IPSM} from "..\/interfaces\/IPSM.sol";\
import {IPSMEvents} from "..\/interfaces\/IPSMEvents.sol";|' "$file"
  fi

  # Extend contract header
  if ! grep -q "IPSMEvents" "$file"; then
    sed -i '' 's/contract PegStabilityModule is IPSM,/contract PegStabilityModule is IPSM, IPSMEvents,/' "$file"
  fi

  # Add event emit skeletons (no logic change)
  if ! grep -q "PSMSwapExecuted" "$file"; then
    sed -i '' 's/swapTo1kUSD(/PSMSwapExecuted(msg.sender, tokenIn, amountIn, block.timestamp);\n        swapTo1kUSD(/' "$file"
    sed -i '' 's/swapFrom1kUSD(/PSMSwapExecuted(msg.sender, tokenOut, amountIn, block.timestamp);\n        swapFrom1kUSD(/' "$file"
  fi
}

apply_patch

echo "✓ PegStabilityModule now wired with IPSMEvents skeleton"
echo "== DEV-43 Step 5 Complete =="
