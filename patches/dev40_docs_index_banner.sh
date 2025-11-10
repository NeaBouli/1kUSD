#!/usr/bin/env bash
set -euo pipefail
FILE="docs/index.md"
TMP="${FILE}.tmp"

banner='!!! success "Latest: DEV-40 — OracleWatcher & Interface Recovery"
    - [Release Report](reports/DEV40_RELEASE_REPORT.md)
    - [Phase 2 Report](reports/DEV40_PHASE2_REPORT.md)
    - [Architect Handoff](reports/DEV40_ARCHITECT_HANDOFF.md)
'

# Falls Banner bereits existiert, nichts tun
if grep -Fq 'Latest: DEV-40 — OracleWatcher & Interface Recovery' "$FILE"; then
  echo "Banner already present, skipping."
  exit 0
fi

# Wenn Datei existiert, Banner ganz oben einfügen, sonst Datei mit Banner erstellen
if [ -f "$FILE" ]; then
  { printf "%s\n\n" "$banner"; cat "$FILE"; } > "$TMP" && mv "$TMP" "$FILE"
else
  mkdir -p docs
  printf "%s\n" "$banner" > "$FILE"
fi

echo "Inserted DEV-40 banner into docs/index.md"
