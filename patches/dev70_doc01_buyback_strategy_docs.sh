#!/usr/bin/env bash
set -euo pipefail

ARCH_FILE="docs/architecture/buybackvault_strategy.md"
OVERVIEW_FILE="docs/architecture/economic_layer_overview.md"
LOG_FILE="logs/project.log"

echo "== DEV70 DOC01: add BuybackVault StrategyConfig docs =="

########################################
# 1) Neues Strategy-Dokument
########################################

cat <<'MD' > "$ARCH_FILE"
# BuybackVault StrategyConfig (v0.51.0 baseline)

## 1. Ziel

Dieses Dokument beschreibt die minimale **StrategyConfig-Schicht** des BuybackVault,
wie sie ab Version **v0.51.0** implementiert ist. Ziel ist:

- die BuybackVault-Architektur frühzeitig auf **Multi-Asset- / Policy-basierte Buybacks**
  vorzubereiten,
- ohne das bisherige Verhalten von `executeBuyback()` zu verändern.

> Wichtig: In v0.51.0 ist **kein automatisches Scheduling** aktiv. Strategien werden
> nur als Konfiguration gehalten und noch nicht im Ausführungsweg erzwungen.

---

## 2. Datenstruktur

```solidity
struct StrategyConfig {
    address asset;
    uint16  weightBps;
    bool    enabled;
}
asset
Ziel-Asset der Buyback-Strategie. In v0.51.0 faktisch deckungsgleich mit dem
asset, das der Vault ohnehin hält.

weightBps
Gewichtung in Basis-Punkten (0–10_000). Dient als Vorbereitung für
Multi-Asset-Setups (z. B. mehrere Ziel-Assets mit unterschiedlichen Gewichten).

enabled
Schalter, ob diese Strategie derzeit aktiv berücksichtigt werden soll
(für spätere, automatisierte Ausführungs-Module).

3. Storage & API
3.1 Storage
solidity
Code kopieren
StrategyConfig[] public strategies;
strategies.length bestimmt die Anzahl der konfigurierten Strategien.

In v0.51.0 wird typischerweise Index 0 verwendet.

3.2 Externe View-Funktionen
solidity
Code kopieren
function strategyCount() external view returns (uint256);
function getStrategy(uint256 id) external view returns (StrategyConfig memory);
strategyCount()
Liefert strategies.length.

getStrategy(id)
Gibt die StrategyConfig am entsprechenden Index zurück oder revertiert mit
INVALID_STRATEGY(), falls id >= strategies.length.

3.3 DAO-only Mutator
solidity
Code kopieren
function setStrategy(
    uint256 id,
    address asset_,
    uint16 weightBps_,
    bool enabled_
) external;
Regeln:

Nur dao darf setStrategy aufrufen (NOT_DAO() bei Verstoß).

Falls id > strategies.length → revert mit INVALID_STRATEGY().

Falls id == strategies.length → neue Strategie wird appended.

Falls id < strategies.length → bestehende Strategie wird aktualisiert.

Event:

solidity
Code kopieren
event StrategyUpdated(uint256 indexed id, address asset, uint16 weightBps, bool enabled);
Wird für sowohl neue als auch aktualisierte Strategien emittiert und erlaubt
dem Indexer, ein vollständiges Bild der Strategiekonfigurationen aufzubauen.

Error:

solidity
Code kopieren
error INVALID_STRATEGY();
Wird verwendet für:

getStrategy(id) mit id >= strategies.length

setStrategy(id, ...) mit id > strategies.length

4. Interaktion mit executeBuyback()
In v0.51.0:

executeBuyback() nutzt noch keine StrategyConfig-Felder zur Laufzeit.

Der Buyback erfolgt weiterhin gemäß dem durch den DAO-Call übergebenen
Betrag und Empfänger.

StrategyConfig dient ausschließlich als Konfigurations- / Planungs-Layer
für zukünftige Erweiterungen.

Geplante Erweiterungen (nicht Teil von v0.51.0):

Verteilung eines 1kUSD-Budgets auf mehrere Ziel-Assets gemäß weightBps.

Wiederverwendung derselben Strategiekonfiguration für periodische
Ausführungen (DCA-ähnliche Strategien).

Nutzung durch Offchain-Scheduler oder zusätzliche Onchain-Module.

5. Governance & Telemetrie
5.1 Governance
Nur der DAO-Account (gleicher Caller wie für BuybackVault-Funding und
Parameter-Änderungen) kann Strategien anlegen oder ändern.

StrategyConfig-Änderungen sollten idealerweise über den gleichen
Timelock/Proposal-Prozess laufen wie andere Economic-Layer-Entscheidungen.

5.2 Telemetrie
StrategyUpdated-Events können vom Indexer konsumiert werden, um einen
aktuellen Konfigurations-Snapshot abzuleiten.

In Kombination mit BuybackVault-Events (StableFunded, BuybackExecuted,
StableWithdrawn, AssetWithdrawn) kann ein Monitoring-Dashboard
aufgebaut werden, das zeigt:

welche Strategien konfiguriert sind,

wie viel 1kUSD in Buybacks geflossen ist,

wie sich das Asset im Zeitverlauf entwickelt.

MD

echo "✓ BuybackVault strategy architecture written to $ARCH_FILE"

########################################

2) Optional: Economic Layer Overview verlinken
########################################

python3 - <<'PY'
from pathlib import Path

path = Path("docs/architecture/economic_layer_overview.md")
text = path.read_text()

marker = "## 4. BuybackVault"
if marker in text and "StrategyConfig" not in text:
insert_pos = text.index(marker)
# wir hängen einen kurzen Hinweisblock direkt NACH der Überschrift an
heading_end = text.index("\n", insert_pos) + 1
add = """
StrategyConfig (v0.51.0):

BuybackVault hält eine minimale StrategyConfig-Schicht
(asset / weightBps / enabled), um zukünftige Multi-Asset- und
Policy-basierte Buybacks vorzubereiten.

In v0.51.0 beeinflussen Strategien den executeBuyback()-Pfad noch nicht;
sie dienen lediglich als Konfigurations- und Telemetrie-Basis.

"""
text = text[:heading_end] + add + text[heading_end:]
path.write_text(text)
print("✓ Economic Layer overview updated with StrategyConfig note")
else:
print("Economic Layer overview not updated (marker missing or StrategyConfig already mentioned).")
PY

########################################

3) Log-Eintrag
########################################

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-70] ${timestamp} BuybackVault: added StrategyConfig architecture doc + optional overview note." >> "$LOG_FILE"
echo "✓ Log updated at $LOG_FILE"

echo "== DEV70 DOC01: done =="
