#!/usr/bin/env bash
set -euo pipefail

FILE="docs/architecture/economic_layer_overview.md"
LOG_FILE="logs/project.log"

echo "== DEV72 DOC02: mention IBuybackStrategy in Economic Layer overview =="

python3 - "$FILE" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()

snippet = """- A forward-looking strategy interface `IBuybackStrategy`
  (`contracts/strategy/IBuybackStrategy.sol`) is defined for v0.52+ to host
  external, upgradable buyback strategy modules. In v0.51.0 it is **not yet**
  wired into `BuybackVault` and only serves as a design anchor."""

if "IBuybackStrategy" in text:
    print("IBuybackStrategy already mentioned; no change.")
else:
    lines = text.splitlines(keepends=True)
    idx = None

    # 1) Bevorzugt direkt hinter der StrategyConfig-Notiz
    for i, line in enumerate(lines):
        if "StrategyConfig (v0.51.0)" in line:
            idx = i
            break

    # 2) Fallback: erste BuybackVault-Zeile
    if idx is None:
        for i, line in enumerate(lines):
            if "BuybackVault" in line:
                idx = i
                break

    if idx is None:
        # 3) Fallback: ans Ende anhängen
        print("No StrategyConfig / BuybackVault reference found; appending snippet at end.")
        if not text.endswith("\n"):
            text += "\n"
        text = text + "\n" + snippet + "\n"
    else:
        print(f"Inserting snippet after line {idx+1}.")
        # Eine Bullet-Zeile direkt unterhalb einfügen
        insertion = "  " + snippet + "\n"
        # Wenn die Zeile bereits ein Bullet hat, einfach danach einfügen
        lines.insert(idx + 1, insertion)
        text = "".join(lines)

    path.write_text(text)
    print("✓ Economic Layer overview updated with IBuybackStrategy mention.")
PY

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-72] ${timestamp} Economic Layer: mentioned IBuybackStrategy as forward-looking strategy interface in economic_layer_overview.md." >> "$LOG_FILE"
echo "✓ Log updated at $LOG_FILE"

echo "== DEV72 DOC02: done =="
