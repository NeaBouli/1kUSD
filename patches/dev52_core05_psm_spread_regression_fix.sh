#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Spreads.t.sol"

echo "== DEV52 CORE05: align spread tests with registry usage (global + per-token) =="

python3 - <<'PY'
from pathlib import Path

path = Path("foundry/test/psm/PSMRegression_Spreads.t.sol")
text = path.read_text()

old = '''    function _setMintSpread(address token, uint256 bps) internal {
        vm.prank(dao);
        registry.setUint(_mintSpreadKey(token), bps);
    }

    function _setRedeemSpread(address token, uint256 bps) internal {
        vm.prank(dao);
        registry.setUint(_redeemSpreadKey(token), bps);
    }
'''
new = '''    function _setMintSpread(address token, uint256 bps) internal {
        // For regression we set both per-token and global spread.
        vm.prank(dao);
        registry.setUint(_mintSpreadKey(token), bps);
        vm.prank(dao);
        registry.setUint(KEY_MINT_SPREAD_BPS, bps);
    }

    function _setRedeemSpread(address token, uint256 bps) internal {
        // Same pattern for redeem spreads.
        vm.prank(dao);
        registry.setUint(_redeemSpreadKey(token), bps);
        vm.prank(dao);
        registry.setUint(KEY_REDEEM_SPREAD_BPS, bps);
    }
'''
if old not in text:
    raise SystemExit("pattern not found in PSMRegression_Spreads.t.sol")

path.write_text(text.replace(old, new))
PY

echo "✓ Updated _setMintSpread/_setRedeemSpread to set global+per-token spreads"
