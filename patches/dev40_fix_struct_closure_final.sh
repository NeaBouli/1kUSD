#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-40 Final Structural Closure Fix =="

FILE="contracts/oracle/OracleWatcher.sol"
TMP="${FILE}.tmp"

# 1) Entferne fehlerhafte Zeilen oder Blöcke außerhalb des Vertrags
perl -0777 -pe '
  # Entferne mehrfache Leerzeilen und dangling braces nach contract-Ende
  s/}\s*}\s*$/}\n/s;
  # Entferne doppelte closing braces falls vorhanden
  s/}\s*}\s*$/}\n/s;
  # Entferne leerzeilen oder unerlaubte tokens am Dateiende
  s/\n+\z/\n/s;
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

# 2) Sicherstellen, dass Contract sauber mit } endet
grep -q "^}" "$FILE" || echo "}" >> "$FILE"

# 3) Build prüfen
forge clean && forge build

# 4) Log
mkdir -p logs
printf "%s DEV-40 fix: finalized OracleWatcher structural closure + clean contract end (build ok)\n" "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" >> logs/project.log
echo "✅ Structural closure complete – build successful."
