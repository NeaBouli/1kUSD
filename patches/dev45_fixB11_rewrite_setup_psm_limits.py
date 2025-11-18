#!/usr/bin/env python3
from pathlib import Path

FILE = Path("foundry/test/psm/PSMRegression_Limits.t.sol")

print("== DEV45 FIX B11: rewrite setUp() in PSMRegression_Limits with correct wiring ==")

lines = FILE.read_text().splitlines()

start = None
end = None

# 1) Position der function setUp() finden
for i, line in enumerate(lines):
    if "function setUp()" in line:
        start = i
        break

if start is None:
    raise SystemExit("ERROR: function setUp() not found in PSMRegression_Limits.t.sol")

# 2) Ende der function setUp() via Klammerzählung finden
brace = 0
opened = False
for i in range(start, len(lines)):
    line = lines[i]
    # Klammern zählen
    for ch in line:
        if ch == "{":
            brace += 1
            opened = True
        elif ch == "}":
            brace -= 1
    if opened and brace == 0:
        end = i
        break

if end is None:
    raise SystemExit("ERROR: could not determine end of setUp()")

print(f"setUp() block lines: {start+1}..{end+1} (1-based)")

# 3) Neue setUp()-Implementation
new_setup = [
"    function setUp() public {",
"        // Core PSM wiring for limit regression tests",
"",
"        // 1) OneKUSD and core infra",
"        oneKUSD = new OneKUSD(dao);",
"        vault = new MockCollateralVault();",
"        reg = new ParameterRegistry(dao);",
"",
"        // 2) PegStabilityModule with real vault/registry, no safety automata",
"        psm = new PegStabilityModule(",
"            dao,",
"            address(oneKUSD),",
"            address(vault),",
"            address(0),",
"            address(reg)",
"        );",
"",
"        // 3) Allow PSM to mint/burn 1kUSD",
"        vm.prank(dao);",
"        oneKUSD.setMinter(address(psm), true);",
"        vm.prank(dao);",
"        oneKUSD.setBurner(address(psm), true);",
"",
"        // 4) Collateral token and approvals",
"        collateralToken = new MockERC20(\"COL\", \"COL\");",
"        collateralToken.mint(user, 10_000e18);",
"        vm.prank(user);",
"        collateralToken.approve(address(psm), type(uint256).max);",
"",
"        // 5) Limits: dailyCap = 1000, singleTxCap = 500",
"        limits = new PSMLimits(address(this), 1000, 500);",
"        psm.setLimits(address(limits));",
"",
"        // 6) No fees — isolate limit behaviour",
"        psm.setFees(0, 0);",
"    }",
]

# 4) File neu zusammensetzen: alles vor setUp, neue setUp, alles nach setUp
new_lines = lines[:start] + new_setup + lines[end+1:]
FILE.write_text("\n".join(new_lines) + "\n")

print("✓ setUp() in PSMRegression_Limits rewritten successfully.")
