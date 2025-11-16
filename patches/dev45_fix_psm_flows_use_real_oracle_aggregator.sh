#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Flows.t.sol"

echo "== DEV-45 Fix: Replace FixedOracle with OracleAggregator and set operational price =="

# 1) Replace FixedOracle declaration
sed -i '' 's/FixedOracle internal oracle;/OracleAggregator internal oracle;/' "$FILE"

# 2) Replace initialization new FixedOracle() -> new OracleAggregator()
sed -i '' 's/oracle = new FixedOracle()/oracle = new OracleAggregator()/' "$FILE"

# 3) Clean any existing setPriceMock lines and reinsert correct one at top of setUp
sed -i '' '/setPriceMock/d' "$FILE"

sed -i '' '/function setUp() public {/a\
        // DEV-45: OracleAggregator mock price setup\n\
        vm.prank(admin);\n\
        oracle.setPriceMock(address(collateral), int256(1e18), 18, true);\n\
' "$FILE"

echo "✓ OracleAggregator mock correctly wired"
echo "== Complete =="
