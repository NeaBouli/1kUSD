#!/usr/bin/env bash
set -euo pipefail
FILE="foundry/test/oracle/OracleRegression_Watcher.t.sol"
TMP="${FILE}.tmp"

echo "== DEV-41-T40: Make OracleRegression_Watcher inherit from OracleRegression_Base =="

cp -n "$FILE" "${FILE}.bak.t40" || true

awk '
  BEGIN {done=0}
  {
    if ($0 ~ /contract OracleRegression_Watcher/ && !done) {
      sub(/contract OracleRegression_Watcher[[:space:]]*\{/,
          "import \"./OracleRegression_Base.t.sol\";\n\ncontract OracleRegression_Watcher is OracleRegression_Base {")
      done=1
    }
    print
  }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✅ OracleRegression_Watcher now inherits from OracleRegression_Base."
