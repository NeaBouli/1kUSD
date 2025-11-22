#!/usr/bin/env bash
set -euo pipefail

FILE="README.md"

echo "== DEV59 DOC02: link governance parameter how-to from README =="

cat <<'EOL' >> "$FILE"

### Further reading

- **Governance Parameter How-To (DE):** \`docs/governance/parameter_howto.md\`

EOL

echo "✓ Governance Parameter How-To linked from $FILE"
