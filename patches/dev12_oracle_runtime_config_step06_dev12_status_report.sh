#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

python3 - << 'PY'
from pathlib import Path

path = Path("docs/reports/DEV12_Oracle_Governance_Toolkit_Status_v051_r1.md")

content = r"""
# DEV-12 Status Report – OracleRequired Governance Toolkit (v0.51.x)

**System:** 1kUSD – Economic Layer v0.51.x  
**Rollen:** DEV-11 (Oracle / Telemetrie), DEV-12 (Governance & Ops)  
**Stand:** main, Release-Check (`scripts/check_release_status.sh`) grün

---

## 1. Zielbild von DEV-12

DEV-12 ergänzt das bestehende OracleRequired-Fundament um eine **Governance- und
Operations-Perspektive**. Ziel ist, dass OracleRequired nicht nur

- im **Code** (PSM, BuybackVault, OracleWatcher),
- in den **Tests** (Foundry-Regressionen),
- in der **Doku** (Architekturbundle, Governance-Docs)

verankert ist, sondern auch **im laufenden Betrieb**:

- konkrete Incident-Runbooks existieren,
- eine Runtime-Checklist für Konfiguration & Betrieb vorhanden ist,
- Release- und Governance-Prozesse OracleRequired explizit berücksichtigen.

DEV-12 liefert dafür das „OracleRequired Governance Toolkit“ für v0.51.x.

---

## 2. Kontext – Was vor DEV-12 bereits stand

Bereits vor dieser DEV-12-Welle waren folgende Bausteine etabliert:

- **ARCHITECT_OracleRequired_OperationsBundle_v051_r1.md**  
  – Architektonische Leitplanke: OracleRequired ist zwingender Bestandteil
    des Economic Layer (PSM + BuybackVault).

- **GOV_Oracle_PSM_Governance_v051_r1.md**  
  – Governance-Regeln speziell zur Oracle-Abhängigkeit des PSM.

- **DEV11_OracleRequired_Handshake_r1.md**  
  – Übergabe/Handshake zwischen Architekt und DEV-11/DEV-12 zur
    OracleRequired-Umsetzung.

- **DEV94_Release_Status_Workflow_Report.md**  
  – Integration des OracleRequired-Dokumentations-Gates in den Release-Check
    (`scripts/check_release_status.sh` + RELEASE_TAGGING_GUIDE_v0.51.x).

- **RELEASE_TAGGING_GUIDE_v0.51.x.md**  
  – Menschlicher Leitfaden, wie Release-Tags geschnitten werden und welche
    Rolle das OracleRequired-Dokumentations-Gate spielt.

- **ARCHITECT_OracleRequired_Telemetry_Status_v051_r1.md**  
  – Architekten-Statusbericht: Tests grün, Release-Gate aktiv, Telemetry-Phase-B
    als Preview angelegt.

DEV-12 baut auf diesen Bausteinen auf und ergänzt sie um explizite
Governance-/Ops-Werkzeuge.

---

## 3. Neue DEV-12 Artefakte

### 3.1 Incident-Runbook

- **GOV_OracleRequired_Incident_Runbook_v051_r1.md**

Rolle:

- Operationales Runbook für drei Incident-Typen:
  - **Typ A:** `PSM_ORACLE_MISSING`
  - **Typ B:** `BUYBACK_ORACLE_REQUIRED`
  - **Typ C:** `BUYBACK_ORACLE_UNHEALTHY`

Inhaltliche Schwerpunkte:

- **Trigger / Signale:**
  - On-Chain Revert-Reasons
  - Telemetrie-Signale aus DEV-11 Phase B (künftige Indexer / Monitoring)
  - Alerts aus Observability-Stack (sofern vorhanden)

- **Sofortmaßnahmen je Typ:**
  - Was ist **sofort** zu tun, wenn der Zustand auftritt?
  - Welche Komponenten sind zu pausieren / zu überprüfen?
  - Welche Checks sind vor einem Wiederanlauf Pflicht?

- **Governance-Entscheidungen & Dokumentation:**
  - Welche Entscheidungen gehören ins Protokoll (z.B. DAO-Proposals)?
  - Welche Reports / Logs müssen im Nachgang geschrieben werden?
  - Wie die Incident-Historie für spätere Audits festgehalten wird.

Verknüpfungen:

- **ARCHITECT_OracleRequired_OperationsBundle_v051_r1.md**
- **ARCHITECT_OracleRequired_Telemetry_Status_v051_r1.md**
- **GOV_Oracle_PSM_Governance_v051_r1.md**
- **DEV11_PhaseB_Telemetry_TestPlan_r1.md**

---

### 3.2 Runtime Config Checklist

- **GOV_OracleRequired_Runtime_Config_Checklist_v051_r1.md**

Rolle:

- Checkliste für Governance/Ops, um sicherzustellen, dass die aktuelle
  Konfiguration eines Deployments **kompatibel mit OracleRequired** ist.

Kern-Fragen:

1. **PSM:**
   - Ist ein gültiger Oracle-Pricefeed konfiguriert?
   - Sind alle „Fallback“-Mechanismen entfernt, so dass
     `PSM_ORACLE_MISSING` ein **Explizit-Fehler** bleibt?
   - Sind Oracle-bezogene Parameter (Stale-Zeiten, Diff-Limits etc.)
     bewusst gesetzt und dokumentiert?
   - Greifen Telemetrie/Monitoring-Signale im Fehlerfall?

2. **BuybackVault (Strict Mode):**
   - Ist ein Oracle-Health-Modul konfiguriert und aktiv?
   - Ist das Modul so parametriert, dass es Real-World-Risiken sinnvoll
     abbildet (z.B. Stale-Preise, starke Preissprünge)?
   - Werden `BUYBACK_ORACLE_REQUIRED` und `BUYBACK_ORACLE_UNHEALTHY` als
     **Schutzmechanismen** verstanden und überwacht, nicht als „normale“ Zustände?

3. **Governance & Telemetrie:**
   - Ist klar dokumentiert, **wann** die Checklist ausgeführt wurde?
   - Sind Änderungen an Oracle-/Health-Konfiguration an die Community/DAO
     kommuniziert und nachvollziehbar?
   - Sind Telemetrie-/Monitoring-Kanäle (bzw. deren Fehlen) bewusst
     beschrieben?

Empfohlene Einsatzzeitpunkte:

- vor größeren Deployments / Upgrades,
- vor und nach wichtigen Governance-Entscheidungen,
- nach jeder Anpassung der Oracle-/Health-Parameter oder Konfiguration.

---

## 4. Index- und Navigations-Integration

DEV-12 stellt sicher, dass die neuen Artefakte an den relevanten Stellen
auffindbar sind:

- **docs/governance/index.md**
  - Sektion „OracleRequired – Incident Handling (v0.51.x)“
    - verweist auf `GOV_OracleRequired_Incident_Runbook_v051_r1.md`.
  - Sektion „OracleRequired – Runtime configuration checklist (v0.51.x)“
    - verweist auf `GOV_OracleRequired_Runtime_Config_Checklist_v051_r1.md`.

- **docs/reports/REPORTS_INDEX.md**
  - Sektion „OracleRequired – Incident handling (v0.51.x)“
    - verweist auf das Incident-Runbook als Governance-/Ops-Report.
  - Sektion „Release tagging – OracleRequired docs gate (v0.51+)“
    - verweist auf `RELEASE_TAGGING_GUIDE_v0.51.x.md` als menschliche
      Begleitdokumentation zu `scripts/check_release_status.sh`.

Damit entsteht ein konsistenter Navigations-Pfad:

> ARCHITEKTEN-BUNDLE → GOVERNANCE-DOKS → INCIDENT-RUNBOOK  
> → RUNTIME-CHECKLIST → REPORTS-INDEX → RELEASE-GUIDE

---

## 5. Zusammenspiel mit dem Release-Gate

Der bereits etablierte Release-Check:

- `./scripts/check_release_status.sh`

stellt sicher, dass für v0.51+ folgende Punkte erfüllt sind:

1. **Status-Reports vorhanden und nicht leer:**
   - `PROJECT_STATUS_EconomicLayer_v051`
   - `DEV60-72_BuybackVault_EconomicLayer`
   - `DEV74-76_StrategyEnforcement_Report`
   - `DEV87_Governance_Handover_v051`
   - `DEV89_Dev7_Sync_EconomicLayer_Security`
   - `DEV93_CI_Docs_Build_Report`

2. **OracleRequired-Dokumentations-Gate erfüllt:**
   - `ARCHITECT_OracleRequired_OperationsBundle_v051_r1`
   - `DEV94_Release_Status_Workflow_Report`
   - `BLOCK_DEV49_DEV11_OracleRequired_Block_r1`
   - `DEV11_OracleRequired_Handshake_r1`
   - `GOV_Oracle_PSM_Governance_v051_r1`

DEV-12 ergänzt dies durch:

- **Incident-Runbook**  
  (wie man reagiert, wenn OracleRequired verletzt wird)

- **Runtime-Checklist**  
  (wie man sicherstellt, dass die Konfiguration OracleRequired-kompatibel ist)

Ergebnis:

- Das Release-Gate stellt die **Dokumentations- und Struktur-Integrität** sicher.
- Incident-Runbook und Checklist stellen die **Betriebs-Integrität** sicher.

---

## 6. Offene Punkte und Risiken (aus Governance-Sicht)

Die folgenden Punkte bleiben bewusst als zukünftige Wellen markiert:

1. **Telemetrie-Implementierung (Phase B / Indexer & Monitoring)**  
   - DEV-11 Phase B liefert Konzepte und Testpläne, aber noch keine
     verpflichtende Implementierung.
   - Für Governance bedeutet das:
     - Telemetrie ist derzeit „Best Effort“ und hängt von der jeweiligen
       Integrations-/Ops-Umgebung ab.
     - Eine spätere DEV-Welle sollte eine Referenz-Umsetzung für Indexer
       und Dashboards definieren.

2. **A03 Rolling-Window-Boundary-Tests**  
   - Die Tests für bestimmte Zeitfensterrandfälle (BuybackVault / Caps)
     sind bewusst in eine spätere Hardening-Welle (Phase C) verschoben.
   - Governance sollte diese Lücke kennen und im Zweifel konservative
     Parameter bevorzugen, bis die Tests nachgezogen sind.

3. **Runtime-Config-Disziplin**  
   - Checklisten und Runbooks helfen nur, wenn sie tatsächlich
     verwendet werden.
   - Risiko:
     - Deployments oder Param-Änderungen ohne Nutzung der Checklist.
   - Empfehlung:
     - In Governance-/Ops-Playbooks festhalten, dass:
       - jede relevante Änderung + Nutzung der Checklist dokumentiert wird,
       - Incident-Runbooks als verpflichtender Teil von Incident-Postmortems
         gelten.

---

## 7. Empfehlungen an Architekten und Governance

1. **Toolkit als verbindlich anerkennen (v0.51.x)**  
   - Die folgenden Dokumente sollten als Teil des „verpflichtenden
     Governance-Toolkits“ für v0.51.x gelten:
     - `ARCHITECT_OracleRequired_OperationsBundle_v051_r1.md`
     - `ARCHITECT_OracleRequired_Telemetry_Status_v051_r1.md`
     - `GOV_Oracle_PSM_Governance_v051_r1.md`
     - `GOV_OracleRequired_Incident_Runbook_v051_r1.md`
     - `GOV_OracleRequired_Runtime_Config_Checklist_v051_r1.md`
     - `RELEASE_TAGGING_GUIDE_v0.51.x.md`

2. **Verfahrensregel: Keine v0.51+-Releases ohne dokumentierten Gate-Run**  
   - Vor jedem Release:
     - `./scripts/check_release_status.sh` ausführen,
     - Output und Exit-Code dokumentieren,
     - im Zweifel `RELEASE_TAGGING_GUIDE_v0.51.x.md` konsultieren.

3. **Verfahrensregel: OracleRequired-Änderungen nur mit Checklist + Runbook**  
   - Jede relevante Änderung an Oracle-/Health-Konfiguration:
     - vorher/nachher mit der Runtime-Checklist prüfen,
     - Incident-Runbook als Referenz für „Fehler-Betrieb“ verwenden.

4. **Planung zukünftiger DEV-Wellen**  
   - Dedizierte Welle für:
     - Telemetrie-Referenz-Implementierung (Indexers + Dashboards)
     - A03-Hardening (Boundary-Tests)
   - Governance sollte diese Themen frühzeitig im Roadmap-Prozess
     verankern.

---

## 8. Fazit

DEV-12 hat das OracleRequired-Prinzip im 1kUSD-Ökosystem von einem
reinen Code- und Doku-Konstrukt zu einem **operativen Standard** weiterentwickelt:

- Release-Gate schützt das Architekten-Bundle.
- Incident-Runbook definiert das Verhalten im Fehlerfall.
- Runtime-Checklist sichert die laufende Konfiguration ab.
- Indizes (Governance & Reports) machen das Toolkit auffindbar.

Damit steht für v0.51.x eine konsistente Basis, auf der spätere
Telemetrie- und Hardening-Wellen aufbauen können, ohne das zugrunde
liegende Governance-Modell neu erfinden zu müssen.
"""

path.write_text(content.lstrip("\n"), encoding="utf-8")
print("DEV12_Oracle_Governance_Toolkit_Status_v051_r1.md written.")
PY

echo "[DEV-12] $(date -u +"%Y-%m-%dT%H:%M:%SZ") add DEV-12 Oracle governance toolkit status report v0.51 (r1)" >> logs/project.log
echo "== DEV-12 step06: Oracle governance toolkit status report v051 written =="
