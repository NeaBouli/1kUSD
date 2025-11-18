#!/usr/bin/env python3
from pathlib import Path

FILE = Path("foundry/test/psm/PSMRegression_Limits.t.sol")

print("== DEV45 FIX B10: insert vm.prank(user) before PSM swaps in PSMRegression_Limits ==")

text = FILE.read_text().splitlines()
out = []
inserted_count = 0

for i, line in enumerate(text):
    # Wenn wir eine Zeile mit psm.swapTo1kUSD finden:
    if "psm.swapTo1kUSD" in line:
        # Schau auf die letzte Nicht-Leerzeile im out-Buffer
        j = len(out) - 1
        while j >= 0 and out[j].strip() == "":
            j -= 1
        last_line = out[j] if j >= 0 else ""

        # Nur einfügen, wenn noch kein vm.prank(user); direkt davor steht
        if "vm.prank(user);" not in last_line:
            out.append("        vm.prank(user);")
            inserted_count += 1

    out.append(line)

FILE.write_text("\n".join(out) + "\n")
print(f"Inserted vm.prank(user); before {inserted_count} swapTo1kUSD calls.")
print("✓ PSMRegression_Limits now calls swaps as the funded user.")
