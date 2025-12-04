#!/bin/bash
set -e

echo "== DEV-10 16: add Dev CI smoketest hint to Developer Quickstart =="

FILE="docs/dev/DEV_Developer_Quickstart.md"

if [ ! -f "$FILE" ]; then
  echo "$FILE not found, aborting."
  exit 1
fi

# Nur anhängen, wenn der Abschnitt noch nicht existiert
if grep -q "Dev CI smoketest (optional)" "$FILE"; then
  echo "Dev CI smoketest section already present, nothing to do."
else
  cat <<'EOD' >> "$FILE"

---

## Dev CI smoketest (optional)

If you want to run a small local healthcheck that mirrors parts of the CI,
you can use the helper script:

```bash
patches/dev9_34_dev_ci_smoketest.sh
This script will, if available:

run `forge test`,

run `mkdocs build`,

execute `scripts/check_release_status.sh`.

It does not change contracts or configuration; it is only a convenience
helper for contributors before pushing patches.
EOD
fi

LOG_FILE="logs/project.log"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-10 16] ${timestamp} Added Dev CI smoketest hint to Developer Quickstart" >> "$LOG_FILE"

echo "== DEV-10 16 done =="
