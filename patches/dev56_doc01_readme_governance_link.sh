#!/usr/bin/env bash
set -euo pipefail

FILE="README.md"

echo "== DEV56 DOC01: wire Governance & parameter docs into README =="

cat <<'EOL' >> "$FILE"

## Governance & Parameters

- **Governance Parameter Playbook (DE):** \`docs/governance/parameter_playbook.md\`
- **PSM Parameter & Registry Map:** \`docs/architecture/psm_parameters.md\`
- **Economic Layer (PSM + Oracle Health):**
  - PSM decimals/fees/spreads: \`docs/architecture/psm_dev43-45.md\`
  - Oracle health gates (stale/diff): Oracle-Abschnitt in dieser README

EOL

echo "✓ Governance & parameter docs section appended to $FILE"
