#!/usr/bin/env bash
set -euo pipefail
FILE="foundry/test/oracle/OracleRegression_Base.t.sol"
TMP="${FILE}.tmp"

echo "== DEV-41-T32: Add registry argument to OracleWatcher deployment =="

cp -n "$FILE" "${FILE}.bak.t32" || true

awk '
  {
    sub(/new OracleWatcher\(safety, aggregator\)/,
        "new OracleWatcher(safety, aggregator, registry)")
    print
  }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✅ OracleWatcher now receives registry as third constructor argument."
