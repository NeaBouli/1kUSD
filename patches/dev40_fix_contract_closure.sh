#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-40 Fix: add missing contract closure before OracleWatcher =="

FILE="contracts/oracle/OracleWatcher.sol"
TMP="${FILE}.tmp"

awk '
NR==56 { print "    }"; print ""; print $0; next }  # füge } VOR Zeile 57 ein
{ print }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

forge clean && forge build

mkdir -p logs
printf "%s DEV-40 fix: inserted missing contract closure before OracleWatcher (build ok)\n" "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" >> logs/project.log
echo "✅ Missing contract closure added – build should now succeed."
