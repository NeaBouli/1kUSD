#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Flows.t.sol"

echo "== DEV45 STEP 7D: Restore correct oracle import in header =="

# 1) Remove all oracle/mock imports everywhere
sed -i '' '/MockOracleAggregator/d' "$FILE"
sed -i '' '/IOracleAggregator/d' "$FILE"

# 2) Insert correct imports AFTER OneKUSD import (safe anchor)
sed -i '' '/OneKUSD/a\
import {IOracleAggregator} from "../../../contracts/interfaces/IOracleAggregator.sol";\
import {MockOracleAggregator} from "../../mocks/MockOracleAggregator.sol";\
' "$FILE"

echo "✓ STEP 7D: Header imports restored"
