#!/bin/bash
set -e

echo "== DEV-10 04: enrich Guardian & Safety Events Integration Guide content =="

GUIDE="docs/integrations/guardian_and_safety_events.md"

if [ ! -f "$GUIDE" ]; then
  echo "File $GUIDE not found, aborting."
  exit 1
fi

cat <<'EOD' > "$GUIDE"
# Guardian & Safety Events Integration Guide

> Status: DEV-10 – integration-focused documentation, no contract changes implied.  
> Audience: external builders (dApps, indexers, risk / monitoring systems, operators).

The **Guardian / SafetyAutomata layer** provides the protocol with a
second line of defence:

- enforcing safety rules,
- coordinating emergency responses,
- emitting explicit signals when something is *not* normal.

This guide describes how to **consume Guardian- and safety-related events**
so that external systems can:

- react to pauses and emergency states,
- understand why certain actions are currently blocked,
- build dashboards and alerting around safety transitions.

For deep architecture details, see:

- `docs/architecture/guardian_overview.md`
- `docs/architecture/guardian_psm_flows.md`
- `docs/risk/emergency_depeg_runbook.md`

---

## 1. Role of the Guardian / SafetyAutomata layer

From an integrator's perspective, the Guardian / SafetyAutomata layer:

- enforces certain **global or scoped invariants**,
- can **pause or restrict** specific protocol actions,
- may require **explicit, traceable steps** to re-enable functions,
- emits **events** when:

  - a rule is triggered,
  - a state changes (e.g. paused → unpaused),
  - an emergency procedure starts or ends.

The key idea:

- Economic core contracts (PSM, Vaults, etc.) focus on *what* they do.
- The Guardian focuses on *when* and *under which conditions* they are
  allowed to do it.

Integrators should therefore monitor the Guardian layer to:

- understand current system state,
- avoid acting on out-of-date assumptions (e.g. “PSM is live”),
- provide operators and users with clear, auditably correct explanations.

---

## 2. Integration modes

### 2.1 Off-chain event consumers (recommended primary mode)

Most integrations will consume Guardian events via:

- log subscriptions (e.g. WebSocket / RPC filters),
- indexers (custom, TheGraph-like, or bespoke),
- monitoring pipelines feeding into dashboards and alerting.

Off-chain consumers can:

- aggregate and correlate events across multiple Guardians,
- store historical sequences for post-incident analysis,
- provide human-readable timelines for operators.

### 2.2 On-chain consumers (advanced / specialized)

Some smart contracts might:

- query Guardian state (e.g. “is this subsystem currently paused?”),
- react conditionally to **Guardian-controlled flags**,
- read configuration parameters guarded by the SafetyAutomata.

This is more advanced and should only be done by protocols that:

- align their behaviour with the Guardian’s safety design,
- accept that emergency rules may take precedence over their own logic.

---

## 3. Conceptual event categories

Exact event names and fields are defined in the contracts.  
This section focuses on **categories** that integrators should look out for.

### 3.1 Pause / Unpause events

These events indicate that a component or subsystem was:

- **paused** (temporarily disabled),
- **unpaused** (re-enabled after checks/governance).

Conceptually, you may encounter events like:

- `SystemPaused`
- `SystemUnpaused`
- `PSMPaused`
- `PSMUnpaused`
- `VaultPaused`
- `VaultUnpaused`
- or equivalent names that encode the scope.

Integration implications:

- Off-chain systems should treat pauses as **hard signals**:
  - stop presenting actions that rely on the paused component as available,
  - annotate UI with explicit safety messaging,
  - ensure operators see a clear alert when a pause occurs.
- Unpause events should be accompanied by:
  - updated risk status,
  - clear governance trails (which admin/Governance action caused it),
  - possibly additional checks before resuming automation.

### 3.2 Parameter / configuration changes

Guardian or SafetyAutomata contracts may emit events when:

- thresholds are updated (e.g. price deviation limits),
- timeouts / windows are adjusted (e.g. orphan or stale thresholds),
- roles or guardianship parameters change.

Examples (conceptual):

- `ConfigUpdated`
- `ThresholdChanged`
- `RoleGranted` / `RoleRevoked`

Integration implications:

- Indexers should store a timeline of configuration changes.
- Risk dashboards should correlate **config changes** with:

  - incident windows,
  - observed anomalies,
  - governance proposals / decisions.

- Sudden or unexpected changes might warrant special alerts, especially
  for parameters with systemic impact.

### 3.3 Enforcement / rule-trigger events

Some SafetyAutomata designs emit events when a specific rule triggers, e.g.:

- “oracle stale over limit, enforcement activated”,
- “PSM outbound capacity reached, enforcement mode X engaged”,
- “emergency depeg flow initiated”.

While exact naming and encoding is implementation-specific, the pattern is:

- **precondition** met (e.g. risk threshold),
- **enforcement action** taken (e.g. pause, cap, reject),
- **event** emitted for observability.

Integration implications:

- Off-chain systems can categorise events by severity:
  - informational (e.g. minor limit adjust),
  - warning (e.g. approaching a risk boundary),
  - critical (e.g. emergency mode entered).
- This feeds into incident timelines and postmortems.

---

## 4. Observing Guardian state in practice

### 4.1 Indexer pattern

A typical indexer for Guardian / Safety events might:

1. Subscribe to logs from all relevant Guardian / Safety contracts.
2. Decode events into a structured schema, e.g.:

   - timestamp / block number,
   - event type (pause, config change, enforcement, etc.),
   - scope (which component / subsystem),
   - additional metadata (e.g. thresholds, new values).
3. Store them in a database (SQL / time-series / document store).
4. Expose an API for dashboards and internal tools, such as:
   - “get all pauses in the last 30 days”,
   - “current Guardian state for subsystem X”,
   - “changes to enforcement thresholds during incident Y”.

This pattern is a natural extension of the ideas in:

- `docs/indexer/indexer_buybackvault.md`
- other indexer-related docs in the repository.

### 4.2 Dashboard pattern

On top of the indexer, a dashboard might show:

- **Global safety status**:
  - green: no active emergency / pause,
  - yellow: partial restrictions,
  - red: emergency mode or full pause.
- **Recent Guardian actions**:
  - last N events, grouped by category.
- **Incident view**:
  - start and end block of a critical event sequence,
  - relevant configuration changes,
  - impacted subsystems (e.g. PSM, BuybackVault).

Dashboards should be updated with low latency and offer drill-downs for
operators.

---

## 5. Example scenarios (integration behaviour)

This section describes how external systems should ideally behave in
typical safety-related scenarios.

### 5.1 Emergency PSM pause due to oracle issues

Preconditions:

- Oracle prices become stale or diverge significantly.
- Guardian detects unhealthy conditions, triggers a **PSM pause**.

Expected sequence:

1. Oracle-related health events and/or Guardian enforcement events fire.
2. A `PSMPaused`-type event (or equivalent) is emitted.
3. New PSM-related user actions revert or are rejected on-chain.

Integrator response:

- Off-chain services:
  - stop offering PSM swaps in UIs,
  - clearly communicate “PSM paused due to oracle conditions”.
- Monitoring:
  - raise a high-severity alert,
  - create an incident record with correlated oracle/Guardian events.
- On-chain:
  - any composed protocol depending on PSM should treat pause as a hard block.

### 5.2 Depeg incident and emergency runbook

Preconditions:

- 1kUSD deviates from the intended peg beyond acceptable risk tolerance.
- Guardian and/or governance trigger the **emergency depeg runbook** as
  described in `docs/risk/emergency_depeg_runbook.md`.

Event sequence (conceptual):

- Guardian emits events indicating:
  - mode transitions (e.g. `EmergencyModeEntered`),
  - changes to limits / fees / caps for PSM and related components,
  - potential shutdown or unwind steps.
- Throughout the incident, further events document:
  - manual interventions,
  - restoration steps,
  - final return to normal mode.

Integrator response:

- Indexers capture a full timeline for audit and postmortem.
- Dashboards show emergency state clearly (red / prominent banners).
- Automated systems may:
  - halt certain strategies,
  - switch to safe “observation only” mode,
  - require manual operator approval for actions that remain possible.

### 5.3 Planned maintenance / governance changes

Not all Guardian-related events are emergencies.  
Some simply reflect planned governance actions:

- e.g. temporarily pausing interactions to deploy an upgrade,
- adjusting parameters after a vote.

Integrator response:

- Use event metadata and governance context to:
  - distinguish between planned and unplanned disruptions,
  - suppress panic alerts when changes are expected,
  - still document the transition for completeness.

---

## 6. Designing your own safety-aware integration

When building on top of the 1kUSD protocol, external systems should:

1. **Treat Guardian state as authoritative**
   - if a subsystem is paused or in emergency mode, act accordingly,
   - do not attempt to bypass or override these conditions.

2. **Expose safety state to users and operators**
   - surface clear, concise messages in UIs,
   - provide operators with detailed, technical context.

3. **Correlate Guardian events with your own metrics**
   - e.g. transaction volumes, error rates, latency,
   - to understand the impact of safety actions.

4. **Document your assumptions**
   - which events you listen to,
   - how you classify severities,
   - which automation is paused under what conditions.

5. **Regularly test failure handling**
   - simulate pause/unpause flows in test environments,
   - ensure alerting and dashboards behave as expected.

---

## 7. Integration checklist

Before you rely on Guardian / Safety events in production:

- [ ] Identify all relevant Guardian / Safety contracts and addresses.
- [ ] Implement robust log decoding for their core events.
- [ ] Maintain a mapping from event types to severity levels.
- [ ] Test your systems under:
  - pause / unpause sequences,
  - emergency mode toggles,
  - parameter-change bursts.
- [ ] Ensure your operators can:
  - see current safety state at a glance,
  - retrieve incident timelines quickly,
  - correlate actions with governance artefacts.

As the protocol evolves, this guide may be extended with:

- concrete event signatures and field names,
- example indexer schemas,
- recommended alert rules and runbook templates.
EOD

# 2) Log entry
LOG_FILE="logs/project.log"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-10 04] ${timestamp} Enriched Guardian & Safety events integration guide for external integrators" >> "$LOG_FILE"

echo "== DEV-10 04 done =="
