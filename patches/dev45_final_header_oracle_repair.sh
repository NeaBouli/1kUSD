#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Flows.t.sol"

echo "== DEV-45 FINAL HEADER/ORACLE REPAIR =="

# 1) Entferne kaputten Import innerhalb FixedOracle
sed -i '' '/import {OracleAggregator}/d' "$FILE"

# 2) Fügt fehlende korrekte Import-Sektion ein
# Direkt nach OneKUSD-Import einfügen
sed -i '' '/OneKUSD/a\
import {IOracleAggregator} from "../../../contracts/interfaces/IOracleAggregator.sol";\
import {OracleAggregator} from "../../../contracts/core/OracleAggregator.sol";\
' "$FILE"

echo "✓ Header imports repaired"

# 3) Prüfe ob FixedOracle korrekt beginnt
# Wenn nicht, stelle die korrekten ersten Zeilen wieder her
sed -i '' '11,15c\
contract FixedOracle is IOracleAggregator {\
    Price private _p;\
' "$FILE"

echo "✓ FixedOracle contract header restored"

echo "== COMPLETE =="
