#!/usr/bin/env bash
set -euo pipefail
FILE="foundry/test/oracle/OracleRegression_Base.t.sol"
TMP="${FILE}.tmp"

echo "== DEV-41-T15: Restore missing space between 'pure' and 'returns' =="

cp -n "$FILE" "${FILE}.bak.t15" || true

# Füge wieder ein Leerzeichen ein, falls pure/payer/view in purereturns zusammengeklebt ist
sed -E 's/(pure|view|payable)(returns)/\1 \2/g' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✅ Restored proper spacing between state mutability and returns."
