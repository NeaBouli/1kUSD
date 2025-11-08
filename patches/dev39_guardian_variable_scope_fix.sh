#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/security/Guardian.sol"
TMP="/tmp/Guardian_variable_scope_fix.tmp"

echo "== DEV-39 FINAL STRUCTURAL PATCH: SafetyAutomata-Variable korrekt in den Contract-Körper verschieben =="

# Backup
cp "$FILE" "$FILE.bak"

# 1️⃣ Entferne alte (fehlplatzierte) Definitionen
grep -v "ISafetyAutomata public safetyAutomata" "$FILE" > "$TMP" && mv "$TMP" "$FILE"

# 2️⃣ Füge Variable direkt NACH den anderen state-Variablen ein (dao, sunsetBlock, paused)
awk '
/bool public paused;/ && !done {
  print;
  print "    ISafetyAutomata public safetyAutomata; // <== correctly placed for Oracle propagation linkage";
  done=1; next
}
{print}
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

# 3️⃣ Sichtprüfung
grep -n "ISafetyAutomata" "$FILE" | head -n 3

# 4️⃣ Kompilieren & Tests
echo "== Forge Kompilation & Tests =="
forge clean && forge test --match-path "foundry/test/Guardian_OraclePropagation.t.sol" -vv || true
