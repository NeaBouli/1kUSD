#!/usr/bin/env bash
set -euo pipefail

echo "== DEV90 DOC01: create docs/index.md stub for MkDocs =="

DOC="docs/index.md"
LOG_FILE="logs/project.log"

mkdir -p "$(dirname "$DOC")"
mkdir -p "$(dirname "$LOG_FILE")"

cat > "$DOC" <<'MD'
# 1kUSD Documentation Index

This file exists as the MkDocs `index.md` entry point and to satisfy
internal links that refer to `../index.md`.

For the main project overviews, see:

- [Project README](README.md)
- [Documentation INDEX](INDEX.md)

Both files live in this `docs/` directory and are the canonical entrypoints
for contributors and reviewers.
MD

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-90] ${timestamp} Docs: add docs/index.md stub to satisfy MkDocs nav and cross-links." >> "$LOG_FILE"

echo "✓ docs/index.md written"
echo "✓ Log updated at $LOG_FILE"
echo "== DEV90 DOC01: done =="
