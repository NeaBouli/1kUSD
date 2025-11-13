#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/core/SafetyAutomata.sol"
TMP="/tmp/SafetyAutomata_stub_fix.tmp"

echo "== DEV-39 PATCH: Dummy-Implementierungen für pause/unpauseModule =="

# Backup
cp "$FILE" "$FILE.bak"

# Prüfen, ob schon vorhanden
if ! grep -q "pauseModule(bytes32" "$FILE"; then
  awk '
  /function globalPause/ && !done {
    print;
    print "    // --- Added for Guardian integration ---";
    print "    function pauseModule(bytes32 moduleId) external override {";
    print "        emit ModulePaused(moduleId, msg.sender, block.number);";
    print "    }";
    print "";
    print "    function unpauseModule(bytes32 moduleId) external override {";
    print "        emit ModuleResumed(moduleId, msg.sender, block.number);";
    print "    }";
    done=1; next
  }
  {print}
  ' "$FILE" > "$TMP" && mv "$TMP" "$FILE"
  echo "✓ Dummy-Funktionen in SafetyAutomata hinzugefügt."
else
  echo "ℹ️ Stubs bereits vorhanden."
fi

# Sichtprüfung
grep -n "pauseModule" "$FILE" | head -n 2
grep -n "unpauseModule" "$FILE" | head -n 2

echo "== Forge Build (Syntaxcheck) =="
forge build || true
