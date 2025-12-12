#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

python - << 'PY'
from pathlib import Path

path = Path("foundry/test/psm/PSMRegression_Spreads.t.sol")
text = path.read_text()

# 1) dao nicht mehr hart auf 0xDA0 setzen, sondern variabel
text_new = text.replace(
    "    address internal dao = address(0xDA0);\n",
    "    address internal dao;\n",
    1
)

if text_new == text:
    raise SystemExit("dao anchor not found in PSMRegression_Spreads.t.sol")
text = text_new

# 2) In setUp direkt nach dem Funktionskopf dao = address(this); einfügen
needle = "    function setUp() public {\n"
insert = """    function setUp() public {
        dao = address(this);
"""
if needle not in text:
    raise SystemExit("setUp() anchor not found in PSMRegression_Spreads.t.sol")

text = text.replace(needle, insert, 1)

# 3) vm.prank(dao) in setUp entfernen – setFees & setOracle direkt aufrufen

text = text.replace(
    "        vm.prank(dao);\n        psm.setFees(0, 0);\n",
    "        psm.setFees(0, 0);\n",
    1
)

text = text.replace(
    "        vm.prank(dao);\n        psm.setOracle(address(oracle));\n",
    "        psm.setOracle(address(oracle));\n",
    1
)

path.write_text(text)
PY

echo "[DEV-49] $(date -u +"%Y-%m-%dT%H:%M:%SZ") adjust PSMRegression_Spreads: use dao = address(this) and remove vm.prank in setUp" >> logs/project.log

echo "== DEV-49 step02c: PSMRegression_Spreads admin wiring simplified =="
