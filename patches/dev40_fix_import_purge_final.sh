#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-40 Fix: purge all imports below header =="

FILE="contracts/oracle/OracleWatcher.sol"
TMP="${FILE}.tmp"

# 1️⃣ Backup
cp "$FILE" "${FILE}.bak"

# 2️⃣ Alle Zeilen nach der ersten 10 durchsuchen und späte Imports entfernen
awk '
NR<=10 { print; next }
# lösche alle import-Zeilen (mit oder ohne Klammern)
!/^[[:space:]]*import[[:space:]]/ { print }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

# 3️⃣ Validierung
echo "=== Remaining imports ==="
grep -n "^import" "$FILE" || echo "(none beyond header)"

# 4️⃣ Build
forge clean && forge build

# 5️⃣ Log
mkdir -p logs
printf "%s DEV-40 fix: purged stray imports beyond header (build ok)\n" "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" >> logs/project.log
echo "✅ All stray import lines removed – build expected to succeed."
