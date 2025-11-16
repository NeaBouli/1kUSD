#!/usr/bin/env python3
from pathlib import Path

FILE = Path("foundry/test/psm/PSMRegression_Flows.t.sol")
src = FILE.read_text()

src = src.replace(
    "vault = new CollateralVault(dao);",
    "vault = new CollateralVault(dao, address(oracle), address(limits));"
)

src = src.replace(
    "limits = new PSMLimits(dao);",
    "limits = new PSMLimits(dao, 1e30, 1e30);"
)

src = src.replace(
    "psm.swapTo1kUSD(address(collateralToken), 1000e18);",
    'psm.swapTo1kUSD(address(collateralToken), user, user, 1000e18, bytes32("TEST"));'
)

FILE.write_text(src)
print("✓ Constructors + swapTo1kUSD fixed")
