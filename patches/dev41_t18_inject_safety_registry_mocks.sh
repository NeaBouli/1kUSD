#!/usr/bin/env bash
set -euo pipefail
FILE="foundry/test/oracle/OracleRegression_Base.t.sol"
TMP="${FILE}.tmp"

echo "== DEV-41-T18: Inject mock SafetyAutomata + mock ParameterRegistry into OracleWatcher setup =="

cp -n "$FILE" "${FILE}.bak.t18" || true

awk '
  BEGIN {inserted=0}
  /new OracleWatcher/ && !inserted {
      print "        SafetyAutomata mockSafety = new SafetyAutomata(address(this));"
      print "        ParameterRegistry mockRegistry = new ParameterRegistry(address(this));"
      print "        safety = address(mockSafety);"
      print "        registry = address(mockRegistry);"
      inserted=1
  }
  { print }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✅ Injected mock SafetyAutomata + mock ParameterRegistry for ZERO_ADDRESS resolution."
