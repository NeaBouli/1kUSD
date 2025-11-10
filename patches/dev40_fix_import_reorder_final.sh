#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-40 Fix: reorder imports to top and remove duplicates =="

FILE="contracts/oracle/OracleWatcher.sol"
TMP="${FILE}.tmp"

# 1️⃣ Backup
cp "$FILE" "${FILE}.bak"

# 2️⃣ Alle Importzeilen extrahieren (einmalig)
imports=$(grep '^import' "$FILE" | sort | uniq)

# 3️⃣ Datei neu aufbauen – pragma + Imports ganz oben, alte Imports entfernen
awk -v imps="$imports" '
BEGIN { inserted=0 }
/^pragma solidity/ && !inserted {
  print $0
  print ""
  print imps
  print ""
  inserted=1
  next
}
/^import/ { next } # alte Imports überspringen
{ print }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

# 4️⃣ Build prüfen
forge clean && forge build

# 5️⃣ Loggen
mkdir -p logs
printf "%s DEV-40 fix: reordered imports to file top and removed duplicates (build ok)\n" "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" >> logs/project.log
echo "✅ Imports reordered and duplicates removed. Build expected to succeed."
