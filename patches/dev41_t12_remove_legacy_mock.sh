#!/usr/bin/env bash
set -euo pipefail
FILE="foundry/test/oracle/OracleRegression_Base.t.sol"
TMP="${FILE}.tmp"

echo "== DEV-41-T12: Remove legacy MockOracleAggregator (duplicate definition) =="

cp -n "$FILE" "${FILE}.bak.t12" || true

# Entferne alten einfachen Mock-Block (die Version ohne inheritance)
awk '
  BEGIN {skip=0}
  /contract MockOracleAggregator {/ && !found {
      found=1
      skip=1
      next
  }
  skip && /^\}/ { skip=0; next }
  !skip { print }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✅ Old untyped MockOracleAggregator removed."
