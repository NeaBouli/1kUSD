# 1kUSD Indexer & Telemetry Specification – BuybackVault  
## Economic Layer v0.51.0

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

