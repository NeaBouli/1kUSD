#!/usr/bin/env bash
set -euo pipefail
FILE="foundry/test/oracle/OracleRegression_Base.t.sol"
TMP="${FILE}.tmp"

echo "== DEV-41-T36: Ensure mockAggregator & mockSafety initialized before watcher =="

cp -n "$FILE" "${FILE}.bak.t36" || true

awk '
  BEGIN {done=0}
  {
    # kurz vor new OracleWatcher einfügen
    if ($0 ~ /new OracleWatcher\(aggregator, safety\)/ && !done) {
      print "        // --- DEV-41-T36: pre-init mocks to prevent ZERO_ADDRESS ---"
      print "        if (address(mockSafety) == address(0)) mockSafety = new SafetyAutomata(address(this), 0);"
      print "        if (address(mockRegistry) == address(0)) mockRegistry = new ParameterRegistry(address(this));"
      print "        if (address(mockAggregator) == address(0)) mockAggregator = new OracleAggregator(address(this), mockSafety, mockRegistry);"
      print "        aggregator = mockAggregator;"
      print "        safety = mockSafety;"
      done=1
    }
    print
  }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✅ mockAggregator & mockSafety guaranteed non-zero before OracleWatcher construction."
