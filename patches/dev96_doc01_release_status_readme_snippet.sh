#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

README="README.md"
LOG_FILE="logs/project.log"

python3 - << 'PY'
from pathlib import Path

path = Path("README.md")
text = path.read_text()

marker = "## Release status check (local)"

if marker in text:
    print("Release status section already present in README; no change.")
else:
    snippet = """
## Release status check (local)

Before cutting a new tag you can run:

```bash
scripts/check_release_status.sh
This script checks that the key Economic Layer / BuybackVault /
StrategyEnforcement / Governance / CI status reports exist and are
non-empty, so you don’t accidentally tag a release with missing state.
"""

swift
Code kopieren
if not text.endswith("\n"):
    text += "\n"
text = text + "\n" + snippet.lstrip("\n") + "\n"
path.write_text(text)
print("✓ Release status section appended to README.md")
PY

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-96] ${timestamp} Docs: documented scripts/check_release_status.sh in README." >> "$LOG_FILE"

echo "✓ README updated with release status check section"
echo "✓ Log updated at $LOG_FILE"
echo "== DEV96 DOC01: done =="
