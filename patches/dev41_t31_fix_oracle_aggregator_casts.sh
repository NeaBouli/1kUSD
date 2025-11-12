#!/usr/bin/env bash
set -euo pipefail
FILE="foundry/test/oracle/OracleRegression_Base.t.sol"
TMP="${FILE}.tmp"

echo "== DEV-41-T31: Fix OracleAggregator constructor to use interface types =="

cp -n "$FILE" "${FILE}.bak.t31" || true

awk '
  {
    sub(/new OracleAggregator\(address\(this\), address\(mockSafety\), address\(mockRegistry\)\)/,
        "new OracleAggregator(address(this), mockSafety, mockRegistry)")
    print
  }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✅ OracleAggregator call now uses interface-typed mocks (no address casts)."
