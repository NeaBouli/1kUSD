# DEV-7 Infra Plan – CI, Docker/Multi-Arch & Pages (Economic Layer v0.51.0)

> Scope: Dieser Plan richtet sich an DEV-7 und beschreibt, wie CI, Docker/Multi-Arch
> und Pages weiter geschärft werden – **ohne** Änderungen an Contracts/PSM/Economic-Core.

---

## 1. Rahmen & Constraints

- Economic Layer **v0.51.0** ist als stabile Basis gesetzt.
- BuybackVault + StrategyConfig + StrategyEnforcement (Phase 1 Preview) sind:
  - implementiert,
  - getestet,
  - in Architektur/Governance/Indexer/Status-Dokus verankert.
- Neue Security/Risk-Schicht (DEV-80–89) ist integriert:
  - keine Änderungen an contracts/, CI-Workflows, Dockerfiles.
  - Fokus auf docs/ + README.

**Wichtige Leitplanke für DEV-7:**

- 🔒 **Keine** Änderungen an:
  - `contracts/`
  - PSM-/Oracle-/Guardian-Logik
- ✅ Fokus auf:
  - CI-Stabilisierung,
  - Docker-/Multi-Arch-Builds,
  - MkDocs/Pages-Qualität,
  - Integration der neuen Docs in die Infra-Sicht.

---

## 2. CI-Stabilisierung (Foundry + Docs)

Ziele:

1. Sicherstellen, dass **alle relevanten Foundry-Suites** im CI laufen:
   - Economic Layer (PSM, Limits, Flows, Fees, Spreads).
   - BuybackVault inkl. StrategyGuard:
     - `BuybackVaultTest`
     - `BuybackVaultStrategyGuardTest`
   - Guardian-/Oracle-Regression-Tests.

2. Optionaler Ausbau (später):
   - Gas-/Regressions-Gates (nur, wenn vom Architekten freigegeben).
   - Check, dass neue Tests im CI nicht versehentlich „auskommentiert“ werden
     (z.B. via `--match-contract` nur auf Subsets).

Verknüpfung zu DEV-78:

- DEV78-Checkliste (`docs/logs/DEV78_Infra_CI_StrategyRisk_Docs_Checklist.md`)
  dient als detaillierter Fahrplan für:
  - CI-Deckung der neuen Strategy-/Security-/Risk-Doks,
  - optionale Ergänzung von Docs-Builds im CI.

---

## 3. Docker- & Multi-Arch-Builds

Ziele (nur Infra, keine Contract-Änderungen):

- Docker-Images so ausrichten, dass sie die aktuelle Tooling-Landschaft unterstützen:
  - Foundry-Tests (einschließlich neuer Suites).
  - MkDocs-Build (Pages).
- Multi-Arch-Build (z.B. amd64 + arm64) beibehalten oder wiederherstellen,
  ohne neue Abhängigkeiten für den Economic-Core zu erzwingen.

Empfohlene Vorgehensweise für DEV-7:

1. Bestehende Dockerfiles prüfen:
   - Welche Tool-Versionen (Foundry, Python/MkDocs, Node/etc.) sind enthalten?
   - Sind die Security/Risk-Doks automatisch mitbaubar (MkDocs in Container)?

2. Schrittweise Anpassungen:
   - Nur dort Änderungen vornehmen, wo:
     - Builds brechen, oder
     - klarer Mehrwert für CI/Deploy entsteht.

---

## 4. Pages & MkDocs-Optimierung

Ziele:

- GitHub Pages bleibt **stabil** (keine Build-Fehler).
- Neue Doku-Bereiche sind **auffindbar**, ohne die bestehende Navigation zu zerstören.

Konkrete Ansatzpunkte:

1. MkDocs Navigation:
   - Optional neue Sektionen:
     - „Security & Risk“ (Verlinkung auf `docs/security/` und `docs/risk/`).
     - „Reports & Status“ (DEV60–72, DEV74–76, PROJECT_STATUS_v051, Governance-Handover).
   - Wichtig: Keine bestehenden Routen löschen, um Broken-Links zu vermeiden.

2. Warnungen im MkDocs-Build:
   - Die aktuellen Warnungen (fehlende `index.md`-Zielpfade, nicht in `nav` aufgeführte Seiten)
     sind **bekannt** und nicht kritisch.
   - DEV-7 kann sie in kleinen Schritten abbauen:
     - Entweder durch Ergänzung in `nav`,
     - oder durch gezieltes Umhängen einzelner Links.

---

## 5. Empfohlene Mini-Tickets für DEV-7

Vorschlag für kleinteilige, risikoarme Schritte:

- **DEV-79 INFRA01 – Plan dokumentieren (dieses Dokument)**
  - ✅ Dieses File: high-level Plan für CI/Docker/Pages.

- **DEV-79 INFRA02 – CI-Inventur**
  - Review bestehender `.github/workflows/*`:
    - Welche `forge test` / `npm` / `mkdocs`-Jobs laufen?
    - Sind alle relevanten Suites abgedeckt?
  - Ergebnis als kurzes Log-/Report-File in `docs/logs/` festhalten.

- **DEV-79 INFRA03 – MkDocs-Navi (kleinstmöglicher Schritt)**
  - Eine minimale Ergänzung der Navigation, z.B.:
    - Ein neuer Menüpunkt „Security & Risk“ mit 2–3 Kernseiten.
  - Danach: `mkdocs build` zur Verifikation.

- **DEV-79 INFRA04 – Docker-Check**
  - Dokumentation der aktuellen Docker-/Multi-Arch-Situation:
    - Welche Images?
    - Welche Targets (amd64/arm64)?
  - Erst im nächsten Schritt tatsächliche Anpassungen.

---

## 6. Zusammenfassung

- Economic Layer v0.51.0 bleibt **unverändert** (keine Contract-/Logic-Patches).
- StrategyEnforcement Phase 1 ist implementiert, aber **opt-in**.
- DEV-7 fokussiert sich auf:
  - CI-Sichtbarkeit und Stabilität,
  - Docker-/Multi-Arch-Unterstützung,
  - MkDocs/Pages-Qualität und Navigation,
  - Integration der neuen Strategy/Security/Risk-Dokumente in die Infra-Perspektive.

Dieses Dokument dient als Ausgangspunkt für weitere DEV-7-Patches
(jeweils kleine, abgeschlossene INFRA-Schritte mit eigener Log-Zeile).

### Update DEV-93: Docs-Build CI integriert

- Der CI-Teil „Docs/MkDocs in CI einbinden“ wurde mit **DEV-93** teilweise
  umgesetzt:
  - Neuer Workflow: `.github/workflows/docs-build.yml`
  - Aktion: `mkdocs build` auf `push` / `pull_request` nach `main`.
- Damit ist sichergestellt, dass die Doku in der CI baubar bleibt und
  Fehler früh sichtbar werden.
- Offene Punkte aus diesem Plan bleiben bewusst **separate Tickets**:
  - Docker/Multi-Arch-Build (Images, Tags, Registry).
  - Release-Tag-Checks (z.B. `PROJECT_STATUS_*.md`).
  - Feinere Pages-/Preview-Flows, falls später gewünscht.

