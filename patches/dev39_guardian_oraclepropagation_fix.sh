#!/usr/bin/env bash
set -euo pipefail

TEST="foundry/test/Guardian_OraclePropagation.t.sol"
TMP="/tmp/Guardian_OraclePropagation_fix.tmp"

echo "== DEV-39: Patch Guardian_OraclePropagation.t.sol =="

cp "$TEST" "$TEST.bak"

###############################################################################
# A) setSafetyAutomata() + selfRegister() nach Guardian-Deployment einfügen
#    -> Sucht die Zeile mit 'guardian = new Guardian(' und fügt direkt danach:
#       guardian.setSafetyAutomata(safety);
#       guardian.selfRegister();
###############################################################################
awk '
/guardian[[:space:]]*=[[:space:]]*new[[:space:]]*Guardian\(/ && !done_link {
  print
  print "        guardian.setSafetyAutomata(safety);"
  print "        guardian.selfRegister();"
  done_link=1
  next
}
{ print }
' "$TEST" > "$TMP" && mv "$TMP" "$TEST"

echo "✓ Guardian wiring (setSafetyAutomata + selfRegister) eingefügt (falls gefehlt)."

###############################################################################
# B) Doppelte vm.prank-Zeilen ohne dazwischenliegenden Call entfernen
#    -> Wenn zwei vm.prank(..); direkt hintereinander stehen, lösche die zweite.
###############################################################################
awk '
function is_nonempty_code(line) {
  # echte Codezeile (nicht leer/Kommentar) zählt als "call" (reset)
  if (line ~ /^[[:space:]]*$/) return 0
  if (line ~ /^[[:space:]]*\/\//) return 0
  return 1
}

BEGIN { prank_armed = 0 }

{
  if ($0 ~ /vm\.prank\(/) {
    if (prank_armed == 1) {
      # zweite vm.prank unmittelbar ohne Call dazwischen -> skip
      next
    } else {
      prank_armed = 1
      print
      next
    }
  }

  # jede andere nicht-leere/nicht-Kommentar Zeile resetet den Zustand
  if (is_nonempty_code($0)) {
    prank_armed = 0
  }
  print
}
' "$TEST" > "$TMP" && mv "$TMP" "$TEST"

echo "✓ Doppelte vm.prank()-Aufrufe bereinigt."

echo
echo "== Forge: Build & gezielter Testlauf =="
forge clean && forge test --match-path "foundry/test/Guardian_OraclePropagation.t.sol" -vv
