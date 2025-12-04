#!/bin/bash
set -e

echo "== DEV-10 17: fix Dev CI smoketest section markdown in Developer Quickstart =="

FILE="docs/dev/DEV_Developer_Quickstart.md"

if [ ! -f "$FILE" ]; then
  echo "$FILE not found, aborting."
  exit 1
fi

# Falls der Abschnitt existiert, alles ab der Überschrift entfernen
if grep -q "## Dev CI smoketest (optional)" "$FILE"; then
  tmp="${FILE}.tmp"
  awk '
    /^## Dev CI smoketest \(optional\)/ { exit }
    { print }
  ' "$FILE" > "$tmp"
  mv "$tmp" "$FILE"
else
  echo "Dev CI smoketest section not found, will append fresh section."
fi

# Korrigierten Abschnitt anhängen
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

Log entry
LOG_FILE="logs/project.log"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-10 17] ${timestamp} Fixed Dev CI smoketest section markdown in Developer Quickstart" >> "$LOG_FILE"

echo "== DEV-10 17 done =="
