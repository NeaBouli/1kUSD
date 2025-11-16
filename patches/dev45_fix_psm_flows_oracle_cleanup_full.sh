#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Flows.t.sol"

echo "== DEV-45 Oracle Cleanup: Remove corrupted oracle setter lines =="

# Entferne ALLE Zeilen mit oracle.setPrice oder oracle.setPriceMock
sed -i '' '/oracle.setPrice/d' "$FILE"
sed -i '' '/oracle.setPriceMock/d' "$FILE"

echo "✓ Removed all corrupted oracle.setPrice* lines"

# Jetzt saubere Version einfügen
sed -i '' '/function setUp() public {/a\
        // DEV-45: Correct oracle mock initialization\n\
        vm.prank(admin);\n\
        oracle.setPriceMock(collateral, int256(1e18), 18, true);\n\
' "$FILE"

echo "✓ Inserted clean oracle.setPriceMock() call"
echo "== Complete =="
