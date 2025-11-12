#!/usr/bin/env bash
set -euo pipefail
FILE="foundry/test/oracle/OracleRegression_Base.t.sol"
TMP="${FILE}.tmp"

echo "== DEV-41-T37: Ensure aggregator & safety assigned before use in child tests =="

cp -n "$FILE" "${FILE}.bak.t37" || true

awk '
  BEGIN {inserted=0}
  {
    if ($0 ~ /function setUp\(\)/ && !inserted) {
      print $0
      print "        // --- DEV-41-T37: guarantee nonzero base assignments ---"
      print "        if (address(mockSafety) == address(0)) mockSafety = new SafetyAutomata(address(this), 0);"
      print "        if (address(mockRegistry) == address(0)) mockRegistry = new ParameterRegistry(address(this));"
      print "        if (address(mockAggregator) == address(0)) mockAggregator = new OracleAggregator(address(this), mockSafety, mockRegistry);"
      print "        aggregator = mockAggregator;"
      print "        safety = mockSafety;"
      inserted=1
      next
    }
    print
  }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✅ aggregator & safety now assigned during Base.setUp(), eliminating ZERO_ADDRESS in child constructors."
