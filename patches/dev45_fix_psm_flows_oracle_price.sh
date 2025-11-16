#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Flows.t.sol"

echo "== DEV-45 Hotfix: Set oracle price in PSMRegression_Flows =="

# Insert after setUp block: oracle price set to 1e18
sed -i '' '/function setUp() public {/a\
        // DEV-45: Set oracle price so swapTo1kUSD produces nonzero notional\n\
        vm.prank(admin);\n\
        oracle.setPrice(collateral, IOracleAggregator.Price({ value: 1e18, lastUpdate: block.timestamp }));\n\
' "$FILE"

echo "✓ Oracle price initialization added"
echo "== Complete =="
