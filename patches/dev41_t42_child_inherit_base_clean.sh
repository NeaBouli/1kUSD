#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/oracle/OracleRegression_Watcher.t.sol"
TMP="${FILE}.tmp"

echo "== DEV-41-T42: enforce inheritance from OracleRegression_Base =="

cp -n "$FILE" "${FILE}.bak.t42" || true

awk '
  BEGIN {done=0}
  {
    # FIRST: Insert correct import if missing
    if (!done && $0 ~ /contract OracleRegression_Watcher/) {
      print "import \"./OracleRegression_Base.t.sol\";"

      # Replace contract header with inheritance
      sub(/contract OracleRegression_Watcher[[:space:]]*\{/,
          "contract OracleRegression_Watcher is OracleRegression_Base {")

      done=1
    }
    print
  }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✅ Child now inherits Base correctly."
