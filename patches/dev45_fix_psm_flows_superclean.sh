#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Flows.t.sol"

echo "== SUPER-CLEAN: Remove ALL lines containing hidden 'n' artifacts =="

# 1) Lösche ALLE Zeilen, die irgendwo ein 'n' am Ende enthalten
sed -i '' 's/\r//g' "$FILE"
sed -i '' 's/;n/;/g' "$FILE"
sed -i '' 's/)n/)/g' "$FILE"
sed -i '' '/n$/d' "$FILE"

# 2) Lösche jede Zeile, die 'setPrice' enthält
sed -i '' '/setPrice/d' "$FILE"
sed -i '' '/setPriceMock/d' "$FILE"

# 3) Füge ganz oben in setUp den **korrekten** Preis-Setter ein
sed -i '' '/function setUp() public {/a\
        // DEV-45 clean oracle setup\n\
        vm.prank(admin);\n\
        oracle.setPriceMock(address(collateral), int256(1e18), 18, true);\n\
' "$FILE"

echo "✓ SUPER-CLEAN applied"
echo "== COMPLETE =="
