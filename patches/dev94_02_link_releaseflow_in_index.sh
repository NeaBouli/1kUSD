#!/bin/bash
set -e

echo "== DEV-94 02: link ReleaseFlow plan from docs index =="

INDEX_FILE="docs/INDEX.md"

if [ ! -f "$INDEX_FILE" ]; then
  echo "docs/INDEX.md not found, aborting."
  exit 1
fi

# 1) Append a small Release Flow section at the end of the index
cat <<'EOD' >> "$INDEX_FILE"

## Release flow (DEV-94)

- [DEV94_ReleaseFlow_Plan_r2](dev/DEV94_ReleaseFlow_Plan_r2.md) – Current & target release flow and DEV-94 backlog (docs-only, no CI changes).
EOD

# 2) Append log entry
LOG_FILE="logs/project.log"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-94 02] ${timestamp} Linked DEV94_ReleaseFlow_Plan_r2 from docs/INDEX.md" >> "$LOG_FILE"

echo "== DEV-94 02 done =="
