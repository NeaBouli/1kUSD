#!/usr/bin/env python3
from pathlib import Path

FILE = Path("foundry/test/psm/PSMRegression_Flows.t.sol")
src = FILE.read_text()

# 1) CollateralVault neutralisieren (kein echter Konstruktor-Call)
src = src.replace(
    "        vault = new CollateralVault(dao, address(oracle), address(limits));",
    "        vault = CollateralVault(address(0));"
)

# 2) PSMLimits neutralisieren
src = src.replace(
    "        limits = new PSMLimits(dao, 1e30, 1e30);",
    "        limits = PSMLimits(address(0));"
)

# 3) swapTo1kUSD mit richtiger Signatur aufrufen:
#    swapTo1kUSD(address asset, uint256 amountIn, address to, uint256 minOut, uint256 deadline)
src = src.replace(
    "        psm.swapTo1kUSD(address(collateralToken), user, user, 1000e18, bytes32(\"TEST\"));",
    "        psm.swapTo1kUSD(address(collateralToken), 1000e18, user, 0, block.timestamp + 1 days);"
)

FILE.write_text(src)
print(\"✓ Vault/limits neutral + swapTo1kUSD signature fixed\")
