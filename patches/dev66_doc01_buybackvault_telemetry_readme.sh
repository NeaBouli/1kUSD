#!/usr/bin/env bash
set -euo pipefail

README_FILE="README.md"
LOG_FILE="logs/project.log"

echo "== DEV66 DOC01: link BuybackVault telemetry spec from README =="

cat <<'EOL' >> "$README_FILE"

## BuybackVault Telemetry

Buyback-bezogene Onchain-Aktivitäten des BuybackVault sollen über den
Indexing-Stack beobachtet werden:

- Detail-Spezifikation der geplanten Events (StableFunded, BuybackExecuted,
  StableWithdrawn, AssetWithdrawn): `indexer/docs/BUYBACKVAULT_TELEMETRY.md`
- Einbettung in den globalen Indexing/Telemetry-Stack:
  `indexer/docs/INDEXING_TELEMETRY.md`
EOL

echo "✓ BuybackVault telemetry section appended to $README_FILE"

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-66] ${timestamp} BuybackVault: README links BuybackVault telemetry spec and global indexing doc." >> "$LOG_FILE"
echo "✓ Log updated at $LOG_FILE"

echo "== DEV66 DOC01: done =="
