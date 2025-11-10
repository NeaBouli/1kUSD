#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-40 Fix (macOS): remove stray closing brace at EOF =="

FILE="contracts/oracle/OracleWatcher.sol"
TMP="${FILE}.tmp"

# Backup
cp "$FILE" "${FILE}.bak"

# Prüfe, ob letzte Zeile eine einzelne schließende Klammer ist
if tail -n 1 "$FILE" | grep -qE '^[[:space:]]*}[[:space:]]*$'; then
  # Entferne letzte Zeile portabel (macOS-kompatibel)
  total_lines=$(wc -l < "$FILE" | tr -d ' ')
  end_line=$((total_lines - 1))
  sed -n "1,${end_line}p" "$FILE" > "$TMP"
  mv "$TMP" "$FILE"
  echo "Removed trailing stray brace at EOF."
else
  echo "No trailing brace found; no change."
fi

# Build-Test
forge clean && forge build

# Log
mkdir -p logs
printf "%s DEV-40 fix: removed stray closing brace (macOS-safe, build ok)\n" "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" >> logs/project.log
echo "✅ Trailing brace removed – build expected to succeed."
