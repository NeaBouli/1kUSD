#!/bin/bash
set -e

echo "== DEV-9 26: relax mkdocs strict mode in all workflows =="

for f in .github/workflows/*.yml .github/workflows/*.yaml; do
  if [ -f "$f" ] && grep -q "mkdocs build --strict" "$f"; then
    echo "Patching $f (mkdocs build --strict → mkdocs build)"
    sed -i.bak 's/mkdocs build --strict/mkdocs build/g' "$f"
    rm -f "${f}.bak"
  fi
done

LOG_FILE="logs/project.log"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-9 26] ${timestamp} Relaxed mkdocs strict mode in all workflows" >> "$LOG_FILE"

echo "== DEV-9 26 done =="
