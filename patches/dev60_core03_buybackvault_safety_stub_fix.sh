#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/BuybackVault.t.sol"

echo "== DEV60 CORE03: narrow SafetyStub to minimal isPaused stub =="

python3 - <<'PY'
from pathlib import Path

path = Path("foundry/test/BuybackVault.t.sol")
text = path.read_text()

text = text.replace(
    "contract SafetyStub is ISafetyAutomata {",
    "contract SafetyStub {",
)

text = text.replace(
    "    function isPaused(bytes32 moduleId) external view override returns (bool) {",
    "    function isPaused(bytes32 moduleId) external view returns (bool) {",
)

path.write_text(text)
print("✓ SafetyStub no longer implements full ISafetyAutomata; only isPaused stub remains")
PY

echo "✓ DEV60 CORE03: SafetyStub adjusted in $FILE"
