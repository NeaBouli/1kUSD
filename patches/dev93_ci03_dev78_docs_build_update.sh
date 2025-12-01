#!/usr/bin/env bash
set -euo pipefail

echo "== DEV93 CI03: append DEV-93 docs-build update to DEV78 checklist =="

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

DOC="docs/logs/DEV78_Infra_CI_StrategyRisk_Docs_Checklist.md"
LOG_FILE="logs/project.log"

if [ ! -f "$DOC" ]; then
  echo "Error: $DOC not found. Aborting."
  exit 1
fi

python3 - <<'PY'
from pathlib import Path

path = Path("docs/logs/DEV78_Infra_CI_StrategyRisk_Docs_Checklist.md")
text = path.read_text()

marker = "### Update DEV-93: Docs-Build CI umgesetzt"

if marker in text:
    print("DEV-93 update already present in DEV78 checklist; no change.")
else:
    snippet = f"""
{marker}

- Der Punkt „Docs/MkDocs in CI einhängen“ ist für den reinen Build-Check
  mit **DEV-93** umgesetzt:
  - Workflow: `.github/workflows/docs-build.yml`
  - Aktion: `mkdocs build` auf `push` / `pull_request` nach `main`.
- Zusätzlich wurde ein **Docs Build**-Badge im `README.md` ergänzt, der den
  Status des Workflows sichtbar macht.
- Weitere Schritte (z.B. Release-Tag-Checks, engere Kopplung an
  `PROJECT_STATUS_*.md`) bleiben als separate INFRA-Tickets offen.
"""

    if not text.endswith("\n"):
        text += "\n"
    text = text + "\n" + snippet.lstrip("\n") + "\n"
    path.write_text(text)
    print("✓ DEV-93 update section appended to DEV78 checklist.")
PY

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-93] ${timestamp} CI: documented docs-build workflow (DEV-93) in DEV78 Infra checklist." >> "$LOG_FILE"
echo "✓ Log updated at $LOG_FILE"

echo "== DEV93 CI03: done =="
