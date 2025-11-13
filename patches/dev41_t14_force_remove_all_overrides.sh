#!/usr/bin/env bash
set -euo pipefail
FILE="foundry/test/oracle/OracleRegression_Base.t.sol"
TMP="${FILE}.tmp"

echo "== DEV-41-T14: Force-remove all residual 'override' keywords =="

cp -n "$FILE" "${FILE}.bak.t14" || true

# Lösche alle override-Vorkommen unabhängig von Leerzeichen oder Tabs
sed -E 's/[[:space:]]*override[[:space:]]*//g' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✅ All residual override keywords forcibly removed."
