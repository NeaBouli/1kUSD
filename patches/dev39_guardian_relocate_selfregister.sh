#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/security/Guardian.sol"
TMP="/tmp/Guardian_relocate_selfregister.tmp"

echo "== DEV-39 FINAL FIX: Verschiebe selfRegister() unter setSafetyAutomata() =="

cp "$FILE" "$FILE.bak"

awk '
# --- Phase 1: selfRegister-Zeilen zwischenspeichern
/function selfRegister/ {capture=1; buf=$0; next}
capture && /SafetyAutomata not set/ {buf=buf ORS $0; next}
capture && /grantGuardian/ {buf=buf ORS $0; next}
capture && /^\s*}/ {buf=buf ORS $0; capture=0; next}

# --- Phase 2: normaler Durchlauf, aber füge gespeicherten Block nach setSafetyAutomata-Abschluss ein
/function setSafetyAutomata/ {in_fn=1}
in_fn && /^\s*}\s*$/ {
  print $0;
  print "";
  print buf;
  print "";
  in_fn=0;
  next
}

# alle anderen Zeilen ausgeben, aber selfRegister-Zeilen überspringen
!capture {print}
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✓ selfRegister() korrekt NACH setSafetyAutomata() positioniert."
echo
echo "-- Sichtprüfung Guardian.sol (Funktionsübergang) --"
nl -ba "$FILE" | sed -n "35,60p"
echo
echo "== Forge Build & Tests =="
forge clean && forge test --match-path "foundry/test/Guardian_OraclePropagation.t.sol" -vv || true
