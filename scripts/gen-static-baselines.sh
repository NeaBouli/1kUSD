#!/usr/bin/env bash
set -euo pipefail
mkdir -p reports security/baselines

Slither (placeholder JSON if slither not installed)

if command -v slither >/dev/null 2>&1; then
slither . --config-file security/baselines/SLITHER.config.json --json reports/slither.json || true
else
echo '{ "tool":"slither","version":"n/a","findings":[] }' > reports/slither.json
fi

Mythril (placeholder JSON if myth not installed)

if command -v myth >/dev/null 2>&1; then
myth analyze contracts --out-format jsonv2 --execution-timeout 120 > reports/mythril.json || true
else
echo '{ "tool":"mythril","version":"n/a","findings":[] }' > reports/mythril.json
fi

echo "Baselines generated into reports/ (placeholders if tools missing)."
