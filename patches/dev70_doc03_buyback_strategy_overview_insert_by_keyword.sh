#!/usr/bin/env bash
set -euo pipefail

OVERVIEW_FILE="docs/architecture/economic_layer_overview.md"
LOG_FILE="logs/project.log"

echo "== DEV70 DOC03: robust StrategyConfig note insert into Economic Layer overview =="

python3 - "$OVERVIEW_FILE" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()

note = """**StrategyConfig (v0.51.0):**

- BuybackVault hält eine minimale `StrategyConfig`-Schicht
  (asset / weightBps / enabled), um zukünftige Multi-Asset- und
  Policy-basierte Buybacks vorzubereiten.
- In v0.51.0 beeinflussen Strategien den `executeBuyback()`-Pfad noch nicht;
  sie dienen lediglich als Konfigurations- und Telemetrie-Basis.

"""

# Wenn der Hinweis schon drin ist: nichts tun
if "StrategyConfig (v0.51.0)" in text:
    print("StrategyConfig note already present; no change.")
else:
    # Wir suchen die erste Zeile, die 'BuybackVault' enthält
    lines = text.splitlines(keepends=True)
    idx = None
    for i, line in enumerate(lines):
        if "BuybackVault" in line:
            idx = i
            break

    if idx is None:
        print("No 'BuybackVault' line found; overview not changed.")
    else:
        # Hinweis direkt nach dieser Zeile einfügen
        lines.insert(idx + 1, note + "\n")
        path.write_text("".join(lines))
        print("✓ StrategyConfig note inserted after first BuybackVault line")
PY

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-70] ${timestamp} BuybackVault: StrategyConfig note robustly inserted into economic_layer_overview.md." >> "$LOG_FILE"
echo "✓ Log updated at $LOG_FILE"

echo "== DEV70 DOC03: done =="
