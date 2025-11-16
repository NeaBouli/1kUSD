#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Flows.t.sol"

echo "== DEV45 STEP 7A: Restore correct import header =="

# 1) Wipe all non-header imports inside body (safety)
sed -i '' '/import {IOracleAggregator}/d' "$FILE"
sed -i '' '/import {OracleAggregator}/d' "$FILE"

# 2) Insert correct imports after OneKUSD
sed -i '' '/OneKUSD/a\
import {IOracleAggregator} from "../../../contracts/interfaces/IOracleAggregator.sol";\
import {MockOracleAggregator} from "../../mocks/MockOracleAggregator.sol";\
' "$FILE"

echo "✓ STEP 7A complete"
