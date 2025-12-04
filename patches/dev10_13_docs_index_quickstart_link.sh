#!/bin/bash
set -e

echo "== DEV-10 13: link Developer Quickstart from docs/index.md =="

DOCS_INDEX="docs/index.md"

if [ ! -f "$DOCS_INDEX" ]; then
  echo "docs/index.md not found, aborting."
  exit 1
fi

# Nur anhängen, wenn noch kein Hinweis auf DEV_Developer_Quickstart.md existiert
if grep -q "DEV_Developer_Quickstart.md" "$DOCS_INDEX"; then
  echo "Developer Quickstart already linked in docs/index.md, nothing to do."
else
  cat <<'EOD' >> "$DOCS_INDEX"

---

## Developer Quickstart

If you are new to the 1kUSD repository and want a concise overview of how to
set up your environment, run tests and follow the patch-based workflow, see:

- \`dev/DEV_Developer_Quickstart.md\`

This page complements the DEV-9 and DEV-10 documents and is intended as a
first stop for new contributors.
EOD
fi

# Log entry
LOG_FILE="logs/project.log"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-10 13] ${timestamp} Linked Developer Quickstart from docs/index.md" >> "$LOG_FILE"

echo "== DEV-10 13 done =="
