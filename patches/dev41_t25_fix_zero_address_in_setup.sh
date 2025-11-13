#!/usr/bin/env bash
set -euo pipefail
FILE="foundry/test/oracle/OracleRegression_Base.t.sol"
TMP="${FILE}.tmp"

echo "== DEV-41-T25: Ensure mocks assigned before watcher deployment (ZERO_ADDRESS fix) =="

cp -n "$FILE" "${FILE}.bak.t25" || true

awk '
  BEGIN { injected=0 }
  {
    print
    if ($0 ~ /setUp\(\)/ && !injected) {
      print "        // --- DEV-41-T25 injection: ensure mockSafety and mockRegistry initialized ---"
      print "        if (address(mockSafety) == address(0)) mockSafety = new SafetyAutomata(address(this), 0);"
      print "        if (address(mockRegistry) == address(0)) mockRegistry = new ParameterRegistry(address(this));"
      print "        safety = mockSafety;"
      print "        registry = mockRegistry;"
      injected=1
    }
  }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✅ ZERO_ADDRESS safeguarded by early mock initialization in setUp()."
