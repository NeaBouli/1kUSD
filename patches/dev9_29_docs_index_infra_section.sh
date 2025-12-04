#!/bin/bash
set -e

echo "== DEV-9 29: add Infra & CI section to docs/index.md =="

INDEX_FILE="docs/index.md"

if [ ! -f "$INDEX_FILE" ]; then
  echo "docs/index.md not found, aborting."
  exit 1
fi

# Nur einmal anhängen, falls der Block noch nicht existiert
if grep -q "Infrastructure & CI (DEV-9 snapshot)" "$INDEX_FILE"; then
  echo "Infra & CI (DEV-9 snapshot) section already present, nothing to do."
else
  cat <<'EOD' >> "$INDEX_FILE"

---

## Infrastructure & CI (DEV-9 snapshot)

This section summarizes the current infra / CI helpers maintained by DEV-9:

- **DEV-9 Infra Status (r2)**  
  High-level overview of what DEV-9 changed and which areas are in scope.  
  See: \`dev/DEV9_Status_Infra_r2.md\`

- **DEV-9 Backlog**  
  Living backlog for infra/CI work, including Zone A/B/C separation and future blocks.  
  See: \`dev/DEV9_Backlog.md\`

- **DEV-9 Operator Guide**  
  How to run the manual workflows and tools introduced by DEV-9  
  (docker baseline build, docs linkcheck, CI checks).  
  See: \`dev/DEV9_Operator_Guide.md\`

The goal is to keep infra/CI changes transparent and reproducible without touching
the core Economic Layer contracts.
EOD
fi

LOG_FILE="logs/project.log"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-9 29] ${timestamp} Added Infra & CI (DEV-9 snapshot) section to docs/index.md" >> "$LOG_FILE"

echo "== DEV-9 29 done =="
