# 1kUSD Indexer & Telemetry Specification – BuybackVault  
\n### StrategyEnforcement Flag & Guards (v0.52.x)

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
\n## Economic Layer v0.51.0

## 1. Purpose

This document specifies how an indexer and telemetry stack SHOULD ingest, normalize and expose data related to the **BuybackVault** and associated strategies for the 1kUSD Economic Layer v0.51.0 on an EVM-compatible environment (Kasplex-compatible, final deployment chain TBD).

It defines:

- core events and telemetry DTOs,
- key performance indicators (KPIs),
- integration with PoR and risk monitoring,
- requirements for DevOps monitoring and user-facing dashboards.

It does **not** prescribe a specific implementation (The Graph, custom Go/Python indexer, SubQuery, etc.), but all such implementations MUST provide equivalent semantics.

## 2. Scope

In scope:

- BuybackVault (Stages A–C as implemented in v0.51.0),
- StrategyConfig contract(s) controlling BuybackVault behaviour,
- related oracle and PSM signals that are directly relevant for buyback decisions.

Out of scope:

- multi-asset or multi-chain buyback mechanisms beyond v0.51.0,
- cross-chain indexers,
- non-economic telemetry (e.g., generic node health).

## 3. Indexer Architecture Requirements

An indexer implementation:

- MUST support at least one of:
  - a The Graph–style subgraph,
  - a custom service (Go/Python/etc.) reading logs via JSON-RPC / WebSocket,
  - a SubQuery or equivalent indexing stack.
- MUST be able to:
  - follow the canonical chain,
  - handle reorgs and rollbacks,
  - expose an idempotent, queryable data model (e.g., via REST/GraphQL).

Telemetry:

- SHOULD integrate with Prometheus/Grafana-style monitoring for operational metrics,
- MAY feed data into user-facing dashboards (e.g., Dune, custom explorers).

## 4. Core Events (Conceptual Interface)

The BuybackVault and StrategyConfig contracts SHOULD emit (or already emit) events of the following conceptual types:

1. **StrategyUpdated**  
   - Emitted when a strategy or its parameters change.

2. **BuybackExecuted**  
   - Emitted when a buyback operation is performed (e.g., spending collateral to buy and burn 1kUSD or acquire backing assets).

3. **LimitUpdated / ConfigUpdated**  
   - Emitted when key limits or configuration values change.

4. **Error / Fallback / Skipped** (if available)  
   - Emitted when a buyback attempt fails, is skipped, or falls back to a safe behaviour.

Event schemas MUST be concretely defined at implementation time; the indexer MUST treat these semantics as canonical.

## 5. Telemetry DTOs

The indexer SHOULD project on-chain events into normalized DTOs.

### 5.1 Strategy DTO

Represents the current configuration and effective parameters for the BuybackVault.

Fields (indicative):

- `strategy_id`: string / numeric identifier.
- `enabled`: boolean.
- `collateral_asset`: address (USDT, USDC, WBTC, WETH / ETH or other).
- `target_asset`: address (e.g., 1kUSD or a backing asset).
- `max_notional_per_period`: numeric (e.g., in collateral units or USD).
- `period_seconds`: numeric.
- `slippage_bps`: numeric.
- `last_updated_block`: uint64.
- `last_updated_timestamp`: uint64.

Each `StrategyUpdated` event MUST update or create a Strategy DTO.

### 5.2 Buyback Execution DTO

Represents a single executed buyback.

Fields (indicative):

- `tx_hash`: transaction hash.
- `log_index`: log index in the transaction.
- `timestamp`: block timestamp.
- `block_number`: uint64.
- `strategy_id`: identifier linking to Strategy DTO.
- `collateral_asset`: address.
- `collateral_amount_in`: numeric (raw units).
- `target_asset`: address.
- `target_amount_out`: numeric (raw units).
- `price_used`: numeric (e.g., price of target/collateral from oracle, if exposed).
- `slippage_bps_effective`: numeric (computed from on-chain amounts and reference price).
- `status`: enum (`SUCCESS`, `PARTIAL`, `FAILED`).
- `reason`: optional string/enum for failures (e.g., slippage too high, oracle stale).

Each `BuybackExecuted` event MUST map to exactly one DTO instance.

### 5.3 Config / Limit DTO

Represents the high-level BuybackVault configuration and risk-related limits.

Fields (indicative):

- `config_id`: string / version identifier.
- `global_max_notional_per_period`: numeric.
- `per_strategy_max_notional`: numeric.
- `min_reserve_ratio_bps`: numeric (PoR-based threshold below which buybacks MAY be limited or disabled).
- `created_at_block`: uint64.
- `created_at_timestamp`: uint64.

Each `ConfigUpdated` / `LimitUpdated` event SHOULD lead to a new Config DTO or a versioned update.

## 6. KPIs & Derived Metrics

The indexer MUST compute or expose at least the following KPIs:

1. **Total buyback volume (per asset / period)**  
   - Sum of `collateral_amount_in` and `target_amount_out` by:
     - day, week, month,
     - collateral asset,
     - strategy.

2. **Average effective price vs. oracle price**  
   - For each buyback:
     - compare implied execution price to oracle reference price,
     - derive slippage metrics over time.

3. **Buyback intensity vs. PoR ratio**  
   - Correlate:
     - aggregate buyback volume,
     - PoR reserve ratios over the same period.

4. **Strategy utilization**  
   - For each strategy:
     - proportion of period limit used,
     - number of executions,
     - success vs. failure counts.

5. **Error / failure rates**  
   - Count and rate of failed/aborted buybacks,
   - reasons for failure (e.g., slippage, stale oracle).

These KPIs MUST be queryable by time window, chain, and asset where applicable.

## 7. Integration with Risk & PoR

The BuybackVault indexer MUST be designed to integrate with:

- **PoR View Data** (`docs/risk/proof_of_reserves_spec.md`)  
  - Using reserve ratios and aggregate reserve values as contextual signals.

- **Collateral Risk Profile** (`docs/risk/collateral_risk_profile.md`)  
  - Tagging assets as primary (USDT, USDC) vs. risk-on (WBTC, WETH / ETH).

Example use cases:

- Suspend or flag aggressive buybacks when PoR reserve ratios approach minimum thresholds.
- Highlight buybacks heavily skewed into or out of a single collateral with elevated risk.

## 8. DevOps Monitoring

The telemetry stack SHOULD expose Prometheus/Grafana-style metrics for:

- indexer health:
  - last processed block,
  - lag vs. head,
  - reorg events handled.
- ingest rates:
  - number of `BuybackExecuted` events per interval,
  - number of strategies and configs tracked.
- error metrics:
  - indexer parse failures,
  - RPC failures,
  - schema or decoding issues.

Alert thresholds (indicative):

- buyback indexer lag > N blocks or > M minutes,
- sustained increase in failed buybacks or indexer errors,
- missing data for critical time windows (e.g., during depeg events).

## 9. User-Facing Dashboards

Dashboards (custom or via platforms like Dune) SHOULD present:

- historical buyback volume charts (per collateral / asset),
- reserve ratio overlays (from PoR),
- breakdown of strategies and their utilization,
- error and failure timelines for buyback operations.

Views SHOULD be understandable by technically informed users and integrators, while remaining transparent and non-misleading.

## 10. Reorg Handling & Data Consistency

The indexer MUST:

- handle chain reorgs by:
  - rolling back affected BuybackVault-related data,
  - reindexing events for replaced blocks.
- ensure idempotent upserts based on:
  - `(tx_hash, log_index)` keys for event-based DTOs,
  - strategy/config identifiers for configuration entities.

Consistency guarantees:

- No duplicate buyback records after reorgs.
- Deterministic state for strategies and configs at any queried block height.

## 11. Maintenance & Versioning

The indexer specification MUST be updated when:

- BuybackVault or StrategyConfig interfaces change,
- new strategies or assets are added,
- Economic Layer versions change in ways that affect telemetry.

Versioning guidelines:

- Expose an explicit `schema_version` field in DTOs or metadata.
- Maintain migration scripts or procedures for dashboards and external consumers when schema changes.


---

## Phase A – Safety Reason Codes & Indexing-Strategie

Mit Phase A führt der BuybackVault zusätzliche Reason Codes ein, die für Indexer
und Monitoring-Systeme von hoher Bedeutung sind.

### 1. Ziel

Dieser Abschnitt beschreibt, wie Indexer:

- relevante Events / Reason Codes erkennen,
- sie strukturiert abspeichern,
- und daraus sinnvolle Alerts / Dashboards bauen können.

### 2. Kern-Reason-Codes (Beispiele)

> Konkrete Namen / Enums sind in  
> `docs/dev/DEV11_Telemetry_Events_Outline_r1.md` beschrieben.  
> Die folgende Tabelle zeigt eine integratorische Sicht.

| Layer | Beispiel-Code                    | Kategorie          | Beschreibung                                                  |
|-------|----------------------------------|--------------------|---------------------------------------------------------------|
| A01   | `BUYBACK_TREASURY_CAP_SINGLE`    | Treasury / Limits  | Per-Operation Cap überschritten                              |
| A03   | `BUYBACK_TREASURY_CAP_WINDOW`    | Treasury / Limits  | Rolling Window Cap überschritten                             |
| A02   | `BUYBACK_ORACLE_UNHEALTHY`       | Oracle / Health    | Oracle-/Health-Gate meldet ungesunde Daten                   |
| A02   | `BUYBACK_GUARDIAN_STOP`          | Governance / Guard | Guardian-/DAO-Stop blockiert Buybacks                        |

Indexern wird empfohlen, Reason Codes mindestens mit folgenden Feldern zu persistieren:

- `tx_hash`
- `block_number` / `timestamp`
- `asset` (falls vorhanden)
- `amount` (falls relevant)
- `reason_code` (String / Enum)
- `layer` (A01/A02/A03)
- optional: `mode` / Konfigurationsprofil (falls aus anderen Events ableitbar)

### 3. Abgeleitete Metriken & Alerts

Aus den oben genannten Daten lassen sich u. a. folgende Metriken ableiten:

- **Cap-Auslastung pro Zeitfenster**:

  - Anteil der Zeit, in der `BUYBACK_TREASURY_CAP_WINDOW` auftritt.
  - Cumulative Volumes vs. Window-Cap.

- **Fehler-Rate pro Layer**:

  - Anteil der Buyback-Versuche, die durch A01, A02 oder A03 geblockt werden.

- **Health-Gate-Stabilität**:

  - Anzahl / Dauer der Perioden mit `BUYBACK_ORACLE_UNHEALTHY`.
  - Korrelation mit Oracle-Infrastruktur-Incidents.

- **Guardian-Stop-Episoden**:

  - Episoden-Liste von `BUYBACK_GUARDIAN_STOP` inkl. Start/Ende.
  - Verknüpfung mit Governance-Entscheidungen (z. B. Proposals).

### 4. Empfohlene Index-Struktur

In einer typischen Indexer-DB (z. B. PostgreSQL, ClickHouse, Elastic) empfiehlt sich:

- Eine Tabelle / Collection `buyback_events` mit:

  - Primärschlüssel basierend auf `(tx_hash, log_index)`
  - Index auf `timestamp`, `asset`, `reason_code`, `layer`.

- Optional eine separate Tabelle `buyback_safety_incidents` für aggregierte Sicht:

  - `incident_id`
  - `layer`
  - `reason_code`
  - `start_timestamp`
  - `end_timestamp` (falls episodenbasiert)
  - `affected_volume`
  - `metadata` (JSON für zusätzliche Felder)

### 5. Verbindung zu anderen Dokumenten

Indexer sollten neben diesem Dokument insbesondere berücksichtigen:

- `docs/dev/DEV11_Telemetry_Events_Outline_r1.md`  
  (detaillierte Definition der Reason Codes, Event-Schemata)
- `docs/integrations/buybackvault_observer_guide.md`  
  (Integrationsperspektive / empfohlene Reaktionen)
- `docs/reports/DEV11_PhaseA_BuybackSafety_Status_r1.md`  
  (High-Level-Status von Phase A)
- `docs/governance/buybackvault_parameter_playbook_phaseA.md`  
  (Governance-Profile und Parameter-Kontext)

---

### 6. Checkliste für Indexer-Implementierungen

1. **Reason Codes parsen & normalisieren** (z. B. in ein internes Enum).
2. **Layer-Tagging** (A01/A02/A03) für jede Safety-bezogene Meldung.
3. **Dashboards**:

   - Zeitreihe der geblockten vs. erfolgreichen Buybacks.
   - Heatmaps für Reason Codes über die Zeit.
   - Fenster-Visualisierung für Treasury-Cap-Auslastung.

4. **Alerts** definieren:

   - Hohe Dichte von `BUYBACK_ORACLE_UNHEALTHY` innerhalb kurzer Zeit.
   - Wiederholte `BUYBACK_GUARDIAN_STOP` ohne klare Governance-Kommunikation.
   - Window-Cap nahezu permanent ausgelastet.


---

## Phase A – Safety Reason Codes & Indexing-Strategie

Mit Phase A führt der BuybackVault zusätzliche Reason Codes ein, die für Indexer
und Monitoring-Systeme von hoher Bedeutung sind.

### 1. Ziel

Dieser Abschnitt beschreibt, wie Indexer:

- relevante Events / Reason Codes erkennen,
- sie strukturiert abspeichern,
- und daraus sinnvolle Alerts / Dashboards bauen können.

### 2. Kern-Reason-Codes (Beispiele)

> Konkrete Namen / Enums sind in  
> `docs/dev/DEV11_Telemetry_Events_Outline_r1.md` beschrieben.  
> Die folgende Tabelle zeigt eine integratorische Sicht.

| Layer | Beispiel-Code                    | Kategorie          | Beschreibung                                                  |
|-------|----------------------------------|--------------------|---------------------------------------------------------------|
| A01   | `BUYBACK_TREASURY_CAP_SINGLE`    | Treasury / Limits  | Per-Operation Cap überschritten                              |
| A03   | `BUYBACK_TREASURY_CAP_WINDOW`    | Treasury / Limits  | Rolling Window Cap überschritten                             |
| A02   | `BUYBACK_ORACLE_UNHEALTHY`       | Oracle / Health    | Oracle-/Health-Gate meldet ungesunde Daten                   |
| A02   | `BUYBACK_GUARDIAN_STOP`          | Governance / Guard | Guardian-/DAO-Stop blockiert Buybacks                        |

Indexern wird empfohlen, Reason Codes mindestens mit folgenden Feldern zu persistieren:

- `tx_hash`
- `block_number` / `timestamp`
- `asset` (falls vorhanden)
- `amount` (falls relevant)
- `reason_code` (String / Enum)
- `layer` (A01/A02/A03)
- optional: `mode` / Konfigurationsprofil (falls aus anderen Events ableitbar)

### 3. Abgeleitete Metriken & Alerts

Aus den oben genannten Daten lassen sich u. a. folgende Metriken ableiten:

- **Cap-Auslastung pro Zeitfenster**:

  - Anteil der Zeit, in der `BUYBACK_TREASURY_CAP_WINDOW` auftritt.
  - Cumulative Volumes vs. Window-Cap.

- **Fehler-Rate pro Layer**:

  - Anteil der Buyback-Versuche, die durch A01, A02 oder A03 geblockt werden.

- **Health-Gate-Stabilität**:

  - Anzahl / Dauer der Perioden mit `BUYBACK_ORACLE_UNHEALTHY`.
  - Korrelation mit Oracle-Infrastruktur-Incidents.

- **Guardian-Stop-Episoden**:

  - Episoden-Liste von `BUYBACK_GUARDIAN_STOP` inkl. Start/Ende.
  - Verknüpfung mit Governance-Entscheidungen (z. B. Proposals).

### 4. Empfohlene Index-Struktur

In einer typischen Indexer-DB (z. B. PostgreSQL, ClickHouse, Elastic) empfiehlt sich:

- Eine Tabelle / Collection `buyback_events` mit:

  - Primärschlüssel basierend auf `(tx_hash, log_index)`
  - Index auf `timestamp`, `asset`, `reason_code`, `layer`.

- Optional eine separate Tabelle `buyback_safety_incidents` für aggregierte Sicht:

  - `incident_id`
  - `layer`
  - `reason_code`
  - `start_timestamp`
  - `end_timestamp` (falls episodenbasiert)
  - `affected_volume`
  - `metadata` (JSON für zusätzliche Felder)

### 5. Verbindung zu anderen Dokumenten

Indexer sollten neben diesem Dokument insbesondere berücksichtigen:

- `docs/dev/DEV11_Telemetry_Events_Outline_r1.md`  
  (detaillierte Definition der Reason Codes, Event-Schemata)
- `docs/integrations/buybackvault_observer_guide.md`  
  (Integrationsperspektive / empfohlene Reaktionen)
- `docs/reports/DEV11_PhaseA_BuybackSafety_Status_r1.md`  
  (High-Level-Status von Phase A)
- `docs/governance/buybackvault_parameter_playbook_phaseA.md`  
  (Governance-Profile und Parameter-Kontext)

---

### 6. Checkliste für Indexer-Implementierungen

1. **Reason Codes parsen & normalisieren** (z. B. in ein internes Enum).
2. **Layer-Tagging** (A01/A02/A03) für jede Safety-bezogene Meldung.
3. **Dashboards**:

   - Zeitreihe der geblockten vs. erfolgreichen Buybacks.
   - Heatmaps für Reason Codes über die Zeit.
   - Fenster-Visualisierung für Treasury-Cap-Auslastung.

4. **Alerts** definieren:

   - Hohe Dichte von `BUYBACK_ORACLE_UNHEALTHY` innerhalb kurzer Zeit.
   - Wiederholte `BUYBACK_GUARDIAN_STOP` ohne klare Governance-Kommunikation.
   - Window-Cap nahezu permanent ausgelastet.


---

## Phase A – Safety Reason Codes & Indexing-Strategie

Mit Phase A führt der BuybackVault zusätzliche Reason Codes ein, die für Indexer
und Monitoring-Systeme von hoher Bedeutung sind.

### 1. Ziel

Dieser Abschnitt beschreibt, wie Indexer:

- relevante Events / Reason Codes erkennen,
- sie strukturiert abspeichern,
- und daraus sinnvolle Alerts / Dashboards bauen können.

### 2. Kern-Reason-Codes (Beispiele)

> Konkrete Namen / Enums sind in  
> `docs/dev/DEV11_Telemetry_Events_Outline_r1.md` beschrieben.  
> Die folgende Tabelle zeigt eine integratorische Sicht.

| Layer | Beispiel-Code                    | Kategorie          | Beschreibung                                                  |
|-------|----------------------------------|--------------------|---------------------------------------------------------------|
| A01   | `BUYBACK_TREASURY_CAP_SINGLE`    | Treasury / Limits  | Per-Operation Cap überschritten                              |
| A03   | `BUYBACK_TREASURY_CAP_WINDOW`    | Treasury / Limits  | Rolling Window Cap überschritten                             |
| A02   | `BUYBACK_ORACLE_UNHEALTHY`       | Oracle / Health    | Oracle-/Health-Gate meldet ungesunde Daten                   |
| A02   | `BUYBACK_GUARDIAN_STOP`          | Governance / Guard | Guardian-/DAO-Stop blockiert Buybacks                        |

Indexern wird empfohlen, Reason Codes mindestens mit folgenden Feldern zu persistieren:

- `tx_hash`
- `block_number` / `timestamp`
- `asset` (falls vorhanden)
- `amount` (falls relevant)
- `reason_code` (String / Enum)
- `layer` (A01/A02/A03)
- optional: `mode` / Konfigurationsprofil (falls aus anderen Events ableitbar)

### 3. Abgeleitete Metriken & Alerts

Aus den oben genannten Daten lassen sich u. a. folgende Metriken ableiten:

- **Cap-Auslastung pro Zeitfenster**:

  - Anteil der Zeit, in der `BUYBACK_TREASURY_CAP_WINDOW` auftritt.
  - Cumulative Volumes vs. Window-Cap.

- **Fehler-Rate pro Layer**:

  - Anteil der Buyback-Versuche, die durch A01, A02 oder A03 geblockt werden.

- **Health-Gate-Stabilität**:

  - Anzahl / Dauer der Perioden mit `BUYBACK_ORACLE_UNHEALTHY`.
  - Korrelation mit Oracle-Infrastruktur-Incidents.

- **Guardian-Stop-Episoden**:

  - Episoden-Liste von `BUYBACK_GUARDIAN_STOP` inkl. Start/Ende.
  - Verknüpfung mit Governance-Entscheidungen (z. B. Proposals).

### 4. Empfohlene Index-Struktur

In einer typischen Indexer-DB (z. B. PostgreSQL, ClickHouse, Elastic) empfiehlt sich:

- Eine Tabelle / Collection `buyback_events` mit:

  - Primärschlüssel basierend auf `(tx_hash, log_index)`
  - Index auf `timestamp`, `asset`, `reason_code`, `layer`.

- Optional eine separate Tabelle `buyback_safety_incidents` für aggregierte Sicht:

  - `incident_id`
  - `layer`
  - `reason_code`
  - `start_timestamp`
  - `end_timestamp` (falls episodenbasiert)
  - `affected_volume`
  - `metadata` (JSON für zusätzliche Felder)

### 5. Verbindung zu anderen Dokumenten

Indexer sollten neben diesem Dokument insbesondere berücksichtigen:

- `docs/dev/DEV11_Telemetry_Events_Outline_r1.md`  
  (detaillierte Definition der Reason Codes, Event-Schemata)
- `docs/integrations/buybackvault_observer_guide.md`  
  (Integrationsperspektive / empfohlene Reaktionen)
- `docs/reports/DEV11_PhaseA_BuybackSafety_Status_r1.md`  
  (High-Level-Status von Phase A)
- `docs/governance/buybackvault_parameter_playbook_phaseA.md`  
  (Governance-Profile und Parameter-Kontext)

---

### 6. Checkliste für Indexer-Implementierungen

1. **Reason Codes parsen & normalisieren** (z. B. in ein internes Enum).
2. **Layer-Tagging** (A01/A02/A03) für jede Safety-bezogene Meldung.
3. **Dashboards**:

   - Zeitreihe der geblockten vs. erfolgreichen Buybacks.
   - Heatmaps für Reason Codes über die Zeit.
   - Fenster-Visualisierung für Treasury-Cap-Auslastung.

4. **Alerts** definieren:

   - Hohe Dichte von `BUYBACK_ORACLE_UNHEALTHY` innerhalb kurzer Zeit.
   - Wiederholte `BUYBACK_GUARDIAN_STOP` ohne klare Governance-Kommunikation.
   - Window-Cap nahezu permanent ausgelastet.


## OracleRequired telemetry signals (v0.51+)

For v0.51+ the BuybackVault indexer must treat **OracleRequired** as a
first-class operational axis:

- **Revert reasons (BuybackVault)**
  - \`BUYBACK_ORACLE_REQUIRED()\` – strict-mode BuybackVault was called
    without a configured oracle health module or with enforcement active
    but no module set.
  - \`BUYBACK_ORACLE_UNHEALTHY()\` – the configured oracle health module
    reported an unhealthy state for the relevant asset pair.

- **Revert reason (PSM)**
  - \`PSM_ORACLE_MISSING()\` – PegStabilityModule was called without a
    configured oracle for the asset/stable pair.

Indexers SHOULD:

- decode these reason codes as structured fields (e.g. \`reason_code\`,
  \`severity = "critical"\`);
- surface them in dashboards and logs as **OracleRequired violations**;
- wire alerts so that any occurrence in production is treated as a
  hard incident (e.g. pager / on-call notification);
- correlate occurrences with:
  - Guardian pause / unpause events for PSM and BuybackVault,
  - OracleAggregator health changes and config updates.

This is the operational face of the OracleRequired invariant – a build
that passes tests but hides these reason codes from monitoring is **not**
acceptable.

**Related documents**

- \`ARCHITECT_OracleRequired_OperationsBundle_v051_r1.md\`
- \`DEV11_PhaseB_Telemetry_Concept_r1.md\`
- \`GOV_Oracle_PSM_Governance_v051_r1.md\`

