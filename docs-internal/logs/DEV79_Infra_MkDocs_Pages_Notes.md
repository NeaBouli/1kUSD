# DEV-79 – MkDocs / GitHub Pages Integration Notes (Read-Only)

> Scope: Dieses Dokument fasst den aktuellen, beobachteten Umgang mit MkDocs
> und GitHub Pages zusammen – ohne Änderungen an `mkdocs.yml`, Workflows
> oder Docker-Setup vorzunehmen.

- Generated: (UTC) via DEV-79 INFRA03
- Context:
  - Economic Layer v0.51.0 ist stabil (keine Contract-/Logic-Änderungen).
  - BuybackVault + StrategyConfig + StrategyEnforcement Phase 1 sind
    implementiert, getestet und umfassend dokumentiert.
  - DEV-8 Security/Risk-Layer wurde integriert, ohne CI/Docker/MkDocs
    anzufassen.

---

## 1. Beobachtete Praxis (Stand DEV-70…79)

- MkDocs-Build und GitHub-Pages-Deployment werden derzeit **manuell** über:
  - `mkdocs gh-deploy --force --no-history`
  angestoßen.
- Der Build läuft grün, erzeugt jedoch wiederkehrend Hinweise:
  - Viele Files in `docs/` sind **nicht in der `nav`** referenziert.
  - Es existiert ein `index.md`-Verweis in der `nav`, während faktisch
    mit `INDEX.md` / `README.md` gearbeitet wird.
- Dies ist aktuell **kein Fehler**, sondern eine bewusste, tolerierte
  Konstellation:
  - Das Projekt nutzt `docs/` als „Doc-Tree“ mit vielen intern verlinkten
    Artefakten.
  - Nur ein Teil davon ist explizit in der Navigation sichtbar.

---

## 2. Konsequenzen für DEV-7 / Infra-Arbeit

- Solange:
  - der Build (`mkdocs build`, `mkdocs gh-deploy`) **erfolgreich** ist und
  - die **wichtigsten Einstiegsseiten** erreichbar sind,
  ist kein sofortiger Eingriff in `mkdocs.yml` nötig.
- Die wiederkehrenden Warnungen sollten jedoch:
  - dokumentiert,
  - für spätere Cleanup-/Hardening-Tickets eingeplant werden.

Dieses Dokument erfüllt den Dokumentations-Part.

---

## 3. Vorschläge für zukünftige, **separate** INFRA-Tickets

> Nur als Ideensammlung – **nicht** in DEV-79 umzusetzen.

### INFRA-Next A – `nav`-Bereinigung & Einstiegsseiten

- Ziel:
  - Klarer definierte Einstiegsnavigation für:
    - Economic Layer v0.51.0
    - BuybackVault / StrategyEnforcement
    - Security / Risk / Testing
- Mögliche Schritte (separates Ticket):
  - `mkdocs.yml` prüfen:
    - Welche `index*.md`-Varianten sollen offiziell sein?
    - Welche Sektionen sollen in der Navigation sichtbar sein
      (z.B. `architecture/`, `security/`, `risk/`, `reports/`)?
  - `index.md`-Verweise konsolidieren oder explizit auf `INDEX.md` /
    `README.md` mappen.

### INFRA-Next B – Minimaler MkDocs-CI-Check

- Ziel:
  - Sicherstellen, dass der MkDocs-Build auch im CI grün bleibt.
- Mögliche Schritte (separates Ticket):
  - Einen sehr leichten CI-Job definieren:
    - `mkdocs build` ohne Deploy.
  - Optional: nur auf `main` / Release-Branches laufen lassen.

### INFRA-Next C – Pages-Veröffentlichung dokumentieren

- Ziel:
  - Klar dokumentieren, wie und wann Pages deployed werden.
- Mögliche Schritte (separates Ticket):
  - README / `docs/logs/`-Eintrag erweitern:
    - „Pages werden bewusst manuell mit `mkdocs gh-deploy ...` ausgelöst.“
  - Optional: später auf GitHub-Action-Workflow migrieren, falls gewünscht.

---

## 4. Abgrenzung

Diese Notiz stellt klar:

- DEV-79:
  - **ändert nichts** an:
    - `mkdocs.yml`
    - GitHub-Actions-Workflows
    - Docker / Build-System
  - ergänzt nur:
    - ein logisches Bild der aktuellen MkDocs-/Pages-Situation,
    - Vorschläge für spätere, isolierte INFRA-Tickets.

- Economic Layer v0.51.0 und BuybackVault/StrategyEnforcement-Logic
  bleiben vollständig unberührt.

