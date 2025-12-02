# DEV-94 – Infra Plan: Release-Tag Checks & Status Files

> **Scope:** Reiner *Plan* für zukünftige Release-Tag-Checks.  
> Es werden **keine** CI-Workflows, Dockerfiles oder Contracts verändert.

---

## 1. Motivation

Der Economic Layer v0.51.0 ist als stabile Basis definiert.  
Gleichzeitig existiert eine wachsende Menge an Status- und Report-Dateien:

- `docs/reports/PROJECT_STATUS_EconomicLayer_v051.md`
- `docs/reports/DEV60-72_BuybackVault_EconomicLayer.md`
- `docs/reports/DEV74-76_StrategyEnforcement_Report.md`
- `docs/reports/DEV87_Governance_Handover_v051.md`
- `docs/reports/DEV89_Dev7_Sync_EconomicLayer_Security.md`
- Security-/Risk-/Testing-Dokumente (`docs/security/*`, `docs/risk/*`, `docs/testing/*`)

DEV-94 beschreibt, **wie** zukünftige Release-Tag-Workflows aussehen könnten,
ohne sie bereits umzusetzen:

- Ziel: Bei einem Release-Tag (z.B. `v0.51.0`, `v0.52.0`) automatisch prüfen,
  ob zentrale Status-/Report-Dateien und die Doku konsistent sind.
- Kein Eingriff in:
  - Economic Layer Logic
  - BuybackVault / StrategyEnforcement Logic
  - Bestehende CI-/Docker-/Pages-Pipelines

---

## 2. Zielbild für Release-Tag-Checks (High-Level)

Ein zukünftiger Release-Tag-Workflow (z.B. `.github/workflows/release-tag-checks.yml`)
könnte bei einem Tag wie `v0.51.0` oder `v0.52.0`:

1. **Repository auschecken**
2. **Status-/Report-Dateien prüfen**, z.B.:
   - `docs/reports/PROJECT_STATUS_EconomicLayer_v051.md`
   - `docs/reports/DEV60-72_BuybackVault_EconomicLayer.md`
   - `docs/reports/DEV74-76_StrategyEnforcement_Report.md`
   - (optional) weitere `PROJECT_STATUS_*.md` oder `DEVxx_*.md`
3. **MkDocs-Build triggern** (Read-Only):
   - Sicherstellen, dass die Doku mit dem Tag-Stand baubar ist.
4. **Ergebnis reporten**, z.B.:
   - „Status-Files vorhanden & lesbar“
   - „MkDocs-Build erfolgreich“
   - Bei Fehlern: eindeutige, nicht-blockende Hinweise.

Wichtig:

- Release-Tag-Checks dienen primär der **Transparenz**,
  nicht zwingend als Hard-Gate.
- Ob ein Release-Tag bei Fehlern als „failed“ markiert wird,
  soll ein eigener Governance-/Maintainer-Entscheid sein.

---

## 3. Welche Dateien sollten zukünftig geprüft werden?

### 3.1 Projekt-Status-Files

Pflichtkandidaten:

- `docs/reports/PROJECT_STATUS_EconomicLayer_v051.md`
- (zukünftige) `PROJECT_STATUS_*`-Files für weitere Komponenten
  (z.B. Collateral Vaults, Oracle Layer v2, etc.)

Mögliche Checks:

- Datei existiert.
- Datei ist nicht leer.
- Optional: einfache Heuristiken (z.B. enthält eine Überschrift mit der passenden Version).

### 3.2 Kern-Reports (Economic Layer / BuybackVault / Strategy)

Empfohlene Kandidaten:

- `docs/reports/DEV60-72_BuybackVault_EconomicLayer.md`
- `docs/reports/DEV74-76_StrategyEnforcement_Report.md`
- `docs/reports/DEV87_Governance_Handover_v051.md`
- `docs/reports/DEV89_Dev7_Sync_EconomicLayer_Security.md`

Mögliche Checks:

- Datei existiert.
- Datei ist nicht leer.
- Optional: grober Inhalt-Check (z.B. Vorkommen bestimmter Überschriften).

### 3.3 Security / Risk / Testing

Optionale (aber sinnvolle) Kandidaten:

- `docs/security/audit_plan.md`
- `docs/security/bug_bounty.md`
- `docs/risk/proof_of_reserves_spec.md`
- `docs/risk/collateral_risk_profile.md`
- `docs/risk/emergency_depeg_runbook.md`
- `docs/testing/stress_test_suite_plan.md`

Mögliche Checks:

- Existenz & Nicht-Leerheit.
- Optional: Tag-spezifische Annotationen („gültig ab v0.51.0“ etc.)

---

## 4. Beziehung zu DEV-93 (Docs-Build Workflow)

DEV-93 hat bereits einen **Docs-Build-Workflow** eingeführt:

- Datei: `.github/workflows/docs-build.yml`
- Aktion: `mkdocs build` auf `push` / `pull_request` nach `main`.
- Badge im `README.md`, der den Status anzeigt.

DEV-94 baut darauf nur **konzeptionell** auf:

- Für Release-Tags könnte derselbe Build-Schritt wiederverwendet werden:
  - Entweder durch einen zusätzlichen Workflow
  - oder durch einen `workflow_call` aus einem Tag-Workflow heraus.
- DEV-94 definiert **noch keine** konkrete CI-Konfiguration,
  sondern beschreibt nur, wie eine Kopplung aussehen könnte.

---

## 5. Vorschlag für zukünftiges Skript (Nicht implementiert)

Ein späteres Ticket (z.B. DEV-95 oder INFRA-NN) könnte ein einfaches Shell- oder Python-Skript hinzufügen:

- Ort: `scripts/check_release_status.sh` (oder ähnlich)
- Aufgaben:
  - Prüfen, ob alle Pflicht-Dateien existieren.
  - Warnungen ausgeben, wenn Dateien fehlen oder leer sind.
- Verwendung:
  - Lokal durch Maintainer vor einem Tag.
  - Später optional als Teil eines Release-Tag-Workflows.

Beispiel-Aufgabenliste (Pseudo-Code):

- `assert_file_exists docs/reports/PROJECT_STATUS_EconomicLayer_v051.md`
- `assert_file_exists docs/reports/DEV60-72_BuybackVault_EconomicLayer.md`
- `assert_file_exists docs/reports/DEV74-76_StrategyEnforcement_Report.md`
- `assert_file_exists docs/reports/DEV87_Governance_Handover_v051.md`
- `assert_file_exists docs/reports/DEV89_Dev7_Sync_EconomicLayer_Security.md`

---

## 6. Governance / Owner-Fragen

Bevor ein solcher Release-Tag-Workflow implementiert wird, sollten Maintainer klären:

- Wer „owner“ der Status-/Report-Dateien ist?
  - Z.B. Economic-Layer-Lead, Governance-Lead, Security-Lead.
- Welche Schwere ein fehlender Report hat?
  - Nur Warnung (Pipeline läuft weiter)?
  - Oder Hard-Fail (Tag-Workflow schlägt fehl)?
- Ab welcher Projektphase Release-Tag-Checks als Pflicht gelten sollen:
  - z.B. ab `v0.60.0` oder „Mainnet-Release“.

---

## 7. Zusammenfassung

DEV-94 legt **bewusst nur den Plan** für Release-Tag-Checks fest:

- Keine Änderungen an:
  - Economic Layer Contracts
  - BuybackVault / StrategyEnforcement Logic
  - Bestehenden CI-/Docker-/Pages-Workflows
- Klar definierte Kandidaten-Dateien, die zukünftig bei Tags geprüft werden könnten.
- Saubere Anschlussstelle an DEV-93 (Docs-Build Workflow).
- Raum für zukünftige, kleine INFRA-Tickets:
  - Script `scripts/check_release_status.sh`
  - Tag-spezifische CI-Workflows
  - ggf. zusätzliche Reports & Status-Files

Maintainer / Dev7 können dieses Dokument als Referenz verwenden,
wenn Release-Tag-Checks in einer späteren Phase des Projekts
konkret umgesetzt werden.

### Update DEV-96: release-status Workflow umgesetzt

- Der Plan für **Release-Tag-Checks** wurde mit **DEV-96** teilweise
  operativ gemacht:
  - Neuer Workflow: `.github/workflows/release-status.yml`
  - Trigger: `push` auf Tags `v0.51.*` und `v0.52.*`
  - Aktion: `scripts/check_release_status.sh`
    - prüft u.a.:
      - `docs/reports/PROJECT_STATUS_EconomicLayer_v051.md`
      - `docs/reports/DEV60-72_BuybackVault_EconomicLayer.md`
      - `docs/reports/DEV74-76_StrategyEnforcement_Report.md`
      - `docs/reports/DEV87_Governance_Handover_v051.md`
      - `docs/reports/DEV89_Dev7_Sync_EconomicLayer_Security.md`
      - `docs/reports/DEV93_CI_Docs_Build_Report.md`
- Damit ist ein erster, praktischer Check für Release-Tags etabliert:
  - Tags werden nur „grün“, wenn die zentralen Status-/Report-Files
    existieren und nicht leer sind.
- Weitere Ausbaustufen aus diesem Plan bleiben bewusst **separate Tickets**:
  - Feiner granulare Checks für künftige Versionen (z.B. v0.53+).
  - Erweiterte Integrationen mit zusätzlichen Reports / neuen Modulen.
