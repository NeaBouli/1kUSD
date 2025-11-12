#!/usr/bin/env bash
set -euo pipefail
FILE="foundry/test/oracle/OracleRegression_Base.t.sol"
TMP="${FILE}.tmp"

echo "== DEV-41-T26: Promote mockSafety & mockRegistry to internal fields =="

cp -n "$FILE" "${FILE}.bak.t26" || true

awk '
  BEGIN { injected=0 }
  {
    # nach der Kontraktdefinition oben einfügen
    if ($0 ~ /contract[[:space:]]+OracleRegression_Base/ && !injected) {
      print
      print "    // --- DEV-41-T26 injected mock fields ---"
      print "    SafetyAutomata internal mockSafety;"
      print "    ParameterRegistry internal mockRegistry;"
      injected=1
      next
    }
    print
  }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✅ mockSafety and mockRegistry promoted to internal contract fields."
