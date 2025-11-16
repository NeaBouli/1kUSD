#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Limits.t.sol"

echo "== DEV-44: Fix testDailyCapReverts logic =="

# Replace the incorrect block with correct 3-step logic
sed -i '' 's|// smaller swaps: accumulate volume 400 \+ 400 → 800 total|// correct limits accumulation|' "$FILE"

sed -i '' 's|psm.swapTo1kUSD(address(1), 400, user, 0, block.timestamp);|psm.swapTo1kUSD(address(1), 400, user, 0, block.timestamp);\n        psm.swapTo1kUSD(address(1), 400, user, 0, block.timestamp);\n        vm.expectRevert();\n        psm.swapTo1kUSD(address(1), 400, user, 0, block.timestamp);|' "$FILE"

echo "✓ testDailyCapReverts corrected"
