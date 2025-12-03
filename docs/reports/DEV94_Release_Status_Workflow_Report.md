# DEV-94 – Release Status Workflow (v0.51.x)

> Scope: CI-Workflow `release-status.yml` + Script
> `scripts/check_release_status.sh` für v0.51.x Release-Tags.

---

## 1. Kontext & Zielsetzung

Mit DEV-94 wurde ein **Release-Status-Check** eingeführt, der sicherstellt,
dass vor (bzw. beim) Setzen eines `v0.51.x`-Tags die wichtigsten
Status- und Report-Files vorhanden und nicht leer sind.

Ziele:

- **Disziplinierter Release-Prozess** ohne harte Automatisierung:
  - Tags bleiben **manuell**, aber CI überwacht den dokumentarischen Zustand.
- **Frühe Sichtbarkeit** von fehlenden Reports:
  - Ein fehlender Status-Report führt zu einem **roten CI-Run** auf dem Tag.
- **Keine Änderungen** an Economic Layer / Contracts / PSM:
  - Nur CI-/Infra-Schicht betroffen.

DEV-94 baut damit auf den Plänen aus:

- `docs/logs/DEV94_Infra_Release_Tag_Checks_Plan.md`
- `docs/logs/DEV94_Release_Tag_Checks_Plan.md`

und konkretisiert diese als erste, schlanke Umsetzung.

---

## 2. Workflow: .github/workflows/release-status.yml

Der neue Workflow liegt unter:

- `.github/workflows/release-status.yml`

**Trigger:**

```yaml
on:
  push:
    tags:
      - "v0.51.*"
Damit läuft der Workflow nur, wenn ein Tag des Musters v0.51.*
gepusht wird (z.B. v0.51.0, v0.51.1, …).

Job-Übersicht:

yaml
Code kopieren
jobs:
  release-status:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: |
          chmod +x scripts/check_release_status.sh
          scripts/check_release_status.sh
Der Job:

Checkt das Repo aus.

Markiert scripts/check_release_status.sh als ausführbar.

Führt das Script aus.

Der Exit-Code des Scripts entscheidet über grün vs rot.

3. Script: scripts/check_release_status.sh
Das Script wurde in DEV-95 angelegt und von DEV-94 als CI-Baustein
wiederverwendet:

Pfad: scripts/check_release_status.sh

3.1 Zweck
Lokales Tool für Maintainer:

scripts/check_release_status.sh vor einem Taglauf auszuführen
gibt sofort Feedback zum Status der wichtigsten Reports.

CI-Baustein:

Im release-status-Workflow identisch ausgeführt.

3.2 Geprüfte Dateien
Aktuell werden folgende Files geprüft:

docs/reports/PROJECT_STATUS_EconomicLayer_v051.md

docs/reports/DEV60-72_BuybackVault_EconomicLayer.md

docs/reports/DEV74-76_StrategyEnforcement_Report.md

docs/reports/DEV87_Governance_Handover_v051.md

docs/reports/DEV89_Dev7_Sync_EconomicLayer_Security.md

docs/reports/DEV93_CI_Docs_Build_Report.md

Für jede Datei gilt:

Existenz-Check.

Nicht-Leer-Check (Dateigröße > 0).

Beispielhafte Ausgabe:

text
Code kopieren
== 1kUSD Release Status Check ==

[OK]      docs/reports/PROJECT_STATUS_EconomicLayer_v051.md
[OK]      docs/reports/DEV60-72_BuybackVault_EconomicLayer.md
...
All required status/report files are present and non-empty.
You can safely proceed to create a release tag (from this perspective).
Im Fehlerfall:

Entsprechende Zeilen mit [MISSING] oder [EMPTY].

Exit-Code 1 → CI-Job schlägt fehl.

4. Verhalten im CI auf v0.51.x-Tags
Ablauf, wenn ein Maintainer ein Tag wie v0.51.0 pusht:

GitHub Actions triggert release-status.yml.

Repo wird ausgecheckt (Stand des Tags).

scripts/check_release_status.sh läuft:

Wenn alle Reports da sind → Job grün.

Wenn etwas fehlt → Job rot.

Wichtig:

Das Tag selbst wird nicht verhindert oder zurückgenommen.

Maintainer sehen aber sofort im CI, ob der Dokumentations-Status
den Erwartungen entspricht.

Damit bleibt der Prozess manuell kontrolliert, aber
transparent überwacht.

5. Zusammenspiel mit anderen DEV-Tickets
DEV-93 – Docs-Build Workflow

Sicherstellt mit .github/workflows/docs-build.yml, dass
mkdocs build auf main funktioniert.

Bereitstellung eines „Docs Build“-Badges im README.md.

DEV-94 – Release-Status

Fügt Tag-basierte Checks für wichtige Reports hinzu.

Baut auf den Plänen in den DEV94-Logfiles auf.

Nutzt das in DEV-95 eingeführte Script
scripts/check_release_status.sh.

DEV-97 – Release Tagging Guide (v0.51.x)

Beschreibt den manuellen Tagging-Flow für v0.51.x.

Kann auf dieses DEV-94-Report-Dokument verweisen, um zu erklären,
warum der release-status-Workflow existiert und was er prüft.

Gesamtbild:

DEV-93: Doku-Build-Qualität.

DEV-94/95: Release-Status-Qualität (Reports/Status-Files).

DEV-97: Handbuch für Maintainer, wie Tags sauber gesetzt werden.

6. Grenzen & mögliche Erweiterungen
Aktueller Scope ist bewusst minimal-invasiv:

Nur Existenz und Nicht-Leerheit der Files.

Keine inhaltliche Validierung (z.B. Version, Datum, Inhaltsschema).

Nur für Tags im Schema v0.51.*.

Mögliche spätere Erweiterungen (separate Tickets):

Content-Checks:

Z.B. YAML/Frontmatter mit version: v0.51.0 im Status-File
prüfen.

Generalisierung auf künftige Versionen:

z.B. Pattern v0.* mit dynamischeren Checks.

Verzahnung mit Release-Notes:

Prüfen, ob für ein Tag das passende Release-Doc
unter docs/releases/ existiert.

Kombination mit Docs-Build:

Optionaler Workflow, der bei Release-Tags zusätzlich
mkdocs build ausführt.

7. Empfehlung für Maintainer
Kurzfassung:

Vor einem v0.51.x-Tag:

Lokal scripts/check_release_status.sh ausführen.

Sicherstellen, dass relevante Reports aktualisiert sind.

Nach dem Push des Tags:

Release Status Check Workflow im CI prüfen:

Grün → dokumentarischer Status OK.

Rot → Reports anpassen und ggf. Tag korrigieren bzw.
neuen Tag mit Fix-Version setzen.

DEV-94 definiert damit einen ersten, klaren Standard:
Jeder v0.51.x-Tag ist mit einem geprüften Minimum an
Status-/Report-Dokumentation verknüpft – ganz ohne Eingriff in
den ökonomischen Kern des Protokolls.
