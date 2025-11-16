#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Flows.t.sol"

echo "== DEV-45: Remove stray closing brace before MockERC20 =="

python3 - <<'PY'
from pathlib import Path

path = Path("foundry/test/psm/PSMRegression_Flows.t.sol")
src = path.read_text()

needle = "}\n/// @dev Minimal ERC20 for collateral testing.\n"
if needle not in src:
    raise SystemExit("Pattern '}\\n/// @dev Minimal ERC20 for collateral testing.' not found; aborting to avoid corruption.")

src = src.replace(needle, "/// @dev Minimal ERC20 for collateral testing.\n", 1)

path.write_text(src)
PY

echo "✓ Removed stray '}' before MockERC20"
echo "== COMPLETE =="
