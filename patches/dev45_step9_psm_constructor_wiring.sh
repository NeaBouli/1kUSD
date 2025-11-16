#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Flows.t.sol"

echo "== DEV45 STEP 9: Wire real PSM constructor into setUp() =="

python3 - <<'PY'
from pathlib import Path

path = Path("foundry/test/psm/PSMRegression_Flows.t.sol")
src = path.read_text()

marker_start = "    function setUp() public {"
marker_end   = "        // 4) PSM instantiation + real flows will follow in later DEV-45 steps"

if marker_start not in src or marker_end not in src:
    raise SystemExit("Could not find anchor markers. Aborting for safety.")

# Replace the “PSM instantiation placeholder comment” by real PSM constructor
new_block = """        // 4) REAL PSM constructor wiring (neutral external modules)

        psm = new PegStabilityModule(
            dao,
            address(oneKUSD),
            address(vault),     // currently address(0)
            address(safety),    // currently address(0)
            address(limits)     // currently address(0)
        );

        // Set PSM as minter/burner for OneKUSD
        vm.prank(dao);
        oneKUSD.setMinter(address(psm), true);

        vm.prank(dao);
        oneKUSD.setBurner(address(psm), true);

        // Assign oracle (MockOracleAggregator)
        psm.setOracle(address(oracle));
"""

src = src.replace(marker_end, new_block)
path.write_text(src)

PY

echo "✓ PSM constructor wired into setUp()"
echo "== DONE DEV45 STEP 9 =="
