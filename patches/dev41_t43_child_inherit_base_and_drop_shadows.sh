#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/oracle/OracleRegression_Watcher.t.sol"
TMP="${FILE}.tmp"

echo "== DEV-41-T43: make OracleRegression_Watcher inherit Base and remove shadowing fields =="

cp -n "$FILE" "${FILE}.bak.t43" || true

awk '
  {
    line = $0

    # 1) Contract-Header: Test -> OracleRegression_Base
    if (line ~ /contract OracleRegression_Watcher is Test[[:space:]]*\{/) {
      sub(/contract OracleRegression_Watcher is Test[[:space:]]*\{/,
          "contract OracleRegression_Watcher is OracleRegression_Base {", line)
    }

    # 2) Shadowing-Felder entfernen: safety, aggregator, registry
    if (line ~ /SafetyAutomata[[:space:]]+safety;/)     next
    if (line ~ /OracleAggregator[[:space:]]+aggregator;/) next
    if (line ~ /IParameterRegistry[[:space:]]+registry;/) next

    print line
  }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✅ OracleRegression_Watcher now inherits OracleRegression_Base and no longer shadows safety/aggregator/registry."
