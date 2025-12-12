#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

python3 - << 'PYEOF'
from pathlib import Path

path = Path("contracts/core/BuybackVault.sol")
text = path.read_text()

# Wenn das Fenster-Storage schon existiert, nichts tun (idempotent)
if "maxBuybackSharePerWindowBps" in text:
    print("window storage already present, skipping solidity edit")
else:
    # 1) Neue Storage-Felder + Event direkt nach der Zeile mit maxBuybackSharePerOpBps einfügen
    needle = "maxBuybackSharePerOpBps"
    idx = text.find(needle)
    assert idx != -1, "maxBuybackSharePerOpBps needle not found (flex search)"

    line_start = text.rfind("\n", 0, idx)
    if line_start == -1:
        line_start = 0
    else:
        line_start += 1

    line_end = text.find("\n", idx)
    if line_end == -1:
        line_end = len(text)

    insert_pos = line_end + 1

    snippet = (
"    uint16 public maxBuybackSharePerWindowBps;\n"
"    uint64 public buybackWindowDuration;\n"
"    uint64 public buybackWindowStart;\n"
"    uint128 public buybackWindowAccumulatedBps;\n"
"\n"
"    event BuybackWindowConfigUpdated(\n"
"        uint64 oldDuration,\n"
"        uint64 newDuration,\n"
"        uint16 oldCapBps,\n"
"        uint16 newCapBps\n"
"    );\n"
"\n"
    )

    text = text[:insert_pos] + snippet + text[insert_pos:]

    # 2) Setter für die Rolling-Window-Config nach setMaxBuybackSharePerOpBps einfügen
    setter_name = "function setMaxBuybackSharePerOpBps("
    start_idx = text.find(setter_name)
    assert start_idx != -1, "setMaxBuybackSharePerOpBps not found"
    brace_idx = text.find("{", start_idx)
    assert brace_idx != -1, "setter body brace not found"

    depth = 0
    end_idx = None
    for i, ch in enumerate(text[brace_idx:], start=brace_idx):
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0:
                end_idx = i
                break
    assert end_idx is not None, "could not find end of setMaxBuybackSharePerOpBps body"
    insert_pos2 = end_idx + 1

    setter2 = (
"\n"
"    /// @notice Configure the rolling buyback window.\n"
"    /// @dev A zero cap disables the window; duration is in seconds.\n"
"    function setBuybackWindowConfig(uint64 newDuration, uint16 newCapBps) external onlyDAO {\n"
"        require(newCapBps <= 10_000, \"WINDOW_CAP_BPS_TOO_HIGH\");\n"
"        uint64 oldDuration = buybackWindowDuration;\n"
"        uint16 oldCapBps = maxBuybackSharePerWindowBps;\n"
"        buybackWindowDuration = newDuration;\n"
"        maxBuybackSharePerWindowBps = newCapBps;\n"
"        // Reset window accounting; a later DEV-11 A03 patch will implement enforcement logic.\n"
"        buybackWindowStart = 0;\n"
"        buybackWindowAccumulatedBps = 0;\n"
"        emit BuybackWindowConfigUpdated(oldDuration, newDuration, oldCapBps, newCapBps);\n"
"    }\n"
    )

    text = text[:insert_pos2] + setter2 + text[insert_pos2:]

    path.write_text(text)
    print("BuybackVault.sol updated with window storage + config setter")

PYEOF

# DEV-11 A03 Log-Eintrag
echo "$(date -u '+%Y-%m-%dT%H:%M:%SZ') DEV-11 A03 window_storage: add rolling window storage and config in BuybackVault" >> logs/project.log

echo "== DEV-11 A03: window storage & config patch applied =="

forge test
mkdocs build

echo "== DEV-11 A03 window_storage done =="
