#!/bin/bash
set -e

echo "== DEV-9 20: fix DEV-9 19 bookkeeping =="

# 1) Script von DEV-9 19 ausführbar machen (für Re-Runs/Reprod)
if [ -f patches/dev9_19_operator_guide.sh ]; then
  chmod +x patches/dev9_19_operator_guide.sh || true
fi

# 2) Fehlenden Log-Eintrag für DEV-9 19 nachziehen (idempotent)
LOG_FILE="logs/project.log"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

if ! grep -q "DEV-9 19" "$LOG_FILE"; then
  echo "[DEV-9 19] ${timestamp} Added DEV9_Operator_Guide.md" >> "$LOG_FILE"
fi

# 3) Log für diesen Fix
timestamp2="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-9 20] ${timestamp2} Fixed DEV-9 19 script permissions and log entry" >> "$LOG_FILE"

echo "== DEV-9 20 done =="
