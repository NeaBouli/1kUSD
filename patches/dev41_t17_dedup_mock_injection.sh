#!/usr/bin/env bash
set -euo pipefail
FILE="foundry/test/oracle/OracleRegression_Base.t.sol"
TMP="${FILE}.tmp"

echo "== DEV-41-T17: Deduplicate mockAgg injection and ensure single assignment =="

cp -n "$FILE" "${FILE}.bak.t17" || true

# Entferne alle doppelten mockAgg-Zeilen außer der ersten
awk '
  /OracleAggregator mockAgg = new MockOracleAggregator/ {
      if (seen++) next
  }
  { print }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✅ Deduplicated mockAgg injection — single instance remains."
