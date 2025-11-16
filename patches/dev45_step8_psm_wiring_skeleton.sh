#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Flows.t.sol"

echo "== DEV45 STEP 8: Wire core PSM dependencies (skeleton) =="

python3 - <<'PY'
from pathlib import Path

path = Path("foundry/test/psm/PSMRegression_Flows.t.sol")
src = path.read_text()

marker_start = "    function setUp() public {"
marker_next  = "\n\n    function testPlaceholder()"

if marker_start not in src or marker_next not in src:
    raise SystemExit("setUp()/testPlaceholder() markers not found; aborting to avoid corruption.")

start = src.index(marker_start)
end = src.index(marker_next, start)

new_block = """    function setUp() public {
        // DEV-45: basic wiring of core components for PSM regression flows

        // 1) Oracle mock with healthy 1:1 price
        oracle = new MockOracleAggregator();
        oracle.setPrice(int256(1e18), 18, true);

        // 2) 1kUSD token (DAO as admin)
        oneKUSD = new OneKUSD(dao);

        // 3) Neutral handles for external modules (wired to address(0) for now)
        vault = CollateralVault(address(0));
        limits = PSMLimits(address(0));
        safety = ISafetyAutomata(address(0));
        feeRouter = IFeeRouterV2(address(0));

        // 4) PSM instantiation + real flows will follow in later DEV-45 steps
    }

"""

src = src[:start] + new_block + src[end:]
path.write_text(src)
PY

echo "✓ Core dependency wiring skeleton injected into setUp()"
echo "== DONE DEV45 STEP 8 =="
