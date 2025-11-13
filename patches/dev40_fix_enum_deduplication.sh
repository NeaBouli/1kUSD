#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-40 Fix: remove duplicate enum Status in OracleWatcher =="

FILE="contracts/oracle/OracleWatcher.sol"
TMP="${FILE}.tmp"

# Entferne lokale Enum-Definition
awk '!/enum[[:space:]]+Status[[:space:]]*\{/' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

# Ersetze alle lokalen Status-Verweise durch Interface-Namespace
sed -i '' 's/\bStatus\b/IOracleWatcher.Status/g' "$FILE"

forge clean && forge build

mkdir -p logs
printf "%s DEV-40 fix: removed duplicate enum Status and namespaced references (build ok)\n" \
  "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" >> logs/project.log

echo "✅ Duplicate enum removed, build expected to succeed."
