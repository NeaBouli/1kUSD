#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/interfaces/ISafetyAutomata.sol"
TMP="/tmp/ISafetyAutomata_extend.tmp"

echo "== DEV-39 PATCH: Ergänze Schreibmethoden pause/unpauseModule =="

# Backup
cp "$FILE" "$FILE.bak"

# Füge neue Funktionen direkt nach der globalPause()-Definition ein
awk '
/function globalPause/ && !done {
  print;
  print "";
  print "    /// @notice Pause a module (used by Guardian or system admin)";
  print "    function pauseModule(bytes32 moduleId) external;";
  print "";
  print "    /// @notice Unpause a module (used by Guardian or system admin)";
  print "    function unpauseModule(bytes32 moduleId) external;";
  done=1; next
}
{print}
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✓ Methoden pauseModule / unpauseModule hinzugefügt."

# Sichtprüfung
grep -n "pauseModule" "$FILE" | head -n 2
grep -n "unpauseModule" "$FILE" | head -n 2

# Kompilieren & Testen
echo "== Forge Kompilation & Tests =="
forge clean && forge test --match-path "foundry/test/Guardian_OraclePropagation.t.sol" -vv || true
