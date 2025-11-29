#!/usr/bin/env bash
set -euo pipefail

FILE="docs/reports/PROJECT_STATUS_EconomicLayer_v051.md"
LOG_FILE="logs/project.log"

echo "== DEV76 REP02: update Economic Layer status with StrategyEnforcement Phase-1 preview =="

python3 - <<'PY'
from pathlib import Path

path = Path("docs/reports/PROJECT_STATUS_EconomicLayer_v051.md")
text = path.read_text()

snippet = """## BuybackVault StrategyEnforcement – Phase 1 (v0.52.x Preview)

**Kurzfassung**

- Der BuybackVault wurde um eine optionale Policy-Schicht erweitert:
  - `StrategyConfig` (asset / weightBps / enabled) ist in v0.51.0 bereits
    als Konfigurations- und Telemetrie-Schicht vorhanden.
  - `strategiesEnforced` Flag (bool), steuerbar via `setStrategiesEnforced(bool)` (onlyDAO).
  - Fehlercodes: `NO_STRATEGY_CONFIGURED` und `NO_ENABLED_STRATEGY_FOR_ASSET`.
- Standardverhalten bleibt v0.51.0-kompatibel:
  - `strategiesEnforced` ist im Default `false`.
  - Solange das Flag nicht gesetzt wird, verhält sich `executeBuyback()` wie zuvor.

**Code-Status**

- Kernlogik:
  - Strategy-Storage: `StrategyConfig[] public strategies`.
  - Enforcement-Guard in `executeBuyback()`:
    - Wenn `strategiesEnforced == true`:
      - Revert mit `NO_STRATEGY_CONFIGURED`, falls `strategies.length == 0`.
      - Revert mit `NO_ENABLED_STRATEGY_FOR_ASSET`, falls keine aktivierte Strategie
        für das Ziel-Asset existiert.
    - Wenn `strategiesEnforced == false`:
      - Keine zusätzlichen Reverts, Verhalten entspricht v0.51.0.
  - Events:
    - `StrategyUpdated(uint256 indexed id, address asset, uint16 weightBps, bool enabled)`
    - `StrategyEnforcementUpdated(bool enforced)`
- Tests:
  - `BuybackVaultTest` deckt die Basisflüsse (Funding, Withdraw, Execute).
  - `BuybackVaultStrategyGuardTest` prüft explizit:
    - Durchlauf ohne Enforcements (Backward-Compat).
    - Reverts bei aktivem Enforcement ohne Strategie / ohne aktivierte Strategie.
    - Erfolgreiche Buybacks bei aktivierter, gültiger Strategie.
- Interface:
  - `contracts/strategy/IBuybackStrategy.sol` ist als Forward-Layer definiert,
    wird aber in v0.51.x/0.52.x Phase 1 noch nicht produktiv eingebunden.

**Governance & Doku**

- Governance:
  - `docs/governance/parameter_playbook.md` enthält Abschnitte zu:
    - `StrategyConfig` (v0.51.0, vorbereitend).
    - `StrategyEnforcement (v0.52.x)` inkl. Bedienlogik und Rückfall in den
      „v0.51.0-Mode“ über `setStrategiesEnforced(false)`.
- Architektur:
  - `docs/architecture/buybackvault_strategy.md` – Überblick Strategy-Layer.
  - `docs/architecture/buybackvault_strategy_rfc.md` – RFC mit Optionen und
    Nichtzielen.
  - `docs/architecture/buybackvault_strategy_phase1.md` – Phase-1-Plan
    (optional Enforcement, Single-Asset-Guard).
  - `docs/architecture/economic_layer_overview.md` – Economic-Layer-Übersicht
    inkl. StrategyConfig-Note und StrategyEnforcement-Phase-1-Sektion.
- Indexer:
  - `docs/indexer/indexer_buybackvault.md` dokumentiert:
    - Mapping von `strategiesEnforced` und `StrategyEnforcementUpdated`.
    - Interpretation der Reverts `NO_STRATEGY_CONFIGURED` /
      `NO_ENABLED_STRATEGY_FOR_ASSET` als „policy-bedingt“ und nicht als
      Protokollfehler.

**Einschätzung / Release-Impact**

- v0.51.0 Baseline:
  - Bleibt vollständig gültig, solange `strategiesEnforced == false`.
  - Deployment kann mit aktivem Strategy-Layer, aber deaktiviertem Enforcement
    erfolgen, ohne die bisherigen Sicherheits- und Invarianten-Garantien zu brechen.
- v0.52.x Vorbereitung:
  - StrategyEnforcement-Mechanik ist vollständig implementiert und getestet.
  - Aktivierung des Flags ist eine Governance-/DAO-Entscheidung und sollte
    mit einem eigenen Parameter-Beschluss + Monitoring (Indexer-Dashboards)
    gekoppelt werden.
- Empfehlung:
  - Economic-Layer v0.51.0 als „stabile Basis“ führen.
  - StrategyEnforcement-Phase 1 als „opt-in“ Feature deklarieren, das erst
    nach separatem Governance-Beschluss produktiv aktiviert wird.
"""

if "## BuybackVault StrategyEnforcement – Phase 1 (v0.52.x Preview)" in text:
    print("StrategyEnforcement Phase-1 status section already present; no change.")
else:
    # Wir hängen den Abschnitt ans Ende der Datei an (robust und klar sichtbar)
    if not text.endswith("\\n"):
        text += "\\n"
    text = text + "\\n" + snippet + "\\n"
    path.write_text(text)
    print("✓ StrategyEnforcement Phase-1 status section appended to PROJECT_STATUS_EconomicLayer_v051.md")
PY

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-76] ${timestamp} Economic Layer: updated PROJECT_STATUS_EconomicLayer_v051 with StrategyEnforcement Phase-1 preview status." >> "$LOG_FILE"
echo "✓ Log updated at $LOG_FILE"

echo "== DEV76 REP02: done =="
