#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

python - << 'PY'
from pathlib import Path

path = Path("foundry/test/BuybackVault.t.sol")
text = path.read_text()

header = "    function testExecuteBuybackPSM_OracleGate_EnforcedWithoutModuleReverts() public {"
marker = "    function testExecuteBuybackPSM_OracleGate_HealthyModuleAllowsBuyback() public {"

start = text.find(header)
if start == -1:
    raise SystemExit("target function not found in BuybackVault.t.sol")

end = text.find(marker, start)
if end == -1:
    raise SystemExit("marker for next function not found")

new_block = """    function testSetOracleHealthGateConfig_EnforcedWithZeroModuleReverts() public {
        vm.prank(dao);
        vm.expectRevert(BuybackVault.ZERO_ADDRESS.selector);
        vault.setOracleHealthGateConfig(address(0), true);
    }

"""

text = text[:start] + new_block + text[end:]
path.write_text(text)
PY

echo "[DEV-11 PhaseB] $(date -u +"%Y-%m-%dT%H:%M:%SZ") adjust oracle health gate tests to config semantics" >> logs/project.log

echo "== DEV-11 Phase B: oracle gate test fix applied =="
