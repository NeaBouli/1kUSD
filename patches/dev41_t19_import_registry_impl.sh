#!/usr/bin/env bash
set -euo pipefail
FILE="foundry/test/oracle/OracleRegression_Base.t.sol"
TMP="${FILE}.tmp"

echo "== DEV-41-T19: Add import for concrete ParameterRegistry implementation =="

cp -n "$FILE" "${FILE}.bak.t19" || true

# Füge Import oberhalb der OracleWatcher-Imports ein, wenn noch nicht vorhanden
awk '
  /contracts\/interfaces\/IParameterRegistry\.sol/ && !added {
      print "import \"contracts/core/ParameterRegistry.sol\";"
      added=1
  }
  { print }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✅ Added import for concrete ParameterRegistry implementation."
