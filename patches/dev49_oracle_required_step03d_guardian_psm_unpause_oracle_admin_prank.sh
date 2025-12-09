#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

python - << 'PY'
from pathlib import Path
from datetime import datetime, timezone

path = Path("foundry/test/Guardian_PSMUnpause.t.sol")
text = path.read_text()

anchor = "psm.setOracle(address(oracle));"
replacement = """vm.prank(dao);
        psm.setOracle(address(oracle));"""

if anchor not in text:
    raise SystemExit(f"anchor '{anchor}' not found in Guardian_PSMUnpause.t.sol")

# Nur das erste Vorkommen ersetzen
text = text.replace(anchor, replacement, 1)
path.write_text(text)

# Log-Eintrag
log_path = Path("logs/project.log")
ts = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
with log_path.open("a", encoding="utf-8") as f:
    f.write(f"[DEV-49] {ts} Guardian_PSMUnpause: call setOracle as dao via vm.prank(dao)\n")
PY

echo "== DEV-49 step03d: Guardian_PSMUnpause setOracle wrapped in vm.prank(dao) =="
