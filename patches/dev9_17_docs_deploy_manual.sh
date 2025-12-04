#!/bin/bash
set -e

echo "== DEV-9 17: Switch deploy-docs workflow to manual trigger =="

TARGET=".github/workflows/deploy-docs.yml"

if [ ! -f "$TARGET" ]; then
  echo "ERROR: $TARGET not found" >&2
  exit 1
fi

python3 <<'PY'
from pathlib import Path
import sys

path = Path(".github/workflows/deploy-docs.yml")
lines = path.read_text(encoding="utf-8").splitlines(True)

on_start = None
for i, l in enumerate(lines):
    stripped = l.strip()
    if stripped.startswith("on:"):
        on_start = i
        break

if on_start is None:
    print("WARNING: no 'on:' block found in deploy-docs.yml; no changes applied.", file=sys.stderr)
else:
    j = on_start + 1
    while j < len(lines):
        l = lines[j]
        stripped = l.strip()
        # nächster Top-Level-Key (keine Einrückung, keine leere Zeile, kein Kommentar)
        if (stripped and not l.startswith(" ")) and not stripped.startswith("#"):
            break
        j += 1

    new_block = [
        "on:\n",
        "  workflow_dispatch:\n",
        "\n",
    ]
    lines = lines[:on_start] + new_block + lines[j:]
    path.write_text("".join(lines), encoding="utf-8")
PY

LOG_FILE="logs/project.log"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-9 17] ${timestamp} Switched deploy-docs.yml to manual workflow_dispatch trigger" >> "$LOG_FILE"

echo "== DEV-9 17 done =="
