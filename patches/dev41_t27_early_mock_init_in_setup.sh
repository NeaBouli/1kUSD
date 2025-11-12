#!/usr/bin/env bash
set -euo pipefail
FILE="foundry/test/oracle/OracleRegression_Base.t.sol"
TMP="${FILE}.tmp"

echo "== DEV-41-T27: Early initialization of mockSafety & mockRegistry in setUp() =="

cp -n "$FILE" "${FILE}.bak.t27" || true

awk '
  BEGIN { injected=0 }
  {
    if ($0 ~ /function setUp\(\)/ && !injected) {
      print $0
      print "    {"
      print "        // --- DEV-41-T27: ensure mocks exist before any watcher or registry use ---"
      print "        if (address(mockSafety) == address(0)) mockSafety = new SafetyAutomata(address(this), 0);"
      print "        if (address(mockRegistry) == address(0)) mockRegistry = new ParameterRegistry(address(this));"
      print "        safety = ISafetyAutomata(address(mockSafety));"
      print "        registry = IParameterRegistry(address(mockRegistry));"
      injected=1
      next
    }
    print
  }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✅ Early mock initialization injected at start of setUp()."
