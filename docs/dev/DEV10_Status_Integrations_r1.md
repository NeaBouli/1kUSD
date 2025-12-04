# DEV-10 – Integrations & Developer Experience  
## Status Report r1 (Integrations Docs)

> Scope: external-facing integration documentation for the Economic Core  
> Status: r1 – initial structure + first four deep-dive guides  
> Author: DEV-10 (Integrator & Developer Experience)

---

## 1. Mandate & Scope of DEV-10

DEV-10 is responsible for making the **Economic Core** of 1kUSD usable and
understandable for **external builders**, without touching on-chain logic.

In particular, DEV-10 focuses on:

- integration guides for:
  - the PegStabilityModule (PSM),
  - the Oracle Aggregator,
  - Guardian & Safety mechanisms,
  - the BuybackVault Strategy & Enforcement surface (observer view),
- developer-facing documentation:
  - how to read data,
  - how to wire alerts and dashboards,
  - how to reason about protocol behaviour from the outside.

DEV-10 **does not**:

- change contracts,
- modify Economic Layer logic,
- alter protocol parameters or governance flows,
- modify CI or Docker infrastructure.

All work is limited to `docs/` and linking integration docs into the existing
MkDocs navigation.

---

## 2. Work delivered in r1 (DEV-10 01–05)

### 2.1 DEV-10 01 – Integrations docs skeleton & index

Files introduced:

- `docs/integrations/index.md`
- `docs/integrations/psm_integration_guide.md`
- `docs/integrations/oracle_aggregator_guide.md`
- `docs/integrations/guardian_and_safety_events.md`
- `docs/integrations/buybackvault_observer_guide.md`

Plus an entry in `docs/index.md`:

- **Integrations & Developer Guides (DEV-10)** section, acting as a
  single entry point for all integration-focused documentation.

Purpose:

- define a **stable structure** for integration docs,
- make it obvious where external builders should start,
- clearly separate integration concerns from core Economic Layer specs.

---

### 2.2 DEV-10 02 – PSM Integration Guide

File enriched:

- `docs/integrations/psm_integration_guide.md`

Focus:

- conceptual overview of the PegStabilityModule from an **integrator
  perspective**:
  - swap flows (collateral ↔ 1kUSD),
  - fees, spreads, limits,
  - failure modes and common revert reasons,
- design guidance:
  - how to handle slippage and limits,
  - how to interpret PSM errors at the UX / API layer,
  - how to think about test vs. production environments,
- integration checklist before going live:
  - understanding economic parameters,
  - validating flows on a test environment,
  - robust error handling,
  - monitoring and internal documentation.

No function signatures are hard-coded in this guide. It is intentionally
conceptual and aligned with the architecture and regression docs.

---

### 2.3 DEV-10 03 – Oracle Aggregator Integration Guide

File enriched:

- `docs/integrations/oracle_aggregator_guide.md`

Focus:

- how external clients should read data from the Oracle Aggregator,
- how to interpret **health signals** (stale vs diff thresholds),
- how to design systems that **fail safely** when oracle data is unhealthy,
- patterns for:
  - read-only integrations (dashboards, risk analytics),
  - dependent protocols that rely on oracle data for decisions.

Emphasis:

- no guessing or silently accepting stale data,
- clear separation between:
  - “we cannot read data”,
  - “data is unhealthy / must not be used”,
- checklists for health-handling and monitoring.

As with the PSM guide, this document is based on existing architecture
and regression docs, without introducing new on-chain logic.

---

### 2.4 DEV-10 04 – Guardian & Safety Events Integration Guide

File enriched:

- `docs/integrations/guardian_and_safety_events.md`

Focus:

- how to consume **Guardian / Safety-related events** as an external observer,
- typical event categories:
  - safety state changes (pause / unpause, emergency modes),
  - parameter updates,
  - escalation / de-escalation actions,
- how to design:
  - indexers that track safety state over time,
  - dashboards that show current safety posture,
  - alerting rules that notify operators and governance participants.

The guide is deliberately **read-only**:

- it does not prescribe or introduce any new on-chain behaviour,
- it describes how to observe existing and planned Guardian / Safety signals,
- it ties into:
  - `docs/security/`,
  - `docs/risk/`,
  - and governance / incident response runbooks.

---

### 2.5 DEV-10 05 – BuybackVault Observer Integration Guide

File enriched:

- `docs/integrations/buybackvault_observer_guide.md`

Focus:

- how to observe the **BuybackVault** as an external integrator:
  - funding events,
  - buyback execution events,
  - strategy configuration changes,
  - enforcement mode transitions,
- how to design:
  - indexers with normalised schemas (funding, trades, configs, enforcement),
  - dashboards with KPIs and timelines,
  - alerting rules for anomalies (e.g. missing buybacks after funding).

The guide explicitly references StrategyEnforcement Phase 1:

- explains the `strategiesEnforced` concept at a high level,
- shows how observers should interpret enforcement-related periods,
- remains consistent with:
  - `docs/architecture/buybackvault_strategy_phase1.md`,
  - `docs/reports/DEV60-72_BuybackVault_EconomicLayer.md`,
  - `docs/reports/DEV74-76_StrategyEnforcement_Report.md`.

Again, no contract changes are introduced; the guide only explains how to
consume existing telemetry.

---

## 3. Non-goals & Taboo areas

DEV-10 deliberately **does not**:

- touch any files under:
  - `contracts/`,
  - `src/`,
  - core Economic Layer unit tests,
- change:
  - CI workflows,
  - Docker configuration,
  - release tooling.

All DEV-10 work is:

- documentation under `docs/`,
- updates to `docs/index.md` for navigation,
- updates to `logs/project.log` for traceability,
- patches under `patches/dev10_*.sh` for reproducibility.

This is consistent with the overall Tabuzonen policy of the project.

---

## 4. How integrators should use the DEV-10 docs

Recommended reading order for external builders:

1. **Architecture overview (baseline)**  
   - `docs/architecture/economic_layer_overview.md`
   - `docs/reports/PROJECT_STATUS_EconomicLayer_v051.md`

2. **DEV-10 integrations index**  
   - `docs/integrations/index.md`

3. **Component-specific guides**  
   - PSM: `docs/integrations/psm_integration_guide.md`  
   - Oracle: `docs/integrations/oracle_aggregator_guide.md`  
   - Guardian/Safety: `docs/integrations/guardian_and_safety_events.md`  
   - BuybackVault: `docs/integrations/buybackvault_observer_guide.md`

4. **Cross-cutting concerns**  
   - `docs/security/` and `docs/risk/` for safety / risk framing,  
   - `docs/indexer/` for indexer architecture patterns.

The goal is that an external integrator can:

- understand the Economic Core at a conceptual level,
- pick the relevant integration guide,
- design a safe and observable integration without guessing.

---

## 5. Backlog for r2 (DEV-10, not yet started)

The following items are candidates for a future **DEV-10 r2** phase:

1. **Concrete signatures & ABI references**
   - link selected public functions and events from:
     - PSM,
     - Oracle Aggregator,
     - Guardian / Safety contracts,
     - BuybackVault,
   - ensure references are stable and tied to a specific version tag.

2. **Example flows & diagrams**
   - sequence diagrams for:
     - PSM swap flows,
     - oracle read + health check flows,
     - safety state changes and their impact on integrators,
   - example request/response patterns for off-chain clients.

3. **SDK / client examples**
   - code snippets for:
     - typical PSM interactions,
     - oracle reads with health checks,
     - event subscription patterns for indexers,
   - language targets could include:
     - TypeScript/JavaScript (ethers-like),
     - Python (web3-like).

4. **Reference schemas and queries**
   - suggested schemas for BuybackVault and Guardian indexers,
   - example SQL for common analytics queries,
   - example Grafana dashboard layouts.

5. **Integration test playbooks**
   - recommended test scenarios for integrators:
     - simulated stress situations,
     - failure injection (e.g. oracle unhealthy, strategies misconfigured),
     - emergency and recovery sequences.

These items are **not** active yet. They require architectural sign-off and
must remain strictly aligned with the Economic Layer versioning strategy.

---

## 6. Summary

DEV-10 r1 has:

- introduced a dedicated **Integrations & Developer Guides** section,
- delivered four deep integration guides for:
  - PSM,
  - Oracle Aggregator,
  - Guardian & Safety events,
  - BuybackVault observers,
- respected all Tabuzonen (contracts / CI / Docker untouched),
- improved the **developer experience** for external integrators without
  changing protocol behaviour.

From an architectural perspective, DEV-10 r1 is:

- a **pure documentation layer**,
- fully compatible with Economic Layer v0.51.0 and the BuybackVault
  StrategyEnforcement Phase 1 design,
- ready for audit, review and extension in future r2 phases.
