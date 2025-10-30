# 🔒 1kUSD – FINAL_PAGES_LOCK_v0.15
**Datum:** 2025-10-30  
**Commit:** `5bec084`  
**Status:** ✅ Stabil – GitHub Pages Redirect Hard-Lock aktiv

## Beschreibung
Mit diesem Patch wurde der fehleranfällige GitHub-Auto-Redirect-Prozess endgültig deaktiviert.
Der Branch `gh-pages` enthält jetzt eine feste Datei:

/redirects/index.html

markdown
Code kopieren

Diese leitet alle Aufrufe von `/index.md` oder `/index.html` direkt nach  
[`/1kUSD/`](https://neabouli.github.io/1kUSD/) weiter.

## Schutzmechanismen
- `.nojekyll` blockiert alle automatischen Überschreibungen.
- Keine CI- oder MkDocs-Jobs verändern `gh-pages`.
- Cache-Fehler ausgeschlossen.

## Rollback-Befehl
```bash
git fetch origin --tags
git push origin refs/tags/v0.15-pages-lock-stable:refs/heads/gh-pages --force
Überprüfung
bash
Code kopieren
curl -I https://neabouli.github.io/1kUSD/index.md
# → HTTP/2 301 or 200
✅ Home bleibt permanent stabil, unabhängig von zukünftigen Deploys oder Rebuilds.
