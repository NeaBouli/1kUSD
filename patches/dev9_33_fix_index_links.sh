#!/bin/bash
set -e

echo "== DEV-9 33: fix MkDocs index references (INDEX.md vs index.md) =="

MKDOCS_YML="mkdocs.yml"

if [ ! -f "$MKDOCS_YML" ]; then
  echo "mkdocs.yml not found, aborting."
  exit 1
fi

# 1) Nav-Eintrag in mkdocs.yml auf INDEX.md anpassen (falls nötig)
if grep -q "index.md" "$MKDOCS_YML"; then
  echo "Patching mkdocs.yml: index.md -> INDEX.md in nav"
  # macOS-kompatibles sed mit Backup
  sed -i.bak 's/index.md/INDEX.md/g' "$MKDOCS_YML"
  rm -f "${MKDOCS_YML}.bak"
else
  echo "No index.md reference found in mkdocs.yml (nothing to patch)."
fi

# 2) Alle Links in Docs von ../index.md auf ../INDEX.md umbiegen
echo "Patching ../index.md links in docs/*.md to ../INDEX.md"
find docs -name "*.md" | while read -r f; do
  if grep -q "../index.md" "$f"; then
    echo "  - updating $f"
    sed -i.bak 's|\.\./index.md|../INDEX.md|g' "$f"
    rm -f "${f}.bak"
  fi
done

# 3) Log-Eintrag
LOG_FILE="logs/project.log"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-9 33] ${timestamp} Normalised MkDocs index references to use INDEX.md in nav and links" >> "$LOG_FILE"

echo "== DEV-9 33 done =="
