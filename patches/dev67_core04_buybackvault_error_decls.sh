#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/core/BuybackVault.sol"
LOG_FILE="logs/project.log"

echo "== DEV67 CORE04: declare INVALID_AMOUNT and INSUFFICIENT_BALANCE errors in BuybackVault =="

python3 - <<'PY'
from pathlib import Path

path = Path("contracts/core/BuybackVault.sol")
text = path.read_text()

# Wenn die Errors schon existieren, nichts tun (idempotent)
if "error INVALID_AMOUNT();" in text and "error INSUFFICIENT_BALANCE();" in text:
    print("Errors already declared, no change.")
else:
    anchor = "error PAUSED();"
    if anchor not in text:
        raise SystemExit("Anchor 'error PAUSED();' not found in BuybackVault.sol")

    insert_pos = text.index(anchor) + len(anchor)
    add = "\nerror INVALID_AMOUNT();\nerror INSUFFICIENT_BALANCE();"
    text = text[:insert_pos] + add + text[insert_pos:]
    path.write_text(text)
    print("✓ INVALID_AMOUNT and INSUFFICIENT_BALANCE declared in BuybackVault.sol")
PY

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-67] ${timestamp} BuybackVault: declared INVALID_AMOUNT and INSUFFICIENT_BALANCE errors for executeBuyback()." >> "$LOG_FILE"
echo "✓ Log updated at $LOG_FILE"

echo "== DEV67 CORE04: done =="
