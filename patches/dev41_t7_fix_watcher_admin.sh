#!/usr/bin/env bash
set -euo pipefail
FILE="foundry/test/oracle/OracleRegression_Base.t.sol"
TMP="${FILE}.tmp"

echo "== DEV-41-T7: Inject dummy admin for OracleWatcher to resolve ZERO_ADDRESS revert =="

cp -n "$FILE" "${FILE}.bak" || true

awk '
  {
    line=$0
    # Replace watcher construction with dummy admin variant if needed
    gsub(/new OracleWatcher\(aggregator, safety\)/,
         "new OracleWatcher(address(0xD00D), aggregator, safety)", line)
    print line
  }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✅ OracleWatcher admin dummy injected (address(0xD00D))."
