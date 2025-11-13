#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-40 Cleanup-to-EOF: truncate trailing content after contract =="

FILE="contracts/oracle/OracleWatcher.sol"
TMP="${FILE}.tmp"

# 1️⃣ Entferne alles nach der letzten schließenden Contract-Klammer
awk '{
  lines[NR]=$0
}
END {
  last_brace=0
  for (i=1;i<=NR;i++) if (lines[i] ~ /^}/) last_brace=i
  for (i=1;i<=last_brace;i++) print lines[i]
}' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

# 2️⃣ Stelle sicher, dass Datei mit genau einer Zeile "}" endet
if ! tail -n1 "$FILE" | grep -q "^}$"; then
  echo "}" >> "$FILE"
fi

# 3️⃣ Build prüfen
forge clean && forge build

# 4️⃣ Log
mkdir -p logs
printf "%s DEV-40 fix: truncated trailing content after contract (build ok)\n" "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" >> logs/project.log
echo "✅ Cleanup complete – OracleWatcher should now compile successfully."
