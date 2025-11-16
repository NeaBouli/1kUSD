#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Flows.t.sol"

echo "== DEV-45 Hotfix Cleanup: Remove malformed oracle.setPrice line and reinsert cleanly =="

# Entferne jede Zeile, die das fehlerhafte Artefakt enthält
sed -i '' '/oracle.setPrice(collateral/d' "$FILE"

# Saubere Zeilen direkt nach "function setUp() public {" einfügen
sed -i '' '/function setUp() public {/a\
        // DEV-45: Set oracle price so swapTo1kUSD produces nonzero notional\n\
        vm.prank(admin);\n\
        oracle.setPrice(collateral, IOracleAggregator.Price({value: 1e18, lastUpdate: block.timestamp}));\
' "$FILE"

echo "✓ Clean oracle.setPrice inserted"
echo "== Complete =="
