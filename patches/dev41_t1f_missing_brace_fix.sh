#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-41-T1f: insert missing closing brace in OracleRegression_Watcher.t.sol =="

FILE="foundry/test/oracle/OracleRegression_Watcher.t.sol"
TMP="${FILE}.tmp"

awk '
/assertTrue\(healthy, "initial watcher health should be true"\);/ {
  print $0;
  print "    }";  # schließt testInitialHealthIsHealthy korrekt
  next
}
{ print }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

forge clean && forge build

mkdir -p logs
printf "%s DEV-41-T1f: inserted missing closing brace in OracleRegression_Watcher.t.sol\n" "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" >> logs/project.log
echo "✅ Missing closing brace inserted – structure restored."
