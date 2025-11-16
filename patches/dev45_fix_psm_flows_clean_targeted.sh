#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Flows.t.sol"

echo "== DEV-45 Targeted Cleanup: Remove corrupted oracle init lines =="

# Lösche exakt die defekten Zeilen 109–117
# (die mit 'n' am Ende!)
sed -i '' '109,117d' "$FILE"

# Füge saubere Version nach Zeile 108 ein
sed -i '' '108a\
        // DEV-45: Correct oracle initialization\n\
        vm.prank(admin);\n\
        oracle.setPriceMock(collateral, int256(1e18), 18, true);\n\
' "$FILE"

echo "✓ Clean oracle initialization inserted"
echo "== Complete =="
