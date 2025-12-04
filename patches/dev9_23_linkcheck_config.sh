#!/bin/bash
set -e

echo "== DEV-9 23: add LINKCHECK_CONFIG for docs linkcheck =="

# 1) tooling-Verzeichnis sicherstellen
mkdir -p tooling

# 2) Lychee/Linkcheck-Config schreiben (neutral, konservativ)
cat <<'JSON' > tooling/LINKCHECK_CONFIG.json
{
  "//": [
    "Linkcheck configuration for docs/.",
    "This file does NOT change CI by itself.",
    "It is intended to be used by the manual docs-linkcheck workflow later."
  ],
  "max_concurrency": 4,
  "max_retries": 2,
  "timeout": 10,
  "exclude": [
    "localhost",
    "127.0.0.1",
    "0.0.0.0",
    "example.com"
  ],
  "accept": [
    "200",
    "301",
    "302",
    "429"
  ],
  "user_agent": "1kUSD-docs-linkcheck",
  "cache": true
}
JSON

# 3) Log-Eintrag
LOG_FILE="logs/project.log"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-9 23] ${timestamp} Added tooling/LINKCHECK_CONFIG.json for docs linkcheck" >> "$LOG_FILE"

echo "== DEV-9 23 done =="
