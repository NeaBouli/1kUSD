#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Flows.t.sol"

echo "== DEV45 STEP 7C: Wire MockOracleAggregator into PSMRegression_Flows =="

# 1) Insert oracle declaration under variables
sed -i '' '/address internal collateral/a\
    MockOracleAggregator internal oracle;\
' "$FILE"

# 2) Insert oracle instantiation inside setUp()
sed -i '' '/function setUp() {/a\
        oracle = new MockOracleAggregator();\
        oracle.setPrice(int256(1e18), 18, true);\
' "$FILE"

echo "✓ STEP 7C: Oracle wired into test setup"
