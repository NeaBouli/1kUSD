#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Flows.t.sol"

echo "== DEV-45 Hotfix: Use correct OracleAggregator mock method (setPriceMock) =="

# Entferne alte fehlerhafte setPrice-Zeilen
sed -i '' '/setPrice(collateral/d' "$FILE"

# Füge korrekten Mock-Setter ein
sed -i '' '/function setUp() public {/a\
        // DEV-45: Correct oracle price for notional mint math\n\
        vm.prank(admin);\n\
        oracle.setPriceMock(collateral, int256(1e18), 18, true);\n\
' "$FILE"

echo "✓ Oracle mock price set via setPriceMock()"
echo "== Complete =="
