#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Flows.t.sol"

echo "== DEV45 STEP 7B: Remove illegal inner-contract imports =="

# Entferne GENAU die beiden Zeilen innerhalb des Contracts
sed -i '' '/import {IOracleAggregator}/d' "$FILE"
sed -i '' '/import {MockOracleAggregator}/d' "$FILE"

echo "✓ Removed inner-contract imports"
