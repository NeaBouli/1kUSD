#!/usr/bin/env python3
from pathlib import Path
import re

FILE = Path("foundry/test/psm/PSMRegression_Flows.t.sol")
text = FILE.read_text()

# == 1) Extract testMintFlow_1to1 ==
pattern = re.compile(r"function testMintFlow_1to1[\s\S]*?}\s*", re.MULTILINE)
matches = pattern.findall(text)

if not matches:
    raise SystemExit("ERROR: testMintFlow_1to1() not found")

test_block = matches[0]

# == 2) Remove ALL occurrences of the test block ==
cleaned = pattern.sub("", text)

# == 3) Insert AFTER setUp() ==
insert_point = cleaned.find("function setUp()")

if insert_point == -1:
    raise SystemExit("ERROR: setUp() not found")

# Find end of setUp()
brace = 0
end = None

for i in range(insert_point, len(cleaned)):
    if cleaned[i] == "{":
        brace += 1
    elif cleaned[i] == "}":
        brace -= 1
        if brace == 0:
            end = i
            break

if end is None:
    raise SystemExit("ERROR: setUp block end not found")

rebuilt = cleaned[:end+1] + "\n\n" + test_block + "\n" + cleaned[end+1:]

FILE.write_text(rebuilt)
print("✓ testMintFlow_1to1 repositioned correctly INSIDE contract")
