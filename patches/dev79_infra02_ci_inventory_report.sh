#!/usr/bin/env bash
set -euo pipefail

echo "== DEV79 INFRA02: write CI workflow inventory report =="

DOC="docs/logs/DEV79_Infra_CI_Inventory.md"
LOG_FILE="logs/project.log"
WF_DIR=".github/workflows"

mkdir -p "$(dirname "$DOC")"
mkdir -p "$(dirname "$LOG_FILE")"

# 1) CI-Inventur-Dokument schreiben (mit dynamischer Liste der Workflow-Dateien)
{
  echo "# DEV-79 CI Inventory – GitHub Workflows Overview"
  echo
  echo "> Scope: Dieses Dokument fasst den aktuellen Stand der GitHub-Actions-Workflows"
  echo "> für das 1kUSD-Projekt zusammen – ohne Änderungen an CI-Config oder Dockerfiles."
  echo
  echo "- Generated on: $(date -u +"%Y-%m-%dT%H:%M:%SZ") (UTC)"
  echo "- Environment: DEV-7 / Infra-Fokus (CI, Docker, Pages)"
  echo
  echo "## 1. Rahmenbedingungen"
  echo
  echo "- Economic Layer **v0.51.0** ist stabil; keine Contract-/Logic-Änderungen."
  echo "- BuybackVault + StrategyConfig + StrategyEnforcement (Phase 1 Preview) sind:"
  echo "  - implementiert,"
  echo "  - durch Tests abgedeckt,"
  echo "  - in Architektur-/Governance-/Indexer-/Status-Dokus verankert."
  echo "- DEV-8 Security/Risk-Layer (DEV-80–89) wurde integriert,"
  echo "  ohne CI-, Docker- oder MkDocs-Pipelines zu verändern."
  echo
  echo "## 2. Detected workflow files (.github/workflows)"
  echo

  if [ -d "$WF_DIR" ]; then
    WF_FILES=$(ls "$WF_DIR" 2>/dev/null | sort || true)
    if [ -n "$WF_FILES" ]; then
      echo "Folgende Workflow-Dateien wurden gefunden:"
      echo
      for f in $WF_FILES; do
        echo "- \`.github/workflows/$f\`"
      done
    else
      echo "_Verzeichnis \`.github/workflows/\` ist leer._"
    fi
  else
    echo "_Verzeichnis \`.github/workflows/\` existiert nicht im Projekt-Root._"
  fi

  echo
  echo "## 3. Erste Einschätzung (High-Level)"
  echo
  echo "- CI deckt aktuell mindestens folgende Bereiche ab:"
  echo "  - Foundry-Tests für Economic Layer / PSM / Guardian / Oracles."
  echo "  - Basis-Monitoring für Core-Contracts (Regression-Suites)."
  echo "  - MkDocs-Build / GitHub-Pages-Deployment (manuell oder via Workflow)."
  echo
  echo "- Neue Komponenten, die **konzeptionell** im CI sichtbar sein sollten:"
  echo "  - BuybackVault inkl. Strategy-Enforcement-Tests:"
  echo "    - \`BuybackVaultTest\`"
  echo "    - \`BuybackVaultStrategyGuardTest\`"
  echo "  - Security/Risk-Dokumente (Audit-Plan, Bug-Bounty, Proof-of-Reserves, Depeg-Runbook)."
  echo
  echo "Hinweis: Diese Inventur ändert **keine** Workflows, sondern dokumentiert nur,"
  echo "welche YAML-Dateien aktuell vorhanden sind."
  echo
  echo "## 4. Bezüge zu bestehenden Doku-Artefakten"
  echo
  echo "- **Strategy-/Buyback-Doku**:"
  echo "  - \`docs/architecture/buybackvault_strategy.md\`"
  echo "  - \`docs/architecture/buybackvault_strategy_phase1.md\`"
  echo "  - \`docs/architecture/buybackvault_strategy_rfc.md\`"
  echo "  - \`docs/indexer/indexer_buybackvault.md\`"
  echo
  echo "- **Status- & Handover-Reports**:"
  echo "  - \`docs/reports/DEV60-72_BuybackVault_EconomicLayer.md\`"
  echo "  - \`docs/reports/DEV74-76_StrategyEnforcement_Report.md\`"
  echo "  - \`docs/reports/PROJECT_STATUS_EconomicLayer_v051.md\`"
  echo
  echo "- **Security / Risk / Testing / Infra-Checkliste**:"
  echo "  - \`docs/security/audit_plan.md\`"
  echo "  - \`docs/security/bug_bounty.md\`"
  echo "  - \`docs/risk/proof_of_reserves_spec.md\`"
  echo "  - \`docs/risk/emergency_depeg_runbook.md\`"
  echo "  - \`docs/testing/stress_test_suite_plan.md\`"
  echo "  - \`docs/logs/DEV78_Infra_CI_StrategyRisk_Docs_Checklist.md\`"
  echo
  echo "## 5. Offene Punkte für zukünftige INFRA-Tickets"
  echo
  echo "Diese Inventur ist bewusst **read-only**. Mögliche nächste Schritte:"
  echo
  echo "- **INFRA-Next 1 – CI-Abdeckung schärfen (separates Ticket)**"
  echo "  - Prüfen, ob alle relevanten Foundry-Suites im CI laufen"
  echo "    (inkl. BuybackVault- und StrategyGuard-Tests)."
  echo "  - Ggf. einen kleinen Report ergänzen, welche Suites durch welche Workflows"
  echo "    abgedeckt sind."
  echo
  echo "- **INFRA-Next 2 – Docs/MkDocs-Integration (separates Ticket)**"
  echo "  - Sicherstellen, dass MkDocs-Build in CI regelmäßig läuft"
  echo "    (oder bewusst manuell bleibt, aber dokumentiert ist)."
  echo "  - Optional: einen einfachen CI-Check definieren, der nur \`mkdocs build\` ausführt,"
  echo "    ohne Deploy."
  echo
  echo "- **INFRA-Next 3 – Release-Flow-Checks (separates Ticket)**"
  echo "  - Bei Release-Tags prüfen, dass zentrale Reports und Status-Files aktuell sind:"
  echo "    - \`PROJECT_STATUS_*.md\`"
  echo "    - relevante \`DEVxx_*.md\`-Reports."
  echo
  echo "## 6. Zusammenfassung"
  echo
  echo "- Diese Datei dokumentiert den **Ist-Zustand** der CI-Workflows (Datei-Liste)."
  echo "- Es wurden keinerlei Änderungen an CI-/Docker-/MkDocs-Konfiguration vorgenommen."
  echo "- Sie dient als Basis für zukünftige, kleine INFRA-Patches, die:"
  echo "  - CI-Deckung präzisieren,"
  echo "  - Docs-/Status-Files enger mit dem Release-Prozess verbinden,"
  echo "  - ohne den Economic Layer v0.51.0 oder den Strategy-Layer zu verändern."
} > "$DOC"

# 2) Log-Eintrag
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-79] ${timestamp} Infra: added CI workflow inventory report (DEV79_Infra_CI_Inventory.md)." >> "$LOG_FILE"

echo "✓ CI workflow inventory report written to $DOC"
echo "✓ Log updated at $LOG_FILE"
echo "== DEV79 INFRA02: done =="
