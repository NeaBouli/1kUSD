# Reports & Status Index

This index lists the main status, governance and sync reports for the 1kUSD
Economic Core. It is meant as a human entry point for auditors, architects
and developers who need to understand *what happened when* without digging
through the entire docs tree.

---

## 1. Economic Layer v0.51.0 – Core Status

These reports describe the baseline Economic Layer (v0.51.0) and its
governance handover:

- **Economic Layer project status (v0.51.0)**
  - High-level status of the Economic Layer at v0.51.0.
  - See: `PROJECT_STATUS_EconomicLayer_v051.md`

- **Governance handover (v0.51.0)**
  - Governance view on the v0.51.0 Economic Layer.
  - See: `DEV87_Governance_Handover_v051.md`

- **Dev7/Economic Layer ↔ Security sync**
  - How Economic Layer work lines up with the Security & Risk docs.
  - See: `DEV89_Dev7_Sync_EconomicLayer_Security.md`

---

## 2. Security & Risk

These documents are authored under DEV-8 and focus on security posture,
risk management and emergency handling:

- **Security & risk documentation (overview)**
  - Includes audit plans, bug bounty outline, PoR specs, collateral risk and
    depeg runbooks.
  - See the `docs/security/` and `docs/risk/` directories for details.

For exact file lists, refer to the directory structure; this index only
highlights the main clusters.

---

## 3. CI, Docs & Release Status

These reports describe how CI, docs builds and release checks are wired:

- **Docs build & CI (DEV-93)**
  - Overview of the dedicated docs-build workflow, triggers and guarantees.
  - See: `DEV93_CI_Docs_Build_Report.md`

- **Release status workflow (DEV-94)**
  - Describes the Release Status Check workflow and its expectations on
    reports and status files.
  - See: `DEV94_Release_Status_Workflow_Report.md`

- **Release status script & checks (DEV-95+)**
  - Details of the local `scripts/check_release_status.sh` helper and how
    it ties into CI.
  - See the individual DEV-95+ reports under `docs/reports/`.

---

## 4. Infra & Integrations (DEV-9 / DEV-10)

These reports bridge infra/CI work (DEV-9) and integration docs (DEV-10):

- **DEV-9 Infra status (r1/r2)**
  - Status of infra/CI helpers, docker baseline, docs build settings and
    linkcheck workflows.
  - See:
    - `docs/dev/DEV9_Status_Infra_r1.md`
    - `docs/dev/DEV9_Status_Infra_r2.md`

- **DEV-9 Infra backlog**
  - Living backlog for infra/CI work (Zone A/B/C).
  - See: `docs/dev/DEV9_Backlog.md`

- **DEV-10 Integrations status (r1)**
  - Summary of the initial integrations/DevEx layer and its boundaries.
  - See: `docs/dev/DEV10_Status_Integrations_r1.md`

- **DEV-10 Integrations backlog**
  - Planned r2+ items for integrator experience.
  - See: `docs/dev/DEV10_Backlog.md`

- **DEV-9 / DEV-10 sync report (r1)**
  - How infra/CI (DEV-9) and integrations/DevEx (DEV-10) line up.
  - See: `DEV9_Dev10_Sync_Infra_Integrations_r1.md`

---

## 5. How to use this index

- Start here when you need to understand:
  - *Which Economic Layer version is live?*
  - *Which reports must exist for a given release?*
  - *How infra/CI and integrations work together?*
- Use the linked reports as anchors and then drill into:
  - `docs/architecture/`
  - `docs/security/` and `docs/risk/`
  - `docs/dev/` for role-specific logs and plans.

This page is intentionally high-level and should be kept up to date whenever
new major reports or status documents are added.

- **BLOCK_DEV9_DEV10_Infra_Integrations_r1** – Infra & Integrations block report (DEV-9 / DEV-10, r1)

- [DEV-11 Phase A – Buyback Safety Status](DEV11_PhaseA_BuybackSafety_Status_r1.md)

- [ARCHITECT_BULLETIN_Oracle_Safety_Clarifications_2025-12](ARCHITECT_BULLETIN_Oracle_Safety_Clarifications_2025-12.md) – Oracle & buyback safety clarifications (architect bulletin, Dec 2025).

## Architect Bulletins

- [ARCHITECT_BULLETIN_OracleRequired_Impact_v2](ARCHITECT_BULLETIN_OracleRequired_Impact_v2.md)

## DEV-11

- [DEV11_OracleRequired_Handshake_r1](DEV11_OracleRequired_Handshake_r1.md)
