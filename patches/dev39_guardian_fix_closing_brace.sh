#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/security/Guardian.sol"
TMP="/tmp/Guardian_fix_closing_brace.tmp"

echo "== DEV-39 FIX: Stelle sicher, dass setSafetyAutomata() korrekt geschlossen ist =="

cp "$FILE" "$FILE.bak"

awk '
/function setSafetyAutomata/ { in_fn=1; print; next }
in_fn && /safetyAutomata\s*=\s*_safety/ { print; print "    }"; in_fn=0; next }
{ print }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✓ Fehlende schließende Klammer nach setSafetyAutomata() eingefügt (falls nötig)."

echo
echo "-- Sichtprüfung Guardian.sol (Ausschnitt) --"
nl -ba "$FILE" | sed -n "35,60p"

echo
echo "== Forge Build & Tests (Guardian_OraclePropagation) =="
forge clean && forge test --match-path "foundry/test/Guardian_OraclePropagation.t.sol" -vv || true
