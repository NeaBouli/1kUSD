#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/core/SafetyAutomata.sol"
TMP="/tmp/SafetyAutomata_grantguardian.tmp"

echo "== DEV-39 PATCH: grantGuardian() für Test-/DAO-Setup hinzufügen =="

cp "$FILE" "$FILE.bak"

awk '
/constructor/ {found_ctor=1}
found_ctor && /}/ && !added {
  print;
  print "";
  print "    /// @notice Grants GUARDIAN_ROLE to a given address (for Guardian wiring)";
  print "    function grantGuardian(address guardian) external onlyRole(ADMIN_ROLE) {";
  print "        _grantRole(GUARDIAN_ROLE, guardian);";
  print "    }";
  print "";
  added=1; next
}
{print}
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✓ grantGuardian() hinzugefügt."
echo
echo "== Forge Test (Guardian_OraclePropagation) =="
forge clean && forge test --match-path "foundry/test/Guardian_OraclePropagation.t.sol" -vv || true
