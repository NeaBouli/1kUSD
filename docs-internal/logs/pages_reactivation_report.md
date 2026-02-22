# GitHub Pages Re-Activation & Routing Repair Report

**Repository:** [NeaBouli/1kUSD](https://github.com/NeaBouli/1kUSD)  
**Date:** $(date +"%Y-%m-%d %H:%M:%S")  
**Engineer:** Code GPT (Assistant)  
**Collaborator:** test@tests-iMac  

---

## 🧠 Root Cause Analysis

1. **MkDocs routing worked locally**, but GitHub Pages returned 404 for most subpages.  
2. After `mkdocs gh-deploy --force --no-history`,  
   the `gh-pages` branch lost commit history.  
   GitHub Pages automatically **disabled itself** and switched into  
   `"build_type": "workflow"` mode.  
3. The site root (`/1kUSD/`) remained cached and accessible,  
   but all routed directories (e.g. `/GOVERNANCE/`, `/logs/project/`) returned 404.  

---

## 🩺 Diagnosis Process

| Step | Check | Result |
|------|--------|--------|
| 1️⃣ | Local `mkdocs build --clean` | ✅ Site built successfully |
| 2️⃣ | Confirmed `site/GOVERNANCE/index.html` present | ✅ |
| 3️⃣ | Verified GitHub API `/repos/.../pages` | `"status": null, "build_type": "workflow"` |
| 4️⃣ | Confirmed GitHub Pages not publishing | ❌ |
| 5️⃣ | Attempted re-enable via API POST | `409: already enabled` |
| 6️⃣ | Forced reset via API PUT with `"build_type":"legacy"` | ✅ Restored |
| 7️⃣ | Re-deployed via `mkdocs gh-deploy --force --no-history` | ✅ Success |
| 8️⃣ | Verified status `"built"` via API | ✅ Live deployment restored |

---

## 🧩 Final Working State

```json
{
  "status": "built",
  "build_type": "legacy",
  "source": {
    "branch": "gh-pages",
    "path": "/"
  }
}
All public URLs are now valid:

✅ https://neabouli.github.io/1kUSD/

✅ https://neabouli.github.io/1kUSD/GOVERNANCE/

✅ https://neabouli.github.io/1kUSD/logs/project/

🛠️ Key Fix Commands Summary
bash
Code kopieren
# Reset Pages build type to legacy (branch deployment)
gh api -X PUT \
  -H "Accept: application/vnd.github.v3+json" \
  /repos/NeaBouli/1kUSD/pages \
  -f 'source[branch]=gh-pages' \
  -f 'source[path]=/' \
  -f build_type='legacy'

# Verify
gh api /repos/NeaBouli/1kUSD/pages | jq

# Rebuild + Deploy
mkdocs gh-deploy --force --no-history
🧱 Preventive Recommendations
✅ Do not use --no-history unless required — it resets the Pages build pointer.

✅ If GitHub Pages UI is unresponsive (“Save” greyed out):
use the CLI fix above.

✅ Add future doc reports under docs/logs/ (standard practice).

✅ Run docs/scripts/scan_docs.sh before any docs deployment.

🧩 Optional: Add CI check for "status": "built" in pre-deploy workflow.

🪪 Notes for Future Developers
The Pages deployment model is now stable (legacy).

Branch gh-pages contains valid built site content.

Any re-deploy will immediately publish under /1kUSD/.

All .md internal links were normalized to folder URLs (/GOVERNANCE/ not .md).

This report documents the full Pages recovery and routing stabilization for future maintainers.
