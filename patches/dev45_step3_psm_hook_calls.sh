#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/core/PegStabilityModule.sol"

echo "== DEV-45 Step 3: Hook notional math to scaffold helpers =="

# swapTo1kUSD: insert helper calls
sed -i '' 's|// DEV-45: integrate asset flows here for mint path|_pullCollateral(tokenIn, from, q.gross);\n        _mint1kUSD(to, q.net);\n        _routeFee(tokenIn, q.fee);|' "$FILE"

# swapFrom1kUSD: insert helper calls
sed -i '' 's|// DEV-45: integrate asset flows here for redeem path|_burn1kUSD(from, q.gross1k);\n        _pushCollateral(tokenOut, to, q.netOut);\n        _routeFee(tokenOut, q.fee);|' "$FILE"

echo "✓ Hooked swap paths to new asset-flow scaffolds (no functional change yet)"
