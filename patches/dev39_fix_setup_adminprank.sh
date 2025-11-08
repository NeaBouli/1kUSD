#!/usr/bin/env bash
set -euo pipefail

TEST="foundry/test/Guardian_OraclePropagation.t.sol"
TMP="/tmp/Guardian_OraclePropagation_setupfix.tmp"

echo "== DEV-39 PATCH: Füge Admin-Prank für grantGuardian() in setUp() hinzu =="

cp "$TEST" "$TEST.bak"

# Sucht grantGuardian-Aufruf oder selfRegister und umschließt ihn mit vm.startPrank(admin)/vm.stopPrank()
awk '
/safety\.grantGuardian\(address\(guardian\)\)/ && !patched {
  print "        vm.startPrank(admin);"
  print $0
  print "        vm.stopPrank();"
  patched=1
  next
}
/guardian\.selfRegister\(\)/ && !patched {
  print "        vm.startPrank(admin);"
  print $0
  print "        vm.stopPrank();"
  patched=1
  next
}
{ print }
' "$TEST" > "$TMP" && mv "$TMP" "$TEST"

echo "✓ Admin-Prank in setUp() eingebaut."
echo
echo "== Forge: Finaler Testlauf =="
forge clean && forge test --match-path "foundry/test/Guardian_OraclePropagation.t.sol" -vv
