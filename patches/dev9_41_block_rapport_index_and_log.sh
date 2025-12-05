#!/bin/bash
set -e

echo "== DEV-9 41: link block report from REPORTS_INDEX and add log entry =="

# 1) Link from REPORTS_INDEX (if present)
INDEX_FILE="docs/reports/REPORTS_INDEX.md"
if [ -f "$INDEX_FILE" ]; then
  if ! grep -q "BLOCK_DEV9_DEV10_Infra_Integrations_r1" "$INDEX_FILE"; then
    cat <<'EOR' >> "$INDEX_FILE"

- **BLOCK_DEV9_DEV10_Infra_Integrations_r1** – Infra & Integrations block report (DEV-9 / DEV-10, r1)
EOR
  else
    echo "Entry already present in REPORTS_INDEX.md"
  fi
else
  echo "REPORTS_INDEX.md not found, skipping index link."
fi

# 2) Append log entry
LOG_FILE="logs/project.log"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-9 41] ${timestamp} Linked BLOCK_DEV9_DEV10_Infra_Integrations_r1 from REPORTS_INDEX and added log entry" >> "$LOG_FILE"

echo "== DEV-9 41 done =="
