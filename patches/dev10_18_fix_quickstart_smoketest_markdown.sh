#!/bin/bash
set -e

echo "== DEV-10 18: tighten Dev CI smoketest section & fix dev10_17 script =="

FILE="docs/dev/DEV_Developer_Quickstart.md"
SCRIPT="patches/dev10_17_fix_quickstart_smoketest_markdown.sh"

if [ ! -f "$FILE" ]; then
  echo "$FILE not found, aborting."
  exit 1
fi

# 1) Quickstart: Smoketest-Abschnitt ab Überschrift entfernen
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

# 2) Korrigierten Abschnitt anhängen
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

3) dev10_17 Script: "Log entry" Zeile kommentieren, damit macOS log nicht anspringt
if [ -f "$SCRIPT" ]; then
sed -i.bak 's/^Log entry$/# Log entry/' "$SCRIPT" || true
rm -f "${SCRIPT}.bak"
fi

4) Log-Eintrag
LOG_FILE="logs/project.log"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-10 18] ${timestamp} Tightened Dev CI smoketest section and fixed dev10_17 script comment" >> "$LOG_FILE"

echo "== DEV-10 18 done =="
