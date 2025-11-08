#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/core/SafetyAutomata.sol"
TMP="/tmp/SafetyAutomata_grant_guardian_role.tmp"

echo "== DEV-39 PATCH: Guardian erhält automatisch GUARDIAN_ROLE in SafetyAutomata =="

cp "$FILE" "$FILE.bak"

awk '
/constructor/ && !done {
  print;
  print "        // Auto-grant Guardian role for constructor-defined guardian";
  print "        if (guardian != address(0)) {"; 
  print "            _grantRole(GUARDIAN_ROLE, guardian);";
  print "        }";
  done=1; next
}
{print}
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✓ Guardian erhält nun GUARDIAN_ROLE automatisch."
echo
echo "== Forge Test: Guardian_OraclePropagation =="
forge clean && forge test --match-path "foundry/test/Guardian_OraclePropagation.t.sol" -vv || true
