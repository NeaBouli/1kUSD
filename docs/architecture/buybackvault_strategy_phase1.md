# BuybackVault Strategy Phase 1 – Single-Asset Guard (v0.52.x)

Status: RFC / Draft  
Ziel-Release: v0.52.x+  
Autor: DEV-7 / Economic Layer

---

## 1. Hintergrund

Mit v0.51.0 wurde der Economic Layer wie folgt konsolidiert:

- **PegStabilityModule (PSM)** – Kern-Swap-Logik zwischen 1kUSD und Collateral.
- **Oracles + Guardian** – Preisfeeds + Sicherheitslogik zur Pausierung.
- **BuybackVault** – DAO-gesteuerter Vault für 1kUSD-basiertes Buyback-Programm:
  - Funding (1kUSD → Vault)
  - Withdraw (Asset/Stable → DAO)
  - PSM-basiertes Buyback (1kUSD → Asset)
  - Guardian-Pause via `moduleId` + Safety

In v0.51.0 wurde außerdem eine minimale **StrategyConfig**-Schicht eingeführt:

- `struct StrategyConfig { address asset; uint16 weightBps; bool enabled; }`
- `StrategyConfig[] strategies;`
- `function strategyCount() external view returns (uint256);`
- `function getStrategy(uint256 id) external view returns (StrategyConfig memory);`
- `function setStrategy(uint256 id, address asset, uint16 weightBps, bool enabled) external;`
- `error INVALID_STRATEGY();`
- `event StrategyUpdated(uint256 indexed id, address indexed asset, uint16 weightBps, bool enabled);`

Wichtig:  
> In v0.51.0 beeinflussen Strategien den `executeBuyback()`-Pfad **nicht**.  
> Sie dienen ausschließlich als Konfigurations- und Telemetrie-Basis.

Phase 1 soll dies **sanft** erweitern, ohne die Stabilität des Economic Layers zu gefährden.

---

## 2. Ziele von Strategy Phase 1

1. **Optionale Aktivierung von Strategien**  
   - Standardverhalten bleibt wie v0.51.0 (strategies nicht aktiv erzwingend).
   - DAO kann explizit einen „Strategy Mode“ einschalten.

2. **Single-Asset Guard (Forward Compatibility)**  
   - In Phase 1 bleibt BuybackVault effektiv **Single-Asset**:
     - Vault‐Asset = eine Ziel-Asset-Adresse.
   - Strategien dienen als **Guardrail**:
     - Überprüfung, dass es mindestens eine kompatible, aktivierte Strategie
       für dieses Asset gibt.

3. **Keine „Magie“ im Execution Path**  
   - `executeBuyback()` bleibt strukturell ähnlich:
     - zieht 1kUSD ein,
     - ruft PSM,
     - sendet Asset an den Empfänger.
   - Strategien wirken nur als **Konfigurations-Constraint**, nicht als komplexer
     Allocator für mehrere Assets.

4. **Guarded Evolution zu Multi-Asset / Policy-Modulen**  
   - Phase 1 soll so geschnitten sein, dass sie später zu:
     - Multi-Asset-Strategien,
     - DCA/Scheduling,
     - dynamischen Policies
     ausgebaut werden kann, ohne große Refactors.

---

## 3. Proposed Contract Changes (Entwurf)

### 3.1 BuybackVault: Strategy Mode

Neues Feld (Entwurf):

- `bool public strategiesEnforced;`

Neue Funktion:

- `function setStrategiesEnforced(bool enforced) external;`
  - `onlyDAO`
  - Event:
    - `event StrategyEnforcementUpdated(bool enforced);`

Semantik:

- Default (nach Deployment / in v0.51.x) → `strategiesEnforced = false`
  - Das entspricht exakt dem aktuellen Verhalten.
- Wenn die DAO `strategiesEnforced = true` setzt:
  - BuybackVault verlangt, dass mindestens eine gültige, aktivierte Strategie
    existiert, bevor `executeBuyback()` ausgeführt werden kann.

### 3.2 StrategyConfig Nutzung in executeBuyback()

Aktueller Pfad (vereinfacht):

- `executeBuyback(recipient, amountStable, minAssetOut, deadline)`
  - Checks:
    - `onlyDAO`
    - `!paused`
    - `amountStable > 0`
    - `recipient != address(0)`
  - PSM-Swap:
    - `psm.swapFrom1kUSD(address(asset), amountStable, recipient, minAssetOut, deadline);`

Phase 1 (nur wenn `strategiesEnforced == true`):

- Vor dem PSM-Call:
  1. `require(strategyCount() > 0, "NO_STRATEGY_CONFIGURED");`
  2. Mindestens **eine** Strategie muss:
     - `enabled == true`
     - `asset == address(asset)` (Vault-Asset)
  3. Optional: Konsistenzcheck der Gewichte:
     - Summe `weightBps` aller `enabled` Strategien == 10000 (oder <= 10000).

Neue Errors (Entwurf):

- `error NO_STRATEGY_CONFIGURED();`
- `error NO_ENABLED_STRATEGY_FOR_ASSET();`

Wichtig:  
- In Phase 1 führt diese Prüfung **nur zu einem Revert**, wenn Strategien nicht
  sinnvoll gesetzt sind.
- Es werden **keine** komplexen Allokations-Berechnungen durchgeführt.

---

## 4. DAO / Governance-Sicht

### 4.1 Parameter im Governance-Kontext

Aus DAO-Sicht kommen damit folgende Parameter hinzu:

- `strategiesEnforced` (bool)
  - „Schalte den Strategy-Guard für BuybackVault ein/aus“.
- `StrategyConfig[] strategies`
  - Pro Eintrag:
    - `asset` (sollte aktuell == Vault-Asset sein),
    - `weightBps`,
    - `enabled`.

Empfohlene Governance-Richtlinien:

1. **Phasenweiser Rollout**
   - Zuerst Strategien definieren (StrategyConfig setzen).
   - Danach `strategiesEnforced = true` setzen, wenn alle Checks OK sind.

2. **Konsistenz-Checks vor On-Chain-Änderungen**
   - Off-Chain Tooling (z.B. Scripts/CI) sollte:
     - sicherstellen, dass es mindestens eine aktivierte Strategie mit
       der Vault-Asset-Adresse gibt.
     - prüfen, dass Gewichtssummen sinnvoll sind.

3. **Rollback-Strategie**
   - Bei Problemen kann die DAO:
     - `strategiesEnforced = false` setzen,
     - und damit sofort zum v0.51.0-Verhalten zurückkehren.

---

## 5. Interaktion mit Guardian / Safety

Strategy Phase 1 ändert **nicht** das Guardian-/Safety-Modell:

- `safety.isPaused(moduleId)` bleibt die oberste Instanz:
  - ist das Modul pausiert → kein Buyback, unabhängig von Strategien.
- Strategien ergänzen das Modell nur um „feinere“ DAO-seitige Entscheidungen:
  - welche Assets (in Zukunft: mehrere),
  - welche Gewichte.

Für spätere Phasen (nicht Teil von Phase 1) kann man überlegen:

- Asset-spezifische Pausen (z.B. `pauseAsset(asset)`).
- Strategie-spezifische Caps (z.B. max Daily Volume pro Strategie).

---

## 6. Telemetrie / Indexer

Phase 1 erzeugt keine neuen Kern-Events außer ggf.:

- `StrategyEnforcementUpdated(bool enforced)`

Bereits existierende Events:

- `StrategyUpdated(id, asset, weightBps, enabled)`
- BuybackVault-Basis-Events:
  - `StableFunded`
  - `StableWithdrawn`
  - `AssetWithdrawn`
  - `BuybackExecuted`

Empfehlung für Indexer:

- Zusätzliches Flag im Off-Chain-Model:
  - `buyback_vault.strategies_enforced`
- Alerts:
  - Wenn `strategiesEnforced = true`, aber keine aktivierte Strategie für das
    Vault-Asset existiert → Warnung.

---

## 7. Scope & Non-Goals von Phase 1

**In Scope**

- Einführung eines optionalen Strategy-Guard-Modus.
- Minimaler Check in `executeBuyback()`:
  - vorhandene, aktivierte Strategie(n) für das Vault-Asset.
- Erweiterung der Governance-Doku (Parameter-Playbook).
- Ggf. kleinere Anpassungen im Telemetrie-Dokument.

**Nicht in Scope**

- Multi-Asset Buyback (mehrere Ziel-Assets).
- Zeitbasierte Strategien (DCA, Schedules).
- Komplexe On-Chain-Optimierung (z.B. Preise, Slippage, Multi-DEX).
- Änderungen an PSM-/Oracle-Core-Logik.

---

## 8. Empfohlene DEV-Tasks (Forward Plan v0.52.x)

Vorschlag für saubere, kleine Tickets:

- **DEV-74 CORE01 – StrategyEnforcement Flag**
  - `strategiesEnforced` Feld + Getter.
  - `setStrategiesEnforced(bool)` mit `onlyDAO`.
  - `StrategyEnforcementUpdated` Event.
  - Basis-Tests in `BuybackVault.t.sol`.

- **DEV-75 CORE02 – Strategy Guard in executeBuyback()**
  - Einbau der `NO_STRATEGY_CONFIGURED` / `NO_ENABLED_STRATEGY_FOR_ASSET`
    Checks, nur wenn `strategiesEnforced == true`.
  - Tests:
    - Mode off → keine Änderungen.
    - Mode on, aber keine Strategie → Revert.
    - Mode on, gültige Strategie → OK.

- **DEV-76 DOC – Governance & Telemetrie**
  - Update `docs/governance/parameter_playbook.md` mit StrategyEnforcement-Flow.
  - Ergänzung in `economic_layer_overview.md` zu Phase 1.
  - Ggf. Indexer-Notiz / Telemetrie-Guides.

Dieses Dokument dient als Referenz für den Architekten / Lead-Dev und kann
vor dem eigentlichen v0.52.x-Implementierungsschritt noch geschärft werden.

---

_For planned advanced phases beyond StrategyEnforcement v0.52, see  
`docs/dev/DEV11_BuybackVault_EconomicAdvanced_Plan_r1.md` (DEV-11 planning document, docs-only, no contract changes)._
