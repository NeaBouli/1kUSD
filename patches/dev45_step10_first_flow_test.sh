#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Flows.t.sol"

echo "== DEV45 STEP 10: Add first real PSM mint flow test =="

python3 - <<'PY'
from pathlib import Path
path = Path("foundry/test/psm/PSMRegression_Flows.t.sol")
src = path.read_text()

insertion_point = "function testPlaceholder()"
if insertion_point not in src:
    raise SystemExit("Anchor not found")

new_test = r"""
    function testMintFlow_1to1() public {
        // 1) User erhält Collateral
        MockERC20 collateralToken = new MockERC20("COL", "COL");
        collateralToken.mint(user, 1000e18);

        // 2) User genehmigt PSM
        vm.prank(user);
        collateralToken.approve(address(psm), type(uint256).max);

        // 3) Oracle Preis steht bereits in setUp() auf 1e18 (1:1)

        // 4) Swap 1000 Collateral -> 1000 1kUSD
        vm.prank(user);
        psm.swapTo1kUSD(address(collateralToken), 1000e18);

        // 5) Prüfung: User hat 1000 1kUSD
        assertEq(oneKUSD.balanceOf(user), 1000e18, "User should receive 1kUSD");

        // Minimal check: PSM sollte Collateral halten
        assertEq(collateralToken.balanceOf(address(psm)), 1000e18);
    }
"""

src = src.replace("function testPlaceholder()", new_test + "\n\n    function testPlaceholder()")
path.write_text(src)
PY

echo "✓ First PSM mint flow test injected"
