#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/security/Guardian.sol"
TMP="/tmp/Guardian_force_import.tmp"

echo "== DEV-39 PATCH: Erzwinge Import an erster Stelle =="

# Backup
cp "$FILE" "$FILE.bak"

# Entferne alle alten Zeilen mit ISafetyAutomata (falls dupliziert)
grep -v "ISafetyAutomata" "$FILE" > "$TMP" && mv "$TMP" "$FILE"

# Füge Import direkt nach SPDX und pragma ein
awk '
NR==1 {print; next}
NR==2 {
  print "import \"../interfaces/ISafetyAutomata.sol\";";
  print "";
  next
}
{print}
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✓ Import ganz oben platziert."

# Teste Kompilation
echo "== Forge Kompilation & Tests =="
forge clean && forge test --match-path "foundry/test/Guardian_OraclePropagation.t.sol" -vv || true
