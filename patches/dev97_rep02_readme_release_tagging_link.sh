#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

README="README.md"
LOG_FILE="logs/project.log"

python3 - << 'PY'
from pathlib import Path

path = Path("README.md")
text = path.read_text()

marker = "### Release tagging (v0.51.x baseline)"

if marker in text:
    print("Release tagging section already present; no change.")
else:
    snippet = """
### Release tagging (v0.51.x baseline)

- For manual release tagging, see:
  - `docs/logs/RELEASE_TAGGING_GUIDE_v0.51.x.md`
- Before creating a tag, run:
  - \`scripts/check_release_status.sh\`
- GitHub Releases are created manually based on these checks; GitHub Pages
  is still deployed via:
  - \`mkdocs gh-deploy --force --no-history\`
"""

    if not text.endswith("\\n"):
        text += "\\n"
    text = text + "\\n" + snippet.lstrip("\\n") + "\\n"
    path.write_text(text)
    print("✓ Release tagging section appended to README.md")
PY

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-97] ${timestamp} Release: linked release tagging guide + status script from README." >> "$LOG_FILE"

echo "✓ Log updated at $LOG_FILE"
echo "== DEV97 REP02: done =="
