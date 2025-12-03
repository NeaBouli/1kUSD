#!/usr/bin/env bash
set -euo pipefail

REPORT="docs/reports/DEV94_Release_Status_Workflow_Report.md"
LOG_FILE="logs/project.log"

mkdir -p "$(dirname "$REPORT")" "$(dirname "$LOG_FILE")"

if [[ -f "$REPORT" ]]; then
  echo "Report $REPORT already exists; not overwriting."
  exit 0
fi

cat > "$REPORT" <<'MD'
# DEV-94 – Release Status Workflow (v0.51.x Tags)

**Rolle:** DEV-7 / Infra & CI  
**Scope:** Release-Tag-Checks für das Economic Layer v0.51.x

---

## 1. Kontext & Ziel

Das Economic Layer v0.51.0 ist als stabile Basis gesetzt.  
Für Release-Tags im Bereich `v0.51.*` soll sichergestellt werden, dass zentrale
Status- und Report-Dateien:

- **vorhanden** sind und  
- **nicht leer** sind,

bevor ein Release als „sauber dokumentiert“ betrachtet wird.

DEV-94 ergänzt dazu einen schlanken CI-Workflow:

- löst **nur bei Tags** vom Muster `v0.51.*` aus,
- ruft ein lokales Release-Status-Script auf,
- fasst die Checks in einem einzigen, übersichtlichen Job zusammen.

---

## 2. Technische Umsetzung

### 2.1 Workflow: `.github/workflows/release-status.yml`

Der Workflow wird auf `push` von Tags der Form `v0.51.*` getriggert:

```yaml
name: Release Status Check

on:
  push:
    tags:
      - "v0.51.*"

jobs:
  release-status:
    name: Run release status script for v0.51.x tags
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Run release status check
        run: |
          chmod +x scripts/check_release_status.sh
          scripts/check_release_status.sh
Wesentliche Eigenschaften:

Kein Build / Deploy – der Job ist rein prüfend.

Keine Contract-Änderungen – es wird nur Doku-/Report-Status geprüft.

Tag-basiert – normale Branch-Pushes sind nicht betroffen.

2.2 Lokales Script: scripts/check_release_status.sh (DEV-95)
Der Workflow ruft ein separates Shell-Script auf, eingeführt in DEV-95:

bash
Code kopieren
== 1kUSD Release Status Check ==

[OK]      docs/reports/PROJECT_STATUS_EconomicLayer_v051.md
[OK]      docs/reports/DEV60-72_BuybackVault_EconomicLayer.md
[OK]      docs/reports/DEV74-76_StrategyEnforcement_Report.md
[OK]      docs/reports/DEV87_Governance_Handover_v051.md
[OK]      docs/reports/DEV89_Dev7_Sync_EconomicLayer_Security.md
[OK]      docs/reports/DEV93_CI_Docs_Build_Report.md
Bei fehlenden oder leeren Dateien setzt das Script einen non-zero exit code.

Dadurch schlägt der release-status-Job fehl.

Maintainer erhalten im CI-Log eine klare Liste, welche Datei nachgezogen
oder vervollständigt werden muss.

3. Abgedeckte Dateien (v0.51.x Scope)
Aktuell prüft scripts/check_release_status.sh insbesondere:

docs/reports/PROJECT_STATUS_EconomicLayer_v051.md
→ Gesamtstatus Economic Layer v0.51.0

docs/reports/DEV60-72_BuybackVault_EconomicLayer.md
→ BuybackVault / Economic Layer Hauptreport

docs/reports/DEV74-76_StrategyEnforcement_Report.md
→ StrategyEnforcement Phase-1 (Guard, Errors, Governance)

docs/reports/DEV87_Governance_Handover_v051.md
→ Governance-Handover v0.51.0

docs/reports/DEV89_Dev7_Sync_EconomicLayer_Security.md
→ Sync-Report zwischen Economic Layer & Security/Risk (DEV-8/DEV-7)

docs/reports/DEV93_CI_Docs_Build_Report.md
→ Docs-Build-Workflow (DEV-93) & CI-Dokustatus

Damit wird abgedeckt:

Ökonomischer Kern (PSM / BuybackVault),

StrategyEnforcement-Preview,

Governance & Security Hand-off,

CI/Doku-Infrastruktur.

4. Interaktion mit anderen DEV-Tickets
DEV-93 – Docs-Build Workflow

.github/workflows/docs-build.yml prüft mkdocs build auf main.

Dient als kontinuierliche Doku-Qualitätssicherung.

DEV-95 – Local Release Status Script

scripts/check_release_status.sh kann lokal vor einem Tag ausgeführt
werden (gleiche Logik wie im CI).

DEV-97 – Manuelle Release-Tagging-Guides

docs/logs/RELEASE_TAGGING_GUIDE_v0.51.x.md beschreibt den manuellen
Ablauf inkl. Empfehlung, vor dem Tag:

scripts/check_release_status.sh

forge test

mkdocs build
manuell zu fahren.

DEV-94 fügt sich als CI-Brücke ein:

Lokal: Maintainer können das Script direkt ausführen.

Remote (CI): Der gleiche Check läuft automatisch bei v0.51.*-Tags.

5. Nutzung / Workflow für Maintainer
Empfohlene Reihenfolge vor einem Tag z.B. v0.51.1:

Lokal prüfen

forge test

mkdocs build

scripts/check_release_status.sh

Release-Tag setzen

git tag v0.51.1

git push origin v0.51.1

CI prüfen

In GitHub Actions:

Release Status Check für Tag v0.51.1.

Wenn der Job grün ist:

GitHub-Release + Release-Notes anlegen

auf die relevanten Reports verlinken.

Fehlende oder leere Status-Files führen zu einem roten CI-Run und signalisieren,
dass vor einem „offiziellen“ Release noch Doku-/Status-Arbeit nötig ist.

6. Grenzen & mögliche Erweiterungen
DEV-94 ist bewusst minimal gehalten:

Es werden nur Existenz und Nicht-Leere der Dateien geprüft.

Es findet keine semantische Validierung der Inhalte statt.

Der Workflow ist auf Tags v0.51.* beschränkt.

Mögliche zukünftige Erweiterungen (separate Tickets):

Zusätzliche Checks, z.B.:

bestimmte Strings/Versionen in PROJECT_STATUS_EconomicLayer_v051.md.

Querverweise zwischen Reports (Links, Nav-Einträge).

Erweiterung auf weitere Release-Linien (z.B. v0.52.*), wenn der
StrategyEnforcement-Guard produktiv wird.

Kombination mit automatisierten Link-Checks oder Doku-Linting.

7. Fazit
DEV-94 sorgt dafür, dass Release-Tags nicht „blind“ gesetzt werden, sondern:

an eine minimale, aber wichtige Status-Dokumentation gebunden sind,

den Economic Layer v0.51.0 inkl. Strategy-Preview und Security/Governance
in Form von Reports konsistent abbilden,

die bestehende manuelle Release-Disziplin (DEV-97) durch einen
schlanken CI-Guard ergänzt wird.

Die ökonomische Logik, Smart-Contracts und PSM-Flows bleiben dabei unangetastet –
DEV-94 bewegt sich strikt im Bereich Infra / CI / Doku-Qualität.
MD

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-94] ${timestamp} CI: DEV94_Release_Status_Workflow_Report.md added (release-status.yml + check_release_status.sh)." >> "$LOG_FILE"

echo "✓ Report written to $REPORT"
echo "✓ Log updated at $LOG_FILE"
echo "== DEV94 REP01: done =="
