# DEV-94 – Release-Status Workflow (v0.51.x Tags)

## 1. Zielsetzung

DEV-94 ergänzt den Economic-Layer v0.51.0 um einen **rein prüfenden Release-Status-Workflow**:

- Stellt sicher, dass bestimmte **Status-/Report-Dateien vorhanden und nicht leer** sind,
  bevor ein Release-Tag im Schema `v0.51.*` als „sauber“ betrachtet wird.
- Greift **nicht** in Deployment- oder Tagging-Entscheidungen ein:
  - keine automatischen Tags,
  - kein automatisches Pages-Deploy,
  - kein Einfluss auf Contracts, PSM oder Economic Layer Logik.

DEV-94 hängt damit an die bereits vorhandenen Arbeiten an:

- **DEV-93 – CI Docs-Build Workflow** (`docs-build.yml`)
- **DEV-95 – Local Release Status Script** (`scripts/check_release_status.sh`)
- Status-/Strategy-Dokumente aus:
  - `DEV60-72_BuybackVault_EconomicLayer.md`
  - `DEV74-76_StrategyEnforcement_Report.md`
  - `PROJECT_STATUS_EconomicLayer_v051.md`
  - `DEV87_Governance_Handover_v051.md`
  - `DEV89_Dev7_Sync_EconomicLayer_Security.md`
  - `DEV93_CI_Docs_Build_Report.md`

---

## 2. Komponenten von DEV-94

### 2.1 GitHub Actions Workflow: `.github/workflows/release-status.yml`

- **Trigger**:
  - `on: push: tags: - "v0.51.*"`
- **Job**: `release-status`
  - Runner: `ubuntu-latest`
  - Schritte:
    1. `actions/checkout@v4`
    2. Ausführen von:
       ```bash
       chmod +x scripts/check_release_status.sh
       scripts/check_release_status.sh
       ```

Damit stellt DEV-94 sicher:

- Jedes Tag im Muster `v0.51.*` löst **automatisch** einen Status-Check aus.
- Falls zentrale Reports fehlen oder leer sind, schlägt der Workflow fehl.

### 2.2 Lokales Tool: `scripts/check_release_status.sh` (DEV-95)

DEV-95 hat ein **lokales Script** bereitgestellt, das die gleiche Logik abbildet:

- Prüft folgende Dateien auf Existenz und Non-Empty:

  - `docs/reports/PROJECT_STATUS_EconomicLayer_v051.md`
  - `docs/reports/DEV60-72_BuybackVault_EconomicLayer.md`
  - `docs/reports/DEV74-76_StrategyEnforcement_Report.md`
  - `docs/reports/DEV87_Governance_Handover_v051.md`
  - `docs/reports/DEV89_Dev7_Sync_EconomicLayer_Security.md`
  - `docs/reports/DEV93_CI_Docs_Build_Report.md`

- Exit-Codes:
  - `0` → alle Dateien vorhanden, nicht leer.
  - `1` → mindestens eine Datei fehlt oder ist leer.

DEV-94 nutzt dieses Script **unverändert**, um lokale und CI-Checks zu synchronisieren.

---

## 3. Typische Nutzungsflows

### 3.1 Vorbereiten eines v0.51.x-Tags (lokal)

Empfohlener Ablauf für Maintainer:

```bash
# 1) Status-/Reports lokal prüfen
scripts/check_release_status.sh

# 2) Nur bei Exit-Code 0 weitergehen:
#    Tag setzen und nach GitHub pushen
git tag v0.51.1
git push origin v0.51.1
Effekt:

Der lokale Lauf zeigt unmittelbar, ob die Dokumentation für das Release
formal konsistent ist (aus Sicht der definierten Status-/Report-Dateien).

Der anschließende Push auf v0.51.1 löst den GitHub Actions Workflow
Release Status Check aus, der dieselbe Prüfung im CI wiederholt.

3.2 Verhalten im CI bei Fehlern
Falls eine Datei fehlt oder leer ist:

scripts/check_release_status.sh gibt STATUS=1 zurück.

Der Job release-status in release-status.yml schlägt fehl.

Das Release-Tag bleibt technisch existierend, aber:

Der zugehörige Workflow wird als failed markiert.

Maintainer sehen direkt, dass die Status-Dokumentation unvollständig ist.

Wichtig:

DEV-94 löscht keine Tags, verschiebt keine Releases und führt keine Deployments aus.

Es handelt sich um einen Dokumentations-/Status-Gate, nicht um einen
Deployment-Gate.

4. Zusammenspiel mit anderen DEV-Arbeiten
4.1 Verbindung zu DEV-93 (Docs Build CI)
DEV-93:

Workflow .github/workflows/docs-build.yml

Führt mkdocs build auf push / pull_request nach main aus.

Stellt sicher, dass die Doku baubar ist.

DEV-94:

Workflow .github/workflows/release-status.yml

Führt scripts/check_release_status.sh auf v0.51.*-Tags aus.

Stellt sicher, dass definierte Status-/Report-Dateien konsistent vorhanden sind.

Zusammen:

DEV-93 prüft die technische Build-Fähigkeit der Doku.

DEV-94 prüft die inhaltliche Vollständigkeit definierter Kernreports
vor/zu einem v0.51.x-Release.

4.2 Verbindung zu Strategy-/Governance-Reports
Die folgenden Reports werden explizit durch DEV-94 abgesichert:

DEV60-72_BuybackVault_EconomicLayer.md
→ Dokumentiert die BuybackVault-Integration in den Economic Layer.

DEV74-76_StrategyEnforcement_Report.md
→ Beschreibt StrategyEnforcement Phase 1 (Guard, Flags, Governance-Sicht).

PROJECT_STATUS_EconomicLayer_v051.md
→ Aggregierter Status-Bericht zum Economic Layer v0.51.0.

DEV87_Governance_Handover_v051.md
→ Governance-Handover für das v0.51.0-Setup.

DEV89_Dev7_Sync_EconomicLayer_Security.md
→ Abgleich zwischen Economic Layer und Security/Risk-Schicht.

DEV93_CI_Docs_Build_Report.md
→ Beschreibung des Docs-Build-Workflows und seiner Rolle im CI.

Damit ist sichergestellt, dass jeder v0.51.x-Tag immer im Kontext der
aktuellen Economic-Layer-/Strategy-/Governance-Dokumentation steht.

5. Einschränkungen & zukünftige Erweiterungen
DEV-94 ist bewusst minimal-invasiv:

Kein Eingriff in:

Contracts,

PSM,

Vaults,

Deployment-Pipeline,

Docker-/Multi-Arch-Builds,

Pages-Deploy.

Fokus ausschließlich auf:

Sichtbarkeit der Releases,

Konsistenz der Kern-Status-/Report-Dateien.

Mögliche nächste Schritte (separate Tickets):

Erweiterter Release-Gate für zukünftige Versionen:

Analoge Check-Skripte für v0.52.* u.ä.

Erweiterte Dateienliste (z.B. neue Strategy-/Risk-Reports).

Integration in einen „Release Dashboard“-View:

Verknüpfung von Tag, CI-Status, Report-Dateien und Docs-Build
in einem konsolidierten Überblick.

Optionale Kopplung an Pages Deploy:

Nur wenn alle Checks (DEV-93, DEV-94) grün sind, wird ein manueller
Pages-Deploy empfohlen oder erlaubt.

6. Zusammenfassung für Maintainer
DEV-94 ergänzt die CI um einen Release-Status-Workflow für v0.51.* Tags.

Kernfunktion:

Ausführen von scripts/check_release_status.sh im CI,

Sicherstellen, dass definierte Status-/Reports vorhanden und nicht leer sind.

DEV-94 arbeitet Hand in Hand mit:

DEV-93 (Docs-Build CI)

DEV-95 (lokales Status-Script)

den Strategy-/Governance-Reports (DEV60-72, DEV74-76, DEV87, DEV89, DEV93).

Keine Änderungen an Economic Layer, PSM oder BuybackVault-Logik:

Die Maßnahme ist rein dokumentations- und prozessbezogen.

Empfehlung:

Vor jedem neuen v0.51.x-Tag:

Lokal scripts/check_release_status.sh laufen lassen.

Tag setzen & pushen.

Release-Status-Workflow in GitHub beobachten.

Damit bildet DEV-94 einen klaren, nachvollziehbaren Status-Gate,
ohne die Flexibilität des manuellen Release-Prozesses einzuschränken.
