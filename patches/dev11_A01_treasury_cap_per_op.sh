#!/bin/bash
set -e

echo "== DEV-11 A01: add per-operation treasury cap for buybacks (Phase A) =="

python3 - <<'PY'
from pathlib import Path

path = Path("contracts/core/BuybackVault.sol")
text = path.read_text()

# Wenn die Cap-Logik schon da ist, abbrechen
if "BUYBACK_TREASURY_CAP_EXCEEDED()" in text:
    raise SystemExit("Cap logic already present, nothing to do.")

# 1) Neues Error
if "error NO_ENABLED_STRATEGY_FOR_ASSET();" in text:
    text = text.replace(
        "error NO_ENABLED_STRATEGY_FOR_ASSET();",
        "error NO_ENABLED_STRATEGY_FOR_ASSET();\nerror BUYBACK_TREASURY_CAP_EXCEEDED();",
        1,
    )
else:
    raise SystemExit("Could not find NO_ENABLED_STRATEGY_FOR_ASSET error anchor")

# 2) Neues Feld + Event nach moduleId
module_line = "bytes32 public immutable moduleId;"
if module_line not in text:
    raise SystemExit("moduleId anchor not found")

insert = """bytes32 public immutable moduleId;

    /// @notice Maximum share of the vault's stable balance that can be spent
    ///         in a single buyback operation (in basis points, 1% = 100 bps).
    /// @dev A value of 0 disables the per-operation cap check.
    uint16 public maxBuybackSharePerOpBps;

    event BuybackTreasuryCapUpdated(uint16 oldCapBps, uint16 newCapBps);
"""
text = text.replace(module_line, insert, 1)

# 3) Setter-Funktion bei Strategy-Config einfügen
marker_strategy = "// --- Strategy config ---"
if marker_strategy not in text:
    raise SystemExit("Strategy config marker not found")

setter = """// --- Strategy config ---

    /// @notice Set the maximum share of the vault's stable balance that can be
    ///         spent in a single buyback operation.
    /// @dev Value is expressed in basis points (1% = 100 bps). A value of 0
    ///      disables the check.
    /// @param newCapBps New per-operation cap in basis points.
    function setMaxBuybackSharePerOpBps(uint16 newCapBps) external onlyDAO {
        if (newCapBps > 10_000) revert INVALID_AMOUNT();
        uint16 oldCap = maxBuybackSharePerOpBps;
        maxBuybackSharePerOpBps = newCapBps;
        emit BuybackTreasuryCapUpdated(oldCap, newCapBps);
    }

"""
text = text.replace(marker_strategy, setter, 1)

# 4) Check in executeBuybackPSM (Stage B)
anchor_psm = "if (amount1k == 0) revert ZERO_AMOUNT();"
if anchor_psm not in text:
    raise SystemExit("executeBuybackPSM ZERO_AMOUNT anchor not found")

text = text.replace(
    anchor_psm,
    anchor_psm + "\n        _checkPerOpTreasuryCap(amount1k);",
    1,
)

# 5) Check in legacy executeBuyback (Stage B alt)
anchor_legacy = "if (bal < amountStable) revert INSUFFICIENT_BALANCE();"
if anchor_legacy not in text:
    raise SystemExit("legacy executeBuyback INSUFFICIENT_BALANCE anchor not found")

text = text.replace(
    anchor_legacy,
    anchor_legacy + "\n        _checkPerOpTreasuryCap(amountStable);",
    1,
)

# 6) Helper-Funktion vor dem Views-Block einfügen
marker_views = "// --- Views ---"
if marker_views not in text:
    raise SystemExit("views marker not found")

helper = """    function _checkPerOpTreasuryCap(uint256 amountStable) internal view {
        uint16 capBps = maxBuybackSharePerOpBps;
        if (capBps == 0) {
            return;
        }
        uint256 bal = stable.balanceOf(address(this));
        uint256 cap = (bal * capBps) / 10_000;
        if (amountStable > cap) {
            revert BUYBACK_TREASURY_CAP_EXCEEDED();
        }
    }

    // --- Views ---
"""
text = text.replace(marker_views, helper, 1)

path.write_text(text)
PY

LOG_FILE="logs/project.log"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-11 A01] ${timestamp} Add per-operation buyback treasury cap (Phase A, code-only, no tests yet)" >> "$LOG_FILE"

echo "== DEV-11 A01 done =="
