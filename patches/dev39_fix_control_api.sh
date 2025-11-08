#!/usr/bin/env bash
set -euo pipefail

SAFETY="contracts/core/SafetyAutomata.sol"
GUARD="contracts/security/Guardian.sol"
TMP="/tmp/dev39_safety_fix.tmp"

echo "== DEV-39: Fix SafetyAutomata Control API (pause/unpause) =="

# 1) Backups
cp "$SAFETY" "$SAFETY.bak"
cp "$GUARD" "$GUARD.bak"

###############################################################################
# 2) SafetyAutomata: Rekonstruiere den Bereich pauseModule(..) sauber und
#    füge unpauseModule(..) direkt hinter pauseModule(..) ein.
###############################################################################
# Wir entfernen alles vom Beginn der defekten pauseModule(..) bis VOR resumeModule(..)
# und setzen zwei saubere Funktionen (pauseModule + unpauseModule) ein.
awk '
  BEGIN{replaced=0}
  /function pauseModule\(bytes32 moduleId\) external/ && !replaced {
    # Start defekten Block überspringen
    skip=1; next
  }
  skip && /function resumeModule\(bytes32 moduleId\) external/ {
    # Vor resumeModule die sauberen Implementierungen einfügen
    print ""
    print "    /// @notice Pause a specific module. Guardian/DAO/Admin by role."
    print "    function pauseModule(bytes32 moduleId) external override {"
    print "        _pauseModule(moduleId, msg.sender);"
    print "        emit ModulePaused(moduleId, msg.sender, block.number);"
    print "    }"
    print ""
    print "    /// @notice Unpause a specific module. Interface compat for Guardian."
    print "    function unpauseModule(bytes32 moduleId) external override {"
    print "        _resumeModule(moduleId, msg.sender);"
    print "        emit ModuleResumed(moduleId, msg.sender, block.number);"
    print "    }"
    print ""
    # Jetzt resumeModule Zeile ausgeben und skip beenden
    print $0
    skip=0; replaced=1; next
  }
  !skip {print}
' "$SAFETY" > "$TMP" && mv "$TMP" "$SAFETY"

echo "✓ SafetyAutomata: pause/unpauseModule rekonstruiert."

###############################################################################
# 3) Guardian: pragma solidity sicherstellen (einfügen, falls fehlt)
###############################################################################
if ! grep -q '^pragma solidity' "$GUARD"; then
  awk '
    NR==1 { print $0; next }
    NR==2 {
      print "pragma solidity ^0.8.30;";
      print $0;
      next
    }
    { print }
  ' "$GUARD" > "$TMP" && mv "$TMP" "$GUARD"
  echo "✓ Guardian: pragma solidity ^0.8.30 hinzugefügt."
else
  echo "ℹ︎ Guardian: pragma bereits vorhanden."
fi

###############################################################################
# 4) Sichtprüfungen
###############################################################################
echo
echo "-- SAFETY (Kontext um Control API) --"
nl -ba "$SAFETY" | sed -n "60,110p" || true
echo
echo "-- GUARDIAN (Header) --"
nl -ba "$GUARD" | sed -n "1,40p" || true

###############################################################################
# 5) Build & Tests
###############################################################################
echo
echo "== Forge Build & Tests (nur betroffener Test) =="
forge clean && forge test --match-path "foundry/test/Guardian_OraclePropagation.t.sol" -vv
