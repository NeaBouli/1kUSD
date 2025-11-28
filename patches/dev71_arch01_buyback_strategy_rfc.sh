#!/usr/bin/env bash
set -euo pipefail

FILE="docs/architecture/buybackvault_strategy_rfc.md"
LOG_FILE="logs/project.log"

echo "== DEV71 ARCH01: write BuybackVault Strategy RFC =="

mkdir -p "$(dirname "$FILE")"

cat > "$FILE" <<'MD'
# BuybackVault Strategy RFC (DEV-71)

_Status: Draft – v0.51.0 Baseline, Forward Design für v0.52+_

## 1. Kontext & Zielsetzung

Der Economic Layer der 1kUSD-Protokollfamilie besteht aktuell (v0.51.0) aus:

- **PSM (PegStabilityModule)** als Kern-Swap-Engine zwischen 1kUSD und Collateral-Assets.
- **Oracle-Layer** (Aggregator, Watcher, Guardian-Propagation) für Preis- und Health-Signale.
- **BuybackVault** als DAO-gesteuerter Buyback-Tresor für 1kUSD → Target-Asset Swaps via PSM.

Mit v0.51.0 wurde im BuybackVault eine minimale **StrategyConfig**-Schicht eingeführt:

- `StrategyConfig { address asset; uint16 weightBps; bool enabled; }`
- `StrategyConfig[] public strategies;`
- `function strategyCount() external view returns (uint256)`
- `function getStrategy(uint256 id) external view returns (StrategyConfig memory)`
- `function setStrategy(uint256 id, address asset, uint16 weightBps, bool enabled) external`

WICHTIG: In v0.51.0 ist StrategyConfig **rein konfigurativ** – es findet noch keine
late-binding Nutzung im `executeBuyback()`-Pfad statt. Diese RFC beschreibt,
wie zukünftige Versionen (v0.52+) auf dieser Schicht aufbauen sollen.

Ziele:

- Eine klare, DAO-steuerbare **Policy-Schicht** über dem BuybackVault definieren.
- Multi-Asset Buybacks, Gewichtungen und Caps vorbereiten.
- Guardian-/Safety-Regeln für Buybacks fein-granularer gestalten.
- Telemetrie & Indexer von Beginn an mitdenken (event- und snapshot-basiert).

Nicht-Ziele (für diese RFC):

- Konkrete UI-Implementierung
- Vollständige ökonomische Parameterisierung (z.B. exakte Buyback-Formeln)
- On-Chain Scheduler-Implementierung

## 2. Aktuelle Baseline (v0.51.0)

### 2.1 BuybackVault Verhalten

In v0.51.0 gilt:

- DAO fundet BuybackVault mit 1kUSD (`fundStable`).
- DAO ruft `executeBuyback(recipient, amountStable, minAssetOut, deadline)` auf.
- BuybackVault:
  - prüft DAO-Caller, Non-Null Recipient, Non-Zero Amount.
  - prüft via Safety/Guardian, ob `moduleId` pausiert ist.
  - `approve`'t den PSM für `amountStable`.
  - ruft `psm.swapFrom1kUSD(address(asset), amountStable, recipient, minAssetOut, deadline);`
  - emittiert `BuybackExecuted(recipient, amountStable, assetOut)`.

Die **StrategyConfig**-Datenstruktur wird aktuell nur persistent gehalten und event-basiert
sichtbar, aber noch **nicht** für Entscheidungslogik verwendet.

### 2.2 StrategyConfig (v0.51.0)

```solidity
struct StrategyConfig {
    address asset;
    uint16  weightBps; // 0..10000
    bool    enabled;
}
Design-Kriterien:

weightBps ist explizit auf 0..10000 begrenzt (Basis 10000 = 100%).

asset == address(0) kann als "Slot ungenutzt" interpretiert werden.

enabled == false erlaubt, Strategien temporär „stumm“ zu schalten, ohne sie zu löschen.

DAO-only Schreibrechte via setStrategy.

Validierungsregeln:

weightBps == 0 ist erlaubt (z.B. deaktivierte Gewichtung, aber Konfiguration bleibt erhalten).

Spätere Releases können zusätzliche Constraints einführen (z.B. Summe aller enabled-Gewichte <= 10000).

3. Zielbild: Strategy Layer v0.52+
3.1 Hohe Ebene
Die Strategy-Schicht soll mittelfristig:

Multi-Asset Buybacks ermöglichen

Mehrere StrategyConfig-Einträge mit unterschiedlichen Ziel-Assets.

Gewichtete Allokation von 1kUSD-Buybacks über diese Strategien.

Policy-Driven Execution erlauben

DAO kann Ziel-Gewichtungen, Caps und Mindest-Liquidität pro Asset definieren.

Optional: Nur bestimmte Strategien bei bestimmten Marktbedingungen aktivieren.

Guardian/Safety Hooks verfeinern

Guardian kann selektiv bestimmte Strategien pausen (z.B. nur Asset X).

Abbildung von „per-asset“ oder „per-strategy“ Pause-States.

Telemetrie-First sein

Alle relevanten Änderungen über Events:

StrategyUpdated(id, asset, weightBps, enabled)

Bestehende BuybackVault-Events für Funding/Withdraw/Buyback.

Indexer kann daraus historische Strategie-Zeitleisten und Wirksamkeit ableiten.

3.2 Ausführungsmodi (Kandidaten)
Diese RFC behandelt drei mögliche Ausführungsmodi, ohne sie sofort zu implementieren:

Single-Strategy Execution (v0.52 Minimal)

DAO gibt bei executeBuyback() einen Strategy-Index an.

Vault prüft, ob die Strategie:

existiert (id < strategyCount()),

enabled == true ist,

asset != address(0) ist.

Buyback wird ausschließlich mit einer Strategie ausgeführt.

Weighted Multi-Strategy Execution

Input: Gesamt-amountStable.

Vault verteilt amountStable proportional zu weightBps auf alle enabled Strategien.

Mögliche Implementierungsdetails:

Runden auf kleinste Einheit → Restbetrag an höchste Gewichtungs-Strategie.

Fail-fast, wenn eine Strategie-Fee/Slippage-Constraint verletzt ist.

Policy-Module Delegation (spätere Phase)

BuybackVault führt nicht mehr selbst die Allokation durch, sondern callt
ein Strategy-Policy-Modul (z.B. IBuybackStrategy), das die Aufteilung
und Asset-Auswahl bestimmt.

Vorteile:

Komplexere Policies (Zeitabhängigkeit, Volatilität, externe Signale).

On-Chain Upgrades nur am Strategy-Modul, BuybackVault bleibt schlank.

3.3 Hard Constraints
Unabhängig vom Modus gelten:

Safety First

Kein Buyback, wenn safety.isPaused(moduleId) true liefert.

Später: extend auf „sub-module“/„sub-strategy“ Pausen.

Min-Out & Deadline

Pro Strategie (oder pro Gesamt-Call) müssen minAssetOut und deadline
eingehalten werden.

Phase 1 (Single-Strategy): Parameter wie bisher global für den Call.

Phase 2 (Multi-Strategy): Optionale per-strategy Overrides.

Determinismus & Reproduzierbarkeit

Gleiche Inputs (Strategien, Gewichte, Marktpreise) → deterministisches Ergebnis.

Keine versteckten Zufallskomponenten.

4. Schnittstellenentwurf (Draft)
4.1 Mögliche Interface-Erweiterungen
Variante A: Leichtgewichtige Erweiterung von BuybackVault
solidity
Code kopieren
function executeBuybackWithStrategy(
    uint256 strategyId,
    uint256 amountStable,
    uint256 minAssetOut,
    uint256 deadline
) external;
Eigenschaften:

Rückwärtskompatibel: executeBuyback() bleibt als „Legacy“-Hook bestehen.

UIs/DAOs können nach und nach auf executeBuybackWithStrategy() migrieren.

Strategy-Checks:

strategyId < strategyCount()

StrategyConfig.enabled == true

StrategyConfig.asset != address(0)

Variante B: Externes Strategy-Interface
solidity
Code kopieren
interface IBuybackStrategy {
    function allocate(
        uint256 totalStableAmount
    ) external view returns (address[] memory assets, uint256[] memory amounts);
}
BuybackVault würde dann:

IBuybackStrategy(strategyModule).allocate(amountStable) callen.

Für jedes (asset[i], amount[i]) einen PSM-Swap ausführen.

BuybackExecuted-Events aggregiert/iteriert emittieren (ggf. pro Asset).

Vor-/Nachteile:

Hohe Flexibilität (DCA, Band-Triggers, Orakel-Signale).

– Höhere Komplexität, Permissions & Upgrades müssen sauber geregelt sein.

4.2 Governance Hooks
Parameter
strategyCount, getStrategy, setStrategy bleiben DAO-only.

Zusätzlich mögliche Hooks:

setStrategyModule(address strategyModule)

setMaxStrategies(uint256 max) (Limit gegen unendliche Strategien).

Invarianten
Summe der weightBps aller enabled Strategien **<= 10000`.

Für bestimmte Releases kann die Invariante verschärft werden (z.B. genau 10000
für „voll allozierten“ Buyback-Modus).

5. Telemetrie & Indexer
5.1 Events
Bereits vorhanden:

StableFunded(address indexed from, uint256 amount);

StableWithdrawn(address indexed to, uint256 amount);

AssetWithdrawn(address indexed to, uint256 amount);

BuybackExecuted(address indexed recipient, uint256 stableIn, uint256 assetOut);

StrategyUpdated(uint256 indexed id, address asset, uint16 weightBps, bool enabled);

Konzept für Indexer:

StrategyConfig-Tabelle:

strategy_id

asset_address

weight_bps

enabled

valid_from_block / valid_to_block

Buyback-Events:

Zuordnung zu Strategie (über executeBuybackWithStrategy() Input oder Strategy-Policy-Event).

Aggregation: Buyback-Volumen pro Strategie/Asset/Zeitraum.

5.2 Monitoring & Health
Indikatoren:

„Effective Weight“: Anteil des tatsächlichen Buyback-Volumens pro Asset vs. Zielgewicht.

„Slippage / Min-Out Deferrals“: Anzahl der abgebrochenen Buybacks aufgrund
von Min-Out-Verletzungen.

„Pause Coverage“: Anteil der Zeit, in der BuybackVault/Strategien pausiert waren.

6. Migrationsplan
Phase 0 – Jetzt (v0.51.0)
StrategyConfig nur als konfigurative Daten.

Nur executeBuyback() im Einsatz.

Strategy-Änderungen bereits vollständig event- & log-dokumentiert.

Phase 1 – Single-Strategy Execution (v0.52.x)
Einführung von executeBuybackWithStrategy(strategyId, ...).

Optional: New Event-Variante, die StrategyId mitemittiert.

Guardian/DAO-Playbook-Update:

Wie Strategien gesetzt/deaktiviert werden.

Wie UIs dies exponieren.

Phase 2 – Multi-Asset / Weighted Execution
Verwendung von weightBps für automatische Allokation.

Erweiterte Tests:

Summe der ausgeführten Teil-Buybacks ≈ Gesamt-Input (inkl. Rundung).

Resilience gegen PSM/Oracle-Edge-Cases pro Asset.

Phase 3 – Externe Strategy-Module
Optionales IBuybackStrategy-Interface.

BuybackVault delegiert Allokationsentscheidungen.

Strikte Guardian/DAO-Controls für Strategy-Module (Upgrades, Pausen, Kill-Switch).

7. Offene Fragen
Welche Granularität soll die DAO für Strategien haben?

Pro Asset?

Pro Marktsegment (z.B. L1/L2, Stable/Volatile)?

Sollen Strategien hard- oder soft-capped sein (max. Volumen pro Tag/Woche)?

Wie werden On-Chain-Kosten gewichtet (Anzahl PSM-Calls vs. Komplexität)?

Nächste Schritte (Empfehlung):

Diese RFC als Basis für ein internes Architekten-Review nutzen.

Eine minimal-invasive Variante („Phase 1“) auswählen.

Konkrete DEV-Tickets für v0.52.x definieren:

Interface-Änderungen

Tests

Governance-Doku

Indexer-Updates
MD

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-71] ${timestamp} BuybackVault: Strategy RFC (buybackvault_strategy_rfc.md) added as forward design for v0.52+." >> "$LOG_FILE"

echo "✓ BuybackVault Strategy RFC written to $FILE"
echo "✓ Log updated at $LOG_FILE"
echo "== DEV71 ARCH01: done =="
