#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Flows.t.sol"

echo "== DEV-45 Hotfix: Correct admin prank for OneKUSD role setup =="

# Insert vm.prank(admin) before setMinter and setBurner
sed -i '' 's/oneKUSD.setMinter(vm\./,/' "$FILE" || true

# Replace:
#   oneKUSD.setMinter(address(psm), true);
# with:
#   vm.prank(admin);
#   oneKUSD.setMinter(address(psm), true);
sed -i '' 's/oneKUSD.setMinter(address(psm), true);/vm.prank(admin);\n        oneKUSD.setMinter(address(psm), true);/' "$FILE"

sed -i '' 's/oneKUSD.setBurner(address(psm), true);/vm.prank(admin);\n        oneKUSD.setBurner(address(psm), true);/' "$FILE"

echo "✓ PSMRegression_Flows roles fixed"
echo "== Complete =="
