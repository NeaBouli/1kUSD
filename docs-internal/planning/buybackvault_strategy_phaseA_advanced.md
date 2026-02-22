# BuybackVault StrategyEnforcement – Phase A (Advanced Plan r1)

## 1. Scope & constraints

This document describes **Phase A** of an advanced buyback strategy layer
for the 1kUSD protocol, built on top of the existing BuybackVault and the
StrategyEnforcement logic.

Scope:

- Focus on **conceptual design** of advanced buyback behaviour ("Phase A").
- No contract changes – this is a **planning/architecture** document only.
- Target version line: **v0.52+** (beyond the v0.51 baseline).
- Backwards-compatibility: v0.51 behaviour and existing Phase 1 strategy
  documents remain valid and unchanged.

Out of scope:

- Concrete Solidity implementations or storage layouts.
- Final parameter values (thresholds, limits, spreads).
- Governance UI / dashboards – these will consume the design later.

## 2. Relation to v0.51 and Phase 1

Baseline:

- **v0.51 Economic Layer** defines the core protocol and BuybackVault
  behaviour used in production.
- **Phase 1 strategy docs** describe the initial buyback approach:
  which assets are eligible, how flows are structured, and how basic
  safety constraints are enforced.

StrategyEnforcement and Phase A:

- StrategyEnforcement (v0.52 preview) introduces a **formalised layer**
  for validating buyback-related actions against a set of rules.
- **Phase A** focuses on using StrategyEnforcement to:

  - make the existing buyback strategy more **explicit**,
  - encode additional **guard rails** for risk and treasury usage,
  - prepare for richer strategies and telemetry in later phases.

v0.51 remains the reference implementation; Phase A is a **forward-looking
extension** that must not invalidate existing reports or release notes.

## 3. High-level objectives of Phase A

Phase A should achieve the following high-level goals:

- **Explicit safety rules** for buyback operations:

  - clear limits on how much can be spent in a given period,
  - guard rails on price impact and slippage,
  - constraints on which assets may be bought at which times.

- **Predictable behaviour** for integrators and governance:

  - avoid "hidden" behaviour in off-chain scripts,
  - make key decisions visible via parameters and events.

- **Stable treasury management**:

  - ensure that buybacks cannot drain the treasury unexpectedly,
  - keep buybacks aligned with broader economic goals (peg stability,
    reserve ratios, target liquidity depth).

- **Preparation for observability**:

  - design StrategyEnforcement so that future indexers and dashboards
    can reason about why a given buyback was allowed or rejected.

Phase A should **harden** the existing behaviour rather than attempting to
introduce fully new economic models.

## 4. Control model & roles (conceptual)

Phase A assumes the following conceptual actors:

- **Governance**:

  - decides the high-level buyback policy (which assets, approximate
    budgets, long-term targets),
  - may set or approve key parameters for StrategyEnforcement.

- **Guardian / Safety role**:

  - can enforce emergency controls (pausing or tightening rules),
  - may veto changes that violate predefined safety envelopes.

- **Operator / Automation**:

  - executes buyback operations, either manually or via bots,
  - is bound by StrategyEnforcement checks on-chain.

StrategyEnforcement in Phase A should be designed such that:

- Operators **cannot bypass** core safety checks.
- Governance **cannot accidentally remove** all safety bounds via a single
  misconfiguration.
- The Guardian role has well-defined levers to **stop or constrain**
  behaviour in stress scenarios, without rewriting the entire strategy.

Exact role names and access patterns are defined in other documents; Phase A
builds on those foundations and focuses on **what** rules must be expressible.

## 5. Activation & deactivation policies

Phase A should define how advanced StrategyEnforcement is **activated** and
**deactivated**:

- Activation:

  - may be gated behind a configuration flag (e.g. "advanced_buyback_mode").
  - could require explicit governance approval and/or a delay mechanism.
  - should be observable via events so indexers can detect mode changes.

- Deactivation:

  - emergency deactivation must be possible via the Guardian / Safety role.
  - a deactivation should not leave the protocol in an undefined state:
    either it falls back to a safe baseline or halts buybacks safely.

Behavioural requirements:

- Mode transitions must be **idempotent and predictable**:
  the same inputs lead to the same state transitions.
- Activation should not retroactively change the semantics of executed
  buybacks; it only affects future actions.
- There should be a clear, documented mapping between:

  - "mode" (baseline vs advanced),
  - the set of rules enforced,
  - and the expectations for operators and dashboards.

The exact on-chain representation of these modes (enums, flags, separate
contracts) is deliberately left open in this phase.

## 6. Safety bounds & invariants (conceptual)

Phase A focuses on the **design of invariants and bounds**, not on exact
parameter values. Examples of desired properties:

- **Treasury safety**:

  - A single buyback operation must not spend more than a configurable
    fraction of the treasury dedicated to buybacks.
  - Over a rolling window (e.g. daily/weekly), total buyback volume must
    stay below a configured cap.

- **Market impact / price safety**:

  - Buybacks should respect maximum slippage or spread parameters derived
    from oracles and liquidity conditions.
  - StrategyEnforcement should be able to reject trades if prices diverge
    too far from a reference band.

- **Protocol health**:

  - Buybacks must not violate peg-stability parameters or collateralisation
    constraints defined elsewhere in the economic layer.
  - If safety metrics (e.g. reserve ratios, oracle health) fall below
    thresholds, advanced buybacks may be automatically restricted or paused.

Formal invariants:

- Wherever possible, these properties should be expressed as **checkable
  predicates** (e.g. ratios, deltas, limits) rather than informal rules.
- Violations should produce deterministic reasons / error codes that can be
  surfaced via events and logs.

## 7. Interaction with oracles & Guardian

Phase A assumes that price and health information is provided by the
existing oracle and guardian stack.

Design requirements:

- StrategyEnforcement must be able to consume **validated prices** and
  health signals (staleness, deviation checks, etc.).
- If oracle data is flagged as **unhealthy** (e.g. stale or inconsistent),
  Phase A rules should:

  - enforce stricter bounds (reduced limits),
  - or fully block certain operations.

Guardian hooks:

- The Guardian should be able to:

  - enforce global "no-buyback" conditions under extreme stress,
  - tighten limits for a given asset or asset group,
  - require manual confirmation before large operations proceed.

All such interventions should be:

- **observable** (events, status fields),
- and designed so that economic reports and dashboards can explain why a
  particular buyback was allowed, limited, or rejected.

## 8. Telemetry & events (Phase B preview)

Although detailed event schemas belong to a later phase, Phase A should
already anticipate the need for:

- **reason codes** for accepted/rejected buyback attempts,
- events that capture:

  - the requested operation (asset, size, side),
  - key parameters at the time (prices, limits, mode),
  - the outcome (executed, rejected, capped).

This document does not specify the exact event interface, but any Phase A
design decision should be evaluated against the question:

> "Can an off-chain indexer reconstruct and explain what happened?"

Phase B of DEV-11 will focus more deeply on telemetry and event design.

## 9. Open questions & future work

The following questions are explicitly left open for further DEV-11 work:

- Which exact **time windows** (e.g. 24h, 7d) are appropriate for caps?
- How should the protocol deal with **multi-asset** buyback strategies
  (e.g. different rules per asset type)?
- To what extent should StrategyEnforcement be configurable on-chain vs.
  encoded in contract logic and upgraded rarely?
- How should Governance and Guardian responsibilities be split in detail
  for parameter changes and emergency actions?
- Which external dashboards / monitoring systems do we assume, and which
  minimal telemetry do they need?

Future DEV-11 tasks will refine these points into more concrete designs and,
eventually, implementation requirements for a separate Solidity developer
track.
