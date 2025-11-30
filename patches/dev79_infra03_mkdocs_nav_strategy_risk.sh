#!/usr/bin/env bash
set -euo pipefail

echo "== DEV79 INFRA03: write MkDocs nav blueprint for Security/Risk/Strategy docs =="

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

DOC="docs/logs/DEV79_Infra_MkDocs_Nav_StrategyRisk.md"
LOG_FILE="logs/project.log"

mkdir -p "$(dirname "$DOC")"

cat > "$DOC" <<'MD'
# DEV79 – MkDocs Navigation Blueprint (Security / Risk / Strategy)

**Rolle:** DEV-7 (Infra / Docker / CI / Pages)  
**Scope:** Nur Dokumentation – _keine_ Änderungen an `mkdocs.yml` in diesem Ticket.

Dieses Dokument beschreibt, wie die neuen Security-, Risk- und
Strategy-/Reports-Dateien langfristig in die MkDocs-Navigation
integriert werden können, ohne den bestehenden Build-Flow zu brechen.

---

## 1. Ausgangssituation

Aktueller Stand (aus `mkdocs build`):

- Viele Dateien in `docs/` existieren, sind aber nicht im `nav`-Block von
  `mkdocs.yml` referenziert, z.B.:
  - `security/audit_plan.md`
  - `security/bug_bounty.md`
  - `risk/proof_of_reserves_spec.md`
  - `risk/collateral_risk_profile.md`
  - `risk/emergency_depeg_runbook.md`
  - `architecture/buybackvault_strategy.md`
  - `architecture/buybackvault_strategy_phase1.md`
  - `architecture/buybackvault_strategy_rfc.md`
  - `reports/DEV60-72_BuybackVault_EconomicLayer.md`
  - `reports/DEV74-76_StrategyEnforcement_Report.md`
  - `reports/PROJECT_STATUS_EconomicLayer_v051.md`
  - `reports/DEV87_Governance_Handover_v051.md`
  - `reports/DEV89_Dev7_Sync_EconomicLayer_Security.md`
  - `logs/DEV78_Infra_CI_StrategyRisk_Docs_Checklist.md`
  - `logs/DEV79_Infra_CI_Inventory.md`
- Zusätzlich gibt es Warnungen zu einer `index.md`-Referenz im `nav`,
  während aktuell eher `INDEX.md` / `README.md` im Repo liegen.

Diese Blueprint-Datei ändert daran **nichts**, sondern dient als
Leitfaden für spätere, kleine Tickets.

---

## 2. Zielbild für die Navigation

Vorschlag für eine logisch strukturierte Navigation
(ausdrücklich als Entwurf, nicht 1:1 verbindlich):

- **Home**
  - `README.md` oder ein dediziertes `index.md` (später zu entscheiden)
- **Architecture**
  - Economic Layer Overview
    - `architecture/economic_layer_overview.md`
  - PSM
    - `architecture/psm_parameters.md`
    - `architecture/psm_flows_invariants.md`
  - BuybackVault
    - `architecture/buybackvault_execution.md`
    - `architecture/buybackvault_plan.md`
    - `architecture/buybackvault_strategy.md`
    - `architecture/buybackvault_strategy_phase1.md`
    - `architecture/buybackvault_strategy_rfc.md`
- **Security & Risk**
  - Security
    - `security/audit_plan.md`
    - `security/bug_bounty.md`
  - Risk
    - `risk/proof_of_reserves_spec.md`
    - `risk/collateral_risk_profile.md`
    - `risk/emergency_depeg_runbook.md`
- **Governance**
  - `governance/index.md`
  - `governance/parameter_howto.md`
  - `governance/parameter_playbook.md`
- **Indexer & Telemetry**
  - `indexer/indexer_buybackvault.md`
  - (später: weitere Indexer-Dokumente)
- **Reports**
  - Economic Layer / BuybackVault
    - `reports/DEV60-72_BuybackVault_EconomicLayer.md`
    - `reports/DEV74-76_StrategyEnforcement_Report.md`
    - `reports/PROJECT_STATUS_EconomicLayer_v051.md`
  - Governance / Security Sync
    - `reports/DEV87_Governance_Handover_v051.md`
    - `reports/DEV89_Dev7_Sync_EconomicLayer_Security.md`
- **Infra & Logs**
  - `logs/DEV78_Infra_CI_StrategyRisk_Docs_Checklist.md`
  - `logs/DEV79_Infra_CI_Inventory.md`
  - (weitere Infra-/Routing-/Pages-Reports)

Dieses Zielbild kann iterativ umgesetzt werden – z.B. erst nur
Security/Risk, später Reports und Logs.

---

## 3. YAML-Snippets (Beispiele, nicht aktiv)

### 3.1. Security & Risk

Ein mögliches Snippet für `mkdocs.yml`:

```yaml
  - Security & Risk:
      - Security:
          - "Audit Plan": security/audit_plan.md
          - "Bug Bounty": security/bug_bounty.md
      - Risk:
          - "Proof of Reserves": risk/proof_of_reserves_spec.md
          - "Collateral Risk Profile": risk/collateral_risk_profile.md
          - "Emergency Depeg Runbook": risk/emergency_depeg_runbook.md
3.2. BuybackVault Strategy / Economic Layer
yaml
Code kopieren
  - Economic Layer:
      - "Overview": architecture/economic_layer_overview.md
      - "PSM Parameters": architecture/psm_parameters.md
      - "PSM Flows & Invariants": architecture/psm_flows_invariants.md
      - "BuybackVault":
          - "Execution": architecture/buybackvault_execution.md
          - "Plan": architecture/buybackvault_plan.md
          - "Strategy": architecture/buybackvault_strategy.md
          - "Strategy Phase-1": architecture/buybackvault_strategy_phase1.md
          - "Strategy RFC": architecture/buybackvault_strategy_rfc.md
3.3. Reports (Economic Layer v0.51.0, StrategyEnforcement)
yaml
Code kopieren
  - Reports:
      - "Economic Layer v0.51.0 – Overview":
          - "Status v0.51.0": reports/PROJECT_STATUS_EconomicLayer_v051.md
          - "DEV60–72 BuybackVault + Economic Layer": reports/DEV60-72_BuybackVault_EconomicLayer.md
          - "DEV74–76 StrategyEnforcement": reports/DEV74-76_StrategyEnforcement_Report.md
          - "DEV87 Governance Handover v0.51.0": reports/DEV87_Governance_Handover_v051.md
          - "DEV89 Dev7 Sync EconomicLayer/Security": reports/DEV89_Dev7_Sync_EconomicLayer_Security.md
Diese YAML-Blöcke sind nur Beispiele. Die tatsächliche Struktur
kann der Architekt/Lead-Dev später anpassen.

4. Offene Punkte / Nächste Schritte (als eigene Tickets)
Empfohlene, kleine Folge-Tickets:

INFRA-Next-MkDocs-01 – Startpunkt klären

Entscheidung, ob:

ein echtes index.md als Startseite verwendet wird, oder

README.md / INDEX.md angebunden wird.

Anpassung von mkdocs.yml entsprechend.

Sicherstellen, dass die bisherigen Warnungen bzgl. index.md
geklärt sind.

INFRA-Next-MkDocs-02 – Security & Risk ins nav aufnehmen

Schrittweise Aufnahme der Security/Risk-Dateien ins nav.

Nach jedem Schritt:

lokaler mkdocs build,

ggf. minimaler Link-Check.

INFRA-Next-MkDocs-03 – Reports sauber integrieren

Economic Layer / Strategy-Reports strukturiert unter „Reports“ oder
einem eigenen „Releases / Reports“-Kapitel sammeln.

INFRA-Next-MkDocs-04 – Infra-/CI-Logs optional in separaten Bereich

Entscheidung, ob docs/logs/*.md in der offiziellen Navigation
sichtbar oder nur intern referenziert werden sollen.

5. Zusammenfassung
DEV79 INFRA03 ändert nichts an mkdocs.yml oder der CI.

Es dokumentiert:

die Zielstruktur der Navigation,

konkrete YAML-Snippets als Vorlage,

sinnvolle nächste INFRA-Schritte.

Damit behält DEV-7 die volle Kontrolle, wann und wie die
Navigation angepasst wird, ohne den jetzt stabilen
Economic Layer v0.51.0 oder die Strategy-Doku zu gefährden.
MD

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-79] ${timestamp} Infra: added MkDocs nav blueprint for Security/Risk/Strategy docs." >> "$LOG_FILE"

echo "✓ MkDocs nav blueprint written to ${DOC}"
echo "✓ Log updated at ${LOG_FILE}"
echo "== DEV79 INFRA03: done =="
