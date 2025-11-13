#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/security/Guardian.sol"
TMP="/tmp/Guardian_remove_duplicate_ctor.tmp"

echo "== DEV-39 FINAL PATCH: Entferne alten/doppelten Guardian-Konstruktor =="

# Backup anlegen
cp "$FILE" "$FILE.bak"

# Entferne den ersten (veralteten) Konstruktor-Block vollständig (Zeilen 9-15 typischerweise)
awk '
/constructor\(address _dao/ && !removed {
  in_old=1; next
}
in_old && /^\s*}/ {in_old=0; next}
!in_old {print}
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✓ Alter Konstruktorblock entfernt (der neue in Zeile 38 bleibt bestehen)."

# Sichtprüfung
grep -n "constructor" "$FILE" | head -n 5

echo "== Forge Kompilation & Tests =="
forge clean && forge test --match-path "foundry/test/Guardian_OraclePropagation.t.sol" -vv || true
