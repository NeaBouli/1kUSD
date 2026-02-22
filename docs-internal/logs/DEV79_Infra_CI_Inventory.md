# DEV-79 CI Inventory – GitHub Workflows Overview

> Scope: Dieses Dokument fasst den aktuellen Stand der GitHub-Actions-Workflows
> für das 1kUSD-Projekt zusammen – ohne Änderungen an CI-Config oder Dockerfiles.

- Generated on: 2025-11-29T20:53:14Z (UTC)
- Environment: DEV-7 / Infra-Fokus (CI, Docker, Pages)

## 1. Rahmenbedingungen

- Economic Layer **v0.51.0** ist stabil; keine Contract-/Logic-Änderungen.
- BuybackVault + StrategyConfig + StrategyEnforcement (Phase 1 Preview) sind:
  - implementiert,
  - durch Tests abgedeckt,
  - in Architektur-/Governance-/Indexer-/Status-Dokus verankert.
- DEV-8 Security/Risk-Layer (DEV-80–89) wurde integriert,
  ohne CI-, Docker- oder MkDocs-Pipelines zu verändern.

## 2. Detected workflow files (.github/workflows)

Folgende Workflow-Dateien wurden gefunden:

- `.github/workflows/_disabled_release.yml`
- `.github/workflows/_disabled_security-gate.yml`
- `.github/workflows/_global_disable_docs.yml`
- `.github/workflows/_scope_quarantine.yml`
- `.github/workflows/ci.yml`
- `.github/workflows/deploy-docs.yml`
- `.github/workflows/deploy-pages.yml.disabled`
- `.github/workflows/deploy-skeleton.yml`
- `.github/workflows/docs-check.yml`
- `.github/workflows/docs.yml`
- `.github/workflows/docs.yml.disabled`
- `.github/workflows/forge-ci.yml`
- `.github/workflows/foundry-fmt.yml`
- `.github/workflows/foundry-test.yml`
- `.github/workflows/foundry.yml`
- `.github/workflows/linkcheck.yml`
- `.github/workflows/pages.yml`

## 3. Erste Einschätzung (High-Level)

- CI deckt aktuell mindestens folgende Bereiche ab:
  - Foundry-Tests für Economic Layer / PSM / Guardian / Oracles.
  - Basis-Monitoring für Core-Contracts (Regression-Suites).
  - MkDocs-Build / GitHub-Pages-Deployment (manuell oder via Workflow).

- Neue Komponenten, die **konzeptionell** im CI sichtbar sein sollten:
  - BuybackVault inkl. Strategy-Enforcement-Tests:
    - `BuybackVaultTest`
    - `BuybackVaultStrategyGuardTest`
  - Security/Risk-Dokumente (Audit-Plan, Bug-Bounty, Proof-of-Reserves, Depeg-Runbook).

Hinweis: Diese Inventur ändert **keine** Workflows, sondern dokumentiert nur,
welche YAML-Dateien aktuell vorhanden sind.

## 4. Bezüge zu bestehenden Doku-Artefakten

- **Strategy-/Buyback-Doku**:
  - `docs/architecture/buybackvault_strategy.md`
  - `docs/architecture/buybackvault_strategy_phase1.md`
  - `docs/architecture/buybackvault_strategy_rfc.md`
  - `docs/indexer/indexer_buybackvault.md`

- **Status- & Handover-Reports**:
  - `docs/reports/DEV60-72_BuybackVault_EconomicLayer.md`
  - `docs/reports/DEV74-76_StrategyEnforcement_Report.md`
  - `docs/reports/PROJECT_STATUS_EconomicLayer_v051.md`

- **Security / Risk / Testing / Infra-Checkliste**:
  - `docs/security/audit_plan.md`
  - `docs/security/bug_bounty.md`
  - `docs/risk/proof_of_reserves_spec.md`
  - `docs/risk/emergency_depeg_runbook.md`
  - `docs/testing/stress_test_suite_plan.md`
  - `docs/logs/DEV78_Infra_CI_StrategyRisk_Docs_Checklist.md`

## 5. Offene Punkte für zukünftige INFRA-Tickets

Diese Inventur ist bewusst **read-only**. Mögliche nächste Schritte:

- **INFRA-Next 1 – CI-Abdeckung schärfen (separates Ticket)**
  - Prüfen, ob alle relevanten Foundry-Suites im CI laufen
    (inkl. BuybackVault- und StrategyGuard-Tests).
  - Ggf. einen kleinen Report ergänzen, welche Suites durch welche Workflows
    abgedeckt sind.

- **INFRA-Next 2 – Docs/MkDocs-Integration (separates Ticket)**
  - Sicherstellen, dass MkDocs-Build in CI regelmäßig läuft
    (oder bewusst manuell bleibt, aber dokumentiert ist).
  - Optional: einen einfachen CI-Check definieren, der nur `mkdocs build` ausführt,
    ohne Deploy.

- **INFRA-Next 3 – Release-Flow-Checks (separates Ticket)**
  - Bei Release-Tags prüfen, dass zentrale Reports und Status-Files aktuell sind:
    - `PROJECT_STATUS_*.md`
    - relevante `DEVxx_*.md`-Reports.

## 6. Zusammenfassung

- Diese Datei dokumentiert den **Ist-Zustand** der CI-Workflows (Datei-Liste).
- Es wurden keinerlei Änderungen an CI-/Docker-/MkDocs-Konfiguration vorgenommen.
- Sie dient als Basis für zukünftige, kleine INFRA-Patches, die:
  - CI-Deckung präzisieren,
  - Docs-/Status-Files enger mit dem Release-Prozess verbinden,
  - ohne den Economic Layer v0.51.0 oder den Strategy-Layer zu verändern.
\n\n
### Update DEV-93: docs-build.yml hinzugefügt

- Nach der ursprünglichen CI-Inventur wurde mit **DEV-93** ein zusätzlicher
  Workflow hinzugefügt:
  - Datei: `.github/workflows/docs-build.yml`
  - Aufgabe: `mkdocs build` auf `push` / `pull_request` nach `main`.
- Dieser Workflow stellt sicher, dass die Dokumentation weiterhin baubar ist
  und macht Build-Fehler früh im CI sichtbar.
- Die ursprüngliche Inventur bleibt als Snapshot bestehen; dieses Update
  dokumentiert nur die Erweiterung durch DEV-93.
\n