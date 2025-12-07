# DEV-11 – Telemetry & Events Outline (r1)

## 1. Scope & intent

This document sketches the **telemetry and events layer** needed for
advanced BuybackVault and StrategyEnforcement behaviour in future
versions (v0.52+).

Scope:

- Focus on *what needs to be observable* for operators, governance and
  indexers.
- No contract changes – this is a **planning doc only**.
- Covers buyback-related operations and StrategyEnforcement decisions.

Out of scope:

- Final Solidity event signatures.
- Full indexer implementation.
- UI/analytics dashboards.

## 2. High-level goals

Telemetry and events for BuybackVault & StrategyEnforcement should:

- Make it possible to **reconstruct what happened** for any buyback
  attempt.
- Explain **why** an operation was accepted, capped, or rejected.
- Provide enough context for:

  - economic analysis (are buybacks aligned with policy?),
  - risk monitoring (are safety bounds respected?),
  - incident response (what went wrong and when?).

## 3. Core event categories (conceptual)

Phase A/B of DEV-11 is expected to use at least the following categories:

1. **Configuration & mode changes**

   - Activation/deactivation of advanced StrategyEnforcement modes.
   - Changes to key parameters (caps, thresholds, slippage limits).
   - Guardian interventions (tightening or relaxing bounds).

2. **Buyback attempts**

   - Requested operation (asset, size, direction).
   - Context at decision time (prices, mode, limits).
   - Outcome: executed / capped / rejected.

3. **Safety & invariant checks**

   - Events for triggered safety conditions (e.g. treasury caps, reserve
     ratio thresholds, oracle health issues).
   - Optional "pre-flight check" summaries for large operations.

4. **Oracle / health signals (integration points)**

   - References or links to existing oracle health signals and guardian
     alerts used to decide on buyback actions.

This outline defines **what** needs to be visible, not how the events are
encoded.

## 4. Reason codes & outcomes

To make off-chain analysis practical, StrategyEnforcement should provide:

- A **finite set of reason codes** for:

  - accepted operations,
  - capped operations (partially allowed),
  - rejected operations.

Examples (to be refined later):

- `OK_BASELINE` – baseline buyback accepted under normal conditions.
- `OK_ADV_LIMITED` – advanced mode accepted but limited by caps.
- `ERR_TREASURY_CAP` – rejected due to treasury spend cap.
- `ERR_ORACLE_UNHEALTHY` – rejected due to oracle health issues.
- `ERR_SLIPPAGE_TOO_HIGH` – rejected due to slippage / price band breach.
- `ERR_MODE_DISABLED` – rejected because advanced mode is disabled.

Each buyback attempt should emit enough information so that a downstream
indexer can answer:

> "What was requested, what did the protocol decide, and why?"

## 5. Minimal data per buyback-related event

Without fixing a final ABI, the following **data dimensions** are likely
required:

- **Request metadata**

  - asset / market identifier,
  - requested notional or quantity,
  - side (buy/sell or equivalent).

- **Context snapshot**

  - current mode (baseline vs advanced),
  - relevant caps and thresholds at decision time,
  - oracle-derived prices or price bands (or references to them).

- **Outcome**

  - actual executed size (if any),
  - reason code,
  - flags indicating whether a cap was hit or a safety bound prevented
    full execution.

This document does not prescribe exact field names or types; it defines the
**information content** that events and logs must convey.

## 6. Consumers & usage patterns

Expected consumers of this telemetry include:

- **Economic analysts / protocol maintainers**

  - monitoring whether buyback policy is followed over time,
  - evaluating the impact of parameter changes.

- **Risk & guardian teams**

  - validating that safety bounds and emergency controls behave as
    intended,
  - investigating incidents with clear time-stamped evidence.

- **Indexers & dashboards**

  - building human-readable timelines of buyback activity,
  - exposing alerts when certain reason codes or patterns accumulate.

DEV-11 follow-up work will refine these use cases into more concrete
requirements for event schemas and indexer behaviour.

## 7. Open questions & next steps

Open questions (to be addressed in later DEV-11 tasks):

- How granular should reason codes be (few broad codes vs. many specific)?
- Which parts of the context snapshot must be on-chain vs. reconstructible
  from other events?
- How should we organise event namespaces across BuybackVault,
  StrategyEnforcement, and related contracts?
- What is the minimal telemetry set that still allows reliable economic
  and risk analysis?

Potential next steps:

- Draft candidate event sets and reason code enumerations.
- Map existing reports (e.g. BuybackVault economic layer reports) to
  telemetry requirements.
- Prepare implementation-ready prompts for a future Solidity developer.

This outline is intentionally high-level and conservative; it is a
checklist and framing document for later design and implementation work.

---

## DEV-11 A01 – Per-operation treasury cap

Component: BUYBACK_VAULT

- Error: `BuybackPerOpTreasuryCapExceeded`
  - Trigger:
    - Requested buyback amount (stable) would consume more than `maxBuybackSharePerOpBps`
      of the configured buyback treasury.
  - Semantics:
    - Economic safety guard, protects treasury from oversized single operations.
  - Suggested indexer tag:
    - `reason = "BUYBACK_TREASURY_CAP_SINGLE"`

Notes:

- When the per-operation cap is not configured or set to zero, behaviour is identical
  to v0.51 baseline.
- When configured, any attempt above the cap MUST revert with this error.

## DEV-11 A02 – Oracle / health gate (skeleton, planned)

Component: BUYBACK_VAULT + GUARDIAN / SAFETY

Planned reasons (to be implemented in subsequent DEV-11 A02 coding steps):

- `BUYBACK_ORACLE_UNHEALTHY`
  - Trigger:
    - Underlying price feed or oracle aggregation reports unhealthy state
      for the buyback asset or the reference stable.
  - Semantics:
    - Buyback operations must be blocked while oracle health is not acceptable.

- `BUYBACK_GUARDIAN_STOP`
  - Trigger:
    - Guardian / Safety automata mark the BUYBACK module as paused or blocked.
  - Semantics:
    - Higher-priority safety rule from Guardian; buyback execution must be rejected
      regardless of local vault parameters.

Notes:

- DEV-11 A02 wiring will connect buyback execution paths with existing oracle
  health and guardian/safety state. This section defines the telemetry vocabulary
  so indexers and dashboards can prepare before the code changes land.
