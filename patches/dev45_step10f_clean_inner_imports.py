#!/usr/bin/env python3
from pathlib import Path

FILE = Path("foundry/test/psm/PSMRegression_Flows.t.sol")
lines = FILE.read_text().splitlines()

out = []
inside_contract = False

for line in lines:
    if "contract PSMRegression_Flows" in line:
        inside_contract = True
        out.append(line)
        continue

    # Wenn wir im Contract sind: ALLE import-Lines löschen
    if inside_contract:
        if line.strip().startswith("import "):
            continue

    out.append(line)

FILE.write_text("\n".join(out) + "\n")
print("✓ Inner-contract imports removed")
