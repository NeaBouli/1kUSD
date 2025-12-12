#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

python - << 'PY'
from pathlib import Path

path = Path("foundry/test/psm/PSMRegression_Spreads.t.sol")
text = path.read_text()

old = """        oracle = new MockOracleAggregator();
        oracle.setPrice(int256(1e18), 18, true);
        psm.setOracle(address(oracle));
"""

new = """        oracle = new MockOracleAggregator();
        oracle.setPrice(int256(1e18), 18, true);

        vm.prank(dao);
        psm.setOracle(address(oracle));
"""

if old not in text:
    raise SystemExit("anchor not found in PSMRegression_Spreads.t.sol")

text = text.replace(old, new, 1)
path.write_text(text)
PY

echo "[DEV-49] $(date -u +"%Y-%m-%dT%H:%M:%SZ") fix PSMRegression_Spreads to call setOracle as dao (ADMIN_ROLE)" >> logs/project.log

echo "== DEV-49 step02: spreads admin fix applied =="
