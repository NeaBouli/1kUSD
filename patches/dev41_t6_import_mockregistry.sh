#!/usr/bin/env bash
set -euo pipefail
FILE="foundry/test/oracle/OracleRegression_Base.t.sol"
TMP="${FILE}.tmp"

echo "== DEV-41-T6: Add missing import for MockRegistry =="

cp -n "$FILE" "${FILE}.bak" || true

# Falls der Import schon vorhanden ist, nichts tun
if grep -Fq 'MockRegistry.sol' "$FILE"; then
  echo "MockRegistry import already present."
  exit 0
fi

awk '
  NR==1 { print; next }
  NR==2 {
    print "import \"contracts/core/mocks/MockRegistry.sol\";";
  }
  { print }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✅ MockRegistry import inserted after pragma."
