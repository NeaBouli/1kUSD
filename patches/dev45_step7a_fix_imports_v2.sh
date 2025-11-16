#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Flows.t.sol"

echo "== DEV45 STEP 7A v2: Full header import cleanup =="

# Remove ALL oracle-related imports everywhere
sed -i '' '/IOracleAggregator/d' "$FILE"
sed -i '' '/OracleAggregator/d' "$FILE"
sed -i '' '/MockOracleAggregator/d' "$FILE"

# Insert CORRECT imports after OneKUSD
sed -i '' '/OneKUSD/a\
import {IOracleAggregator} from "../../../contracts/interfaces/IOracleAggregator.sol";\
import {MockOracleAggregator} from "../../mocks/MockOracleAggregator.sol";\
' "$FILE"

echo "✓ STEP 7A v2 complete"
