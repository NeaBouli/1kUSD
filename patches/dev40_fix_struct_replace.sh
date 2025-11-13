#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-40 Final Struct Replace: canonical HealthState + _health on contract level =="

FILE="contracts/oracle/OracleWatcher.sol"

# 1) Ersetze den kompletten HealthState-Struct-Block durch eine kanonische Version
#    und füge unmittelbar danach genau EINE Deklaration `HealthState private _health;` ein.
#    - Entfernt zugleich etwaige falsche Sichtbarkeits-Keywords innerhalb des Structs.
#    - Idempotent: wiederholtes Ausführen lässt die Datei im korrekten Zustand.
perl -0777 -pe '
  s/struct\s+HealthState\s*\{.*?\}\s*/struct HealthState {\n        Status status;\n        uint256 lastUpdate;\n        bool cached;\n    }\n\n    HealthState private _health;\n/s
' "$FILE" > "${FILE}.tmp" && mv "${FILE}.tmp" "$FILE"

# 2) Doppelte _health-Deklarationen außerhalb des Structs vermeiden:
#    - entferne (bis auf die erste nach dem Struct) alle weiteren HealthState *_health;-Zeilen
#    (Einfache Heuristik: lässt die zuerst platzierte stehen, entfernt nachfolgende Duplikate)
awk '
  /HealthState[[:space:]]+(private|internal|public|)[[:space:]]*_health;/ {
    if (seen++) next
  }
  { print }
' "$FILE" > "${FILE}.tmp" && mv "${FILE}.tmp" "$FILE"

# 3) Build prüfen
forge clean && forge build

# 4) Log
mkdir -p logs
printf "%s DEV-40 fix: canonical HealthState struct + single _health declaration; build ok\n" "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" >> logs/project.log

echo "✅ Struct replaced & _health placed on contract-level. Build success."
