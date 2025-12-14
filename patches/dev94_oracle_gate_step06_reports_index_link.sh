#!/usr/bin/env bash
set -euo pipefail

REPORTS_INDEX="docs/reports/REPORTS_INDEX.md"

if [ ! -f "$REPORTS_INDEX" ]; then
  echo "ERROR: $REPORTS_INDEX not found (run from repo root)" >&2
  exit 1
fi

python3 - << 'PY'
from pathlib import Path

path = Path("docs/reports/REPORTS_INDEX.md")
text = path.read_text(encoding="utf-8")

block = """
### Release tagging – OracleRequired docs gate (v0.51+)

- `docs/logs/RELEASE_TAGGING_GUIDE_v0.51.x.md` – release tagging guide for v0.51+, including
  the OracleRequired docs gate. This guide is the human companion to:

  - the Architect's OracleRequired bundle
  - `scripts/check_release_status.sh` (status + OracleRequired docs gate)
"""

if "Release tagging \u2013 OracleRequired docs gate (v0.51+)" in text:
    print("OracleRequired release tagging section already present; no changes made.")
else:
    if not text.endswith("\n"):
        text += "\n"
    text += block.lstrip("\n") + "\n"
    path.write_text(text, encoding="utf-8")
    print("OracleRequired release tagging section appended to REPORTS_INDEX.md.")
PY

echo "[DEV-94] $(date -u +\"%Y-%m-%dT%H:%M:%SZ\") link RELEASE_TAGGING_GUIDE_v0.51.x into REPORTS_INDEX.md (OracleRequired gate)" >> logs/project.log

echo "== DEV-94 gate step06: REPORTS_INDEX.md updated with OracleRequired release tagging link =="
