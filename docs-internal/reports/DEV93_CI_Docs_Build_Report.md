# DEV-93 – CI Docs-Build Mini-Report

## 1. Kontext & Zielsetzung

DEV-93 ergänzt den bestehenden CI-/Infra-Layer des 1kUSD-Projekts um einen
eigenständigen **Docs-Build-Workflow** für die MkDocs-Dokumentation.

Ziele:

- Sicherstellen, dass die Doku kontinuierlich **baubar** bleibt.
- Frühe Sichtbarkeit von Fehlern in `docs/` und `mkdocs.yml`.
- Keine Änderungen an Economic Layer v0.51.0, PSM, Oracles oder BuybackVault
  – rein **Infra/CI/Dokumentation**.

---

## 2. Änderungen im Überblick

### 2.1 Neuer CI-Workflow: `.github/workflows/docs-build.yml`

DEV-93 führt einen separaten GitHub-Actions-Workflow ein:

- Datei: `.github/workflows/docs-build.yml`
- Trigger:
  - `on: push` nach `main`
  - `on: pull_request` gegen `main`
- Steps (vereinfacht):
  - Checkout Repo (`actions/checkout@v4`)
  - Python Setup (`actions/setup-python@v5`, z.B. 3.11)
  - Install MkDocs + Theme:
    - `pip install mkdocs mkdocs-material`
  - `mkdocs build`

Damit wird bei jedem Push/PR mit Bezug zu `main` geprüft, ob die Doku vollständig
gebaut werden kann.

### 2.2 README-Badge für Docs-Build

Zur besseren Sichtbarkeit wurde im `README.md` ein zusätzlicher CI-Badge
eingefügt:

- Badge: **Docs Build**
- Link auf Workflow:
  - `actions/workflows/docs-build.yml`
- Einbettung direkt bei den bestehenden Badges (CI / Foundry / Docs Deploy etc.).

So ist der Status des Doku-Builds unmittelbar auf der Projekt-Startseite sichtbar.

---

## 3. Verknüpfung mit bestehenden Infra-Dokumenten

DEV-93 ist eng mit den bereits existierenden Infra-/Strategy-Dokumenten
verdrahtet und dort explizit als Update vermerkt:

### 3.1 DEV78 – Infra CI/Docs Integration Checklist

In `docs/logs/DEV78_Infra_CI_StrategyRisk_Docs_Checklist.md` wurde ein
zusätzlicher Abschnitt ergänzt:

- Überschrift:
  - `### Update DEV-93: Docs-Build CI umgesetzt`
- Inhalt (Kernaussagen):
  - Der Punkt „Docs/MkDocs in CI einhängen“ ist für den reinen Build-Check
    mit DEV-93 umgesetzt.
  - Workflow: `.github/workflows/docs-build.yml`
  - Aktion: `mkdocs build` auf `push` / `pull_request` nach `main`.
  - Weitere, komplexere Checks (z.B. Release-Tag-Validierung) bleiben
    als separate Tickets offen.

### 3.2 DEV79 – CI Inventory

In `docs/logs/DEV79_Infra_CI_Inventory.md` wurde DEV-93 ebenfalls als
**Update** dokumentiert:

- Überschrift:
  - `### Update DEV-93: docs-build.yml hinzugefügt`
- Inhalt:
  - Ergänzung um den neuen Workflow `.github/workflows/docs-build.yml`.
  - Klarstellung, dass die ursprüngliche Inventur als Snapshot bestehen bleibt
    und DEV-93 als Erweiterung zu verstehen ist.

### 3.3 DEV79 – Dev7 Infra CI/Docker/Pages Plan

In `docs/logs/DEV79_Dev7_Infra_CI_Docker_Pages_Plan.md` wurde DEV-93
in den Dev7-Plan integriert:

- Überschrift:
  - `### Update DEV-93: Docs-Build CI integriert`
- Inhalt:
  - Der CI-Teil „Docs/MkDocs in CI einbinden“ ist mit DEV-93 teilweise
    umgesetzt.
  - Offene Punkte:
    - Docker/Multi-Arch-Build.
    - Release-Tag-Checks (`PROJECT_STATUS_*.md`).
    - Feinere Pages-/Preview-Flows.

Damit ist dokumentiert, dass DEV-93 einen Teil des Dev7-Infra-Plans abdeckt,
ohne andere, noch offene Tickets vorwegzunehmen.

---

## 4. Scope & Nicht-Ziele

**Was DEV-93 abdeckt:**

- Prüft, dass `mkdocs build` in CI erfolgreich durchläuft.
- Macht Doku-Build-Fehler frühzeitig sichtbar.
- Bindet den Status über einen Badge in `README.md` ein.
- Verknüpft die Änderung sauber mit:
  - DEV78 (Docs-Integration-Checklist).
  - DEV79 CI-Inventory.
  - DEV79 Dev7-Infra-Plan.

**Was DEV-93 explizit nicht tut:**

- Keine Änderungen an:
  - `contracts/`
  - Economic Layer v0.51.0
  - PSM-/Oracle-/BuybackVault-Logik
- Kein automatisches Pages-Deploy:
  - Der bestehende, manuell ausgelöste `mkdocs gh-deploy`-Flow bleibt –
    wie dokumentiert – das Werkzeug für bewusste Releases.
- Keine Docker-/Multi-Arch-Änderungen:
  - Docker bleibt für separate INFRA-Tickets vorgesehen.

---

## 5. Auswirkungen auf Release- / Governance-Flows

Kurzfristig:

- Releases werden nicht automatisiert; aber jede Änderung an Doku/Specs wird
  durch den Docs-Build-Workflow auf Build-Fähigkeit geprüft.
- Maintainer sehen im README direkt, ob der letzte Docs-Build erfolgreich war.

Mittelfristig (optionale nächste Schritte, separate Tickets):

- Ergänzung eines Release-Tag-Workflows, der z.B. prüft:
  - `PROJECT_STATUS_*.md` aktuell.
  - zentrale Reports wie:
    - `DEV60-72_BuybackVault_EconomicLayer.md`
    - `DEV74-76_StrategyEnforcement_Report.md`
    - `PROJECT_STATUS_EconomicLayer_v051.md`
- Engere Kopplung zwischen Release-Tags, Doku-Stand und Pages-Deployment.

---

## 6. Empfehlung für Maintainer / Dev7

- DEV-93 kann als **abgeschlossene CI-Einheit** betrachtet werden:
  - Workflow aktiv.
  - Badge sichtbar.
  - Referenzen in DEV78/DEV79/Dev7-Plan gesetzt.
- Weitere Infra-Schritte sollten in eigenen, kleinen Tickets erfolgen:
  - Docker/Multi-Arch.
  - Release-Tag-Checks.
  - Pages-/Preview-Optimierungen.

DEV-93 schafft damit eine saubere Grundlage, um künftig Doku,
CI und Release-Flows enger zu verzahnen – ohne in die ökonomische
Kernlogik des Protokolls einzugreifen.
