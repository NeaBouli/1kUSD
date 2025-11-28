#!/usr/bin/env bash
set -euo pipefail

FILE="docs/governance/parameter_playbook.md"
LOG_FILE="logs/project.log"

echo "== DEV70 DOC04: add BuybackVault StrategyConfig snippet to governance playbook =="

python3 - "$FILE" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()

snippet = """### BuybackVault StrategyConfig (v0.51.0)

Die BuybackVault-Strategie erlaubt es dem DAO, zukünftige Buyback-Policies
vorzukonfigurieren, ohne den aktuellen Ausführungs-Flow zu verändern.

**Parameter (pro Strategie-Slot):**

- \`asset\` – Ziel-Asset (z.B. Governance- oder Treasury-Token)
- \`weightBps\` – Gewichtung in Basispunkten (0–10_000) für spätere Multi-Asset-Logik
- \`enabled\` – Flag, ob die Strategie für Auswertungen/Telemetrie aktiv ist

**Wichtige Hinweise für v0.51.0:**

- \`executeBuyback()\` ignoriert \`StrategyConfig\` aktuell vollständig.
- Strategien dienen ausschließlich als **Konfigurations- und Telemetrie-Basis**
  für künftige Erweiterungen (Multi-Asset, Scheduling, Policy-Module).
- Änderungen an Strategien sind DAO-only und sollten wie Parameter-Änderungen
  dokumentiert und versioniert werden.

"""

# idempotent: wenn die Überschrift schon existiert, nichts tun
if "### BuybackVault StrategyConfig (v0.51.0)" in text:
    print("StrategyConfig snippet already present; no change.")
else:
    # Versuche, eine BuybackVault-Stelle zu finden
    lines = text.splitlines(keepends=True)
    idx = None
    for i, line in enumerate(lines):
        if "BuybackVault" in line:
            idx = i
            break

    if idx is None:
        # Wenn keine BuybackVault-Referenz existiert, einfach am Ende anhängen
        print("No BuybackVault reference found; appending snippet at end of file.")
        if not text.endswith("\n"):
            text += "\n"
        text = text + "\n" + snippet + "\n"
    else:
        # Snippet direkt nach der ersten BuybackVault-Zeile einfügen
        print("Inserting StrategyConfig snippet after first BuybackVault reference.")
        lines.insert(idx + 1, "\n" + snippet + "\n")
        text = "".join(lines)

    path.write_text(text)
    print("✓ StrategyConfig snippet written/updated in parameter_playbook.md")
PY

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-70] ${timestamp} Governance: documented BuybackVault StrategyConfig in parameter_playbook.md." >> "$LOG_FILE"
echo "✓ Log updated at $LOG_FILE"

echo "== DEV70 DOC04: done =="
