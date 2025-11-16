#!/usr/bin/env python3
from pathlib import Path

FILE = Path("foundry/test/psm/PSMRegression_Flows.t.sol")
src = FILE.read_text().splitlines()

new_header = [
"// SPDX-License-Identifier: MIT",
"pragma solidity ^0.8.24;",
"",
'import "forge-std/Test.sol";',
"",
'import {PegStabilityModule} from "../../../contracts/core/PegStabilityModule.sol";',
'import {OneKUSD} from "../../../contracts/core/OneKUSD.sol";',
'import {IOracleAggregator} from "../../../contracts/interfaces/IOracleAggregator.sol";',
'import {MockOracleAggregator} from "../mocks/MockOracleAggregator.sol";',
'import {MockERC20} from "../mocks/MockERC20.sol";',
'import {CollateralVault} from "../../../contracts/core/CollateralVault.sol";',
'import {PSMLimits} from "../../../contracts/psm/PSMLimits.sol";',
'import {ISafetyAutomata} from "../../../contracts/interfaces/ISafetyAutomata.sol";',
'import {IFeeRouterV2} from "../../../contracts/router/IFeeRouterV2.sol";',
"",
]

# FIND FIRST OCCURRENCE OF contract PSMRegression_Flows
idx = None
for i, line in enumerate(src):
    if "contract PSMRegression_Flows" in line:
        idx = i
        break

if idx is None:
    raise SystemExit("ERROR: Contract anchor not found")

# REBUILD FILE
rebuilt = new_header + src[idx:]
FILE.write_text("\n".join(rebuilt) + "\n")

print("✓ Python header reset applied successfully")
