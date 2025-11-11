#!/usr/bin/env bash
set -euo pipefail
FILE="foundry/test/oracle/OracleRegression_Base.t.sol"
TMP="${FILE}.tmp"

echo "== DEV-41-T2: Fix chained assignment in OracleRegression_Base.t.sol =="

cp -n "$FILE" "${FILE}.bak" || true

awk '
  {
    line=$0
    if (line ~ /aggregator[[:space:]]*=[[:space:]]*registry[[:space:]]*=[[:space:]]*IParameterRegistry\(address\(0\)\);/) {
      print "        registry = IParameterRegistry(address(0));"
      next
    }
    print line
  }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✅ Chained assignment replaced by explicit registry initialization."
