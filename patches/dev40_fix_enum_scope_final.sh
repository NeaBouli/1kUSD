#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-40 Final Enum Scope Fix: embed Status inside OracleWatcher =="

FILE="contracts/oracle/OracleWatcher.sol"
TMP="${FILE}.tmp"

# 1️⃣ Entferne alle bisherigen globalen Enum-Definitionen
perl -0777 -pe 's/enum\s+Status\s*\{[^}]*\}//g' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

# 2️⃣ Füge Enum sauber direkt nach der Contract-Headerzeile ein
awk '
/contract[[:space:]]+OracleWatcher/ && /\{/ {
  print $0
  print ""
  print "    /// @notice Operational state classification within OracleWatcher"
  print "    enum Status { Healthy, Paused, Stale }"
  next
}
{ print }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

# 3️⃣ Passe alle Funktionssignaturen an, damit sie den vollen Typnamen verwenden
#     → returns (OracleWatcher.Status)
perl -pi -e 's/returns\s*\(\s*Status\s*\)/returns (OracleWatcher.Status)/g' "$FILE"

# 4️⃣ Build prüfen
forge clean && forge build

# 5️⃣ Log
mkdir -p logs
printf "%s DEV-40 fix: restored enum inside OracleWatcher scope + namespaced returns (build ok)\n" "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" >> logs/project.log
echo "✅ Enum scope fixed and build successful."
