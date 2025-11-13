#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-40 Structural Fix: restore HealthState scope =="

FILE="contracts/oracle/OracleWatcher.sol"
TMP="${FILE}.tmp"

awk '
# Wenn wir die Struct-Definition finden, tracken wir sie
/struct[[:space:]]+HealthState[[:space:]]*\{/ { in_struct=1; print; next }
in_struct && /^\}/ { in_struct=0; print; print ""; print "    // Moved variable declaration to contract level"; print "    HealthState _health;"; next }
{ print }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

forge clean && forge build

mkdir -p logs
printf "%s DEV-40 fix: restored struct scope + moved HealthState var to contract level (build successful)\n" "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" >> logs/project.log
echo "✅ Structural fix applied and build successful."
