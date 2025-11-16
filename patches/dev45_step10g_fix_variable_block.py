#!/usr/bin/env python3
from pathlib import Path

FILE = Path("foundry/test/psm/PSMRegression_Flows.t.sol")
lines = FILE.read_text().splitlines()

out = []
inside = False
done = False

variable_block = [
"    PegStabilityModule internal psm;",
"    OneKUSD internal oneKUSD;",
"    MockOracleAggregator internal oracle;",
"    CollateralVault internal vault;",
"    PSMLimits internal limits;",
"    ISafetyAutomata internal safety;",
"    IFeeRouterV2 internal feeRouter;",
"",
"    address internal dao = address(this);",
"    address internal user = address(0xBEEF);",
"    address internal collateral = address(0xCA11);",
"",
]

for line in lines:
    if "contract PSMRegression_Flows" in line and not done:
        out.append(line)
        inside = True
        continue

    if inside:
        if "function setUp()" in line:
            out.extend(variable_block)
            out.append("")
            out.append(line)
            inside = False
            done = True
            continue
        else:
            # skip old/dirty lines
            continue

    out.append(line)

FILE.write_text("\n".join(out) + "\n")
print("✓ Variable block rebuilt successfully")
