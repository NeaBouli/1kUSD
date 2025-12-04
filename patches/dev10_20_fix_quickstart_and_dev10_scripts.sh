#!/bin/bash
set -e

echo "== DEV-10 20: normalise Dev CI smoketest section and dev10 scripts =="

FILE="docs/dev/DEV_Developer_Quickstart.md"
SCRIPT17="patches/dev10_17_fix_quickstart_smoketest_markdown.sh"
SCRIPT18="patches/dev10_18_fix_quickstart_smoketest_markdown.sh"

if [ ! -f "$FILE" ]; then
  echo "$FILE not found, aborting."
  exit 1
fi

# 1) Smoketest-Abschnitt aus Quickstart entfernen (bis zur nächsten ##-Überschrift)
tmp="${FILE}.tmp"
awk '
  /^## Dev CI smoketest \(optional\)/ { in_block=1; next }
  /^## / && in_block { in_block=0 }
  !in_block { print }
' "$FILE" > "$tmp"
mv "$tmp" "$FILE"

# 2) Korrigierten Smoketest-Abschnitt anhängen
cat <<'EOD' >> "$FILE"

---

## Dev CI smoketest (optional)

If you want to run a small local healthcheck that mirrors parts of the CI,
you can use the helper script:

```bash
patches/dev9_34_dev_ci_smoketest.sh
This script will, if available:

run forge test,

run mkdocs build,

execute scripts/check_release_status.sh.

It does not change contracts or configuration; it is only a convenience
helper for contributors before pushing patches.
EOD

3) "Log entry" in dev10_17 / dev10_18 Skripten auskommentieren, falls vorhanden
for s in "$SCRIPT17" "$SCRIPT18"; do
if [ -f "$s" ]; then
sed -i.bak 's/^Log entry$/# Log entry/' "$s" || true
rm -f "${s}.bak" || true
fi
done

4) Log-Eintrag
LOG_FILE="logs/project.log"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-10 20] ${timestamp} Normalised Dev CI smoketest section and commented Log entry in dev10 helper scripts" >> "$LOG_FILE"

echo "== DEV-10 20 done =="
