#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

FILE="README.md"
LOG_FILE="logs/project.log"

if [ ! -f "$FILE" ]; then
  echo "ERROR: $FILE not found. Aborting."
  exit 1
fi

python3 - << 'PY'
from pathlib import Path

path = Path("README.md")
text = path.read_text()

marker = "## Releases & status"

if marker in text:
    print("Releases & status section already present in README; no change.")
else:
    snippet = """
## Releases & status

- Manual release tagging for the Economic Layer v0.51.x is described in
  [`docs/logs/RELEASE_TAGGING_GUIDE_v0.51.x.md`](docs/logs/RELEASE_TAGGING_GUIDE_v0.51.x.md).
- Before creating a tag, you can run the local helper:

  ```bash
  scripts/check_release_status.sh
This checks that the core Economic Layer / BuybackVault reports and the
CI docs-build report (DEV-93) are present and non-empty.

The Docs Build workflow and badge above ensure that the MkDocs
documentation still builds successfully on every push / pull request
to main.
"""

lines = text.splitlines(keepends=True)
insert_idx = None

Wir hängen den Block möglichst weit oben ein:
direkt vor der ersten "## "-Überschrift, falls vorhanden.
for i, line in enumerate(lines):
if line.startswith("## "):
insert_idx = i
break

if insert_idx is None:
# Keine zweite Ebene gefunden – Abschnitt ans Ende anhängen
if not text.endswith("\n"):
text += "\n"
new_text = text + "\n" + snippet.lstrip("\n") + "\n"
print("No level-2 heading found; appended Releases & status section at end of README.")
else:
lines.insert(insert_idx, snippet.lstrip("\n") + "\n\n")
new_text = "".join(lines)
print(f"Inserted Releases & status section before first level-2 heading (line {insert_idx}).")

path.write_text(new_text)
PY

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-99] ${timestamp} Docs: added 'Releases & status' helper section to README." >> "$LOG_FILE"

echo "✓ README updated with Releases & status section"
echo "✓ Log updated at $LOG_FILE"
echo "== DEV99 DOC01: done =="
