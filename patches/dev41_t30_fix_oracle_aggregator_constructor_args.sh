#!/usr/bin/env bash
set -euo pipefail
FILE="foundry/test/oracle/OracleRegression_Base.t.sol"
TMP="${FILE}.tmp"

echo "== DEV-41-T30: Fix OracleAggregator constructor argument count (add mockRegistry) =="

cp -n "$FILE" "${FILE}.bak.t30" || true

awk '
  {
    sub(/new OracleAggregator\(address\(this\), address\(mockSafety\)\)/,
        "new OracleAggregator(address(this), address(mockSafety), address(mockRegistry))")
    print
  }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✅ OracleAggregator now receives 3 arguments (admin, safety, registry)."
