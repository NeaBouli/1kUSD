#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Flows.t.sol"

echo "== DEV45 STEP 12B: Remove broken logs and insert correct debug logs =="

# 1) Entferne ALLE vorherigen log_named_uint injections
sed -i '' '/log_named_uint/d' "$FILE"

# 2) Füge Logs NACH swapTo1kUSD und VOR assertEq(oneKUSD...) ein
sed -i '' '/psm.swapTo1kUSD/a\
        emit log_named_uint("DEBUG_user1k_before", oneKUSD.balanceOf(user));\
        emit log_named_uint("DEBUG_user1k_after", oneKUSD.balanceOf(user));\
        emit log_named_uint("DEBUG_psm_1k_bal", oneKUSD.balanceOf(address(psm)));\
        emit log_named_uint("DEBUG_totalSupply", oneKUSD.totalSupply());\
' "$FILE"

echo "✓ Correct debug logs inserted"
