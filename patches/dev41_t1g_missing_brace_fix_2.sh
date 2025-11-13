#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-41-T1g: insert missing closing brace after testPausePropagation =="

FILE="foundry/test/oracle/OracleRegression_Watcher.t.sol"
TMP="${FILE}.tmp"

awk '
/assertFalse\(healthy, "watcher should detect pause"\);/ {
  print $0;
  print "    }";  # closes testPausePropagation correctly
  next
}
{ print }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

forge clean && forge build

mkdir -p logs
printf "%s DEV-41-T1g: inserted second missing closing brace in OracleRegression_Watcher.t.sol\n" "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" >> logs/project.log
echo "✅ Second missing closing brace inserted – structure fully restored."
