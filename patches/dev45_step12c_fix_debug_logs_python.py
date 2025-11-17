#!/usr/bin/env python3
from pathlib import Path

FILE = Path("foundry/test/psm/PSMRegression_Flows.t.sol")
lines = FILE.read_text().splitlines()

out = []
inside_test = False

for line in lines:
    out.append(line)

    # Start detection
    if "function testMintFlow_1to1()" in line:
        inside_test = True
        continue

    # Insert logs right AFTER swap call
    if inside_test and "psm.swapTo1kUSD" in line:
        out.append('        emit log_named_uint("DEBUG_user1k_before", user1kBefore);')
        out.append('        emit log_named_uint("DEBUG_user1k_after", oneKUSD.balanceOf(user));')
        out.append('        emit log_named_uint("DEBUG_psm_1k_bal", oneKUSD.balanceOf(address(psm)));')
        out.append('        emit log_named_uint("DEBUG_totalSupply_after", oneKUSD.totalSupply());')
        continue

    # End test detection
    if inside_test and "assertEq(oneKUSD" in line:
        inside_test = False

# Remove old broken logs (safety)
out = [l for l in out if "DEBUG_" not in l or "emit" in l]

FILE.write_text("\n".join(out) + "\n")
print("✓ Proper debug logs inserted inside the correct test function")
