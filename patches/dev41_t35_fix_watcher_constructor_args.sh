#!/usr/bin/env bash
set -euo pipefail
FILE="foundry/test/oracle/OracleRegression_Base.t.sol"
TMP="${FILE}.tmp"

echo "== DEV-41-T35: Fix OracleWatcher constructor args (correct order and count) =="

cp -n "$FILE" "${FILE}.bak.t35" || true

# Ersetze fehlerhaften Aufruf mit richtiger Argumentreihenfolge (2 statt 3)
awk '
  {
    sub(/new OracleWatcher\(safety, aggregator, registry\)/,
        "new OracleWatcher(aggregator, safety)")
    sub(/new OracleWatcher\(safety, aggregator\)/,
        "new OracleWatcher(aggregator, safety)")
    print
  }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✅ OracleWatcher now called with correct arguments (IOracleAggregator, ISafetyAutomata)."
