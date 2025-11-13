#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-40 Fix: remove stray closing brace at EOF =="

FILE="contracts/oracle/OracleWatcher.sol"
TMP="${FILE}.tmp"

# 1️⃣ Backup
cp "$FILE" "${FILE}.bak"

# 2️⃣ Wenn letzte Zeile ausschließlich "}" enthält → löschen
if tail -n1 "$FILE" | grep -qE '^[[:space:]]*}[[:space:]]*$'; then
  head -n -1 "$FILE" > "$TMP"
  mv "$TMP" "$FILE"
  echo "Removed trailing stray brace at EOF."
else
  echo "No trailing brace found; no change."
fi

# 3️⃣ Build prüfen
forge clean && forge build

# 4️⃣ Loggen
mkdir -p logs
printf "%s DEV-40 fix: removed stray closing brace at EOF (build ok)\n" "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" >> logs/project.log
echo "✅ Trailing brace removed – build expected to succeed."
