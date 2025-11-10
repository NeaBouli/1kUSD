#!/usr/bin/env bash
set -euo pipefail

# Minimaler MkDocs-Sanity-Check: baut (falls nötig) und prüft Schlüsselpfade.
SITE_DIR="site"

echo "== scan_docs.sh: starting docs scan =="

if [ ! -d "$SITE_DIR" ]; then
  echo "No site/ found. Running: mkdocs build"
  mkdocs build >/dev/null
fi

# Erwartete MKDocs-Ausgabe-Struktur: jede Markdown-Seite -> /<pfad>/<name>/index.html
must_exist=(
  "index.html"
  "reports/DEV39_RELEASE_REPORT/index.html"
  "reports/DEV40_RELEASE_REPORT/index.html"
  "reports/DEV40_PHASE2_REPORT/index.html"
  "reports/DEV40_ARCHITECT_HANDOFF/index.html"
)

fail=0
for p in "${must_exist[@]}"; do
  if [ ! -f "${SITE_DIR}/${p}" ]; then
    echo "MISSING: ${SITE_DIR}/${p}"
    fail=1
  else
    echo "OK     : ${SITE_DIR}/${p}"
  fi
done

# Grobe Inhaltsprüfung: DEV-40 muss irgendwo auf der Startseite erwähnt sein.
if grep -qi "DEV-40" "${SITE_DIR}/index.html"; then
  echo "OK     : index.html mentions DEV-40"
else
  echo "WARN   : index.html does not mention DEV-40 (could still be fine if only linked from /reports)"
fi

if [ $fail -eq 0 ]; then
  echo "== scan_docs.sh: PASSED =="
  exit 0
else
  echo "== scan_docs.sh: FAILED (missing files) =="
  exit 2
fi
