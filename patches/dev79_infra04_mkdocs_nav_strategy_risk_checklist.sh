#!/usr/bin/env bash
set -euo pipefail

echo "== DEV79 INFRA04: write MkDocs nav checklist for Strategy/Security/Risk docs =="

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

DOC="docs/logs/DEV79_Infra_MkDocs_Nav_StrategyRisk.md"
LOG_FILE="logs/project.log"

mkdir -p "$(dirname "$DOC")"

cat > "$DOC" <<'MD'
# DEV79 – MkDocs Nav / Pages Checklist für Strategy + Security/Risk

**Rolle:** DEV-7 (Infra / Docker / CI / Pages)  
**Scope:** Nur Doku, keine direkten Änderungen an `mkdocs.yml` oder CI.

Dieses Dokument beschreibt, **wie** die neuen Strategy-, Security- und Risk-Dokumente
sauber in die MkDocs-Navigation und die GitHub-Pages-Oberfläche integriert werden
können – als Grundlage für spätere, kleine INFRA-Tickets.

---

## 1. Relevante neue Dateien (Strategy / Security / Risk)

**Architecture / Strategy**

- \`docs/architecture/buybackvault_strategy.md\`
- \`docs/architecture/buybackvault_strategy_phase1.md\`
- \`docs/architecture/buybackvault_strategy_rfc.md\`
- \`docs/architecture/economic_layer_overview.md\`

**Governance**

- \`docs/governance/parameter_playbook.md\`

**Indexer**

- \`docs/indexer/indexer_buybackvault.md\`

**Security & Risk**

- \`docs/security/audit_plan.md\`
- \`docs/security/bug_bounty.md\`
- \`docs/risk/proof_of_reserves_spec.md\`
- \`docs/risk/collateral_risk_profile.md\`
- \`docs/risk/emergency_depeg_runbook.md\`

**Reports / Status**

- \`docs/reports/DEV60-72_BuybackVault_EconomicLayer.md\`
- \`docs/reports/DEV74-76_StrategyEnforcement_Report.md\`
- \`docs/reports/DEV87_Governance_Handover_v051.md\`
- \`docs/reports/DEV89_Dev7_Sync_EconomicLayer_Security.md\`
- \`docs/reports/PROJECT_STATUS_EconomicLayer_v051.md\`

---

## 2. Vorschlag: MkDocs-Navigation (YAML-Snippet)

> **Hinweis:** Dieses Snippet ändert **nichts** automatisch.  
> Es ist als Copy/Paste-Vorlage gedacht, wenn ein zukünftiges INFRA-Ticket
> die Integration in \`mkdocs.yml\` explizit beauftragt.

Beispielausschnitt, der unter einem geeigneten Abschnitt (z.B. \`Architecture\`,
\`Security & Risk\`, \`Governance\`) in \`mkdocs.yml\` eingefügt werden könnte:

```yaml
- Architecture:
  - Economic Layer Overview: architecture/economic_layer_overview.md
  - BuybackVault:
    - Execution Overview: architecture/buybackvault_execution.md
    - Strategy Config (v0.51.0): architecture/buybackvault_strategy.md
    - Strategy Phase 1 (v0.52.x Preview): architecture/buybackvault_strategy_phase1.md
    - Strategy RFC: architecture/buybackvault_strategy_rfc.md

- Security & Risk:
  - Audit Plan: security/audit_plan.md
  - Bug Bounty: security/bug_bounty.md
  - Proof of Reserves Spec: risk/proof_of_reserves_spec.md
  - Collateral Risk Profile: risk/collateral_risk_profile.md
  - Emergency Depeg Runbook: risk/emergency_depeg_runbook.md

- Governance:
  - Governance Index: governance/index.md
  - Parameter How-To: governance/parameter_howto.md
  - Parameter Playbook: governance/parameter_playbook.md
  - Governance Handover v0.51.0: reports/DEV87_Governance_Handover_v051.md

- Indexer:
  - BuybackVault Indexer Guide: indexer/indexer_buybackvault.md

- Reports & Status:
  - Economic Layer v0.50.0 Release: releases/v0.50.0_economic-layer.md
  - BuybackVault v0.51.0 Release: releases/v0.51.0_buybackvault.md
  - BuybackVault + Economic Layer DEV60–72: reports/DEV60-72_BuybackVault_EconomicLayer.md
  - StrategyEnforcement DEV74–76: reports/DEV74-76_StrategyEnforcement_Report.md
  - Economic Layer Project Status v0.51.0: reports/PROJECT_STATUS_EconomicLayer_v051.md
  - Security/Economic Sync (DEV-7 & DEV-8): reports/DEV89_Dev7_Sync_EconomicLayer_Security.md
3. Empfohlener Ablauf für ein zukünftiges Nav-Update-Ticket
Wenn ein späteres Ticket (`INFRA-Next – MkDocs Nav`) die tatsächliche Integration
beauftragt, könnte der Ablauf so aussehen:

Ist-Stand sichern

Aktuelle `mkdocs.yml` sichten.

Vor einem Eingriff ein kurzes Backup-Diff notieren
(z.B. in einem eigenen DEV-Log).

YAML-Snippet integrieren

Obiges Snippet an die bestehende Struktur anpassen:

Namen/Labels ggf. auf Englisch angleichen.

Doppelte Einträge vermeiden.

Einfügen in `mkdocs.yml`.

Lokal testen

`mkdocs build` lokal ausführen.

Prüfen, dass:

keine YAML-Fehler auftreten,

alle verlinkten Dateien existieren,

die neue Nav-Struktur sinnvoll ist.

Optional: CI-Check ergänzen

Separates Ticket, das z.B. einen schlanken Job `mkdocs build` im CI
ausführt (ohne Deploy), um Nav-/Docs-Fehler früh zu sehen.

GitHub Pages verifizieren

Nach einem Deploy (z.B. via `mkdocs gh-deploy`) die neue Nav-Struktur
auf `https://NeaBouli.github.io/1kUSD/\` manuell prüfen.

4. Wichtige Design-Prinzipien
Non-invasive: Strategy/Security/Risk-Docs ergänzen die bestehende Doku,
sie ersetzen nichts.

Klare Trennung:

Architecture (Kernlogik, PSM, BuybackVault),

Security & Risk (Audit, PoR, Runbooks),

Governance (Parameter & Handover),

Reports & Status (historische DEV-Reports, Status-Files).

Governance-Awareness: StrategyEnforcement ist ein optionales Feature;
die Nav sollte diesen „Preview“-Charakter widerspiegeln.

5. Fazit
Dieses Dokument ist eine Checkliste und Vorlage, kein aktiver Eingriff:

`mkdocs.yml` bleibt durch DEV79 INFRA04 unverändert.

Docker-/CI-Konfiguration bleibt unverändert.

DEV-7 kann dieses File als Grundlage nutzen, um in einem eigenen,
kleinen INFRA-Ticket die Navigation zu schärfen, sobald es gewünscht ist.
MD

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-79] ${timestamp} Infra: added MkDocs nav checklist for Strategy/Security/Risk docs." >> "$LOG_FILE"

echo "✓ MkDocs nav checklist written to ${DOC}"
echo "✓ Log updated at ${LOG_FILE}"
echo "== DEV79 INFRA04: done =="
