#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Flows.t.sol"

echo "== DEV-45: Wire OracleAggregator into PSMRegression_Flows =="

python3 - << 'PY'
from pathlib import Path

path = Path("foundry/test/psm/PSMRegression_Flows.t.sol")
src = path.read_text()

# 1) Import für OracleAggregator ergänzen (falls noch nicht vorhanden)
import_line = 'import {OracleAggregator} from "../../../contracts/core/OracleAggregator.sol";\n'
if "OracleAggregator.sol" not in src:
    marker = 'import {IOracleAggregator} from "../../../contracts/interfaces/IOracleAggregator.sol";\n'
    if marker not in src:
        raise SystemExit("IOracleAggregator import marker not found; aborting to avoid corruption.")
    src = src.replace(marker, marker + import_line)

# 2) Falls noch ein FixedOracle-Decl existiert, auf OracleAggregator umbiegen
old_decl = "    FixedOracle internal oracle;\n"
if old_decl in src:
    src = src.replace(old_decl, "    OracleAggregator internal oracle;\n")

# 3) In setUp() nach new OracleAggregator() einen sauberen setPriceMock-Call einfügen
needle = """        // --- 1) Core-Components ---
        oneKUSD = new OneKUSD(admin);
        collateral = new MockERC20("COLL", "COLL", 18);
        oracle = new OracleAggregator();
"""
if needle not in src:
    raise SystemExit("Core component block not found; aborting to keep file consistent.")

replacement = needle + '        oracle.setPriceMock(address(collateral), int256(1e18), 18, true);\n'
src = src.replace(needle, replacement)

path.write_text(src)
PY

echo "✓ OracleAggregator import + mock price setup wired"
echo "== COMPLETE =="
