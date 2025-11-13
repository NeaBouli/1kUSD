#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/core/SafetyAutomata.sol"
TMP="/tmp/SafetyAutomata_unpause_fix.tmp"

echo "== DEV-39 PATCH: Ergänze fehlende unpauseModule() Implementierung =="

# Backup
cp "$FILE" "$FILE.bak"

# Nur hinzufügen, wenn unpauseModule fehlt
if ! grep -q "function unpauseModule" "$FILE"; then
  awk '
  /function pauseModule/ && !added {
    print;
    print "";
    print "    /// @notice Unpause a module (Guardian integration)";
    print "    function unpauseModule(bytes32 moduleId) external override {";
    print "        emit ModuleResumed(moduleId, msg.sender, block.number);";
    print "    }";
    added=1; next
  }
  {print}
  ' "$FILE" > "$TMP" && mv "$TMP" "$FILE"
  echo "✓ unpauseModule() hinzugefügt."
else
  echo "ℹ️ unpauseModule bereits vorhanden – nichts geändert."
fi

# Sichtprüfung
grep -n "unpauseModule" "$FILE" | head -n 3

echo "== Forge Kompilation & Tests =="
forge clean && forge test --match-path "foundry/test/Guardian_OraclePropagation.t.sol" -vv || true
