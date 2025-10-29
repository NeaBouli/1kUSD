# 🧑‍💻 Developer FAQ — 1kUSD Documentation Maintenance

**Repository:** [NeaBouli/1kUSD](https://github.com/NeaBouli/1kUSD)  
**Last Update:** $(date +"%Y-%m-%d %H:%M:%S")  
**Maintainers:** All future doc maintainers / contributors  

---

## 🧩 General Overview

This document centralizes the operational knowledge required to maintain  
and troubleshoot the 1kUSD documentation system built with **MkDocs + Material Theme**  
and deployed through **GitHub Pages (legacy mode)**.

---

## 🧱 1️⃣ Core Commands

### 🔧 Local Build
```bash
source .venv/bin/activate
mkdocs build --clean
🌍 Local Preview
bash
Code kopieren
mkdocs serve --dev-addr=127.0.0.1:8000
🚀 Deployment
bash
Code kopieren
mkdocs gh-deploy --force --no-history
⚠️ Use --no-history only when necessary (e.g. full rebuilds).
Frequent use may reset GitHub Pages configuration.

⚙️ 2️⃣ Validation Scripts
🔍 Structure Scan
Checks docs integrity, missing files, and naming policy.

bash
Code kopieren
./docs/scripts/scan_docs.sh
Generates:

docs/logs/docs_structure_scan.log

docs/logs/dev11_routing_fix_report.md

🧠 Routing Diagnostics
Validates if built pages exist in both site/ and gh-pages:

bash
Code kopieren
bash docs/scripts/diagnose_pages.sh
(See report in docs/logs/routing_diagnosis.log)

🌐 3️⃣ GitHub Pages Maintenance
🔁 Verify Status
bash
Code kopieren
gh api /repos/NeaBouli/1kUSD/pages | jq
Expected:

json
Code kopieren
"status": "built",
"build_type": "legacy"
🔧 Reactivate if Disabled
bash
Code kopieren
gh api -X PUT \
  -H "Accept: application/vnd.github.v3+json" \
  /repos/NeaBouli/1kUSD/pages \
  -f 'source[branch]=gh-pages' \
  -f 'source[path]=/' \
  -f build_type='legacy'
🚨 Force Rebuild
bash
Code kopieren
gh api -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  /repos/NeaBouli/1kUSD/pages/builds
🔗 4️⃣ Known Issues & Solutions
Issue	Symptom	Fix
❌ 404 on subpages	GitHub Pages disabled or in workflow mode	Run PUT reset above
⚠️ “Save” button in Pages UI disabled	Pages config lost	Use CLI PUT fix
🚧 Only root /1kUSD/ works	Cached root build only	Trigger rebuild
🔁 .md links lead to 404	Wrong relative linking	Replace .md → folder style /path/
❗ “Config file mkdocs.yml not found”	Running mkdocs inside /docs/	Run from project root

🧠 5️⃣ Best Practices for Future Devs
Always run scan_docs.sh before deploying.

Do not remove docs/logs/ — it tracks documentation changes.

Keep mkdocs.yml at project root.

Maintain legacy mode (branch-based Pages).

Include new .md files explicitly in nav: section of mkdocs.yml.

📘 References
MkDocs Official Documentation

Material for MkDocs

GitHub Pages REST API

Compiled by Code GPT — Operational record of Pages restoration and documentation process (Oct 2025).
