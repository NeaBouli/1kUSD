#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/core/SafetyAutomata.sol"
TMP="/tmp/SafetyAutomata_add_events.tmp"

echo "== DEV-39 PATCH: Füge Events ModulePaused / ModuleResumed hinzu =="

# Backup
cp "$FILE" "$FILE.bak"

# Nur einfügen, wenn nicht vorhanden
if ! grep -q "event ModulePaused" "$FILE"; then
  awk '
  /Control API/ && !done {
    print;
    print "";
    print "    // --- Events for Guardian & external observers ---";
    print "    event ModulePaused(bytes32 indexed module, address indexed by, uint256 atBlock);";
    print "    event ModuleResumed(bytes32 indexed module, address indexed by, uint256 atBlock);";
    print "";
    done=1; next
  }
  {print}
  ' "$FILE" > "$TMP" && mv "$TMP" "$FILE"
  echo "✓ Events ModulePaused / ModuleResumed hinzugefügt."
else
  echo "ℹ️ Events bereits vorhanden – nichts geändert."
fi

# Sichtprüfung
grep -n "event Module" "$FILE" | head -n 10

# Kompilation & Tests
echo
echo "== Forge Kompilation & Tests =="
forge clean && forge test --match-path "foundry/test/Guardian_OraclePropagation.t.sol" -vv || true
