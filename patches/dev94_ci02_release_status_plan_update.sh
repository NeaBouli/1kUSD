#!/usr/bin/env bash
set -euo pipefail

echo "== DEV94 CI02: update DEV94_Infra_Release_Tag_Checks_Plan with release-status workflow =="

LOG_FILE="logs/project.log"
DOC="docs/logs/DEV94_Infra_Release_Tag_Checks_Plan.md"

if [ ! -f "$DOC" ]; then
  echo "ERROR: $DOC not found. Abort."
  exit 1
fi

python3 - <<'PY'
from pathlib import Path

path = Path("docs/logs/DEV94_Infra_Release_Tag_Checks_Plan.md")
text = path.read_text()

marker = "### Update DEV-94: release-status workflow umgesetzt"

if marker in text:
    print("DEV-94 update already present in DEV94 infra plan; no change.")
else:
    snippet = f"""
{marker}

- Der geplante Release-Tag-Check wurde teilweise umgesetzt:
  - Neuer Workflow: `.github/workflows/release-status.yml`
  - Trigger: `push` auf Tags `v0.51.*`
  - Aktion: Ausführung von `scripts/check_release_status.sh`.
- Damit ist sichergestellt, dass bei v0.51.x-Tags:
  - alle Kern-Status/Report-Files vorhanden und nicht leer sind.
  - ein fehlender/inkonsistenter Status den Release-Tag im CI sichtbar rot macht.
- Weitere, evtl. spätere Erweiterungen (z.B. zusätzliche Prüfungen für künftige
  Major-/Minor-Releases) können als eigene DEV-/INFRA-Tickets ergänzt werden.
"""

    if not text.endswith("\n"):
        text += "\n"
    text = text + "\n" + snippet.lstrip("\n") + "\n"
    path.write_text(text)
    print("✓ DEV-94 update section appended to DEV94 infra release-tag plan.")
PY

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-94] ${timestamp} CI: documented release-status workflow in DEV94 Infra release-tag plan." >> "$LOG_FILE"

echo "✓ Log updated at $LOG_FILE"
echo "== DEV94 CI02: done =="
