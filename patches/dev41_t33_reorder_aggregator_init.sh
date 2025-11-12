#!/usr/bin/env bash
set -euo pipefail
FILE="foundry/test/oracle/OracleRegression_Base.t.sol"
TMP="${FILE}.tmp"

echo "== DEV-41-T33: Reorder mock creation (Safety, Registry before Aggregator) =="

cp -n "$FILE" "${FILE}.bak.t33" || true

awk '
  BEGIN { injected=0 }
  {
    # Replace any existing aggregator initialization with reordered version
    if ($0 ~ /mockAggregator = new OracleAggregator/) {
      print "        // --- DEV-41-T33: reordered: deploy Safety + Registry before Aggregator ---"
      print "        if (address(mockSafety) == address(0)) mockSafety = new SafetyAutomata(address(this), 0);"
      print "        if (address(mockRegistry) == address(0)) mockRegistry = new ParameterRegistry(address(this));"
      print "        mockAggregator = new OracleAggregator(address(this), mockSafety, mockRegistry);"
      next
    }
    print
  }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✅ OracleAggregator now initialized after mocks (correct dependency order)."
