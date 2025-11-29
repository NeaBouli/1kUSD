#!/usr/bin/env bash
set -euo pipefail

FILE="docs/governance/parameter_playbook.md"
LOG_FILE="logs/project.log"

echo "== DEV76 DOC01: document BuybackVault StrategyEnforcement in governance playbook =="

python3 - <<'PY'
from pathlib import Path

path = Path("docs/governance/parameter_playbook.md")
text = path.read_text()

snippet = """### BuybackVault StrategyEnforcement (v0.52.x – Phase 1)

- Flag: \`strategiesEnforced\` (bool, Default: \`false\`).
- Setter: \`setStrategiesEnforced(bool enforced)\` (nur DAO, Revert bei Nicht-DAO).
- Ereignis: \`StrategyEnforcementUpdated(bool enforced)\` bei jeder Änderung.

**Semantik:**

- Wenn \`strategiesEnforced == false\`:
  - \`executeBuyback()\` verhält sich wie in v0.51.0.
  - Strategien (\`StrategyConfig\`) sind rein deklarativ (Doku/Telemetrie), kein Hard-Guard.

- Wenn \`strategiesEnforced == true\`:
  - Falls keine Strategie konfiguriert ist (\`strategies.length == 0\`):
    - Revert: \`NO_STRATEGY_CONFIGURED\`.
  - Falls keine aktivierte Strategie für das Ziel-Asset existiert:
    - Revert: \`NO_ENABLED_STRATEGY_FOR_ASSET\`.
  - Falls eine passende, aktivierte Strategie existiert:
    - \`executeBuyback()\` läuft normal durch (inkl. bestehender PSM-/Guardian-Checks).

**DAO-Workflow (Beispiel):**

1. Eine oder mehrere Strategien über \`setStrategy(id, asset, weightBps, enabled)\` anlegen/aktualisieren.
2. Prüfen, dass die Ziel-Assets und Gewichte im gewünschten Rahmen liegen.
3. \`setStrategiesEnforced(true)\` durch einen Governance-Beschluss ausführen.
4. Buybacks laufen ab diesem Zeitpunkt nur noch durch, wenn eine gültige Strategie für das verwendete Asset existiert.
5. Im Notfall kann die DAO \`setStrategiesEnforced(false)\` aufrufen, um temporär in den „v0.51.0-Mode“ ohne Strategy-Guard zurückzukehren.

"""

# idempotent: wenn der Abschnitt schon existiert, nichts tun
if "### BuybackVault StrategyEnforcement (v0.52.x" in text:
    print("StrategyEnforcement snippet already present; no change.")
else:
    lines = text.splitlines(keepends=True)
    insert_idx = None

    # Bevorzugt: direkt NACH dem StrategyConfig-Abschnitt einfügen
    for i, line in enumerate(lines):
        if "### BuybackVault StrategyConfig" in line:
            insert_idx = i + 1
            break

    if insert_idx is None:
        # Fallback: am Ende der Datei anhängen
        print("StrategyConfig section not found; appending StrategyEnforcement snippet at end.")
        if not text.endswith("\n"):
            text += "\n"
        text = text + "\n" + snippet + "\n"
    else:
        print(f"Inserting StrategyEnforcement snippet after line {insert_idx}.")
        lines.insert(insert_idx, "\n" + snippet + "\n")
        text = "".join(lines)

    path.write_text(text)
    print("✓ StrategyEnforcement snippet written/updated in parameter_playbook.md")
PY

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-76] ${timestamp} Governance: documented BuybackVault strategiesEnforced flag and guard flow in parameter_playbook.md." >> "$LOG_FILE"
echo "✓ Log updated at $LOG_FILE"

echo "== DEV76 DOC01: done =="
