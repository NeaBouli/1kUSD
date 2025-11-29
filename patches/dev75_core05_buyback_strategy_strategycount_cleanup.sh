#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/core/BuybackVault.sol"
LOG_FILE="logs/project.log"

echo "== DEV75 CORE05: cleanup strategyCount var and use strategies.length in guard =="

python3 - <<'PY'
from pathlib import Path

path = Path("contracts/core/BuybackVault.sol")
text = path.read_text()
orig = text

lines = text.splitlines(keepends=True)
new_lines = []
removed_var = False

# 1) State-Var-Zeile "uint256 public strategyCount;" entfernen
for line in lines:
    if "uint256 public strategyCount" in line and "function" not in line:
        removed_var = True
        # Zeile wird weggelassen
        continue
    new_lines.append(line)

text = "".join(new_lines)

if removed_var:
    print("✓ Removed state-variable line for strategyCount")

# 2) Guard-Ausdrücke auf strategies.length umbiegen
if "strategyCount == 0" in text:
    text = text.replace("strategyCount == 0", "strategies.length == 0")
    print("✓ Replaced 'strategyCount == 0' with 'strategies.length == 0'")

if "i < strategyCount" in text:
    text = text.replace("i < strategyCount", "i < strategies.length")
    print("✓ Replaced 'i < strategyCount' with 'i < strategies.length'")

if text == orig:
    print("No changes applied (file already clean).")
else:
    path.write_text(text)
    print("BuybackVault.sol updated.")
PY

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-75] ${timestamp} BuybackVault: cleaned up strategyCount state var, guard now uses strategies.length." >> "$LOG_FILE"
echo "✓ Log updated at $LOG_FILE"

echo "== DEV75 CORE05: done =="
