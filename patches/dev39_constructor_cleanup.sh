#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/core/SafetyAutomata.sol"
TMP="/tmp/SafetyAutomata_constructor_cleanup.tmp"

echo "== DEV-39 FIX: Entferne doppelte schließende Klammern im Konstruktor =="

cp "$FILE" "$FILE.bak"

awk 'NR==36 || NR==41 { next } { print }' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✓ Überzählige } entfernt (Zeilen 36 & 41)."
echo
echo "== Forge Build & Test (Guardian_OraclePropagation) =="

forge clean && forge test --match-path "foundry/test/Guardian_OraclePropagation.t.sol" -vv || true
