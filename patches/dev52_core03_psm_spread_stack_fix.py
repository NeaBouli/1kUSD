#!/usr/bin/env python3
from pathlib import Path

FILE = Path("contracts/core/PegStabilityModule.sol")

print("== DEV52 CORE03: reduce locals for fee+spread (stack-too-deep fix) ==")

text = FILE.read_text()

# --- swapTo1kUSD: feeBps/spreadBps -> inline totalBps ---
old_mint = """        uint16 feeBps = _getMintFeeBps(tokenIn);
        uint16 spreadBps = _getMintSpreadBps(tokenIn);
        uint256 totalBps = uint256(feeBps) + uint256(spreadBps);
        require(totalBps <= 10_000, "PSM: fee+spread too high");
"""

new_mint = """        uint256 totalBps =
            uint256(_getMintFeeBps(tokenIn)) + uint256(_getMintSpreadBps(tokenIn));
        require(totalBps <= 10_000, "PSM: fee+spread too high");
"""

if old_mint not in text:
    raise SystemExit("ERROR: mint-fee block not found (swapTo1kUSD)")

text = text.replace(old_mint, new_mint)

# --- swapFrom1kUSD: feeBps/spreadBps -> inline totalBps ---
old_redeem = """        uint16 feeBps = _getRedeemFeeBps(tokenOut);
        uint16 spreadBps = _getRedeemSpreadBps(tokenOut);
        uint256 totalBps = uint256(feeBps) + uint256(spreadBps);
        require(totalBps <= 10_000, "PSM: fee+spread too high");
"""

new_redeem = """        uint256 totalBps =
            uint256(_getRedeemFeeBps(tokenOut)) + uint256(_getRedeemSpreadBps(tokenOut));
        require(totalBps <= 10_000, "PSM: fee+spread too high");
"""

if old_redeem not in text:
    raise SystemExit("ERROR: redeem-fee block not found (swapFrom1kUSD)")

text = text.replace(old_redeem, new_redeem)

FILE.write_text(text)
print("✓ DEV52 CORE03: locals reduced; fee+spread logic unchanged")
