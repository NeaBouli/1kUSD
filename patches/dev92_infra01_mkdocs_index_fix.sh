#!/usr/bin/env bash
set -euo pipefail

echo "== DEV92 INFRA01: ensure docs/index.md exists for MkDocs =="

DOCS_DIR="docs"
SRC="${DOCS_DIR}/INDEX.md"
DEST="${DOCS_DIR}/index.md"
LOG_FILE="logs/project.log"

if [ ! -f "$SRC" ]; then
  echo "ERROR: ${SRC} not found – cannot create index.md mirror." >&2
  exit 1
fi

if [ -f "$DEST" ]; then
  echo "docs/index.md already exists; no change."
else
  cp "$SRC" "$DEST"
  echo "✓ Copied ${SRC} -> ${DEST} to satisfy MkDocs nav and ../index.md links"
fi

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-92] ${timestamp} Infra: ensured docs/index.md exists (mirroring INDEX.md) for MkDocs nav + relative links." >> "${LOG_FILE}"

echo "✓ Log updated at ${LOG_FILE}"
echo "== DEV92 INFRA01: done =="
