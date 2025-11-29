#!/usr/bin/env bash
set -euo pipefail

FILE="docs/architecture/economic_layer_overview.md"
LOG_FILE="logs/project.log"

echo "== DEV76 DOC02: mention StrategyEnforcement Phase-1 in Economic Layer overview =="

python3 - <<'PY'
from pathlib import Path

path = Path("docs/architecture/economic_layer_overview.md")
text = path.read_text()

snippet = """### BuybackVault StrategyEnforcement – Phase 1 (v0.52.x Plan)

Für v0.52.x ist eine optionale „Phase 1“-Durchsetzung von Strategien vorgesehen:

- Flag: `strategiesEnforced` (bool, Default: `false`).
- Setter: `setStrategiesEnforced(bool enforced)` (nur DAO).
- Event: `StrategyEnforcementUpdated(bool enforced)`.

**Bedeutung für den Economic Layer:**

- `strategiesEnforced == false`  
  - BuybackVault verhält sich wie in v0.51.0: `StrategyConfig` dient primär der Dokumentation und Telemetrie.
- `strategiesEnforced == true`  
  - Buybacks laufen nur durch, wenn:
    - mindestens eine Strategie konfiguriert ist (`strategies.length > 0`), sonst Revert `NO_STRATEGY_CONFIGURED`;
    - eine aktivierte Strategie für das Ziel-Asset existiert, sonst Revert `NO_ENABLED_STRATEGY_FOR_ASSET`.
  - Guardian-/PSM-Checks bleiben unverändert aktiv.

Die Aktivierung von `strategiesEnforced` wird als Governance-Entscheidung behandelt und kann bei Bedarf wieder zurückgenommen werden, um in den v0.51.0-kompatiblen Modus ohne Strategy-Guard zurückzukehren.
"""

# Wenn der Abschnitt schon existiert, nichts tun
if "### BuybackVault StrategyEnforcement – Phase 1" in text:
    print("StrategyEnforcement Phase-1 section already present; no change.")
else:
    lines = text.splitlines(keepends=True)
    insert_idx = None

    # Bevorzugt nach dem StrategyConfig-Hinweis einfügen
    for i, line in enumerate(lines):
        if "StrategyConfig (v0.51.0)" in line:
            insert_idx = i + 1
            break

    if insert_idx is None:
        print("StrategyConfig marker not found; appending Phase-1 section at end.")
        if not text.endswith("\n"):
            text += "\n"
        text = text + "\n" + snippet + "\n"
    else:
        print(f"Inserting Phase-1 section after line {insert_idx}.")
        lines.insert(insert_idx, "\n" + snippet + "\n")
        text = "".join(lines)

    path.write_text(text)
    print("✓ StrategyEnforcement Phase-1 section written/updated in economic_layer_overview.md")
PY

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-76] ${timestamp} Economic Layer: documented StrategyEnforcement Phase-1 (optional guard) in economic_layer_overview.md." >> "$LOG_FILE"
echo "✓ Log updated at $LOG_FILE"

echo "== DEV76 DOC02: done =="
