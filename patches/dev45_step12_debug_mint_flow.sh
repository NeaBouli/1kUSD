#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Flows.t.sol"

echo "== DEV45 STEP 12: Inject debug logs into testMintFlow_1to1 =="

# Füge Logs direkt NACH dem swapTo1kUSD-Call ein
sed -i '' '/psm.swapTo1kUSD/a\
        emit log_named_uint("user1k_before", user1kBefore);\
        emit log_named_uint("user1k_after", oneKUSD.balanceOf(user));\
        emit log_named_uint("psm_1k_balance", oneKUSD.balanceOf(address(psm)));\
        emit log_named_uint("totalSupply_before", supplyBefore);\
        emit log_named_uint("totalSupply_after", oneKUSD.totalSupply());\
' "$FILE"

echo "✓ Debug logs injected into testMintFlow_1to1"
