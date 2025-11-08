#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/core/SafetyAutomata.sol"
TMP="/tmp/SafetyAutomata_final_guardianrole.tmp"

echo "== DEV-39 FINAL PATCH: Auto-grant GUARDIAN_ROLE to deployer (msg.sender) =="

cp "$FILE" "$FILE.bak"

awk '
/constructor\(address admin, uint256 guardianSunsetTimestamp\)/ {
  print;
  in_constructor=1; next
}
in_constructor && /{/ {
  print;
  print "        // Auto-grant GUARDIAN_ROLE to deployer for Guardian control linkage";
  print "        _grantRole(GUARDIAN_ROLE, msg.sender);";
  in_constructor=0; next
}
{print}
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✓ GUARDIAN_ROLE wird jetzt beim Deployment automatisch an msg.sender vergeben."
echo
echo "== Forge Test: Guardian_OraclePropagation =="
forge clean && forge test --match-path "foundry/test/Guardian_OraclePropagation.t.sol" -vv || true
