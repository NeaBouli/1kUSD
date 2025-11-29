#!/usr/bin/env bash
set -euo pipefail

FILE="docs/indexer/indexer_buybackvault.md"
LOG_FILE="logs/project.log"

echo "== DEV76 DOC03: document StrategyEnforcement in BuybackVault indexer guide =="

python3 - <<'PY'
from pathlib import Path

path = Path("docs/indexer/indexer_buybackvault.md")
text = path.read_text()

snippet = """### StrategyEnforcement Flag & Guards (v0.52.x)

Ab v0.52.x kann der BuybackVault optional im „enforced“-Modus laufen:

- Flag: `strategiesEnforced` (bool, on-chain View).
- Setter: `setStrategiesEnforced(bool enforced)` (nur DAO).
- Event: `StrategyEnforcementUpdated(bool enforced)`.

**Relevanz für Indexer / Telemetrie**

- Wenn `strategiesEnforced == false`:
  - Der Vault verhält sich wie in v0.51.0 – `StrategyConfig` dient primär als Doku-/Telemetrie-Schicht.
  - Reverts mit `NO_STRATEGY_CONFIGURED` oder `NO_ENABLED_STRATEGY_FOR_ASSET`
    sollten in diesem Modus _nicht_ auftreten; ein Auftreten wäre ein Signal für
    Inkonsistenz zwischen Deployment und Doku.

- Wenn `strategiesEnforced == true`:
  - Reverts mit `NO_STRATEGY_CONFIGURED` oder `NO_ENABLED_STRATEGY_FOR_ASSET`
    sind „policy expected“ und keine technischen Fehler im Economic Layer.
  - Indexer können optional Metriken ableiten:
    - Anzahl Buyback-Reverts nach Fehlercode (pro Asset / Zeitraum).
    - Zeitspannen, in denen keine gültige Strategie für ein Asset konfiguriert war.
    - Verhältnis erfolgreicher vs. geblockter Buybacks bei aktivem Enforcement.

**Minimum-Anforderungen für Indexer:**

- Events `StrategyEnforcementUpdated` loggen und den jeweils aktuellen Wert
  von `strategiesEnforced` abbilden (z.B. in einem Status-Table).
- Buyback-Versuche, die mit `NO_STRATEGY_CONFIGURED` /
  `NO_ENABLED_STRATEGY_FOR_ASSET` revertieren, erfassen und in Dashboards
  als „Policy-bedingt geblockt“ kennzeichnen (nicht als Protokollfehler).
"""

# Idempotenz: wenn die Überschrift schon existiert, nichts tun
if "### StrategyEnforcement Flag & Guards (v0.52.x)" in text:
    print("StrategyEnforcement indexer snippet already present; no change.")
else:
    lines = text.splitlines(keepends=True)
    insert_idx = None

    # Bevorzugt nach einem StrategyConfig- oder BuybackVault-Hinweis einfügen
    for i, line in enumerate(lines):
        if "StrategyConfig" in line or "BuybackVault" in line:
            insert_idx = i + 1
            break

    if insert_idx is None:
        print("No obvious anchor found; appending StrategyEnforcement snippet at end.")
        if not text.endswith("\\n"):
            text += "\\n"
        text = text + "\\n" + snippet + "\\n"
    else:
        print(f"Inserting StrategyEnforcement snippet after line {insert_idx}.")
        lines.insert(insert_idx, "\\n" + snippet + "\\n")
        text = "".join(lines)

    path.write_text(text)
    print("✓ StrategyEnforcement snippet written/updated in indexer_buybackvault.md")
PY

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-76] ${timestamp} Indexer: documented BuybackVault strategiesEnforced flag & guard semantics in indexer_buybackvault.md." >> "$LOG_FILE"
echo "✓ Log updated at $LOG_FILE"

echo "== DEV76 DOC03: done =="
