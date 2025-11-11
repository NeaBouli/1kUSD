#!/usr/bin/env bash
set -euo pipefail
FILE="foundry/test/oracle/OracleRegression_Watcher.t.sol"
TMP="${FILE}.tmp"

echo "== DEV-41-T2: Syntax fix for OracleRegression_Watcher.t.sol =="

# 1) Safety-Backup
cp -n "$FILE" "${FILE}.bak" || true

# 2) Zielgerichtete Reparatur:
#    - Ab der Zeile mit 'assertFalse(healthy, "watcher should detect pause");'
#      bis zum Dateiende wird der Block durch saubere Closures ersetzt:
#        }                                // schließt testPausePropagation()
#        function testRefreshAlias() ...  // neue Funktionsdeklaration
#        }                                // schließt testRefreshAlias()
#        }                                // schließt contract
awk '
  BEGIN { replace=0 }
  {
    if (!replace) {
      print $0
    }
    if ($0 ~ /assertFalse\(healthy, "watcher should detect pause"\);/) {
      # Bis zum Dateiende alles ersetzen:
      print "    }"
      print "    /// @notice Verify manual refresh triggers same logic"
      print "    function testRefreshAlias() public {"
      print "        watcher.refreshState();"
      print "        assertTrue(watcher.isHealthy(), \"refreshState should not alter state\");"
      print "    }"
      print "}"
      exit 0
    }
  }
' "$FILE" > "$TMP"

mv "$TMP" "$FILE"

# 3) Mini-Check: Klammerzählung
opens=$(grep -o '{' "$FILE" | wc -l | tr -d ' ')
closes=$(grep -o '}' "$FILE" | wc -l | tr -d ' ')
echo "Braces => {:$opens }:$closes"
if [ "$opens" -ne "$closes" ]; then
  echo "ERROR: Unbalanced braces after patch!" >&2
  exit 1
fi

echo "✅ Patch applied successfully."
