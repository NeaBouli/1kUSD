#!/usr/bin/env bash
set -euo pipefail

FILE="docs/logs/DEV79_Dev7_Infra_CI_Docker_Pages_Plan.md"
LOG_FILE="logs/project.log"

echo "== DEV93 CI05: update DEV79 Dev7 infra plan with docs-build status =="

if [ ! -f "$FILE" ]; then
  echo "ERROR: $FILE not found – aborting."
  exit 1
fi

python3 - <<'PY'
from pathlib import Path

path = Path("docs/logs/DEV79_Dev7_Infra_CI_Docker_Pages_Plan.md")
text = path.read_text()

marker = "### Update DEV-93: Docs-Build CI integriert"

if marker in text:
    print("DEV-93 update already present in DEV79 Dev7 infra plan; no change.")
else:
    snippet = f"""
{marker}

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
"""
    if not text.endswith("\n"):
        text += "\n"
    text = text + "\n" + snippet.lstrip("\n") + "\n"
    path.write_text(text)
    print("✓ DEV-93 update section appended to DEV79 Dev7 infra plan.")
PY

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-93] ${timestamp} CI: documented docs-build workflow in DEV79 Dev7 infra plan." >> "$LOG_FILE"
echo "✓ Log updated at $LOG_FILE"

echo "== DEV93 CI05: done =="
