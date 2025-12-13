#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

python - << 'PY'
from pathlib import Path

path = Path("docs/governance/DEV12_Governance_Docs_Outline_r1.md")
if path.exists():
    raise SystemExit("outline already exists, nothing to do")

content = """# Governance documentation outline (DEV-12, r1)

This document is part of DEV-12 and gives a high-level outline of how
governance documentation for the 1kUSD protocol is structured. It is
meant as a companion to `DEV12_Governance_Docs_Plan_r1.md` and should help
authors and reviewers to see **where new docs should live**.

The focus is on:
- making the structure explicit,
- mapping existing files into that structure,
- and listing obvious gaps for future DEV-12 steps.

---

## 1. Scope and goals

The governance docs should enable:

- **Protocol-level understanding**
  - What is governed, by whom, and with which powers and limits.
- **Parameter and runbook driven operations**
  - Concrete “how to change X” guides and parameter playbooks.
- **Clear separation of Economic, Oracle and Safety governance**
  - Economic decisions, oracle configuration, and safety/guardian rules
    must not be mixed into one opaque blob.
- **Auditable decision trail**
  - Governance docs must reference the relevant reports, specs and DEV
    assignments so that auditors can reconstruct *why* a decision was taken.

This outline does **not** add new policy by itself – it only structures and
connects existing and planned documents.

---

## 2. Document clusters

### 2.1 High-level governance overview

**Files:**

- `docs/governance/index.md`

**Purpose:**

- Entry point for readers who need a narrative overview of governance
  for 1kUSD.
- Links to the main playbooks, parameter docs and reports.
- Explains the difference between:
  - protocol contracts (PSM, BuybackVault, Vaults, Oracles),
  - off-chain roles (DAO, Guardian, Operators),
  - and the release / tag process.

DEV-12 will keep `index.md` as the top-level entry point and make sure
it links to all relevant playbooks and status reports.

---

### 2.2 Parameter governance and playbooks

**Existing files:**

- `docs/governance/parameter_playbook.md`
- `docs/governance/parameter_howto.md`

**Planned additions (per DEV-12 plan):**

- Short “parameter taxonomy” section that groups parameters into:
  - economic parameters (fees, spreads, limits),
  - oracle parameters (max stale, diff bps, sources),
  - safety / guardian parameters (pause, caps, gates),
  - release / rollout toggles (feature flags, previews).

**Goal:**

- Make it clear **which document is authoritative** for:
  - “What does parameter X mean?”
  - “Who is allowed to change parameter X?”
  - “Which safety checks must be done before/after changing X?”

DEV-12 will later align these docs with the OracleRequired semantics
introduced in DEV-49/DEV-11.

---

### 2.3 BuybackVault governance (Phase A)

**Existing files:**

- `docs/governance/buybackvault_parameter_playbook_phaseA.md`

**Context:**

- This playbook describes how to operate the BuybackVault in Phase A,
  including treasury caps, buyback share per operation and oracle gate
  configuration.
- It should be kept in sync with:
  - `docs/reports/DEV11_PhaseA_BuybackSafety_Status_r1.md`
  - strategy and architecture docs under `docs/architecture/`.

**DEV-12 responsibilities:**

- Ensure the playbook:
  - clearly references the **OracleRequired** precondition,
  - cross-links to the relevant DEV-11 reports and specs,
  - is discoverable from `docs/governance/index.md`.

---

### 2.4 Oracle & PSM governance

**Existing related docs:**

- Oracle specs and notes under `docs/specs/ORACLE_*.md`
- PSM architecture and parameter docs:
  - `docs/architecture/psm_parameters.md`
  - `docs/specs/PSM_LIMITS_AND_INVARIANTS.md`
  - `docs/reports/DEV43_PSM_CONSOLIDATION.md`
  - `docs/reports/ARCHITECT_BULLETIN_OracleRequired_Impact_v2.md`
  - `docs/reports/DEV11_OracleRequired_Handshake_r1.md`

**Planned DEV-12 outcome:**

- A **dedicated governance-facing document** that explains:
  - which oracle/PSM parameters are governed,
  - how OracleRequired semantics constrain legal configurations,
  - how Guardian / DAO should react to unhealthy or missing oracles.

For now, this outline only reserves the cluster; the concrete document
will be added in a later DEV-12 step.

---

### 2.5 Emergency & safety governance

**Existing related docs:**

- Emergency pause audit and reports under `docs/audits/` and `docs/reports/`
  (e.g. `EMERGENCY_PAUSE_AUDIT_REPORT.md`).
- Guardian and safety specs:
  - `docs/specs/GUARDIAN_SAFETY_RULES.md`
  - `docs/integrations/guardian_and_safety_events.md`
- Security & risk documentation under `docs/security/` and `docs/risk/`.

**Goal for DEV-12:**

- Provide a governance-facing “Emergency handbook” that:
  - describes who can trigger pause / unpause and under which conditions,
  - references the safety rules and reason codes,
  - ties into future operator dashboards and runbooks.

This outline only defines that such a handbook belongs to the
**governance** tree, not to random logs or specs.

---

### 2.6 Release and tag governance

**Existing related docs:**

- Release notes and guides under `docs/releases/`
- DEV-94 release flow and tag guides:
  - `docs/dev/DEV94_ReleaseFlow_Plan_r2.md`
  - `docs/dev/DEV94_How_to_cut_a_release_tag_v051.md`
- Release status workflow report:
  - `docs/reports/DEV94_Release_Status_Workflow_Report.md`

**DEV-12 alignment:**

- Clarify that:
  - release tags are governance artefacts, not only CI details,
  - certain reports (PROJECT_STATUS, Governance Handover, block reports)
    are preconditions for a release,
  - the governance index should help readers find the relevant release docs.

A later DEV-12 step may introduce a short “Release governance summary”
that lives under `docs/governance/` and links into DEV-94 material.

---

## 3. Mapping to DEV roles and reports

This section summarises which DEV assignments feed into governance docs:

- **DEV-7 / DEV-8**
  - Economic Layer and Security & Risk baselines.
  - Reports like `PROJECT_STATUS_EconomicLayer_v051.md` and
    `DEV89_Dev7_Sync_EconomicLayer_Security.md`.

- **DEV-9 / DEV-10**
  - Infra and integrations; relevant for how governance docs are built,
    published and monitored.

- **DEV-11**
  - BuybackVault safety, telemetry and OracleRequired semantics.
  - Directly informs BuybackVault and Oracle governance docs.

- **DEV-87 / DEV-94**
  - Governance handover v0.51 and release workflow.
  - Define which reports must exist for a given release.

DEV-12 does not duplicate these reports – it **connects** them and gives
governance readers a clear map.

---

## 4. Next steps for DEV-12

Planned follow-ups (future patches):

- Add a short “Governance docs index” section to `docs/governance/index.md`
  that references this outline and the main clusters.
- Introduce a dedicated Oracle & PSM governance doc under
  `docs/governance/` and wire it into the index.
- Add a concise “release governance summary” that points to DEV-94 docs
  and the mandatory reports for each tagged release.

These items are intentionally **not** implemented in this patch; they will
be handled in later DEV-12 steps to keep changes reviewable.

"""

path.parent.mkdir(parents=True, exist_ok=True)
path.write_text(content, encoding="utf-8")
PY

echo "[DEV-12] $(date -u +"%Y-%m-%dT%H:%M:%SZ") add governance docs outline skeleton (r1)" >> logs/project.log

echo "== DEV-12 step02: governance docs outline skeleton created =="
