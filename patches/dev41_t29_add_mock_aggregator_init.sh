#!/usr/bin/env bash
set -euo pipefail
FILE="foundry/test/oracle/OracleRegression_Base.t.sol"
TMP="${FILE}.tmp"

echo "== DEV-41-T29: Initialize mock OracleAggregator before watcher setup =="

cp -n "$FILE" "${FILE}.bak.t29" || true

awk '
  BEGIN { injected=0 }
  {
    if ($0 ~ /function setUp\(\)/ && !injected) {
      print $0
      print "        // --- DEV-41-T29: ensure mock OracleAggregator initialized ---"
      print "        if (address(mockAggregator) == address(0)) mockAggregator = new OracleAggregator(address(this), address(mockSafety));"
      print "        aggregator = mockAggregator;"
      injected=1
      next
    }
    # Inject a field declaration if missing
    if ($0 ~ /SafetyAutomata internal mockSafety;/) {
      print "    OracleAggregator internal mockAggregator;"
    }
    print
  }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✅ mockAggregator created and linked before watcher deployment."
