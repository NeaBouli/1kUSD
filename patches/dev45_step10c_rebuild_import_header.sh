#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Flows.t.sol"

echo "== DEV45 STEP 10C: FULL CLEAN IMPORT HEADER REBUILD =="

# 1) Entferne alle MockOracle/MOCKERC20 Imports überall
sed -i '' '/MockOracleAggregator/d' "$FILE"
sed -i '' '/MockERC20/d' "$FILE"
sed -i '' '/IOracleAggregator/d' "$FILE"

# 2) Füge die korrekten Imports im HEADER neu hinzu (direkt nach OneKUSD)
sed -i '' '/OneKUSD/a\
import {IOracleAggregator} from "../../../contracts/interfaces/IOracleAggregator.sol";\
import {MockOracleAggregator} from "../mocks/MockOracleAggregator.sol";\
import {MockERC20} from "../mocks/MockERC20.sol";\
' "$FILE"

echo "✓ CLEAN IMPORT HEADER RESTORED"
