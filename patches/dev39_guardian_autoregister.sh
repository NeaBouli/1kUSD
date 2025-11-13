#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/security/Guardian.sol"
TMP="/tmp/Guardian_autoregister.tmp"

echo "== DEV-39 PATCH: Guardian kann sich selbst bei SafetyAutomata registrieren =="

cp "$FILE" "$FILE.bak"

awk '
/function setSafetyAutomata/ && !done {
  print;
  print "";
  print "    /// @notice Auto-register this Guardian in SafetyAutomata (for testing and setup)";
  print "    function selfRegister() external onlyActiveGuardian {";
  print "        require(address(safetyAutomata) != address(0), \"SafetyAutomata not set\");";
  print "        safetyAutomata.grantGuardian(address(this));";
  print "    }";
  print "";
  done=1; next
}
{print}
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✓ Guardian.selfRegister() hinzugefügt."
echo
echo "== Forge Test (Guardian_OraclePropagation) =="
forge clean && forge test --match-path "foundry/test/Guardian_OraclePropagation.t.sol" -vv || true
