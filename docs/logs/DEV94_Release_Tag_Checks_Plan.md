# DEV-94 – Release-Tag Checks Plan

## 1. Kontext

Mit DEV-74 bis DEV-76 wurde der StrategyEnforcement-Layer im BuybackVault
implementiert und durch Tests/Dokumentation abgesichert. DEV-87 und DEV-89
haben Governance- und Security-Sync-Reports geliefert. DEV-93 fügt nun einen
Standalone **Docs-Build-Workflow** (MkDocs) in der CI hinzu.

Nächster naheliegender Infra-Schritt ist ein Plan, wie zukünftige **Release-Tags**
(z.B. `v0.51.0`, `v0.52.0`) mit verbindlichen Status-/Report-Dateien verknüpft
werden können – ohne jetzt schon den tatsächlichen CI-Mechanismus zu bauen.

Dieses Dokument beschreibt genau diesen Plan.

---

## 2. Ziele der Release-Tag-Checks

Bei einem Release-Tag (z.B. `v0.51.0`, `v0.52.0`) sollen definierte Dateien
mindestens auf **Existenz und Aktualität** überprüft werden. Ziele:

- Sicherstellen, dass der veröffentlichte Stand durch passende Reports
  dokumentiert ist.
- Minimieren des Risikos, dass ein Tag ohne aktualisierte Status-Files
  gesetzt wird.
- Klare Trennung zwischen:
  - **Economic Layer / Contract Logic** (unverändert durch diese Checks).
  - **Meta-Ebene**: Status, Reports, Doku, Governance-Handovers.

---

## 3. Kandidaten für Release-Tag-Checks

### 3.1 Projekt-Status-Files

- `docs/reports/PROJECT_STATUS_EconomicLayer_v051.md`
  - Gesamtstatus Economic Layer v0.51.0
  - Referenzen auf BuybackVault, PSM, Oracle, Guardian etc.
- Für zukünftige Releases:
  - `PROJECT_STATUS_EconomicLayer_v052.md` (oder analoges Naming),
    sobald v0.52.x offiziell wird.

**Check-Idee:**

- Existiert das Status-File für die Version, die getaggt wird?
- Enthält es eine explizite Aussage darüber, ob StrategyEnforcement aktiv
  oder als Preview/opt-in geführt wird?

### 3.2 DEV-Reports (BuybackVault / Strategy / Governance / Security)

Relevante Files u.a.:

- `docs/reports/DEV60-72_BuybackVault_EconomicLayer.md`
- `docs/reports/DEV74-76_StrategyEnforcement_Report.md`
- `docs/reports/DEV87_Governance_Handover_v051.md`
- `docs/reports/DEV89_Dev7_Sync_EconomicLayer_Security.md`
- `docs/reports/DEV93_CI_Docs_Build_Report.md`

**Check-Idee:**

- Für eine bestimmte Release-Linie (z.B. v0.51.x) ist definiert, welche
  Reports mindestens vorhanden sein müssen.
- Optional: Warnung oder Blocker, wenn ein erwarteter Report fehlt.

### 3.3 Risk- / Security- / Testing-Dokumente

- `docs/risk/proof_of_reserves_spec.md`
- `docs/risk/collateral_risk_profile.md`
- `docs/risk/emergency_depeg_runbook.md`
- `docs/security/audit_plan.md`
- `docs/security/bug_bounty.md`
- `docs/testing/stress_test_suite_plan.md`

**Check-Idee:**

- Sicherstellen, dass diese Dateien vorhanden sind und nicht leer sind
  (z.B. minimale Längen-Prüfung).
- Optional: pro Release-Linie definieren, welche Files „must have“ sind,
  bevor ein Tag als „release-ready“ gilt.

---

## 4. Mögliche technische Umsetzung (nur Plan)

> Wichtig: DEV-94 beschreibt **nur den Plan**. Die tatsächliche CI-Pipeline
> (GitHub Actions) wird in separaten INFRA-Tickets umgesetzt.

### 4.1 GitHub Actions Workflow (Konzept)

- Neuer Workflow, z.B.:
  - `.github/workflows/release-tag-checks.yml`
- Trigger:
  - `on: push: tags: ["v*"]`
- Steps (high level):
  1. Checkout Repo
  2. Eindeutige Version aus Tag ermitteln (z.B. `v0.51.0` → `0.51.0`)
  3. Skript ausführen (z.B. `scripts/check_release_status.sh`), das:
     - prüft, ob `PROJECT_STATUS_...`-File für diese Major/Minor-Version existiert.
     - prüft, ob definierte DEV-Reports vorhanden sind.
     - bei Bedarf einfache inhaltliche Checks macht (nicht leer / enthält bestimmtes Pattern).

### 4.2 Mapping Version → Status-/Report-Dateien

Beispiele:

- Tag `v0.51.0` / `v0.51.1`:
  - Muss:
    - `PROJECT_STATUS_EconomicLayer_v051.md`
    - `DEV60-72_BuybackVault_EconomicLayer.md`
    - `DEV74-76_StrategyEnforcement_Report.md` (als Preview-Beschreibung)
    - `DEV87_Governance_Handover_v051.md`
    - `DEV89_Dev7_Sync_EconomicLayer_Security.md`
    - `DEV93_CI_Docs_Build_Report.md`
- Tag `v0.52.0` (hypothetisch):
  - analoges Set, aber mit aktualisiertem Projekt-Status-File und ggf.
    weiteren Reports.

Die konkrete Mapping-Tabelle soll in einem separaten, leicht anpassbaren
File gepflegt werden (z.B. YAML / JSON unter `ops/config/`).

---

## 5. Abgrenzung zu anderen Infra-Tickets

Dieses Dokument **ersetzt nicht**:

- Docker/Multi-Arch-Design und Build-Spezifikation.
- Konkrete CI-Workflows für Docker-Push, Registry-Handling, etc.
- Pages-/Preview-Flows (Deploys auf `gh-pages`).

Stattdessen ist es eine Ergänzung zu:

- DEV78 – CI/Docs-Integration (Checkliste).
- DEV79 – CI-Inventory und Dev7-Infra-Plan.
- DEV93 – Docs-Build-Workflow + Badge.

DEV-94 liefert damit die textuelle Grundlage, um in späteren Patches:

- Einen echten `release-tag-check`-Workflow zu bauen.
- Die Versionierung und den Status des Economic Layers eng mit Doku/Reports
  zu verzahnen.

---

## 6. Empfehlung für Maintainer / Dev7

Kurzfristig:

- DEV-94 kann als **Plan-Dokument** genutzt werden, wenn Release-Tags
  (z.B. für v0.51.x) gesetzt werden.
- Es hilft, manuelle Checklisten zu strukturieren, selbst wenn es noch
  keinen automatisierten Workflow gibt.

Mittelfristig:

- In einem separaten INFRA-Ticket:
  - `release-tag-checks.yml` als GitHub-Action ergänzen.
  - Ein einfaches Check-Skript implementieren, das die hier beschriebenen
    Prüfungen durchführt.

Langfristig:

- Verknüpfung von:
  - Status-/Report-Files,
  - CI-Checks,
  - Pages-Deploy,
  - ggf. externen Monitoring-/Dashboard-Komponenten.

DEV-94 ändert bewusst **keine** on-chain Logik und keinen Economic-Layer-Code.
Es ist ein Planungsbaustein für einen robusten, dokumentationsgestützten
Release-Prozess.
