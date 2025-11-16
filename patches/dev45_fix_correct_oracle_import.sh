#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Flows.t.sol"

echo "== DEV-45: Correct OracleAggregator import path =="

# Falschen Import entfernen
sed -i '' '/core\/OracleAggregator.sol/d' "$FILE"

# Richtigen Import hinzufügen (falls nicht vorhanden)
if ! grep -q 'oracle/OracleAggregator.sol' "$FILE"; then
  sed -i '' '/IOracleAggregator/a\
import {OracleAggregator} from "../../../contracts/oracle/OracleAggregator.sol";\
' "$FILE"
fi

echo "✓ OracleAggregator import corrected"
echo "== COMPLETE =="
