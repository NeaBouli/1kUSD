#!/bin/bash
set -e

echo "== DEV-10 05: enrich BuybackVault Observer Integration Guide content =="

GUIDE="docs/integrations/buybackvault_observer_guide.md"

if [ ! -f "$GUIDE" ]; then
  echo "File $GUIDE not found, aborting."
  exit 1
fi

cat <<'EOD' > "$GUIDE"
# BuybackVault Observer Integration Guide

> Status: DEV-10 – integration-focused documentation, no contract changes implied.  
> Audience: external builders (indexers, risk teams, analytics dashboards, wallets).

The **BuybackVault** is responsible for executing protocol-governed buybacks
according to configured strategies and economic parameters. From an
integration and observability perspective, it is:

- a **source of truth** for how buyback funds are moved,
- a **telemetry surface** for strategy usage and behaviour over time,
- an **anchor** for monitoring protocol-controlled flows.

This guide focuses on how to **observe** the BuybackVault:

- which events to watch,
- how to design indexers and dashboards,
- how to interpret strategy-related state,
- how to reason about enforcement modes.

No on-chain behaviour is changed by this guide. It purely describes how to
consume information that is already emitted by the protocol.

For deep architecture details, see:

- `docs/architecture/economic_layer_overview.md`
- `docs/architecture/buybackvault_strategy_phase1.md`
- `docs/reports/DEV60-72_BuybackVault_EconomicLayer.md`
- `docs/reports/DEV74-76_StrategyEnforcement_Report.md`

---

## 1. Role of the BuybackVault (observer view)

From an external observer’s perspective, the BuybackVault:

- is **funded** by protocol-controlled inflows (e.g. fees, surplus),
- **executes buybacks** according to configured strategies,
- may **hold assets temporarily** in different forms (e.g. collateral, stablecoins),
- exposes **events** for:

  - funding actions,
  - executed buybacks,
  - configuration changes to strategies,
  - enforcement mode transitions.

Key design principles:

- The BuybackVault is **governed** – its behaviour is not arbitrary.
- Strategy configuration is **transparent** – observers can reconstruct which
  strategies were active at which times.
- Enforcement flags allow the protocol to **tighten rules** if needed
  (see StrategyEnforcement Phase 1 docs).

Observers should aim to reconstruct a coherent picture:

- when and how funds entered the Vault,
- which strategies were used,
- what assets were bought / distributed,
- under which configuration and enforcement settings.

---

## 2. Integration modes

### 2.1 Off-chain indexers (primary mode)

Most integrations will consume BuybackVault data via:

- event subscriptions (logs),
- indexing pipelines feeding databases,
- analytics jobs and dashboards.

Off-chain indexers can:

- build **historical timelines** of funding and buybacks,
- compute **aggregated statistics** (volume per asset, per strategy, per interval),
- support **risk and governance reporting**.

This is the recommended mode for:

- protocol analytics,
- treasury / risk teams,
- governance observers,
- external researchers.

### 2.2 On-chain observers (advanced / specialised)

Some other contracts may:

- read high-level BuybackVault state,
- check whether certain strategies are enabled,
- react to enforcement flags.

This is advanced usage and should be done carefully, with:

- clear documentation of assumptions,
- awareness of governance / configuration risk,
- alignment with the StrategyEnforcement model.

---

## 3. Conceptual event categories

Exact event names and fields are defined in the contracts and reports.
This section focuses on **conceptual categories** that indexers should
recognise and separate.

### 3.1 Funding events

Funding-related events describe **inflows into the BuybackVault**, e.g.:

- protocol fees,
- surplus transfers,
- governance-directed top-ups.

Conceptually, events may include:

- source address or module identifier,
- asset address,
- amount,
- optional context (e.g. reason or tag).

Observer usage:

- track how the Vault is being funded over time,
- distinguish between recurring inflows (e.g. fee sweeps) and one-off
  governance actions,
- correlate funding with later buyback activity.

### 3.2 Buyback execution events

These events represent the **actual execution of buybacks**, e.g.:

- trading one asset for another,
- burning tokens,
- directing acquired assets to specific sinks or destinations.

Conceptual contents may include:

- which **strategy** was used,
- which **asset(s)** were spent,
- which **asset(s)** were acquired,
- amounts and effective prices (where derivable),
- destination addresses (e.g. burn, treasury, specific Vault).

Observer usage:

- reconstruct **trade history** for buyback operations,
- compute **effective buyback prices** and slippage (where data allows),
- show **volume per asset** and **per strategy**.

### 3.3 Strategy configuration events

Strategy-related events describe changes to the **configuration**:

- new strategies added,
- strategies enabled/disabled,
- parameter changes for existing strategies (e.g. weights, limits).

Conceptual contents:

- strategy identifiers (ID, index, or hash),
- assets associated with each strategy,
- enabled/disabled flags,
- weight or allocation parameters,
- enforcement-related fields (if any).

Observer usage:

- maintain a **timeline of strategy configurations**,
- reconstruct which strategies were active at any point in time,
- reason about why specific buyback executions chose certain assets or paths.

### 3.4 Enforcement mode events

StrategyEnforcement Phase 1 introduces the notion of:

- a `strategiesEnforced` flag (opt-in),
- errors such as `NO_STRATEGY_CONFIGURED` or
  `NO_ENABLED_STRATEGY_FOR_ASSET`.

Conceptually, events may indicate:

- when enforcement was toggled on/off,
- when operations were rejected due to enforcement rules.

Observer usage:

- mark periods when:

  - enforcement is **off** → behaviour matches v0.51.0 baseline,
  - enforcement is **on** → behaviour constrained by configured strategies.

- correlate enforcement state with:

  - incident periods,
  - governance decisions,
  - risk reports.

---

## 4. Indexer design for BuybackVault telemetry

A robust BuybackVault indexer typically consists of:

1. **Log ingest**:
   - subscribe to BuybackVault events,
   - decode into structured records.

2. **Normalisation layer**:
   - unify different event types into a coherent schema, e.g.:

     - `funding_events`,
     - `buyback_trades`,
     - `strategy_config_changes`,
     - `enforcement_state_changes`.

3. **Storage**:
   - choose a suitable database:

     - relational (PostgreSQL/MySQL) for structured queries,
     - time-series DB for metrics,
     - document store for flexible metadata.

4. **APIs / views**:
   expose standard queries, e.g.:

   - “funding history per asset over the last N days”
   - “all buyback trades grouped by strategy”
   - “strategy configuration timeline for asset X”
   - “enforcement mode intervals”

5. **Aggregation & metrics**:
   - compute useful aggregates:

     - total buyback volume per asset,
     - number of buyback operations per period,
     - funding vs. deployed volume,
     - time between funding and utilisation.

This indexer pattern should align with the general approach outlined in
other indexer docs under `docs/indexer/`.

---

## 5. Dashboard and reporting patterns

On top of the indexer, dashboards can expose:

### 5.1 High-level KPIs

Examples:

- total buyback volume (lifetime, 30d, 7d),
- volume per asset and per strategy,
- utilisation ratio (funding vs. actual buybacks),
- periods with enforcement enabled vs disabled.

These KPIs help:

- governance participants,
- risk teams,
- external observers.

### 5.2 Timeline / activity charts

Charts that visualise:

- funding spikes vs. buyback bursts,
- strategy changes vs. trading patterns,
- enforcement periods vs. buyback volume.

Such views allow operators to:

- correlate configuration changes with observed outcomes,
- detect anomalies or unexpected gaps in activity,
- perform post-incident analysis.

### 5.3 Strategy-focused views

Per-strategy dashboards might show:

- which assets are handled by a strategy,
- how often it is used,
- how much volume it has processed,
- how its parameters evolved over time.

This supports:

- strategy performance evaluation,
- rebalancing decisions,
- discussions on governance proposals.

---

## 6. Example observer scenarios

This section describes how external observers might react in typical
usage scenarios for the BuybackVault.

### 6.1 Monitoring routine buyback operations

Scenario:

- the protocol is in a healthy state,
- strategies are configured and enabled,
- funding inflows occur periodically.

Observer behaviour:

- track that funding inflows are followed by buyback operations,
- monitor utilisation lag (time between funding and buyback),
- ensure no unexpected gaps arise in the presence of sufficient funding.

Alerts might be configured for:

- “funding received but no buybacks within X hours/days”
- “buyback volume significantly below expected pattern”

### 6.2 Detecting configuration drift

Scenario:

- governance updates strategy configs,
- some strategies are disabled or re-weighted.

Observer behaviour:

- record configuration changes,
- compare pre- and post-change buyback behaviour,
- detect discrepancies between intended and actual usage.

Alerts might highlight:

- incomplete or inconsistent configurations (e.g. funding for assets
  without any enabled strategy),
- frequent config churn that could signal operational issues.

### 6.3 Enforcement mode activation

Scenario:

- `strategiesEnforced` is turned on,
- incomplete strategy configuration leads to errors such as
  `NO_ENABLED_STRATEGY_FOR_ASSET`.

Observer behaviour:

- mark enforcement activation time in the timeline,
- track failed operations attributable to enforcement rules,
- ensure governance/risk teams are aware that:

  - additional configuration may be required,
  - some flows may be intentionally blocked.

Alerts might:

- notify when enforcement is turned on or off,
- summarise failures by asset or strategy attempting to be used.

### 6.4 Incident analysis for buyback anomalies

Scenario:

- external analysts suspect that buyback activity diverged from policy
  goals during a market stress event.

Observer behaviour:

- retrieve all BuybackVault-related events in the incident window,
- reconstruct funding, configuration, enforcement and trade sequences,
- correlate with market data and protocol state.

Outputs:

- an incident report that can be mapped back to:

  - Governance decisions,
  - Strategy configurations,
  - Guardian / Safety events (if relevant).

---

## 7. Integration checklist for BuybackVault observers

Before relying on BuybackVault telemetry in production:

- [ ] Identify the canonical BuybackVault contract address (and any proxies).
- [ ] Enumerate and decode all relevant events:

  - funding,
  - buyback execution,
  - strategy configuration,
  - enforcement mode changes.

- [ ] Design and implement a normalised schema for:

  - funding,
  - trades,
  - configs,
  - enforcement state.

- [ ] Implement historical backfill procedures.
- [ ] Build dashboards for:

  - high-level KPIs,
  - activity timelines,
  - per-strategy views.

- [ ] Define alert rules for:

  - missing buybacks after funding,
  - configuration inconsistencies,
  - unexpected enforcement behaviour.

- [ ] Document assumptions:

  - how events are interpreted,
  - how strategies are mapped,
  - which KPIs matter to your stakeholders.

As the protocol evolves, this guide may be extended with:

- concrete event signatures and field layouts,
- recommended schemas and example SQL queries,
- example Grafana dashboards and alerting rules.
EOD

# 2) Log entry
LOG_FILE="logs/project.log"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-10 05] ${timestamp} Enriched BuybackVault observer integration guide for external integrators" >> "$LOG_FILE"

echo "== DEV-10 05 done =="
