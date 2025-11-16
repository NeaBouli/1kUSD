#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Flows.t.sol"

echo "== DEV45: Fix MockOracleAggregator import path =="

# Ersetze den falschen Pfad "../../mocks/" → "../mocks/"
sed -i '' 's#../../mocks/#../mocks/#g' "$FILE"

echo "✓ Import path corrected"
