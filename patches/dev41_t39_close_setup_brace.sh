#!/usr/bin/env bash
set -euo pipefail
FILE="foundry/test/oracle/OracleRegression_Watcher.t.sol"
TMP="${FILE}.tmp"

echo "== DEV-41-T39: Add missing closing brace for setUp() =="

cp -n "$FILE" "${FILE}.bak.t39" || true

awk '
  BEGIN {inserted=0}
  {
    # Wenn testInitialHealth... gefunden wird, prüfen, ob vorher kein } vorhanden ist
    if ($0 ~ /function testInitialHealthIsHealthy/ && !inserted) {
      print "    }"  # fehlende schließende Klammer für setUp()
      inserted=1
    }
    print
  }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✅ Added missing closing brace for setUp()."
