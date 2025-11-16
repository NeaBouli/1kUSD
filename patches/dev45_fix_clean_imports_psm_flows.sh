#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Flows.t.sol"

echo "== DEV-45 CLEAN IMPORT REPAIR =="

# 1) Entferne ALLE import-Zeilen, die NICHT im Header stehen dürfen
sed -i '' '/import {IOracleAggregator}/d' "$FILE"
sed -i '' '/import {OracleAggregator}/d' "$FILE"

# 2) Entferne alle illegal eingefügten Imports innerhalb von setUp() oder Contracts
# (Sicherheitshalber doppelt)
sed -i '' '/contracts\/interfaces\/IOracleAggregator.sol/d' "$FILE"
sed -i '' '/contracts\/core\/OracleAggregator.sol/d' "$FILE"

echo "✓ Removed all illegal/misplaced imports"

# 3) Füge KORREKTEN Importblock direkt unter die bestehenden Header-Imports ein
sed -i '' '/OneKUSD/a\
import {IOracleAggregator} from "../../../contracts/interfaces/IOracleAggregator.sol";\
import {OracleAggregator} from "../../../contracts/core/OracleAggregator.sol";\
' "$FILE"

echo "✓ Inserted correct header imports"

echo "== COMPLETE =="
