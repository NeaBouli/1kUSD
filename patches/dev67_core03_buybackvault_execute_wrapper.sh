#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/core/BuybackVault.sol"
LOG_FILE="logs/project.log"

echo "== DEV67 CORE03: restore BuybackVault.executeBuyback entrypoint =="

python3 - <<'PY'
from pathlib import Path

path = Path("contracts/core/BuybackVault.sol")
text = path.read_text()

# Wenn executeBuyback schon existiert, nichts tun (idempotent).
if "function executeBuyback(" in text:
    print("executeBuyback() already present, no change.")
else:
    idx = text.rfind("}")
    if idx == -1:
        raise SystemExit("Could not find contract closing brace in BuybackVault.sol")

    block = """

    /// @notice Execute a PSM-based buyback of the underlying asset using stable coins held in the vault.
    /// @param recipient Address that will receive the bought-back asset.
    /// @param amountStable Amount of stable (1kUSD) to spend.
    /// @param minAssetOut Minimum acceptable amount of asset to receive from PSM.
    /// @param deadline Unix timestamp after which the buyback is invalid.
    function executeBuyback(
        address recipient,
        uint256 amountStable,
        uint256 minAssetOut,
        uint256 deadline
    ) external {
        if (msg.sender != dao) revert NOT_DAO();
        if (recipient == address(0)) revert ZERO_ADDRESS();
        if (amountStable == 0) revert INVALID_AMOUNT();
        if (safety.isPaused(moduleId)) revert PAUSED();

        uint256 bal = stable.balanceOf(address(this));
        if (bal < amountStable) revert INSUFFICIENT_BALANCE();

        // Approve PSM to pull the requested stable amount
        stable.approve(address(psm), amountStable);

        uint256 assetOut = psm.swapFrom1kUSD(
            address(asset),
            amountStable,
            recipient,
            minAssetOut,
            deadline
        );

        emit BuybackExecuted(recipient, amountStable, assetOut);
    }
"""
    text = text[:idx] + block + "\n" + text[idx:]
    path.write_text(text)
    print("✓ executeBuyback() entrypoint injected into BuybackVault.sol")
PY

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-67] ${timestamp} BuybackVault: restored public executeBuyback() entrypoint calling PSM and emitting BuybackExecuted." >> "$LOG_FILE"
echo "✓ Log updated at $LOG_FILE"

echo "== DEV67 CORE03: done =="
