#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/security/Guardian.sol"
TMP="/tmp/Guardian_contract_brace_fix.tmp"

echo "== DEV-39 FINAL STRUCTURAL FIX: Öffnende Klammer nach contract Guardian wiederherstellen =="

# Backup
cp "$FILE" "$FILE.bak"

# Prüfen, ob contract-Zeile keine { enthält
if grep -q "^contract Guardian" "$FILE"; then
  awk '
  /^contract Guardian/ {
    if ($0 !~ /{/) {
      print $0 " {"
      next
    }
  }
  {print}
  ' "$FILE" > "$TMP" && mv "$TMP" "$FILE"
  echo "✓ Klammer nach 'contract Guardian' gesetzt (falls gefehlt)."
else
  echo "⚠️ Keine Contract-Zeile gefunden!"
fi

# Sichtprüfung
grep -n "contract Guardian" "$FILE" | head -n 3

# Kompilieren & Test
echo "== Forge Kompilation & Tests =="
forge clean && forge test --match-path "foundry/test/Guardian_OraclePropagation.t.sol" -vv || true
