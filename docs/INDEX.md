# 1kUSD Documentation

Welcome to the 1kUSD documentation.

This site describes the architecture, economic layer, security model,
risk framework, governance processes and infrastructure/CI setup of
the 1kUSD stablecoin project.

## High-level structure

The documentation is roughly organized into:

- Architecture and design documents
- Economic layer and protocol behavior (READ-ONLY for DEV-9)
- Security and risk documentation
- Governance and strategy reports
- Infrastructure, CI, and tooling documentation
- Project status and release reports

DEV-9 AAAAAAAA is responsible for infrastructure-related aspects only
(CI, Docker, Docs build, Pages hardening, monitoring preparation) and
must not modify the Solidity contracts or economic layer logic.

For more detailed dev-specific information, see the DEV-9 documents in
`docs/dev/` (especially DEV9_Onboarding.md and DEV9_InfrastructurePlan.md).

---

## Infrastructure & CI (DEV-9 snapshot)

This section summarizes the current infra / CI helpers maintained by DEV-9:

- **DEV-9 Infra Status (r2)**  
  High-level overview of what DEV-9 changed and which areas are in scope.  
  See: \`dev/DEV9_Status_Infra_r2.md\`

- **DEV-9 Backlog**  
  Living backlog for infra/CI work, including Zone A/B/C separation and future blocks.  
  See: \`dev/DEV9_Backlog.md\`

- **DEV-9 Operator Guide**  
  How to run the manual workflows and tools introduced by DEV-9  
  (docker baseline build, docs linkcheck, CI checks).  
  See: \`dev/DEV9_Operator_Guide.md\`

The goal is to keep infra/CI changes transparent and reproducible without touching
the core Economic Layer contracts.

---

## Integrations & Developer Guides (DEV-10)

This section is maintained by DEV-10 and focuses on how external builders
integrate with the 1kUSD Economic Core.

- **Integrations index**  
  High-level entry point for all integration-focused documentation.  
  See: `integrations/index.md`

- **Planned guides**  
  - PSM Integration Guide  
  - Oracle Aggregator Integration Guide  
  - Guardian & Safety Events Guide  
  - BuybackVault Observer Guide

---

## Reports & Status Index

For an overview of the main status, governance and sync reports, see:

- `reports/REPORTS_INDEX.md`

---

## Developer Quickstart

If you are new to the 1kUSD repository and want a concise overview of how to
set up your environment, run tests and follow the patch-based workflow, see:

- \`dev/DEV_Developer_Quickstart.md\`

This page complements the DEV-9 and DEV-10 documents and is intended as a
first stop for new contributors.

---

## DEV Roles Index

For an overview of the main DEV roles (DEV-7, DEV-8, DEV-9, DEV-10) and their
key documents, see:

- `dev/DEV_Roles_Index.md`

## Release flow (DEV-94)

- [DEV94_ReleaseFlow_Plan_r2](dev/DEV94_ReleaseFlow_Plan_r2.md) – Current & target release flow and DEV-94 backlog (docs-only, no CI changes).
