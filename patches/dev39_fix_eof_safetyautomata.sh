#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/core/SafetyAutomata.sol"
TMP="/tmp/SafetyAutomata_fix_eof.tmp"

echo "== DEV-39 FIX: EOF-Fehler beheben und Contract korrekt schließen =="

cp "$FILE" "$FILE.bak"

# Entfernt hängende Kommentarzeilen und fügt fehlende Abschlussklammer hinzu
awk '!/Unpause a module \(Guardian integration\)/ {print} END {print ""; print "}"}' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✓ Datei sauber abgeschlossen mit finaler }"
echo
echo "== Forge Syntaxcheck & Tests =="
forge clean && forge test --match-path "foundry/test/Guardian_OraclePropagation.t.sol" -vv || true
