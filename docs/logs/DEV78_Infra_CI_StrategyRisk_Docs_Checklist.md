# DEV78 – CI/Docker/Docs Integration Checklist (Strategy, Security & Risk)

## 1. Ziel & Kontext

Diese Checkliste beschreibt, wie der bestehende Build-/Infra-Layer (Docker, CI,
GitHub Pages) mit den neuen Doku-Bereichen für:

- **BuybackVault Strategy Layer** (StrategyConfig, StrategyEnforcement),
- **Security & Risk Layer** (Audit-Plan, Bug-Bounty, PoR, Risk-Runbooks),
- **Testing / Stress-Tests**,

sauber integriert werden kann – **ohne** die bestehende Economic-Layer-Logik
oder den PSM-/Guardian-Core zu verändern.

Sie ist als Referenz für DEV-7 (Docker/CI/Pages) und spätere Infra-Owner gedacht.

---

## 2. MkDocs & GitHub Pages

### 2.1 Navigation & Sichtbarkeit

- [ ] Prüfen, ob alle relevanten neuen Dateien bei Bedarf in der `mkdocs.yml`
      Navigation auftauchen sollen:

  - `docs/architecture/buybackvault_strategy.md`
  - `docs/architecture/buybackvault_strategy_phase1.md`
  - `docs/architecture/buybackvault_strategy_rfc.md`
  - `docs/architecture/economic_layer_overview.md`
  - `docs/governance/parameter_playbook.md`
  - `docs/indexer/indexer_buybackvault.md`
  - `docs/security/audit_plan.md`
  - `docs/security/bug_bounty.md`
  - `docs/risk/proof_of_reserves_spec.md`
  - `docs/risk/collateral_risk_profile.md`
  - `docs/risk/emergency_depeg_runbook.md`
  - `docs/testing/stress_test_suite_plan.md`
  - Reports unter `docs/reports/` (z.B. DEV60-72, DEV74-76, PROJECT_STATUS*)

- [ ] Falls einzelne Dateien bewusst **off-nav** bleiben sollen
      (z.B. interne Reports), dokumentieren, wo sie verlinkt werden
      (z.B. aus README oder anderen Reports).

### 2.2 CI-Check „Docs buildbar“

- [ ] Sicherstellen, dass im CI ein Job existiert, der mindestens:
  - `mkdocs build` (oder äquivalent) ausführt.
  - Warnungen bzgl. fehlender Links/Files beobachtet (z.B. `index.md`-Hinweise).

- [ ] Optional: Docs-Job so konfigurieren, dass er bei schweren
      Link-/Strukturfehlern failt, aber **weiche Warnungen** (z.B. bewusst
      nicht referenzierte Files) nur loggt.

- [ ] README-Hinweise zu „Docs Integrity / Pages“ prüfen und anpassen:
  - Verweis auf `scripts/scan_docs.sh` (falls vorhanden) und wie er in
    CI eingebunden wird.

---

## 3. Foundry & Tests in CI

### 3.1 Economic Layer & BuybackVault

- [ ] Sicherstellen, dass der bestehende Foundry-CI-Job:
  - die `BuybackVaultTest`-Suite ausführt.
  - die `BuybackVaultStrategyGuardTest`-Suite ausführt.
  - alle PSM-/Guardian-/Oracle-Regressionssuiten ausführt.

- [ ] Bei zukünftigen Änderungen an StrategyEnforcement:
  - Neue Tests **immer** über die bestehenden Suiten legen (Regressionen).
  - Eventuell einen separaten Job/Matrix-Entry für „Economic Layer“
    definieren, falls Build-Zeiten kritisch werden.

### 3.2 Gas / Performance (optional)

- [ ] Optionalen Gas-Report aktivieren, um Impact von StrategyEnforcement
      im `executeBuyback()` Pfad zu messen.
- [ ] Ergebnisse dokumentieren (z.B. in einem späteren DEVxx-Report),
      falls die Aktivierung des Flags gas-sensitiv ist.

---

## 4. Docker & Runtime-Images

### 4.1 Keine Pflichtänderungen

Aktuell sind für StrategyEnforcement / Security-/Risk-Dokumente **keine**
Pflichtänderungen an Docker-Images nötig. Relevanz:

- Contracts & Tests laufen wie gehabt.
- Doku wird über MkDocs / Pages generiert (build-time, nicht runtime).

### 4.2 Optionale Verbesserungen

- [ ] Falls ein „Docs-Image“ existiert:
  - Sicherstellen, dass alle Python-/MkDocs-Abhängigkeiten für die neuen
    Dokus vorhanden sind (keine exotischen Plugins wurden eingeführt).
- [ ] Falls ein „Dev-Image“ existiert:
  - README ergänzt um Hinweis, wie man:
    - Tests (`forge test`) ausführt.
    - Docs lokal baut (`mkdocs serve` / `mkdocs build`).

---

## 5. Monitoring / Observability

### 5.1 StrategyEnforcement-Telemetrie

- [ ] In Indexer-/Monitoring-Konfiguration:
  - Mapping von `strategiesEnforced` nachziehen.
  - Events `StrategyEnforcementUpdated(bool enforced)` erfassen.
  - Fehler `NO_STRATEGY_CONFIGURED` /
    `NO_ENABLED_STRATEGY_FOR_ASSET` als **policy-bedingte Blocks**
    klassifizieren, nicht als Protokollfehler.

- [ ] Dashboards / Grafana / o.ä.:
  - Panels für:
    - Aktuellen `strategiesEnforced`-Status (on/off).
    - Zeitverlauf der Anzahl von „policy-bedingten Blocks“.
  - Optional: Alerting, falls nach Aktivierung des Flags ungewöhnlich viele
    Reverts auftreten.

---

## 6. Governance & Release-Management

- [ ] Sicherstellen, dass Releases (z.B. v0.51.0, v0.52.x) in den Release-Notes:
  - klar zwischen „Baseline“ und „opt-in StrategyEnforcement Phase 1“
    unterscheiden.
  - auf die relevanten Reports verlinken:
    - `docs/reports/DEV60-72_BuybackVault_EconomicLayer.md`
    - `docs/reports/DEV74-76_StrategyEnforcement_Report.md`
    - `docs/reports/PROJECT_STATUS_EconomicLayer_v051.md`

- [ ] Optional: CI-Check, der sicherstellt, dass bei einem Release-Tag:
  - `PROJECT_STATUS_*.md` aktuell ist.
  - die wichtigsten Reports im `gh-pages`-Build erscheinen.

---

## 7. Fazit

Diese Checkliste ist bewusst **non-invasive**:

- Keine direkten Änderungen an Dockerfiles oder CI-Workflows.
- Fokus auf:
  - Sichtbarkeit & Konsistenz der neuen Docs,
  - Vollständigkeit der Tests in CI,
  - Vorbereitung von Monitoring & Governance-Flows.

DEV-7 kann sie als Grundlage verwenden, um in kleinen, isolierten
Tickets die Integration zu schärfen.

### Update DEV-93: Docs-Build CI umgesetzt

- Der Punkt „Docs/MkDocs in CI einhängen“ ist für den reinen Build-Check
  mit **DEV-93** umgesetzt:
  - Workflow: `.github/workflows/docs-build.yml`
  - Aktion: `mkdocs build` auf `push` / `pull_request` nach `main`.
- Zusätzlich wurde ein **Docs Build**-Badge im `README.md` ergänzt, der den
  Status des Workflows sichtbar macht.
- Weitere Schritte (z.B. Release-Tag-Checks, engere Kopplung an
  `PROJECT_STATUS_*.md`) bleiben als separate INFRA-Tickets offen.

