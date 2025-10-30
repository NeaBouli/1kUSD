# 🔁 Restore GitHub Pages Snapshot

Wenn das Menü oder Layout der Dokumentation beschädigt ist,  
kann dieser Button verwendet werden, um den letzten stabilen Stand (`v0.11.8-fullmenu-stable`) wiederherzustellen:

[![🔁 Restore Pages Snapshot](https://img.shields.io/badge/Restore-FullMenu_Stable-brightgreen?logo=github)](https://github.com/NeaBouli/1kUSD/tree/gh-pages)

---

### 🧰 Wiederherstellung (manuell über Konsole)

```bash
git fetch origin gh-pages
git checkout gh-pages
git reset --hard v0.11.8-fullmenu-stable
git push origin gh-pages --force
Danach wird automatisch wieder das vollständige Menü, Theme und Layout geladen.
