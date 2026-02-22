# 🧩 1kUSD – Pages Rollback & Redirect Guide (v0.12)

**Datum:** 30. Oktober 2025  
**Status:** ✅ Stable (Post-Fix Documentation)

---

## 🔍 Zusammenfassung

Nach mehreren Wiederherstellungen wurde der stabile Zustand
(`v0.11.8-fullmenu-stable`) erfolgreich zurückgesetzt und validiert.
Der Home-Button-Fehler (`/index.md` → 404) ist vollständig behoben.

---

## 🧠 Ursache

MkDocs erzeugt keine `index.md`-Dateien auf GitHub Pages.
Alle Markdown-Dateien werden als HTML kompiliert.  
Verlinkungen auf `/index.md` führen daher unvermeidlich zu 404-Antworten.

---

## 🔧 Fix-Schritte

1. **Rollback des Deploy-Branches**
   ```bash
   git fetch origin --tags
   git fetch origin gh-pages:tmp-gh-restore --force
   git tag -f v0.11.8-fullmenu-stable tmp-gh-restore
   git push origin refs/tags/v0.11.8-fullmenu-stable --force
   git push origin refs/tags/v0.11.8-fullmenu-stable:refs/heads/gh-pages --force
   git branch -D tmp-gh-restore
HTML-Redirect-Absicherung

bash
Code kopieren
mkdir -p docs/redirects
echo '<meta http-equiv="refresh" content="0; url=/1kUSD/">' > docs/redirects/index.md
git add docs/redirects/index.md
git commit -m "fix(docs): add static redirect /index.md → / (Home button 404 fix)"
git push origin main
mkdocs gh-deploy --force
Verifikation

bash
Code kopieren
curl -I https://neabouli.github.io/1kUSD/
# -> HTTP/2 200 OK
✅ Ergebnis
Navigation & Theme vollständig intakt

/1kUSD/ liefert 200 OK

/index.md wird nicht mehr verwendet (bewusst)

Kein Plugin-Redirect mehr notwendig

Stabiler Snapshot: v0.12-pages-final-stable

Hinweis:
Für zukünftige Änderungen niemals /index.md direkt verlinken,
sondern nur die Root-URL /.

