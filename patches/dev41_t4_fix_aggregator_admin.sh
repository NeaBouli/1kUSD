#!/usr/bin/env bash
set -euo pipefail
FILE="foundry/test/oracle/OracleRegression_Base.t.sol"
TMP="${FILE}.tmp"

echo "== DEV-41-T4: Replace OracleAggregator admin 0x0 with dummy 0xCAFE =="

cp -n "$FILE" "${FILE}.bak" || true

awk '
  {
    line=$0
    # Replace admin param address(this) -> address(0xCAFE)
    gsub(/new OracleAggregator\(address\(this\), safety, registry\)/,
         "new OracleAggregator(address(0xCAFE), safety, registry)", line)
    print line
  }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✅ OracleAggregator admin dummy injected (address(0xCAFE))."
