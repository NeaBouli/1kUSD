# 🔁 Restore GitHub Pages Snapshot

Wenn das Menü, Theme oder Layout der Dokumentation beschädigt ist,  
kann dieser Button verwendet werden, um den letzten stabilen Stand  
(`v0.11.8-fullmenu-stable`) wiederherzustellen:

[![🔁 Restore Pages Snapshot](https://img.shields.io/badge/Restore-FullMenu_Stable-brightgreen?logo=github)](https://github.com/NeaBouli/1kUSD/tree/gh-pages)

---

## 🧰 Wiederherstellung über Konsole (manuell)

Führe die folgenden Befehle aus, um GitHub Pages auf den stabilen Stand  
zurückzusetzen:

```bash
git fetch origin gh-pages
git checkout gh-pages
git reset --hard v0.11.8-fullmenu-stable
git push origin gh-pages --force
git checkout main
✅ Danach wird automatisch wieder das vollständige Menü, Theme und Layout geladen.

Hinweis: Diese Wiederherstellung betrifft ausschließlich den gh-pages-Branch
und ändert nichts am eigentlichen Projektcode oder den Markdown-Dateien.
