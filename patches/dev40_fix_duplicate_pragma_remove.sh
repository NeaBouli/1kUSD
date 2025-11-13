#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-40 Fix: remove duplicate pragma solidity statements =="

FILE="contracts/oracle/OracleWatcher.sol"
TMP="${FILE}.tmp"

# 1️⃣ Backup
cp "$FILE" "${FILE}.bak"

# 2️⃣ Nur die erste pragma solidity behalten
awk '
/pragma solidity/ {
  if (seen++) next
}
{ print }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

# 3️⃣ Validierung
echo "=== Remaining pragma lines ==="
grep -n "pragma solidity" "$FILE"

# 4️⃣ Build
forge clean && forge build

mkdir -p logs
printf "%s DEV-40 fix: removed duplicate pragma solidity (build ok)\n" "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" >> logs/project.log
echo "✅ Duplicate pragma removed and build successful."
