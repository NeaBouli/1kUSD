#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-40 Step 2: Interface Imports =="

FILE="contracts/oracle/OracleWatcher.sol"
TMP="${FILE}.tmp"

awk '
/pragma solidity/ { print; print ""; print "import { IOracleAggregator } from \"../core/OracleAggregator.sol\";"; next }
{ print }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

mkdir -p logs
printf "%s DEV-40 step2: added IOracleAggregator import to OracleWatcher (no builds)\n" "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" >> logs/project.log

echo "✅ DEV-40 Step 2 applied – import placeholder inserted (no builds)."
