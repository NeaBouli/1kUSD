#!/bin/bash
set -e

echo "== DEV-10 09: add Integrations & Dev Guides section to README =="

README_FILE="README.md"

if [ ! -f "$README_FILE" ]; then
  echo "README.md not found, aborting."
  exit 1
fi

# Einfach einen kleinen Abschnitt am Ende anhängen, falls noch nicht vorhanden
if grep -q "Integrations & Developer Guides (DEV-10)" "$README_FILE"; then
  echo "Integrations section already present in README.md, nothing to do."
else
  cat <<'EOD' >> "$README_FILE"

---

## Integrations & Developer Guides (DEV-10)

The 1kUSD Economic Core now ships with dedicated documentation for external
integrators. If you are building wallets, dApps, indexers or monitoring
around 1kUSD, start here:

- **Integrations index**  
  High-level entry point into all integration guides.  
  See: \`docs/integrations/index.md\`

- **Core guides**  
  - PSM Integration Guide  
  - Oracle Aggregator Integration Guide  
  - Guardian & Safety Events Guide  
  - BuybackVault Observer Guide  

For infra / CI details supporting these docs, see the DEV-9 infra status and
backlog under \`docs/dev/\`.
EOD
fi

LOG_FILE="logs/project.log"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-10 09] ${timestamp} Added Integrations & Developer Guides section to README.md" >> "$LOG_FILE"

echo "== DEV-10 09 done =="
