#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/security/Guardian.sol"
TMP="/tmp/Guardian_import_fix.tmp"

echo "== DEV-39 PATCH: Import für ISafetyAutomata =="

# 1️⃣ Backup
cp "$FILE" "$FILE.bak"

# 2️⃣ Prüfen, ob der Import bereits vorhanden ist
if ! grep -q 'ISafetyAutomata' "$FILE"; then
  awk '
  NR==1 {
    print "import \"../core/interfaces/ISafetyAutomata.sol\";";
    print "";
  }
  {print}
  ' "$FILE" > "$TMP" && mv "$TMP" "$FILE"
  echo "✓ Import hinzugefügt: ../core/interfaces/ISafetyAutomata.sol"
else
  echo "ℹ️ Import bereits vorhanden – Überspringe."
fi

# 3️⃣ Kompilieren & Tests ausführen
echo "== Forge Kompilation & Tests =="
forge clean && forge test --match-path "foundry/test/Guardian_OraclePropagation.t.sol" -vv || true
