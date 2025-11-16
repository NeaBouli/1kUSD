#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Flows.t.sol"

echo "== DEV45 STEP 10B: Add missing MockERC20 import =="

# Einfügen direkt nach MockOracleAggregator-Import
sed -i '' '/MockOracleAggregator/a\
import {MockERC20} from "../mocks/MockERC20.sol";\
' "$FILE"

echo "✓ MockERC20 import added"
