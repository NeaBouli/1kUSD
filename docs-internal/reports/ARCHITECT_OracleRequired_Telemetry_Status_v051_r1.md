# ARCHITECT Status Report – OracleRequired & Telemetry (v0.51.x)

**System:** 1kUSD – Economic Layer v0.51.x  
**Thema:** OracleRequired Bundle, Release-Gates und DEV-11 Phase B Telemetrie  
**Stand:** main nach PRs #62–#69, Release-Check grün

---

## 1. Technischer Zustand (Code, Tests, Docs-Build)

### 1.1 Code & Tests

- Branch: `main` (lokal == `origin/main`), Working Tree clean (nach Aufräumen der Forge-Artefakte).
- `./scripts/check_release_status.sh` läuft komplett durch und triggert:
  - `forge test`
    - 21 Test-Suites, 74 Tests, alle grün, u. a.:
      - PSM-Regression: Base, Limits, Fees, Spreads, Flows
      - OracleRegression: Watcher + Health
      - Guardian-Stacks: OraclePropagation, PSMPropagation, PSMEnforcement, PSMUnpause, Integration
      - `BuybackVault.t.sol`: A01–A03-Safety inkl. OracleGate-Tests
      - TreasuryVault, SafetyNet, FeeRouter, DAO-Timelock (Placeholder grün)
  - `mkdocs build`
    - Docs bauen ohne Fehler; zahlreiche technische Seiten sind bewusst **nicht** in der `nav`-Navigation verlinkt (Notes, ADRs, Reports etc.).

### 1.2 OracleRequired im Code (PSM & BuybackVault)

Der in früheren DEV-Wellen implementierte OracleRequired-Grundsatz ist jetzt klar durchgezogen und dokumentarisch verankert:

- **PegStabilityModule (PSM)**
  - Kein Fallback mehr auf einen impliziten 1e18-Preis.
  - Ohne gültigen Oracle-Pricefeed werden PSM-Operationen mit `PSM_ORACLE_MISSING` blockiert.
  - Oracle-Pricefeed ist damit eine **harte Pflichtbedingung** für Mint/Redeem im PSM.

- **BuybackVault**
  - Strikter Oracle-Gate für Buybacks:
    - Fehlendes oder deaktiviertes Health-Modul: `BUYBACK_ORACLE_REQUIRED`.
    - Ungesunder Oracle-Status laut Health-Modul: `BUYBACK_ORACLE_UNHEALTHY`.
  - Der A01–A03-Safety-Stack (Limits, Caps etc.) bleibt unverändert; der OracleGate liegt **zusätzlich** darüber.

Die aktuelle DEV-Welle (DEV-11 / DEV-94) hat diesen Status nicht verändert, sondern **explizit dokumentiert und operativ eingebunden**.

---

## 2. OracleRequired Release-Gate – Script & Human Flow

### 2.1 Script: `scripts/check_release_status.sh`

Aktueller Ablauf:

1. (Teilweise) `forge test`  
2. `mkdocs build`  
3. **Status-Docs Check** – folgende Reports müssen existieren und nicht leer sein:
   - `docs/reports/PROJECT_STATUS_EconomicLayer_v051.md`
   - `docs/reports/DEV60-72_BuybackVault_EconomicLayer.md`
   - `docs/reports/DEV74-76_StrategyEnforcement_Report.md`
   - `docs/reports/DEV87_Governance_Handover_v051.md`
   - `docs/reports/DEV89_Dev7_Sync_EconomicLayer_Security.md`
   - `docs/reports/DEV93_CI_Docs_Build_Report.md`
   - Falls einer fehlt oder leer ist: `[ERROR]` und Exit Code ≠ 0.

4. **OracleRequired Docs Gate (neu, DEV-94)**  
   Es werden fünf OracleRequired-bezogene Dokumente geprüft:

   - `docs/reports/ARCHITECT_OracleRequired_OperationsBundle_v051_r1.md`
   - `docs/reports/DEV94_Release_Status_Workflow_Report.md`
   - `docs/reports/BLOCK_DEV49_DEV11_OracleRequired_Block_r1.md`
   - `docs/reports/DEV11_OracleRequired_Handshake_r1.md`
   - `docs/governance/GOV_Oracle_PSM_Governance_v051_r1.md`

   Verhalten:

   - Jedes vorhandene und nicht leere Dokument →  
     `[OK] OracleRequired release gate: report present: …`
   - Fehlt eine Datei oder ist leer →  
     `[ERROR] OracleRequired release gate: …`  
     Script bricht mit Exit Code ≠ 0 ab.

5. **Abschluss-Meldung (bei Erfolg)**

   > You can safely proceed to create a v0.51+ release tag from this perspective (status + OracleRequired docs).

### 2.2 Charakter des Gates

- Das OracleRequired-Gate ist **reine Dokumentations-Validierung**:
  - Es prüft keine On-Chain-Zustände.
  - Es erzwingt, dass das Architekten-Bundle und die Governance-/DEV-Reports vollständig und gepflegt sind.
- Für v0.51+ gilt damit:
  - Ohne OracleRequired-Doku-Bundle **kein zulässiger Release-Tag**.
  - Release-Manager können sich nicht versehentlich über die Architekten-Leitplanken hinwegsetzen.

---

## 3. Docs-Matrix – OracleRequired Verankerung

Diese DEV-Welle hat OracleRequired in mehreren zentralen Dokumenten verankert und untereinander verlinkt.

### 3.1 Release-Tagging Guide

- **`docs/logs/RELEASE_TAGGING_GUIDE_v0.51.x.md`**
  - Neue Sektion **„OracleRequired docs gate (v0.51+)“**.
  - Klarer Auftrag an Release-Manager:
    - `./scripts/check_release_status.sh` MUSS mit Exit Code 0 laufen.
    - Die fünf OracleRequired-Dokumente müssen im Output explizit auftauchen.
    - Jeder `[ERROR] OracleRequired release gate` oder Exit Code ≠ 0 ist ein **harter Stopp** für Tagging.

- **`docs/dev/DEV94_How_to_cut_a_release_tag_v051.md`**
  - Gleiche inhaltliche Botschaft in DEV-94-Sprache:
    - Schritt-für-Schritt-HowTo für Release-Manager.
    - OracleRequired-Gate ist ein **Pflichtschritt** im Release-Prozess.

### 3.2 Reports-Index

- **`docs/reports/REPORTS_INDEX.md`**
  - Neuer Eintrag „**Release tagging – OracleRequired docs gate (v0.51+)**“.
  - Verlinkt auf:
    - `docs/logs/RELEASE_TAGGING_GUIDE_v0.51.x.md`
  - Ordnet die Rolle des OracleRequired-Bundles im Reports-Universum ein.

### 3.3 OracleRequired-Bundle selbst

Folgende Dokumente bilden das OracleRequired-Bundle, das nun Gate-Pflicht ist:

- `ARCHITECT_OracleRequired_OperationsBundle_v051_r1.md`
- `DEV94_Release_Status_Workflow_Report.md`
- `BLOCK_DEV49_DEV11_OracleRequired_Block_r1.md`
- `DEV11_OracleRequired_Handshake_r1.md`
- `GOV_Oracle_PSM_Governance_v051_r1.md`

**Kette:**

> Architekt-Bundle → Governance-Doc → DEV-Handshake → Release-Script → Release-HowTo → Reports-Index

---

## 4. DEV-11 Phase B Telemetrie – Preview-Welle

Ziel von DEV-11 Phase B:  
OracleRequired soll nicht nur on-chain durchgesetzt, sondern auch **off-chain klar sichtbar, auswertbar und auditierbar** sein.

Diese DEV-Welle ist bewusst **Docs-/Planungs-only**, ohne Änderungen an Solidity oder CI.

### 4.1 Testplan

- **`docs/dev/DEV11_PhaseB_Telemetry_TestPlan_r1.md`**
  - Definiert Telemetrie-Ziele für:
    - Solidity-/Foundry-Tests:
      - Reason Codes und Events als Observability-Signale.
      - Keine Duplikation der Business-Logik; Tests prüfen nur das Vorhandensein und die Deterministik der Signale.
    - Indexer-/Monitoring-Tests:
      - Event-Decoding
      - Revert-Reason-Decoding
      - Abgeleitete Flags für OracleRequired-Verletzungen
      - Minimaler Datenmodell-Rahmen (Preview)

  - Fokus-Reason-Codes:
    - `PSM_ORACLE_MISSING`
    - `BUYBACK_ORACLE_REQUIRED`
    - `BUYBACK_ORACLE_UNHEALTHY`

  - Scope:
    - Keine Änderungen an Economic-Layer-Logik.
    - Keine konkrete Monitoring-Stack-Vorgabe (Grafana, Prometheus etc.).
    - A03-Rolling-Window-Grenzfälle explizit **geparkt** für spätere Hardening-Welle (Phase C).

### 4.2 Implementation Backlog

- **`docs/dev/DEV11_Implementation_Backlog_SolidityTrack_r1.md`**
  - Neue Phase-B-Notiz:
    - Verweist auf den Telemetrie-Testplan.
    - Hebt Oracle-bezogene Reason Codes als **erste-Klasse-Observability-Signale** hervor.
    - Markiert A03-Rolling-Window-Grenzfall-Tests explizit als „später (Phase C)“, damit sie nicht vergessen werden.

### 4.3 Integrations-Übersicht

- **`docs/integrations/index.md`**
  - Neue Sektion (Phase-B-Preview) zur OracleRequired-Telemetrie:
    - Für Integratoren: Reason Codes wie `PSM_ORACLE_MISSING`, `BUYBACK_ORACLE_REQUIRED`, `BUYBACK_ORACLE_UNHEALTHY` als Vertrag zwischen Economic-Layer und Off-Chain-Monitoring.
    - Verweist auf:
      - DEV-11 Phase B Telemetrie-Testplan
      - DEV-11 Backlog
      - OracleRequired Operations Bundle

### 4.4 Indexer BuybackVault

- **`docs/indexer/indexer_buybackvault.md`**
  - Ergänzt um eine Phase-B-Preview-Sektion:
    - Indexer SOLLTEN:
      - Reason Codes wie `BUYBACK_ORACLE_REQUIRED` und `BUYBACK_ORACLE_UNHEALTHY` explizit speichern.
      - Ein Flag wie `oracle_required_blocked = true` ableiten, wenn ein Buyback an OracleRequired scheitert.
      - Diese Flags und Reason Codes in Dashboards/Reports sichtbar machen.
    - Verweise auf:
      - `DEV11_PhaseB_Telemetry_TestPlan_r1.md`
      - Integrations-Index
      - Architekten-Bundle

**Ergebnis:**  
Telemetrie-Phase B ist dokumentarisch vollständig vorbereitet, ohne Implementierung zu erzwingen. Integratoren und zukünftige DEV-11-Wellen bekommen einen klaren Startpunkt.

---

## 5. Offene Punkte & Risiken (bewusst geparkt)

### 5.1 A03 Rolling-Window-Boundary-Tests

- A03-Grenzfälle (Fensterwechsel, Reset-Zeitpunkte, Randzeiten) sind derzeit **nicht** implementiert.
- Sie sind in mehreren Docs explizit als zukünftige Hardening-Aufgabe markiert:
  - DEV-11 Phase C oder eine dedizierte Test-Hardening-Welle.
- Risiko:
  - Ohne diese Tests könnten extreme Edge-Cases unerkannt bleiben.
- Gegenmaßnahme:
  - Explizite DEV-Planung für Phase C mit Fokus auf A03-Grenzfälle.

### 5.2 Telemetrie-Implementierung (Indexers / Dashboards)

- Aktueller Stand:
  - Nur Konzepte, Testplan und Guidelines (Phase-B-Preview).
  - Noch keine verbindlichen Indexer-Schemas oder Dashboard-Definitionen.
- Risiko:
  - Ohne spätere Implementierungswelle bleibt Telemetrie-Potenzial ungenutzt.
- Gegenmaßnahme:
  - Eigene DEV-11 Welle für:
    - konkrete Indexer-Implementierung
    - Metriken / Dashboards
    - Alarmierung auf OracleRequired-Verletzungen.

### 5.3 Release-Prozess-Disziplin

- Technisch ist das OracleRequired-Gate sauber integriert.
- Risiko besteht nur, wenn:
  - Release-Manager `./scripts/check_release_status.sh` nicht ausführen, oder
  - außerhalb des definierten Flows Tags erstellt werden.
- Empfehlung:
  - In Governance- / Ops-Playbooks festhalten:
    - Kein v0.51+-Tag ohne dokumentierten Run von `./scripts/check_release_status.sh`.
    - Output und Exit-Code sollten bei wichtigen Releases protokolliert werden.

---

## 6. Empfehlungen an die Architekten

1. **OracleRequired-Bundle als „locked in“ für v0.51 betrachten**
   - Für v0.51 ist klar:
     - PSM ohne gültigen Oracle-Feed → `PSM_ORACLE_MISSING` → Operation verboten.
     - BuybackVault ohne gesundes Oracle-Health-Modul → `BUYBACK_ORACLE_REQUIRED` / `BUYBACK_ORACLE_UNHEALTHY` → Buyback verboten.
   - Release-Gates stellen sicher, dass die zugehörige Dokumentation nicht stillschweigend erodiert.

2. **DEV-11 Phase B Telemetrie als Preview-Welle formell absegnen**
   - Scope bewusst auf Dokumentation, Testplan und Integrationshinweise begrenzt lassen.
   - Im nächsten Schritt separate DEV-Wellen definieren:
     - Phase B Implementierung (Indexers, Telemetry Code, Alerts).
     - Phase C Hardening (A03-Grenzfälle, zusätzliche Invarianten).

3. **Nächste sinnvolle Schritte**

   a. Architekten-Abnahme dieses Status-Reports (OracleRequired + Telemetrie Preview).  
   b. Planung der folgenden Aufgaben:
      - DEV-11 Phase B Implementierung (konkrete Telemetrie).
      - DEV-11 Phase C Test-Hardening (A03 etc.).
   c. Vorbereitung einer kontrollierten v0.51.x-Tagging-Übung:
      - `./scripts/check_release_status.sh` als Pflichtschritt.
      - Ergebnis (inkl. OracleRequired-Gate) als Teil des Release-Logs archivieren.

---
