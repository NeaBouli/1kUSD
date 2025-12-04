#!/bin/bash
set -e

echo "== DEV-10 15: add Developer Quickstart hint to README =="

README_FILE="README.md"

if [ ! -f "$README_FILE" ]; then
  echo "README.md not found, aborting."
  exit 1
fi

# Nur anhängen, wenn der Hinweis noch nicht existiert
if grep -q "Developer Quickstart (for contributors)" "$README_FILE"; then
  echo "Developer Quickstart section already present in README.md, nothing to do."
else
  cat <<'EOD' >> "$README_FILE"

---

## Developer Quickstart (for contributors)

If you plan to work directly on the 1kUSD repository (CI, docs, tests, or
future dev tickets), there are two recommended entry points:

- **Developer Quickstart**
  Short, opinionated overview of how to:
  - set up your local environment,
  - run tests,
  - use the patch-based workflow.
  See: \`docs/dev/DEV_Developer_Quickstart.md\`

- **DEV Roles Index**
  Map of the main DEV roles (DEV-7, DEV-8, DEV-9, DEV-10) and their key
  documents.
  See: \`docs/dev/DEV_Roles_Index.md\`

These pages are meant to keep contributor onboarding consistent without
changing any Economic Layer or contract behaviour.
EOD
fi

LOG_FILE="logs/project.log"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-10 15] ${timestamp} Added Developer Quickstart hint to README.md" >> "$LOG_FILE"

echo "== DEV-10 15 done =="
