#!/bin/bash
set -e

echo "== DEV-9 16: Adjust forge install flag in foundry-test workflow =="

TARGET=".github/workflows/foundry-test.yml"

if [ ! -f "$TARGET" ]; then
  echo "ERROR: $TARGET not found" >&2
  exit 1
fi

python3 <<'PY'
from pathlib import Path
import sys

path = Path(".github/workflows/foundry-test.yml")
text = path.read_text(encoding="utf-8")

old = "forge install openzeppelin/openzeppelin-contracts@v5.0.2 --no-commit"
new = "forge install openzeppelin/openzeppelin-contracts@v5.0.2"

if old not in text:
    print("WARNING: pattern not found in foundry-test.yml; no changes applied.", file=sys.stderr)
else:
    text = text.replace(old, new)
    path.write_text(text, encoding="utf-8")
PY

LOG_FILE="logs/project.log"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-9 16] ${timestamp} Adjusted forge install command in foundry-test workflow (drop --no-commit)" >> "$LOG_FILE"

echo "== DEV-9 16 done =="
