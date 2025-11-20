#!/usr/bin/env python3
from pathlib import Path

FILE = Path("contracts/core/PegStabilityModule.sol")

print("== DEV52 CORE02: wire fee+spread into swapTo1kUSD/swapFrom1kUSD ==")

text = FILE.read_text()

# --- Patch 1: swapTo1kUSD block ---
block_start = '        // For DEV-44 we assume 18 decimals for tokenIn until registry wiring is added.'
dec_line = '        uint8 tokenInDecimals = _getTokenDecimals(tokenIn);'
enforce_line = '        _enforceLimits(notional1k);'

idx_start = text.find(dec_line)
if idx_start == -1:
    raise SystemExit("ERROR: tokenInDecimals line not found")

idx_enforce = text.find(enforce_line, idx_start)
if idx_enforce == -1:
    raise SystemExit("ERROR: _enforceLimits(notional1k) for swapTo1kUSD not found")

before = text[:idx_start]
after = text[idx_enforce + len(enforce_line):]

swap_to_block = """        uint8 tokenInDecimals = _getTokenDecimals(tokenIn);

        uint16 feeBps = _getMintFeeBps(tokenIn);
        uint16 spreadBps = _getMintSpreadBps(tokenIn);
        uint256 totalBps = uint256(feeBps) + uint256(spreadBps);
        require(totalBps <= 10_000, "PSM: fee+spread too high");

        (uint256 notional1k, uint256 fee1k, uint256 net1k) =
            _computeSwapTo1kUSD(tokenIn, amountIn, uint16(totalBps), tokenInDecimals);

        _enforceLimits(notional1k);
"""

text = before + swap_to_block + after

# --- Patch 2: swapFrom1kUSD block ---
dec_line_out = '        uint8 tokenOutDecimals = _getTokenDecimals(tokenOut);'
idx_start2 = text.find(dec_line_out)
if idx_start2 == -1:
    raise SystemExit("ERROR: tokenOutDecimals line not found")

idx_enforce2 = text.find(enforce_line, idx_start2)
if idx_enforce2 == -1:
    raise SystemExit("ERROR: _enforceLimits(notional1k) for swapFrom1kUSD not found")

before2 = text[:idx_start2]
after2 = text[idx_enforce2 + len(enforce_line):]

swap_from_block = """        uint8 tokenOutDecimals = _getTokenDecimals(tokenOut);

        uint16 feeBps = _getRedeemFeeBps(tokenOut);
        uint16 spreadBps = _getRedeemSpreadBps(tokenOut);
        uint256 totalBps = uint256(feeBps) + uint256(spreadBps);
        require(totalBps <= 10_000, "PSM: fee+spread too high");

        (uint256 notional1k, uint256 fee1k, uint256 netTokenOut) =
            _computeSwapFrom1kUSD(tokenOut, amountIn1k, uint16(totalBps), tokenOutDecimals);

        _enforceLimits(notional1k);
"""

text = before2 + swap_from_block + after2

FILE.write_text(text)
print("✓ DEV52 CORE02: fee+spread now applied in swapTo1kUSD/swapFrom1kUSD")
