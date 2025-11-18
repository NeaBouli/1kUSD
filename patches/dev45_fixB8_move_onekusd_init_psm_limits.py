#!/usr/bin/env python3
from pathlib import Path

FILE = Path("foundry/test/psm/PSMRegression_Limits.t.sol")
lines = FILE.read_text().splitlines()

# 1) Entferne oneKUSD-Init aus dem PegStabilityModule-Konstruktorblock
new_lines = []
i = 0
removed = 0

while i < len(lines):
    line = lines[i]
    # Einstieg in die Zeile mit psm = new PegStabilityModule(...)
    if "psm = new PegStabilityModule" in line:
        new_lines.append(line)
        i += 1
        # Innerhalb des Konstruktors: bis zur Zeile mit ');'
        while i < len(lines):
            inner = lines[i]
            if "oneKUSD = new OneKUSD(dao);" in inner:
                removed += 1
                i += 1
                continue
            new_lines.append(inner)
            if ");" in inner:
                i += 1
                break
            i += 1
        continue

    new_lines.append(line)
    i += 1

print(f"Removed {removed} inline oneKUSD init line(s) inside constructor.")

# 2) Prüfen, ob bereits eine gültige oneKUSD-Initialisierung existiert
already = any("oneKUSD = new OneKUSD(dao);" in l for l in new_lines)

# 3) Falls nicht vorhanden: nach function setUp() public { einfügen
if not already:
    out = []
    inserted = False
    for l in new_lines:
        out.append(l)
        if (not inserted) and "function setUp()" in l:
            # eine Ebene tiefer einrücken
            out.append("        oneKUSD = new OneKUSD(dao);")
            inserted = True
    new_lines = out
    print("Inserted oneKUSD init inside setUp() body.")
else:
    print("oneKUSD init already exists outside constructor; not inserting again.")

FILE.write_text("\n".join(new_lines) + "\n")
print("✓ PSMRegression_Limits: oneKUSD init relocated successfully.")
