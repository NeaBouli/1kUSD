#!/usr/bin/env bash
set -euo pipefail
FILE="foundry/test/oracle/OracleRegression_Base.t.sol"
TMP="${FILE}.tmp"

echo "== DEV-41-T21: Reorder mock injections before assignments =="

cp -n "$FILE" "${FILE}.bak.t21" || true

awk '
  BEGIN { done=0 }
  {
    if ($0 ~ /safety = ISafetyAutomata/ && !done) {
      print "        // Reordered: declare mocks before assignment"
      print "        SafetyAutomata mockSafety = new SafetyAutomata(address(this), 0);"
      print "        ParameterRegistry mockRegistry = new ParameterRegistry(address(this));"
      print "        safety = ISafetyAutomata(address(mockSafety));"
      print "        registry = IParameterRegistry(address(mockRegistry));"
      getline; getline; next
      done=1
    }
    else { print }
  }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✅ Reordered mock creation before variable use."
