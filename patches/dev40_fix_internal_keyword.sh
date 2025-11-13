#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-40 Fix: misplaced 'internal' keyword on HealthState =="

FILE="contracts/oracle/OracleWatcher.sol"
TMP="${FILE}.tmp"

# Ersetze fehlerhafte Zeile durch korrektes private-Layout
awk '
/HealthState[[:space:]]+internal[[:space:]]+_health;/ {
  print "    HealthState private _health;";
  next;
}
{ print }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

forge clean && forge build

mkdir -p logs
printf "%s DEV-40 fix: corrected misplaced internal keyword in OracleWatcher (HealthState) and built successfully\n" "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" >> logs/project.log

echo "✅ Keyword fixed and build successful."
