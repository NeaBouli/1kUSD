#!/bin/bash
set -e

echo "== DEV-10 14: add DEV roles index (DEV-7, DEV-8, DEV-9, DEV-10) =="

ROLES_FILE="docs/dev/DEV_Roles_Index.md"

mkdir -p docs/dev

cat <<'EOD' > "$ROLES_FILE"
# DEV Roles Index – Economic Layer, Security/Risk, Infra & Integrations

This document provides a high-level overview of the main DEV roles involved
in the 1kUSD Economic Core and its surrounding documentation / infra layer.

It is intended as a quick orientation for new contributors, reviewers and
architects who want to understand **who touches what** and where to find the
most relevant documents.

---

## DEV-7 – Infra / CI / Release Status (Phase 1)

**Scope:**

- CI-Baseline für:
  - Foundry Tests,
  - Docs-Build,
  - Release-Status-Checks.
- Erste harte Klammern rund um:
  - Docs-Build auf main,
  - Release-Tagging-Prozess v0.51.x.

**Key responsibilities:**

- Einführen und stabilisieren der Docs-Build-Workflows.
- Aufbau des Release-Status-Workflows und des lokalen Scripts
  `scripts/check_release_status.sh`.
- Basis-Integration von Security/Risk-Docs in die MkDocs-Navigation.

**Important artefacts (selection):**

- CI / Infra:
  - `.github/workflows/docs-build.yml`
  - `.github/workflows/Release Status Check`
- Release / Status:
  - `scripts/check_release_status.sh`
  - `docs/reports/PROJECT_STATUS_EconomicLayer_v051.md`
  - `docs/reports/DEV93_CI_Docs_Build_Report.md`
  - `docs/reports/DEV94_Release_Status_Workflow_Report.md`

DEV-7 ist der erste „Klammer-Owner“ für CI und Release-Status rund um die
Economic Layer v0.51.0 Linie.

---

## DEV-8 – Security & Risk Documentation

**Scope:**

- Security- und Risk-Dokumentation rund um den Economic Core.
- Proof-of-Reserves-Spezifikation, Depeg-Runbooks, Audit-Planung.

**Key responsibilities:**

- Dokumentation von:
  - Proof-of-Reserves-Anforderungen,
  - Collateral-Risiken,
  - Notfall- / Depeg-Prozessen,
  - Bug-Bounty-Ansätzen.
- Enge Verzahnung mit Governance / Economic Layer ohne Code-Änderungen.

**Important artefacts (selection):**

- Security:
  - `docs/security/audit_plan.md`
  - `docs/security/bug_bounty.md`
- Risk:
  - `docs/risk/proof_of_reserves_spec.md`
  - `docs/risk/collateral_risk_profile.md`
  - `docs/risk/emergency_depeg_runbook.md`
- Sync / Governance:
  - `docs/reports/DEV89_Dev7_Sync_EconomicLayer_Security.md`

DEV-8 arbeitet rein dokumentarisch. Contracts und Economic-Core-Logik
bleiben unangetastet.

---

## DEV-9 – Infrastructure & CI (Docker, Foundry, Docs)

**Scope:**

- Weiterentwicklung der Infra- / CI-Schicht auf Basis von DEV-7.
- Docker-Baseline, Foundry-CLI-Versionspflege, MkDocs-Feinjustierung.
- Vorbereitung von Linkchecks und Monitoring/Indexer-Design (ohne Implementierung).

**Key responsibilities:**

- Entfernen veralteter Foundry-Flags und Stabilisierung der CI-Runs.
- Einführung eines manuellen Docker-Baseline-Build-Workflows.
- Einführung eines manuellen Docs-Linkcheck-Workflows.
- Aufsetzen von Status- und Backlog-Dokumenten für Infra/CI.

**Important artefacts (selection):**

- Infra / CI Docs:
  - `docs/dev/DEV9_Status_Infra_r2.md`
  - `docs/dev/DEV9_Backlog.md`
  - `docs/dev/DEV9_InfrastructurePlan.md`
  - `docs/dev/DEV9_Workflows_Inventory.md`
  - `docs/dev/DEV9_Operator_Guide.md`
- Workflows:
  - `.github/workflows/docs-build.yml` (MkDocs, relaxed)
  - Docker-Baseline-Workflow (workflow_dispatch)
  - Docs-Linkcheck-Workflow (workflow_dispatch)
- Sync / Reports:
  - `docs/reports/DEV9_Status_Infra_r2.md`
  - `docs/reports/DEV9_Dev10_Sync_Infra_Integrations_r1.md`

DEV-9 hält sich strikt an die Tabuzonen: keine Änderungen an Economic-Core
Contracts oder ökonomischen Parametern.

---

## DEV-10 – Integrations & Developer Experience

**Scope:**

- Externe Integrationsdokumentation für:
  - PSM,
  - Oracle Aggregator,
  - Guardian / Safety,
  - BuybackVault (Observer-Sicht).
- Developer Experience für Integratoren (Wallets, dApps, Indexer, Monitoring).

**Key responsibilities:**

- Strukturieren und Befüllen der Integrations-Docs.
- Bereitstellen von Checklisten und Best Practices für sichere Integrationen.
- Bereitstellen eines Developer-Quickstarts und eines Integrations-Backlogs.

**Important artefacts (selection):**

- Integrations-Guides:
  - `docs/integrations/index.md`
  - `docs/integrations/psm_integration_guide.md`
  - `docs/integrations/oracle_aggregator_guide.md`
  - `docs/integrations/guardian_and_safety_events.md`
  - `docs/integrations/buybackvault_observer_guide.md`
- Dev / Backlog:
  - `docs/dev/DEV10_Status_Integrations_r1.md`
  - `docs/dev/DEV10_Backlog.md`
  - `docs/dev/DEV_Developer_Quickstart.md`
- Reports / Index:
  - `docs/reports/DEV9_Dev10_Sync_Infra_Integrations_r1.md`
  - `docs/reports/REPORTS_INDEX.md`
- README entry:
  - Integrations & Developer Guides Abschnitt in `README.md`.

Auch DEV-10 verliert nie den Scope aus den Augen: Dokumentation only, keine
Änderung am Economic Core oder an CI-/Deploy-Pipelines.

---

## How to use this index

- **Neue Devs / Contributors**
  - Start with:
    - `docs/dev/DEV_Developer_Quickstart.md`
    - then skim this `DEV_Roles_Index.md`.
  - Jump to the DEV area that matches your current assignment.

- **Architects / Leads**
  - Nutzen, um:
    - zuständige DEV-Rollen und ihre Artefakte zu finden,
    - neue Tickets in die passende Zone (Security, Infra, Integrations)
      einzuordnen.

- **Auditors / Reviewers**
  - Verwenden als Navigationshilfe, um schnell:
    - Status-Reports,
    - Backlogs,
    - relevante Spezifikationen
    zu finden, ohne den kompletten Verlauf rekonstruieren zu müssen.
EOD

DOCS_INDEX="docs/index.md"

if [ -f "$DOCS_INDEX" ]; then
  if grep -q "DEV Roles Index" "$DOCS_INDEX"; then
    echo "DEV Roles Index already mentioned in docs/index.md, nothing to do."
  else
    cat <<'EOD' >> "$DOCS_INDEX"

---

## DEV Roles Index

For an overview of the main DEV roles (DEV-7, DEV-8, DEV-9, DEV-10) and their
key documents, see:

- `dev/DEV_Roles_Index.md`
EOD
  fi
else
  echo "docs/index.md not found, skipped linking DEV_Roles_Index.md."
fi

# Log entry
LOG_FILE="logs/project.log"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-10 14] ${timestamp} Added DEV_Roles_Index.md and linked it from docs/index.md" >> "$LOG_FILE"

echo "== DEV-10 14 done =="
