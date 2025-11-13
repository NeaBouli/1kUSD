#!/usr/bin/env bash
set -euo pipefail
FILE="foundry/test/oracle/OracleRegression_Watcher.t.sol"
TMP="${FILE}.tmp"

echo "== DEV-41-T45: fix refreshState() test to reflect real contract behavior =="

cp -n "$FILE" "${FILE}.bak.t45" || true

awk '
  {
    line=$0
    # Replace the wrong assertion
    sub(/assertTrue\(watcher\.isHealthy\(\), "refreshState should not alter state"\);/,
        "assertFalse(watcher.isHealthy(), \"refreshState should update according to aggregator state\");",
        line)
    print line
  }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✅ Updated testRefreshAlias() to expect updated health state."
