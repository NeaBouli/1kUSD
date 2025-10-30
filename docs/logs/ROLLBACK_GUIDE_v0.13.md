# 🧩 1kUSD – GitHub Pages Rollback & Recovery Guide (v0.13)
**Datum:** 30. Oktober 2025  
**Status:** ✅ Final Stable  
**Autor:** Core Dev / Docs Ops  

---

## 🔍 Zusammenfassung

Dieser Leitfaden beschreibt, wie das 1kUSD-Dokumentationssystem
nach einem fehlerhaften Auto-Deploy oder 404-Fehler auf **Home**
schnell und verlustfrei wiederhergestellt werden kann.

Seit dem letzten Fix ist der Zustand auf
`v0.11.8-fullmenu-stable` eingefroren und dient als **Master-Snapshot**.

---

## 🧠 Ursache

- GitHub Actions Workflows (z. B. `Deploy Docs to GitHub Pages`)
  wurden automatisch bei jedem `main`-Commit getriggert.  
- Dadurch wurde `gh-pages` mit fehlerhaften Builds überschrieben.
- Die Seite **Home** führte dann auf `/index.md` → 404.

---

## 🔧 Wiederherstellungsprozedur

**1️⃣ Rollback (schnell und sicher)**

```bash
bash -s <<'EOS'
set -e
echo "♻️ Hard-restore gh-pages from stable snapshot…"
git fetch origin --tags
git push origin refs/tags/v0.11.8-fullmenu-stable:refs/heads/gh-pages --force
echo "✅ gh-pages restored; Home will be live again in ~30 sec."
EOS
Ergebnis prüfen:

bash
Code kopieren
curl -I https://neabouli.github.io/1kUSD/
# Erwartet: HTTP/2 200
2️⃣ Dauerhafte Absicherung

Im Workflow .github/workflows/deploy-pages.yml
folgenden Block ergänzen oder bereits integriert lassen:

yaml
Code kopieren
# Prevent auto-deploy on main
on:
  push:
    branches-ignore: [main]
Dadurch wird kein Auto-Build mehr auf main ausgelöst.

3️⃣ Optionaler Snapshot (nach Stabilisierung)

bash
Code kopieren
git tag -f v0.13-pages-final-stable
git push origin --tags --force
Damit bleibt der aktuelle Zustand versioniert abrufbar.

✅ Ergebnis
Komponente	Status
/1kUSD/	🟢 200 OK
/index.md	🚫 intentional 404
Navigation	🟢 vollständig
Theme	🟢 grün/material
Workflows	⚙️ Auto-Deploy deaktiviert

Hinweis:
Für die Wiederherstellung wird kein lokaler Build benötigt.
Das Kommando git push origin refs/tags/v0.11.8-fullmenu-stable:refs/heads/gh-pages --force
stellt die funktionierende Version in unter 30 Sekunden wieder her.

