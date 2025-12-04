# DEV-9 Monitoring & Indexer Preparation Plan

This document captures DEV-9's proposal for how on-chain events and
off-chain monitoring / indexer integrations should be approached for the
1kUSD protocol. It is purely a planning document and does not change any
contracts or on-chain logic.

All concrete implementation steps for indexers, dashboards or alerts
must be handled in separate tickets and coordinated with the Architect.

## Scope

The focus is on:

- Which protocol components are most important for monitoring.
- Which event types and state changes should be exposed / indexed.
- How indexers and alerting systems could integrate in a clean way.
- How to keep responsibilities separated (on-chain vs off-chain).

Out of scope:

- Changes to Solidity contracts or event definitions.
- Deployment or operations of specific indexer stacks.
- Economic policy decisions (e.g. when to trigger a manual intervention).

## Key Components for Monitoring

From an infra / observability perspective, the following areas of the
protocol are especially relevant:

1. **Peg Stability Module (PSM / PSMSwapCore)**
   - Swaps in and out of 1kUSD.
   - Fee accumulation and routing.
   - Limit enforcement (per-tx and daily limits).
   - Pause / unpause actions affecting PSM behavior.

2. **Oracle Layer**
   - Oracle Aggregator updates (price feed changes).
   - Health checks (stale data, abnormal deviations).
   - Watcher or guardian reactions to oracle anomalies.

3. **Guardian / Safety / Enforcement**
   - Activation of safety mechanisms (rate limiters, pause, kill switches
     where applicable).
   - Changes in strategy enforcement configuration (where exposed).
   - Any event that indicates a risk mitigation or emergency action.

4. **Buyback / Strategy Layer**
   - Strategy execution events (e.g. buyback operations).
   - Configuration changes (e.g. activation/deactivation of strategies).
   - Failures or reverts that indicate systemic issues.

5. **Governance / Param Updates (where events exist)**
   - Parameter changes written via governance (fees, spreads, limits,
     oracle configuration) should be traceable.
   - These are typically low-frequency but high-impact events.

## Event Categories

DEV-9 suggests grouping relevant events for monitoring purposes into
categories:

- **State Changes**
  - Permanent, protocol-level changes (e.g. param updates, strategy
    configuration changes, new collateral types).

- **Operational Events**
  - High-frequency, operational events such as swaps, oracle updates,
    routine strategy executions.

- **Safety / Guardian Events**
  - Any event that indicates a guardrail being triggered: pause,
    unpause, limit hit, enforcement action.

- **Error / Deviation Signals**
  - Events or conditions that indicate:
    - Oracle deviation beyond thresholds.
    - Repeated reverts for a certain operation type.
    - Reaching configured capacity or limits.

## Indexer Integration Considerations

DEV-9 proposes the following basic expectations for off-chain indexers:

1. **Liveness**
   - Indexers should operate with a bounded lag (e.g. within N blocks
     or M seconds behind the chain head).
   - Liveness metrics (e.g. "last processed block") should be exposed
     and monitored.

2. **Coverage**
   - At minimum, indexers should cover:
     - PSM swap events.
     - Oracle update and health-related events.
     - Safety / guardian actions.
   - Additional coverage (buyback / governance events) can be added
     gradually.

3. **Data Model**
   - Store normalized entities such as:
     - Swaps with amount in/out, fees, timestamp, tx hash.
     - Oracle feeds with value, source, deviation indicators.
     - Safety actions with type (pause, unpause, limit hit) and reason.

4. **Alerting Hooks**
   - Expose aggregated views suitable for alerts, for example:
     - PSM volume spikes or unusual fee behavior.
     - Oracle stale data or repeated deviations.
     - Frequent safety actions within a short time window.

## Severity Levels (Proposal)

For alerting systems, DEV-9 proposes the following rough severity levels:

- **INFO**
  - Regular operational activity (swaps, oracle updates).
  - Governance parameter changes that are expected and scheduled.

- **WARN**
  - Oracle data approaching deviation thresholds.
  - High but not critical protocol usage (near capacity).
  - Repeated soft errors that do not yet endanger the peg.

- **CRITICAL**
  - Oracle data clearly broken (stale or out-of-bounds).
  - Safety mechanisms triggered (global pause, hard limits reached).
  - Inability to perform essential operations (e.g. PSM swaps) within
    expected bounds.

Exact thresholds and conditions for these levels must be defined by the
Architect and risk owners.

## Open Questions for the Architect

- Which events are considered *mandatory* for an initial indexer MVP?
- Are there specific dashboards or reporting tools that should be
  targeted first (e.g. Grafana, Prometheus, hosted solutions)?
- Which severity thresholds should be considered CRITICAL for:
  - Oracle deviation,
  - PSM usage/capacity,
  - Safety mechanism activations?
- Should certain monitoring data be made publicly available (community
  dashboards) or remain internal-only at first?

DEV-9 will not change any contract code or event definitions based on
this document alone. It is a planning and coordination basis for future
monitoring and indexer work.
