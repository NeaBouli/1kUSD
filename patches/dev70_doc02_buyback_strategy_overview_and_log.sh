#!/usr/bin/env bash
set -euo pipefail

OVERVIEW_FILE="docs/architecture/economic_layer_overview.md"
LOG_FILE="logs/project.log"

echo "== DEV70 DOC02: update Economic Layer overview with StrategyConfig + log =="

########################################
# 1) Economic Layer Overview aktualisieren
########################################

python3 - "$OVERVIEW_FILE" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()

marker = "## 4. BuybackVault"
note = """**StrategyConfig (v0.51.0):**

- BuybackVault hält eine minimale `StrategyConfig`-Schicht
  (asset / weightBps / enabled), um zukünftige Multi-Asset- und
  Policy-basierte Buybacks vorzubereiten.
- In v0.51.0 beeinflussen Strategien den `executeBuyback()`-Pfad noch nicht;
  sie dienen lediglich als Konfigurations- und Telemetrie-Basis.

"""

if "StrategyConfig (v0.51.0)" in text:
    print("Overview already contains StrategyConfig note; no change.")
elif marker not in text:
    print("Marker not found; overview not changed.")
else:
    idx = text.index(marker)
    end = text.index("\n", idx) + 1
    text = text[:end] + note + "\n" + text[end:]
    path.write_text(text)
    print("✓ Economic Layer overview updated with StrategyConfig note")
PY

########################################
# 2) Log-Eintrag
########################################

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-70] ${timestamp} BuybackVault: StrategyConfig documented in economic_layer_overview.md." >> "$LOG_FILE"
echo "✓ Log updated at $LOG_FILE"

echo "== DEV70 DOC02: done =="
