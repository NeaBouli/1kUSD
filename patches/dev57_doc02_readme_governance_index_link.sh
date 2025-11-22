#!/usr/bin/env bash
set -euo pipefail

FILE="README.md"

echo "== DEV57 DOC02: link governance overview index from README =="

# Fügt unterhalb der Überschrift "Governance & Parameters" einen weiteren Bullet ein
# für docs/governance/index.md, ohne die bestehende Struktur zu verändern.
perl -0pi -e '
  s/## Governance & Parameters\n\n/## Governance & Parameters\n\n- **Governance Overview (DE):** `docs\/governance\/index.md`\n\n/
' "$FILE"

echo "✓ Governance overview index linked from $FILE"
