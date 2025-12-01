#!/usr/bin/env bash
set -euo pipefail

echo "== DEV93 CI04: append DEV-93 docs-build update to DEV79 CI inventory =="

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

DOC="docs/logs/DEV79_Infra_CI_Inventory.md"
LOG_FILE="logs/project.log"

if [ ! -f "$DOC" ]; then
  echo "Error: $DOC not found. Aborting."
  exit 1
fi

python3 - <<'PY'
from pathlib import Path

path = Path("docs/logs/DEV79_Infra_CI_Inventory.md")
text = path.read_text()

marker = "### Update DEV-93: docs-build.yml hinzugefügt"

if marker in text:
    print("DEV-93 update already present in DEV79 inventory; no change.")
else:
    snippet = f"""
{marker}

- Nach der ursprünglichen CI-Inventur wurde mit **DEV-93** ein zusätzlicher
  Workflow hinzugefügt:
  - Datei: `.github/workflows/docs-build.yml`
  - Aufgabe: `mkdocs build` auf `push` / `pull_request` nach `main`.
- Dieser Workflow stellt sicher, dass die Dokumentation weiterhin baubar ist
  und macht Build-Fehler früh im CI sichtbar.
- Die ursprüngliche Inventur bleibt als Snapshot bestehen; dieses Update
  dokumentiert nur die Erweiterung durch DEV-93.
"""

    if not text.endswith("\\n"):
        text += "\\n"
    text = text + "\\n" + snippet.lstrip("\\n") + "\\n"
    path.write_text(text)
    print("✓ DEV-93 update section appended to DEV79 CI inventory.")
PY

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-93] ${timestamp} CI: documented docs-build workflow (DEV-93) in DEV79 CI inventory." >> "$LOG_FILE"
echo "✓ Log updated at $LOG_FILE"

echo "== DEV93 CI04: done =="
