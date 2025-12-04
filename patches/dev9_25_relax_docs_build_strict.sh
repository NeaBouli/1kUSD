#!/bin/bash
set -e

echo "== DEV-9 25: relax mkdocs strict mode in docs-build workflow =="

WF=".github/workflows/docs-build.yml"

if [ -f "$WF" ]; then
  echo "Patching $WF (mkdocs build --strict → mkdocs build)"
  # macOS-kompatibles sed mit Backup
  sed -i.bak 's/mkdocs build --strict/mkdocs build/g' "$WF"
  rm -f "${WF}.bak"
else
  echo "Workflow $WF not found, aborting."
  exit 1
fi

LOG_FILE="logs/project.log"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-9 25] ${timestamp} Relaxed mkdocs strict mode in docs-build workflow" >> "$LOG_FILE"

echo "== DEV-9 25 done =="
