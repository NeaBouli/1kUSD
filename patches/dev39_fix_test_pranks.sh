#!/usr/bin/env bash
set -euo pipefail

TEST="foundry/test/Guardian_OraclePropagation.t.sol"
TMP="/tmp/Guardian_OraclePropagation_fix.tmp"

cp "$TEST" "$TEST.bak"

# 1) admin -> dao (für vm.startPrank)
# 2) Einsamen vm.prank(dao); ohne Call entfernen
awk '
  {
    line=$0
    gsub(/vm\.startPrank\(admin\);/, "vm.startPrank(dao);", line)
    # lösche Zeilen, die nur vm.prank(dao); enthalten
    if (line ~ /^[[:space:]]*vm\.prank\(dao\);[[:space:]]*$/) next
    print line
  }
' "$TEST" > "$TMP" && mv "$TMP" "$TEST"

echo "✓ Testfile bereinigt: vm.startPrank(admin)->dao & einsamen vm.prank(dao) entfernt"
echo "== Forge: gezielter Testlauf =="
forge clean && forge test --match-path "foundry/test/Guardian_OraclePropagation.t.sol" -vv
