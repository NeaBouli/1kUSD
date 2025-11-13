#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/oracle/OracleRegression_Watcher.t.sol"
TMP="${FILE}.tmp"

echo "== DEV-41-T44: remove all shadowing fields from OracleRegression_Watcher =="

cp -n "$FILE" "${FILE}.bak.t44" || true

awk '
  # remove watcher, safety, aggregator, registry declarations
  /OracleWatcher[[:space:]]+watcher;/ { next }
  /SafetyAutomata[[:space:]]+safety;/ { next }
  /OracleAggregator[[:space:]]+aggregator;/ { next }
  /IParameterRegistry[[:space:]]+registry;/ { next }

  { print }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✅ Removed watcher, safety, aggregator, registry shadow declarations."
