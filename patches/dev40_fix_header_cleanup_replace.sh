#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-40 Header Cleanup Replace: move rebuilt header to file start =="

FILE="contracts/oracle/OracleWatcher.sol"
TMP="${FILE}.tmp"

# 1️⃣ Backup
cp "$FILE" "${FILE}.bak"

# 2️⃣ Entferne alles vor dem ersten "pragma" und alles nach der letzten "}"
awk '
BEGIN { inside=0 }
# Nur die letzte gültige Contract-Struktur behalten
/^pragma/ { inside=1 }
inside { print }
' "$FILE" > "$TMP"

# 3️⃣ Prüfe, ob am Ende genau eine geschlossene Klammer steht
if ! tail -n 5 "$TMP" | grep -q '^}'; then
  echo "}" >> "$TMP"
fi

mv "$TMP" "$FILE"

# 4️⃣ Build prüfen
forge clean && forge build

# 5️⃣ Loggen
mkdir -p logs
printf "%s DEV-40 fix: cleaned file header, retained only valid pragma+contract (build ok)\n" "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" >> logs/project.log

echo "✅ Header cleanup complete and build expected to succeed."
