#!/usr/bin/env python3
from pathlib import Path

FILE = Path("foundry/test/psm/PSMRegression_Limits.t.sol")

lines = FILE.read_text().splitlines()

block = [
'        collateralToken = new MockERC20("COL","COL");',
'        collateralToken.mint(user, 1000e18);',
'        vm.prank(user);',
'        collateralToken.approve(address(psm), type(uint256).max);',
'        vault = new MockCollateralVault();',
'        reg = new ParameterRegistry(dao);',
]

print("== DEV45 FIX B6a: Relocate setUp() collateral/vault/reg block ==")

# 1) Entferne bestehende Kopien des Blocks (falls mehrfach vorhanden)
clean_lines = []
i = 0
removed = 0
while i < len(lines):
    if lines[i:i + len(block)] == block:
        removed += 1
        i += len(block)
        continue
    clean_lines.append(lines[i])
    i += 1

print(f"Removed {removed} existing block instance(s).")

# 2) Finde die Zeile mit 'psm = new PegStabilityModule'
ctor_start = None
for idx, line in enumerate(clean_lines):
    if "psm = new PegStabilityModule" in line:
        ctor_start = idx
        break

if ctor_start is None:
    raise SystemExit("ERROR: Could not find 'psm = new PegStabilityModule' in file.")

# 3) Finde das Ende des Konstruktors (erste Zeile nach ctor_start, die ');' enthält)
ctor_end = None
for idx in range(ctor_start + 1, len(clean_lines)):
    if ");" in clean_lines[idx]:
        ctor_end = idx
        break

if ctor_end is None:
    raise SystemExit("ERROR: Could not find closing ');' for PegStabilityModule constructor.")

print(f"Constructor block from line {ctor_start+1} to {ctor_end+1} (1-based indexing).")

# 4) Block direkt nach ctor_end einfügen
new_lines = clean_lines[:ctor_end + 1] + block + clean_lines[ctor_end + 1:]

FILE.write_text("\n".join(new_lines) + "\n")
print("✓ Block relocated after PegStabilityModule constructor.")
