#!/usr/bin/env bash
set -euo pipefail
FILE="foundry/test/oracle/OracleRegression_Base.t.sol"
TMP="${FILE}.tmp"

echo "== DEV-41-T5: Inject MockRegistry instead of zero-address registry =="

cp -n "$FILE" "${FILE}.bak" || true

awk '
  {
    line=$0
    # Replace zero-address registry assignment with MockRegistry instance
    gsub(/registry = IParameterRegistry\(address\(0\)\);/,
         "registry = IParameterRegistry(address(new MockRegistry()));", line)
    print line
  }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✅ MockRegistry injected to replace zero-address registry."
