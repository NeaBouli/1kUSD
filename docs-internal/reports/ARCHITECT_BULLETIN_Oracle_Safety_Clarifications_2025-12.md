# ARCHITECT BULLETIN – Oracle & Buyback Safety Clarifications (Dec 2025)

**Issued by:** Architecture (1kUSD Economic Layer & BuybackVault)  
**Audience:** Co-Architect, DEV-7/8/9/10/11, Governance, Indexer/Infra teams  
**Scope:** 1kUSD Economic Layer, PSM, BuybackVault Phase A (A01–A03)

---

## 1. Purpose

This bulletin codifies several clarifications about the 1kUSD architecture
that became necessary after external summaries introduced incorrect or
ambiguous statements.

These clarifications are **binding** for all future architecture, code,
documentation, governance and integration work.

---

## 2. Oracle dependency – canonical position

1. 1kUSD is **oracle-secured by design**. Oracles are not an optional
   add-on but an inherent part of:

   - the PegStabilityModule (PSM),
   - the BuybackVault safety gate (A02),
   - guardian and safety automata.

2. Disabling stale- or diff-checks for a given oracle does **not** mean
   the PSM can operate without a price feed.  
   A PSM without a valid price feed is considered a **configuration
   failure**, not a supported operating mode.

3. Future Kaspa-native deployments remain bound to this principle:
   removing oracle dependency entirely is **not** an architectural goal.
   Reducing oracle surface and failure modes is.

---

## 3. Buyback safety stack – Phase A is canonical

The canonical buyback safety stack consists of **Phase A** (DEV-11):

- **A01 – Per-operation treasury cap**  
  Hard cap, expressed in basis points of the treasury share dedicated to
  buybacks. Mandatory safety feature; can be effectively disabled only via
  configuration, not by changing semantics.

- **A02 – Oracle/Health gate**  
  Configurable safety layer that uses oracle/health signals and guardian
  policies to allow or block buybacks in strict modes.

- **A03 – Rolling window cap**  
  Time-based aggregation limit that prevents series of operations from
  exceeding a configured cap over a rolling window.

This stack is **authoritative** for buyback safety.  
StrategyEnforcement previews are **not** a replacement for Phase A.

---

## 4. StrategyEnforcement preview – limited role

1. StrategyEnforcement as introduced in preview form (v0.51.1 line) is an
   **optional, experimental layer**.

2. Its role is limited to making strategy definitions explicit and
   enforceable for certain flows. It does not define the baseline safety
   of the BuybackVault.

3. Phase A (A01–A03) has higher priority and must be treated as the
   reference for safety analysis, audits and governance decisions.

---

## 5. PSM vs. BuybackVault – oracle responsibilities

To avoid conceptual drift:

- The **PSM** is responsible for correct pricing and limits using oracles.
- The **BuybackVault** is responsible for safe treasury usage and
  buyback execution, informed by oracle/guardian signals (A02).

Consequences:

- New error/telemetry semantics are introduced:

  - `PSM_ORACLE_MISSING`  
    Indicates that the PSM is asked to operate without a valid price
    feed. This is a configuration error, not a valid operating mode.

  - `BUYBACK_ORACLE_REQUIRED`  
    Indicates that a strict buyback configuration expects oracle/health
    information but no valid module is present.

- Integrations, dashboards and indexers must treat these signals as
  **hard safety flags**, not as soft hints.

---

## 6. Multi-asset buybacks – not active in Phase A/B

1. Current implementations and docs reflect a **single-asset** view for
   BuybackVault (stable + asset).

2. Multi-asset/basket strategies, DEX-routing and similar features belong
   to a potential **Phase C** and are not part of the deployed v0.51.x
   behaviour or the completed Phase A/B work.

3. Any document or roadmap that refers to "multi-asset strategies" must
   clearly label them as **future, not yet implemented**.

---

## 7. Release & messaging guardrails

To prevent misaligned external expectations:

1. No release, announcement or documentation may claim that 1kUSD is
   "oracle-free" or that oracles are optional.

2. Public materials must:

   - describe Phase A (A01–A03) as the **canonical** buyback safety stack,
   - clearly label StrategyEnforcement functionality as "preview" or
     "advanced" and **not** as the safety baseline.

3. Release processes (DEV-94) should include a **human review step** that
   checks:

   - consistency of docs with this bulletin,
   - absence of "oracle-free" language,
   - correct description of PSM/BuybackVault/Oracle responsibilities.

---

## 8. Action items

- **DEV-9**

  - Has implemented an initial docs-only clarification patch (DEV-9 40).
  - Future Infra/Docs changes must be checked against this bulletin.

- **DEV-11**

  - Must treat these clarifications as **normative assumptions** when
    extending BuybackVault and the economic layer.
  - Telemetry, invariants and tests must encode the oracle dependency
    explicitly.

- **Governance & Risk**

  - Governance playbooks and risk reports should be updated (where
    appropriate) to mention Phase A as the canonical safety stack and to
    reflect the mandatory nature of oracle dependency.

This bulletin remains in force until superseded by a later architecture
decision.
