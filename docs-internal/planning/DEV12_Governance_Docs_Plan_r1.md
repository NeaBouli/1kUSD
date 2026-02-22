# DEV-12 – Governance Documentation Plan (r1)

This document outlines the initial scope and work plan for DEV-12
(governance documentation) in the 1kUSD project.

The goal of DEV-12 is to make governance *auditable and operable*:
humans must be able to understand who can change what, under which
constraints, and how this ties back to the Economic Layer and safety
stack.

---

## 1. Scope of DEV-12

DEV-12 focuses on documentation only:

- Governance concepts and roles for 1kUSD.
- Parameter governance (what can be changed, by whom, how).
- Links between governance decisions and safety mechanisms:
  - PegStabilityModule (PSM).
  - BuybackVault and StrategyEnforcement (preview).
  - Oracle layer and OracleRequired semantics.
- Operator- and DAO-facing guides:
  - How to perform safe parameter changes.
  - How to interpret reason codes and status reports.
  - How to prepare governance decisions for on-chain execution.

No Solidity contracts, Foundry tests or CI workflows are modified under
DEV-12.

---

## 2. Existing governance-related documents

The following documents already exist and are inputs to DEV-12:

- `docs/governance/buybackvault_parameter_playbook_phaseA.md`
  - Parameter playbook for BuybackVault Phase A.

- `docs/governance/parameter_playbook.md`
  - General parameter playbook (Economic Layer focus).

- `docs/governance/parameter_howto.md`
  - How-to style guide for parameter changes.

- `docs/reports/DEV87_Governance_Handover_v051.md`
  - Governance view on the Economic Layer v0.51.0.

- `docs/reports/ARCHITECT_BULLETIN_OracleRequired_Impact_v2.md`
  - Architect bulletin describing OracleRequired as root safety layer.

- `docs/reports/BLOCK_DEV49_DEV11_OracleRequired_Block_r1.md`
  - Cross-block report linking DEV-49, DEV-11 and DEV-87.

These documents must not be duplicated. DEV-12 will reference them and
extract a coherent governance view.

---

## 3. Phase A – Core governance docs (DEV-12/A)

Phase A of DEV-12 aims to make governance for the current Economic Layer
(v0.51.x) understandable and actionable:

Planned outputs:

1. **Governance overview page**
   - High-level picture of governance actors:
     - DAO, Guardian, Safety modules, Oracles, Operators.
   - Relation to Economic Layer and safety stack.
   - Link to DEV87 handover and main reports index.

2. **Parameter governance map**
   - Overview which parameters live where:
     - PSM limits, fees, spreads, oracles.
     - BuybackVault caps, strategies, oracle gates.
   - Mapping to contracts and role requirements (DAO only, Guardian, etc.).

3. **Operator / DAO playbook**
   - Narrative guides that re-use:
     - `parameter_playbook.md`
     - `parameter_howto.md`
     - BuybackVault parameter playbook.
   - Focus on safe change patterns:
     - How to stage, review and execute changes.
     - How to roll back in case of issues.

4. **OracleRequired integration**
   - Short, governance-facing explanation how OracleRequired affects:
     - PSM (PSM_ORACLE_MISSING).
     - BuybackVault strict mode (BUYBACK_ORACLE_REQUIRED).
   - Link back to DEV-49, DEV-11 and ARCHITECT bulletins.

---

## 4. Out of scope for DEV-12 (r1)

The following items are explicitly out of scope for DEV-12 in this
iteration:

- Implementing new governance contracts or mechanisms.
- Changing DAO/Guardian/Safety roles on-chain.
- Changing CI workflows or release processes.
- Implementing StrategyEnforcement Phase-1 or multi-asset buybacks.

DEV-12 documents these topics and prepares the ground for future DEV
blocks; it does not perform protocol-level changes.

---

## 5. Next steps

The next DEV-12 steps after this plan (r1) are expected to be:

- Add a structured governance overview page and connect it from the main
  docs navigation.
- Align existing parameter playbooks with OracleRequired semantics and the
  current Economic Layer status (v0.51.x).
- Introduce a small set of governance checklists and runbooks that can be
  used during releases and emergency operations.

This document should be updated whenever the scope of DEV-12 changes or
new governance-related DEV blocks (e.g. StrategyEnforcement, multi-asset
buybacks, or extended DAO mechanics) are introduced.
