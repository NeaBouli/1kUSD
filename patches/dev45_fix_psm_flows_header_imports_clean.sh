#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Flows.t.sol"

echo "== DEV-45: Clean up OracleAggregator imports in PSMRegression_Flows =="

# 1) Alle bisherigen OracleAggregator-Import-Zeilen (Top + Inside-Contract) entfernen
sed -i '' '/OracleAggregator.sol/d' "$FILE"

# 2) KORREKTEN Import direkt nach IOracleAggregator einfügen
sed -i '' '/IOracleAggregator/a\
import {OracleAggregator} from "../../../contracts/core/OracleAggregator.sol";\
' "$FILE"

echo "✓ OracleAggregator imports normalized (only one, correct path, top-level)"
echo "== DONE =="
