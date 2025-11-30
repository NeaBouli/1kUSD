#!/usr/bin/env bash
set -euo pipefail

echo "== DEV93 CI02: add Docs Build badge to README =="

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

README="README.md"
LOG_FILE="logs/project.log"

python3 - <<'PY'
from pathlib import Path

path = Path("README.md")
text = path.read_text()

badge = "[![Docs Build](https://github.com/NeaBouli/1kUSD/actions/workflows/docs-build.yml/badge.svg)](https://github.com/NeaBouli/1kUSD/actions/workflows/docs-build.yml)"

if "docs-build.yml/badge.svg" in text:
    print("Docs Build badge already present; no change.")
else:
    lines = text.splitlines(keepends=True)
    insert_idx = None

    # erste Überschrift als Anker nehmen (meistens "# 1kUSD ..." o.ä.)
    for i, line in enumerate(lines):
        if line.lstrip().startswith("# "):
            insert_idx = i + 1
            break

    if insert_idx is None:
        # Fallback: am Anfang einfügen
        new_text = badge + "\n\n" + text
        print("No top-level heading found; prepended Docs Build badge to README.")
    else:
        # Falls direkt eine Leerzeile folgt, Badge danach einfügen
        if insert_idx < len(lines) and lines[insert_idx].strip() == "":
            insert_idx += 1
        lines.insert(insert_idx, badge + "\n\n")
        new_text = "".join(lines)
        print(f"Inserted Docs Build badge after line {insert_idx}.")

    path.write_text(new_text)
PY

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-93] ${timestamp} CI: added Docs Build badge (docs-build.yml) to README." >> "$LOG_FILE"
echo "✓ Log updated at $LOG_FILE"

echo "== DEV93 CI02: done =="
