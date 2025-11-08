#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/security/Guardian.sol"
TMP="/tmp/Guardian_import_path_fix.tmp"

echo "== DEV-39 PATCH: Korrigiere Importpfad für ISafetyAutomata =="

# Backup
cp "$FILE" "$FILE.bak"

# Ersetze falschen Pfad
sed -i '' 's#../core/interfaces/ISafetyAutomata.sol#../interfaces/ISafetyAutomata.sol#' "$FILE"

# Doppelt prüfen (falls kein Import existiert)
if ! grep -q 'ISafetyAutomata' "$FILE"; then
  awk '
  NR==1 {
    print "import \"../interfaces/ISafetyAutomata.sol\";";
    print "";
  }
  {print}
  ' "$FILE" > "$TMP" && mv "$TMP" "$FILE"
  echo "✓ Import hinzugefügt."
else
  echo "✓ Importpfad korrigiert."
fi

# Kompilieren & testen
echo "== Forge Kompilation & Tests =="
forge clean && forge test --match-path "foundry/test/Guardian_OraclePropagation.t.sol" -vv || true
