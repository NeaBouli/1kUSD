#!/usr/bin/env bash
set -euo pipefail
VER="${1:-v0.0.0}"
OUTDIR="security/submission"
STAMP="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
MAN="$OUTDIR/MANIFEST.json"

mkdir -p "$OUTDIR" reports

Update manifest timestamp

if command -v jq >/dev/null 2>&1; then
tmp="$(mktemp)"
jq --arg ts "$STAMP" '.generatedAt=$ts' "$MAN" > "$tmp" && mv "$tmp" "$MAN"
else

leave as-is if jq not present

:
fi

Ensure baselines exist (placeholders ok)

[ -f reports/slither.json ] || echo '{ "tool":"slither","version":"n/a","findings":[] }' > reports/slither.json
[ -f reports/mythril.json ] || echo '{ "tool":"mythril","version":"n/a","findings":[] }' > reports/mythril.json

ZIP="$OUTDIR/preaudit-$VER.zip"
rm -f "$ZIP"

Build file list (fallback if jq missing)

FILES=(
docs/SECURITY_PREAUDIT_README.md
docs/THREAT_MODEL.md
docs/INVARIANTS_EXEC_MAP.md
docs/PSM_QUOTE_MATH.md
docs/ORACLE_AGGREGATION_GUARDS.md
docs/SAFETY_RATE_LIMITER.md
reports/slither.json
reports/mythril.json
)

add specs and vectors if present

[ -d contracts/specs ] && FILES+=("contracts/specs")
[ -d tests/vectors ] && FILES+=("tests/vectors")

zip -r "$ZIP" "${FILES[@]}" >/dev/null
echo "Created bundle: $ZIP"
