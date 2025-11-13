#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/security/Guardian.sol"
TMP="/tmp/Guardian_rebuild_section.tmp"

echo "== DEV-39 FINAL STRUCTURAL FIX: Rekonstruiere setSafetyAutomata + selfRegister Block =="

cp "$FILE" "$FILE.bak"

awk '
# Wir rekonstruieren den gesamten Bereich ab Zeile mit "setSafetyAutomata("
/function setSafetyAutomata/ {found=1; print "    // --- Wire SafetyAutomata explicitly from tests or deployment scripts ---"; print "    function setSafetyAutomata(ISafetyAutomata _safety) external {"; print "        require(address(_safety) != address(0), \"ZERO_ADDRESS\");"; print "        safetyAutomata = _safety;"; print "        emit SafetyWired(msg.sender, address(_safety));"; print "    }"; print ""; print "    /// @notice Auto-register this Guardian in SafetyAutomata (for testing and setup)"; print "    function selfRegister() external onlyActiveGuardian {"; print "        require(address(safetyAutomata) != address(0), \"SafetyAutomata not set\");"; print "        safetyAutomata.grantGuardian(address(this));"; print "    }"; print ""; next }
found && /^\s*}/ {found=0; next}
!found {print}
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✓ Guardian.sol Block sauber rekonstruiert."
echo
echo "-- Sichtprüfung Guardian.sol (Funktionsübergang) --"
nl -ba "$FILE" | sed -n "35,70p"
echo
echo "== Forge Build & Tests (Guardian_OraclePropagation) =="
forge clean && forge test --match-path "foundry/test/Guardian_OraclePropagation.t.sol" -vv || true
