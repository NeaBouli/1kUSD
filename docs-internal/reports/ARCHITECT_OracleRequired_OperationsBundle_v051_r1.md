# OracleRequired Operations Bundle (v0.51, r1)

**Scope:** This document defines the *OracleRequired Operations Bundle* for the
1kUSD Economic Layer around version **v0.51.x**.

It is the **single reference point** that connects:

- Code & invariants (PSM, BuybackVault, Oracle, Guardian)
- Tests & regression coverage
- Governance & reports
- Release process (DEV-94 / tags)
- Telemetry & indexer expectations

The bundle is meant for:

- Architects and auditors
- Indexer / monitoring / DevOps teams
- Governance / DAO and parameter stewards
- Frontend / UX teams that surface system health

---

## 1. OracleRequired as root operational invariant

The Economic Core now has a **hard invariant**:

> A PSM or BuybackVault configuration without a valid oracle / health module
> is an *illegal operational state* and must not be released or treated as
> “healthy”.

Concretely:

- **PegStabilityModule (PSM)**
  - No 1.0 price fallback any more.
  - If no oracle is configured:
    - Swaps must revert with `PSM_ORACLE_MISSING`.
  - Any configuration where PSM operates without an oracle is considered
    **invalid** for production.

- **BuybackVault (strict mode)**
  - Oracle health is enforced via the `oracleHealthGate` configuration.
  - If strict mode is enabled and no health module is configured:
    - Buybacks must revert with `BUYBACK_ORACLE_REQUIRED`.
  - Strict BuybackVault without a health module is an **illegal** state
    for tagged releases.

- **Guardian / Pause flows**
  - Guardian pause/unpause must propagate to oracle and PSM so that:
    - A paused system does **not** accept new swaps or buybacks.
    - A resumed system still enforces OracleRequired invariants.

The system must be designed and operated under the assumption:

> **No Oracle ⇒ No legal PSM / Buyback operation.**

---

## 2. Code layer – contracts and reason codes

This section summarises the **code artefacts** that are part of the
OracleRequired bundle.

### 2.1 PegStabilityModule

- Contract: `PegStabilityModule`
- Responsibility:
  - Swap stablecoin against collateral and vice versa.
  - Enforce limits, fees and spreads via the Parameter Registry.
- OracleRequired behaviour:
  - Requires a configured oracle source.
  - If missing, swaps revert with `PSM_ORACLE_MISSING`.

### 2.2 BuybackVault

- Contract: `BuybackVault`
- Responsibility:
  - Hold treasury funds for buybacks.
  - Execute buybacks via PSM and strategies under A01–A03 safety rules.
- OracleRequired behaviour:
  - Strict-mode buybacks must check an oracle health module first.
  - If strict mode is enabled but no health module is configured:
    - Revert with `BUYBACK_ORACLE_REQUIRED`.
  - If the health module exists but marks the system unhealthy:
    - Revert with a dedicated “unhealthy” reason (see Buyback tests and docs).

### 2.3 Oracle health and Guardian flows

- Oracle Aggregator and health module:
  - Track price freshness and diff constraints.
  - Provide a binary health signal into BuybackVault and other consumers.

- Guardian / Safety:
  - Can pause oracle updates and PSM operations.
  - Responsible for ensuring that when the system is paused:
    - No swaps or buybacks bypass OracleRequired checks.
    - Operational dashboards clearly show the paused state.

Reason codes that must be treated as **first-class operational signals**:

- `PSM_ORACLE_MISSING`
- `BUYBACK_ORACLE_REQUIRED`
- Buyback “unhealthy” codes (when health module is configured but unhealthy).

These are **not** “internal” errors; they are part of the external,
machine-readable health surface for operators and indexers.

---

## 3. Test layer – regression coverage

The OracleRequired bundle includes **tests** that demonstrate and protect
the expected behaviour.

Key areas:

- **PSM regression**
  - Limits, fees, spreads and flows tests must assume that:
    - A missing oracle is a hard error (`PSM_ORACLE_MISSING`).
  - Regression tests cover the no-oracle path as an explicit revert case.

- **BuybackVault tests**
  - Construction and strict-mode configuration.
  - Behaviour with:
    - No health module configured (must revert with `BUYBACK_ORACLE_REQUIRED`).
    - Health module configured and healthy (buyback allowed).
    - Health module configured and unhealthy (buyback blocked).

- **Guardian / Oracle propagation tests**
  - Verify that guardian pause/unpause affects oracle and PSM correctly.
  - Ensure that operations cannot silently continue with a misconfigured
    or paused oracle.

OracleRequired-facing tests are part of the **minimum regression set** for
any release that uses v0.51.x Economic Core semantics.

---

## 4. Governance & documentation layer

The following documents are part of the OracleRequired bundle and must be
maintained for releases based on v0.51.x:

- **Architect bulletins**
  - `ARCHITECT_BULLETIN_OracleRequired_Impact_v2.md`
    - Explains OracleRequired as a root safety layer.
    - Describes impact on PSM, BuybackVault and Guardian flows.
  - `ARCHITECT_BULLETIN_Oracle_Safety_Clarifications_2025-12.md`
    - Clarifies oracle safety rules and responsibilities.

- **DEV-11 / DEV-49 reports**
  - `DEV11_OracleRequired_Handshake_r1.md`
    - Aligns BuybackVault, PSM and telemetry docs with OracleRequired.
  - `BLOCK_DEV49_DEV11_OracleRequired_Block_r1.md`
    - Cross-block report tying together DEV-49 and DEV-11 work.

- **Governance docs**
  - `GOV_Oracle_PSM_Governance_v051_r1.md`
    - Explains OracleRequired semantics for governance readers.
    - Defines illegal/hazardous states and expected governance reactions.
  - `DEV87_Governance_Handover_v051.md`
    - Handover notes for v0.51, including references to OracleRequired.

These documents together define:

- Which configurations are legal vs. illegal.
- How OracleRequired interacts with PSM and BuybackVault.
- How governance and parameters must be handled under the new invariants.

---

## 5. Release & process layer (DEV-94)

On the release side, OracleRequired is integrated via **DEV-94**:

- `DEV94_Release_Status_Workflow_Report.md`
  - Contains a dedicated section “OracleRequired checks for v0.51+”.
  - Declares the following reports as **mandatory** before cutting a
    v0.51+ release tag:
    - `ARCHITECT_BULLETIN_OracleRequired_Impact_v2.md`
    - `DEV11_OracleRequired_Handshake_r1.md`
    - `BLOCK_DEV49_DEV11_OracleRequired_Block_r1.md`
    - `GOV_Oracle_PSM_Governance_v051_r1.md`

Release managers must treat these reports as **non-optional** for
OracleRequired-based releases.

Future work (DEV-94/95) will extend `scripts/check_release_status.sh`
to enforce presence and freshness of these artefacts programmatically.

---

## 6. Telemetry & indexer layer (DEV-11 Phase B)

For OracleRequired to be effective in operations, the signals must be
visible in **telemetry and indexers**.

The bundle therefore includes expectations for DEV-11 Phase B:

- **Events & reason codes**
  - Reverts and events related to:
    - `PSM_ORACLE_MISSING`
    - `BUYBACK_ORACLE_REQUIRED`
    - Oracle-unhealthy scenarios
  - must be:
    - clearly distinguishable,
    - machine-readable,
    - and documented in indexer / integration guides.

- **Docs & guides**
  - `docs/dev/DEV11_Telemetry_Events_Outline_r1.md`
    - Outlines the telemetry event surface for Economic Core components.
  - `docs/dev/DEV11_PhaseB_Telemetry_TestPlan_r1.md`
    - Describes how telemetry-related behaviour is to be tested.
  - `docs/indexer/indexer_buybackvault.md`
    - Explains indexer expectations for BuybackVault events.
  - `docs/integrations/guardian_and_safety_events.md`
    - Lists safety-related events and how integrators should react.
  - `docs/integrations/oracle_aggregator_guide.md`
    - Describes oracle aggregation and health signalling.

Telemetry and indexer work in DEV-11 Phase B must:

1. Make OracleRequired-related reason codes and events **observable**.
2. Provide clear guidance for building dashboards and alerts, e.g.:
   - “If `PSM_ORACLE_MISSING` occurs in production → raise a critical alert.”
   - “If strict BuybackVault reverts with `BUYBACK_ORACLE_REQUIRED` →
      treat this as misconfiguration or missing health module.”

---

## 7. Adoption and future work

The OracleRequired Operations Bundle is considered:

- **Mandatory** reference for:
  - Indexer / monitoring development.
  - Governance tooling and parameter UIs.
  - Ops runbooks and incident response guides.
  - Release coordination around v0.51.x.

Planned follow-ups (future DEV-11 / DEV-94 work):

- Enhance telemetry docs and tests to:
  - Explicitly cover OracleRequired reason codes.
  - Provide example log / event payloads for indexers.
- Extend `scripts/check_release_status.sh` so that:
  - OracleRequired reports are enforced as a **hard release gate**.
- Add concrete “operations playbooks” that:
  - Describe how to react when OracleRequired signals fire in production.

This document will be updated when:

- New OracleRequired-related reason codes are introduced.
- Additional components (e.g. future StrategyEnforcement layers) become part
  of the OracleRequired safety perimeter.

