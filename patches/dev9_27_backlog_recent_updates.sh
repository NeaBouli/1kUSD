#!/bin/bash
set -e

echo "== DEV-9 27: append recent DEV-9 updates to backlog =="

BACKLOG_FILE="docs/dev/DEV9_Backlog.md"

if [ ! -f "$BACKLOG_FILE" ]; then
  echo "Backlog file $BACKLOG_FILE not found, aborting."
  exit 1
fi

cat <<'EOD' >> "$BACKLOG_FILE"

---

## Recent updates (DEV-9 19–25)

- **DEV-9 19 / 20 – Operator Guide & Fix**
  - Added \`docs/dev/DEV9_Operator_Guide.md\` (how to run DEV-9 tools & workflows).
  - Fixed script permissions and added missing log entry for DEV-9 19.

- **DEV-9 21 – Forge install flag fix**
  - Removed deprecated \`--no-commit\` flag from \`forge install\` in workflows.
  - Aligns CI with current Foundry CLI behavior.

- **DEV-9 23 / 24 – Docs linkcheck & dev docs overview**
  - Wired docs linkcheck + DEV-9 documentation into the docs/dev area.
  - Prepared for stricter link/quality checks without breaking existing docs.

- **DEV-9 25 / 26 – MkDocs strict mode relax**
  - Relaxed \`mkdocs build --strict\` to \`mkdocs build\` in docs workflows.
  - Prevents CI failures due to non-nav/legacy pages while keeping content intact.

EOD

LOG_FILE="logs/project.log"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-9 27] ${timestamp} Appended recent DEV-9 updates summary to DEV9_Backlog.md" >> "$LOG_FILE"

echo "== DEV-9 27 done =="
