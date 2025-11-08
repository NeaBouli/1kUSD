#!/usr/bin/env bash
set -euo pipefail

TEST="foundry/test/Guardian_OraclePropagation.t.sol"
TMP="/tmp/Guardian_OraclePropagation_fix_admin.tmp"

cp "$TEST" "$TEST.bak"

echo "== DEV-39 FIX: Ersetze guardian.selfRegister() durch dao-granted grantGuardian() =="

awk '
# Ersetze selfRegister()-Block durch Admin-grant-Call
/guardian\.selfRegister\(\)\s*;/ {
  print "        vm.startPrank(dao);"
  print "        safety.grantGuardian(address(guardian));"
  print "        vm.stopPrank();"
  next
}
{ print }
' "$TEST" > "$TMP" && mv "$TMP" "$TEST"

echo "✓ guardian.selfRegister() im Test ersetzt durch dao-grant-Call."
echo
echo "== Forge: Finaler Testlauf =="
forge clean && forge test --match-path "foundry/test/Guardian_OraclePropagation.t.sol" -vv
