#!/usr/bin/env bash
set -euo pipefail
FILE="foundry/test/oracle/OracleRegression_Base.t.sol"
TMP="${FILE}.tmp"

echo "== DEV-41-T13: Remove invalid 'override' keywords in MockOracleAggregator =="

cp -n "$FILE" "${FILE}.bak.t13" || true

# Entferne nur das Wort 'override' in den Mock-Funktionssignaturen
sed -E 's/\boverride\b//g' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✅ Removed invalid override keywords from MockOracleAggregator."
