# DEV-11 Phase B – Telemetry & Indexer Concept (v0.51, r1)

> **Role:** DEV-11 – Buyback/PSM Safety & Telemetry  
> **Scope:** Telemetry & indexer orchestration for OracleRequired operations  
> **Version:** v0.51 – r1  

This document describes how telemetry and indexer flows should treat
**OracleRequired** semantics in the 1kUSD Economic Layer, with a focus on:

- surfacing **illegal / hazardous states** rather than just failing swaps,
- turning **revert reasons and events** into *operational signals*,
- providing a reference for future **indexer and monitoring work**.

It builds on:

- `ARCHITECT_OracleRequired_OperationsBundle_v051_r1.md`
- `ARCHITECT_BULLETIN_OracleRequired_Impact_v2.md`
- `DEV11_OracleRequired_Handshake_r1.md`
- `GOV_Oracle_PSM_Governance_v051_r1.md`
- `DEV94_Release_Status_Workflow_Report.md`

and is part of **DEV-11 Phase B** as agreed by the architects.

---

## 1. Problem statement

After DEV-49 and DEV-11 Phase A, the Economic Layer enforces:

- **PSM** without oracle ⇒ `PSM_ORACLE_MISSING` revert.
- **BuybackVault (strict)** without a configured oracle health module ⇒
  `BUYBACK_ORACLE_REQUIRED` revert.
- Additional health-related reason codes (e.g. unhealthy oracle) are treated
  as *hard safety gates* before any buyback or swap is allowed.

From a pure contract perspective this is correct – but *without* proper
telemetry and indexer orchestration, these safety nets remain mostly
**invisible** to operations:

- Reverts appear as generic failures in RPC logs or UIs.
- Monitoring may only see “failed transaction” without semantic meaning.
- Incident response cannot distinguish:
  - configuration errors (missing oracle),
  - expected safety blocks (unhealthy oracle),
  - unrelated bugs.

DEV-11 Phase B addresses this gap and defines how these signals become
first-class **operational events**.

---

## 2. Scope of Phase B

DEV-11 Phase B focuses on **concept and orchestration**, not yet on full
implementation:

In scope:

- Define a **telemetry model** for OracleRequired-related operations:
  - PSM swaps
  - BuybackVault buybacks
  - Relevant Guardian / Safety interactions
- Specify how **reason codes and events** should be exposed so that:
  - Indexers can persist them in a structured way.
  - Monitoring / dashboards can consume them.
- Provide guidance for future:
  - `docs/indexer/*` extensions,
  - `docs/integrations/*` guides,
  - Ops runbooks and alert definitions.

Out of scope (future work):

- Concrete indexer implementation (code).
- RPC node configuration specifics.
- Full UI/Frontend wiring.
- Non-OracleRequired telemetry topics (these can be layered later).

---

## 3. OracleRequired signals to surface

From the Operations Bundle and related docs, the key signals are:

### 3.1 PSM – OracleRequired

- **Revert reason:** `PSM_ORACLE_MISSING`
- **When it appears:**
  - Any swap via `PegStabilityModule` when no oracle is configured.
- **Operational semantics:**
  - This is an **illegal configuration state** for production.
  - Any occurrence in a live environment must be considered a **hard
    incident**, not a benign user error.
- **Telemetry requirement:**
  - Indexer must be able to:
    - detect this revert,
    - store it with at least:
      - timestamp
      - PSM address
      - asset / stable token context
      - calling account
    - flag it for alerts or dashboards.

### 3.2 BuybackVault – OracleRequired

- **Revert reason:** `BUYBACK_ORACLE_REQUIRED`
- **When it appears:**
  - Any buyback execution in strict mode when no oracle health module is
    configured.
- **Operational semantics:**
  - Also an **illegal configuration state**; strict mode assumes the vault
    is guarded by oracle health.
- **Telemetry requirement:**
  - Same pattern as for PSM:
    - capture revert reason,
    - tag the call as “OracleRequired violation”,
    - route to alerts.

### 3.3 BuybackVault – Oracle health failures

- **Revert / condition:** Any path where the configured oracle health module
  marks the situation as **unhealthy** (exact reason codes live in the
  oracle health module).
- **Operational semantics:**
  - Not necessarily a configuration bug – often a **healthy block** in
    response to stale or suspicious price data.
- **Telemetry requirement:**
  - Distinguish **“oracle missing”** from **“oracle unhealthy”**.
  - Missing ⇒ configuration problem.
  - Unhealthy ⇒ data / market problem (or potential attack).

---

## 4. Minimal telemetry model

Phase B proposes a **minimal shared model** that downstream indexers can
follow. The goal is a simple, extensible set of fields that can be stored
in a database or forwarded to monitoring tools.

At minimum, for each relevant operation (swap or buyback):

- `timestamp` – block timestamp or indexer ingestion timestamp.
- `tx_hash` – transaction identifier.
- `chain_id` – for multichain deployments.
- `component` – e.g. `"PSM"`, `"BuybackVault"`.
- `component_address` – contract address.
- `op_type` – e.g. `"swap-mint"`, `"swap-redeem"`, `"buyback-execute"`.
- `amount_in` / `amount_out` – when applicable.
- `reason_code` – one of:
  - `"OK"` (no error, operation succeeded)
  - `"PSM_ORACLE_MISSING"`
  - `"BUYBACK_ORACLE_REQUIRED"`
  - `"ORACLE_UNHEALTHY"` (or more specific health codes later)
- `severity` – suggested operational severity:
  - `"CRITICAL"` for illegal configuration (missing oracle).
  - `"WARNING"` or `"INFO"` for expected health blocks (depending on policy).
- `meta` – JSON blob for additional context:
  - token symbols / addresses,
  - DAO caller / EOA caller,
  - safety module identifiers.

DEV-11 Phase B does **not** mandate a concrete schema language (e.g. JSON
Schema, Protobuf), but all future indexer / integration docs should treat
these fields as **stable anchors**.

---

## 5. Indexer responsibilities (conceptual)

Indexers that integrate with 1kUSD Economic Layer are expected to:

1. **Decode revert reasons**  
   - Recognise `PSM_ORACLE_MISSING` and `BUYBACK_ORACLE_REQUIRED` as
     special-case signals.
   - Map them into the `reason_code` field as described above.

2. **Enrich with on-chain context**  
   - Map contract addresses to component roles (`PSM`, `BuybackVault`, …).
   - Attach token metadata from known registries where available.

3. **Persist in a queryable store**  
   - For example in a relational DB (table `economic_events`) or a
     document store.
   - Ability to filter by:
     - component,
     - reason_code,
     - time window,
     - DAO operations vs. user operations.

4. **Feed monitoring stacks**  
   - Export subsets of events (especially critical reason codes) to
     alerting systems (Prometheus, hosted monitoring, etc.).
   - Support dashboards that answer:
     - “Have we seen any `PSM_ORACLE_MISSING` in the last N hours?”
     - “How often is the oracle health blocking buybacks?”

5. **Support release checks**  
   - For future DEV-94/95 work, indexers should be able to provide simple
     checks like:
     - “No OracleRequired violations since last release tag.”
   - This can be cross-referenced in `scripts/check_release_status.sh` or
     manual release checklist workflows.

---

## 6. Telemetry for Guardian & Safety interactions

While OracleRequired is primarily a PSM/Buyback concern, Guardian and
Safety layers interact with oracles in important ways:

- **Guardian pause/unpause flows** impacting:
  - whether the oracle may be updated,
  - whether the PSM may process swaps,
  - whether buybacks are allowed.

Telemetry implications:

- Guardian events that change the **operational state** of PSM / Buyback /
  Oracle should be captured as separate event types, for example:
  - `guardian_pause_psm`
  - `guardian_unpause_psm`
  - `guardian_pause_oracle`
  - `guardian_unpause_oracle`
- These events help explain *why* subsequent economic operations are blocked
  or allowed.
- DEV-11 Phase B does not redefine Guardian events, but requires that any
  indexer story for OracleRequired **also** understands the Guardian
  state transitions.

---

## 7. Dashboards & alerts – suggested views

DEV-11 Phase B suggests the following operational dashboards and alerts:

### 7.1 OracleRequired incident dashboard

A single board that shows:

- count of `PSM_ORACLE_MISSING` and `BUYBACK_ORACLE_REQUIRED` by:
  - time window (last hour, day, week),
  - component address,
  - environment (testnet, mainnet).
- last occurrence timestamp.
- link to raw transaction / log details.

Goal: Immediately answer “Are we currently in an illegal configuration
state, or haben wir es kürzlich erlebt?”.

### 7.2 Oracle health dashboard

A view focusing on **non-missing** oracle issues:

- count of oracle health blocks (e.g. `ORACLE_UNHEALTHY`),
- distribution over time,
- per-asset breakdown.

Goal: Detect pricefeed instability, stale data or abusive conditions that
trigger the health gate often.

### 7.3 Guardian / Safety state overview

Combining:

- Guardian pause/unpause events,
- PSM / Buyback operational state,
- recent OracleRequired-related reverts,

to show a narrative like:

> Guardian paused PSM at T0 → No swaps allowed;  
> Oracle was marked unhealthy at T1 → buybacks blocked;  
> Guardian unpaused and oracle health recovered by T2 → operations normal.

---

## 8. Relationship to other DEV-11 and DEV-94 artefacts

This concept doc is intentionally aligned with:

- **DEV11_Telemetry_Events_Outline_r1**
  - defines concrete events and reason codes at a lower level.
- **DEV11_PhaseB_Telemetry_TestPlan_r1**
  - describes how to test that telemetry is emitted and indexer-friendly.
- **DEV94_Release_Status_Workflow_Report.md**
  - sets release gating rules and mandatory reports for OracleRequired.

The responsibilities are:

- This document:
  - high-level telemetry / indexer concept and responsibilities.
- Events outline:
  - exact fields per event / code path.
- Test plan:
  - how to prove that events and revert reasons are correctly surfaced.
- Release workflow:
  - how OracleRequired and its telemetry become part of release gating.

---

## 9. Next steps (Phase B follow-up)

Planned Phase B follow-ups (outside this patch):

- Extend `docs/indexer/indexer_buybackvault.md` and related indexer docs
  with concrete schemas and examples using the model defined here.
- Add example log snippets / JSON payloads to
  `docs/integrations/guardian_and_safety_events.md` and other integration
  guides.
- Implement additional tests (or test harness notes) to ensure that:
  - OracleRequired-related reason codes remain stable,
  - the expected events / logs exist for indexers to consume.
- Coordinate with future indexer/monitoring roles to ensure that the
  OracleRequired Operations Bundle is fully visible in production.

DEV-11 Phase B should not be considered “done” until:

- OracleRequired incidents are clearly visible as such in monitoring, and
- release managers and governance actors can rely on dashboards and reports
  that treat these signals as **non-optional safety invariants**.

