#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-40: Append release note to README.md =="

README="README.md"
TMP="${README}.tmp"

if ! grep -q "v0.40.0-rc" "$README"; then
  awk '
    /^## Development History/ {
      print; print "";
      print "### v0.40.0-rc — OracleWatcher & Interface Recovery";
      print "- Restored `IOracleWatcher.sol` interface";
      print "- Removed duplicate local enum in `OracleWatcher.sol`";
      print "- Namespaced all `Status` references to `IOracleWatcher.Status`";
      print "- Verified successful build (Solc 0.8.30)";
      print "- Lint warnings only, no compiler errors";
      print "";
      next
    }
    { print }
  ' "$README" > "$TMP" && mv "$TMP" "$README"
else
  echo "README already contains DEV-40 entry."
fi

mkdir -p logs
printf "%s DEV-40 doc: added README release note for v0.40.0-rc\n" "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" >> logs/project.log
echo "✅ README updated with DEV-40 history entry."
