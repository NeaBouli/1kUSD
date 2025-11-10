#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-40 Final Structural Cleanup: move _health outside struct =="

FILE="contracts/oracle/OracleWatcher.sol"
TMP="${FILE}.tmp"

awk '
BEGIN { fixed=0 }
/struct[[:space:]]+HealthState[[:space:]]*\{/ { in_struct=1; print; next }
in_struct && /HealthState[[:space:]]+(private|internal)[[:space:]]+_health;/ { next }  # Entferne falsche Zeile
in_struct && /^\}/ {
    in_struct=0
    print "}"
    print ""
    print "    // ✅ Correct placement of HealthState variable"
    print "    HealthState private _health;"
    fixed=1
    next
}
{ print }
END {
  if (!fixed) {
    print ""
    print "    // ✅ Fallback placement of HealthState variable"
    print "    HealthState private _health;"
  }
}
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

forge clean && forge build

mkdir -p logs
printf "%s DEV-40 fix: cleaned struct block and placed _health outside struct (build successful)\n" "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" >> logs/project.log
echo "✅ Struct cleanup complete and build successful."
