#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/security/Guardian.sol"
TMP="/tmp/Guardian_autoregister_fix.tmp"

echo "== DEV-39 FIX: selfRegister() außerhalb der vorherigen Funktion platzieren =="

cp "$FILE" "$FILE.bak"

awk '
/function setSafetyAutomata/ && !done {
  print;
  in_fn=1; next
}
in_fn && /^\s*}/ {
  print "    }";
  print "";
  print "    /// @notice Auto-register this Guardian in SafetyAutomata (for testing and setup)";
  print "    function selfRegister() external onlyActiveGuardian {";
  print "        require(address(safetyAutomata) != address(0), \"SafetyAutomata not set\");";
  print "        safetyAutomata.grantGuardian(address(this));";
  print "    }";
  print "";
  in_fn=0; done=1; next
}
{print}
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✓ selfRegister() korrekt außerhalb der vorherigen Funktion eingefügt."
echo
echo "== Forge Build & Tests =="
forge clean && forge test --match-path "foundry/test/Guardian_OraclePropagation.t.sol" -vv || true
