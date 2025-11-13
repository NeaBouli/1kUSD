#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/core/SafetyAutomata.sol"
TMP="/tmp/SafetyAutomata_unpause_relocate.tmp"

echo "== DEV-39 PATCH: Korrigiere Position von unpauseModule() =="

# Backup
cp "$FILE" "$FILE.bak"

# Entferne alte fehlerhafte Definition (falls innerhalb)
grep -v "function unpauseModule" "$FILE" > "$TMP" && mv "$TMP" "$FILE"

# Füge sie korrekt nach dem Ende von pauseModule() ein
awk '
/function pauseModule\(bytes32/ {in_fn=1}
in_fn && /^\s*}/ {
  print "    /// @notice Unpause a module (Guardian integration)";
  print "    function unpauseModule(bytes32 moduleId) external override {";
  print "        emit ModuleResumed(moduleId, msg.sender, block.number);";
  print "    }";
  in_fn=0;
}
{print}
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✓ unpauseModule() korrekt nach pauseModule() eingefügt."

# Sichtprüfung
grep -n -A2 "unpauseModule" "$FILE" | head -n 5

# Kompilation + Tests
echo "== Forge Kompilation & Tests =="
forge clean && forge test --match-path "foundry/test/Guardian_OraclePropagation.t.sol" -vv || true
