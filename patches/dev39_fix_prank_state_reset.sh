#!/usr/bin/env bash
set -euo pipefail

TEST="foundry/test/Guardian_OraclePropagation.t.sol"
TMP="/tmp/Guardian_OraclePropagation_prankreset.tmp"

echo "== DEV-39 PATCH: Prank-State-Reset im setUp() =="

cp "$TEST" "$TEST.bak"

# Direkt vor vm.startPrank(dao) einen Reset erzwingen (durch stopPrank)
awk '
/vm\.startPrank\(dao\);/ && !inserted {
  print "        vm.stopPrank(); // ensure no previous prank active"
  print $0
  inserted=1
  next
}
{ print }
' "$TEST" > "$TMP" && mv "$TMP" "$TEST"

echo "✓ Safety-Reset vor startPrank() eingefügt."
echo
echo "== Forge Testlauf (Guardian_OraclePropagation) =="
forge clean && forge test --match-path "foundry/test/Guardian_OraclePropagation.t.sol" -vv
