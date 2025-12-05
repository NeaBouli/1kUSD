#!/bin/bash
set -e

echo "== DEV-94 04: link release tag guide and add log entry =="

# 1) Link guide from docs/INDEX.md
INDEX_FILE="docs/INDEX.md"
if [ -f "$INDEX_FILE" ]; then
  if ! grep -q "DEV94_How_to_cut_a_release_tag_v051" "$INDEX_FILE"; then
    cat <<'EOT' >> "$INDEX_FILE"

- [DEV94_How_to_cut_a_release_tag_v051](dev/DEV94_How_to_cut_a_release_tag_v051.md) – Step-by-step guide for maintainers cutting v0.51.x tags.
EOT
  else
    echo "Guide already linked in docs/INDEX.md"
  fi
else
  echo "docs/INDEX.md not found, skipping index link."
fi

# 2) Add 'Further reading' hint to DEV94_ReleaseFlow_Plan_r2.md
PLAN_FILE="docs/dev/DEV94_ReleaseFlow_Plan_r2.md"
if [ -f "$PLAN_FILE" ]; then
  if ! grep -qi "How to cut a release tag" "$PLAN_FILE"; then
    cat <<'EOP' >> "$PLAN_FILE"

## Further reading

For a practical step-by-step maintainer guide on how to cut a v0.51.x
release tag, see
[DEV94_How_to_cut_a_release_tag_v051](DEV94_How_to_cut_a_release_tag_v051.md).
EOP
  else
    echo "Further reading section already present in DEV94_ReleaseFlow_Plan_r2.md"
  fi
else
  echo "DEV94_ReleaseFlow_Plan_r2.md not found, skipping further reading hint."
fi

# 3) Append log entry
LOG_FILE="logs/project.log"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-94 03] ${timestamp} Added DEV94_How_to_cut_a_release_tag_v051 guide links (INDEX + DEV94 plan)" >> "$LOG_FILE"

echo "== DEV-94 04 done =="
