#!/bin/bash
set -e

echo "== DEV-9 21: fix forge install --no-commit flag in workflows =="

# 1) Alle Workflow-YAMLs prüfen und veraltetes Flag entfernen
for f in .github/workflows/*.yml .github/workflows/*.yaml; do
  if [ -f "$f" ] && grep -q -- "--no-commit" "$f"; then
    echo "Patching $f"
    # macOS-kompatibles in-place sed mit Backup
    sed -i.bak "s/ --no-commit//g" "$f"
    rm -f "$f.bak"
  fi
done

# 2) Log-Eintrag
LOG_FILE="logs/project.log"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-9 21] ${timestamp} Removed deprecated --no-commit flag from forge install in workflows" >> "$LOG_FILE"

echo "== DEV-9 21 done =="
