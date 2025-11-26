#!/usr/bin/env bash
set -euo pipefail

TEST_FILE="foundry/test/BuybackVault.t.sol"
LOG_FILE="logs/project.log"

echo "== DEV67 CORE02: declare BuybackVault events in test contract =="

python3 - <<'PY'
from pathlib import Path

path = Path("foundry/test/BuybackVault.t.sol")
text = path.read_text()

if "event StableFunded" not in text:
    anchor = "contract BuybackVaultTest is Test {\n"
    if anchor not in text:
        raise SystemExit("Anchor 'contract BuybackVaultTest is Test {' not found")
    insert_pos = text.index(anchor) + len(anchor)
    block = """    // Mirror BuybackVault events for vm.expectEmit
    event StableFunded(address indexed from, uint256 amount);
    event BuybackExecuted(address indexed recipient, uint256 stableIn, uint256 assetOut);
    event StableWithdrawn(address indexed to, uint256 amount);
    event AssetWithdrawn(address indexed to, uint256 amount);

"""
    text = text[:insert_pos] + block + text[insert_pos:]

path.write_text(text)
print("✓ BuybackVault events declared in BuybackVaultTest.")
PY

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-67] ${timestamp} BuybackVault: mirrored on-chain events as test-local declarations for vm.expectEmit." >> "$LOG_FILE"
echo "✓ Log updated at $LOG_FILE"

echo "== DEV67 CORE02: done =="
