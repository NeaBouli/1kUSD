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


## 7. Strategy modules interface (forward-looking)

In version v0.51.0 the BuybackVault exposes only a minimal on-vault
`StrategyConfig` (asset / weightBps / enabled). For future versions
(v0.52+ RFC) external strategy modules can be introduced via a dedicated
`IBuybackStrategy` interface in `contracts/strategy/IBuybackStrategy.sol`.

This interface allows:

- the vault (or a coordinator) to query a strategy contract for a list of
  proposed buyback legs (`BuybackLeg[]`),
- offloading allocation logic and policy rules into upgradable,
  separately-auditable contracts,
- keeping the core vault logic small and focused on execution and safety.

At this stage, `IBuybackStrategy` is defined but *not yet wired* into the
BuybackVault execution path; it serves as a design anchor for future
multi-asset / policy-based buyback phases.

