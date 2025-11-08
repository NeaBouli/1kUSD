#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/security/Guardian.sol"
TMP="/tmp/Guardian_fix_eof.tmp"

echo "== DEV-39 FINAL EOF FIX: Guardian.sol korrekt abschließen =="

cp "$FILE" "$FILE.bak"

# Wenn letzte Zeile kein "}" enthält, füge eine schließende Klammer hinzu
if ! tail -n 1 "$FILE" | grep -q "}"; then
  echo "}" >> "$FILE"
  echo "✓ Fehlende Abschlussklammer hinzugefügt."
else
  echo "ℹ️ Abschlussklammer bereits vorhanden."
fi

echo
echo "-- Letzte Zeilen Guardian.sol --"
tail -n 10 "$FILE"

echo
echo "== Forge Build & Tests (Guardian_OraclePropagation) =="
forge clean && forge test --match-path "foundry/test/Guardian_OraclePropagation.t.sol" -vv || true
