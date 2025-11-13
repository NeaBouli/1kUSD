#!/usr/bin/env bash
set -euo pipefail

echo "== DEV-41 Patch 4: Insert Oracle Regression cross-links into whitepaper =="

for FILE in docs/whitepaper/WHITEPAPER_1kUSD_EN.md docs/whitepaper/WHITEPAPER_1kUSD_DE.md; do
  TMP="${FILE}.tmp"
  cp -n "$FILE" "${FILE}.bak.dev41p4" || true

  awk '
    BEGIN { inserted = 0 }
    {
      print
      # Insert DEV-41 section before end of document or before appendix
      if (!inserted && $0 ~ /^## /) {
        print ""
        print "## Oracle Regression Stability — DEV-41"
        print ""
        print "This release consolidates the stability of the OracleWatcher, OracleAggregator,"
        print "and Oracle propagation paths. It resolves ZERO_ADDRESS initialization issues,"
        print "restores correct inheritance chains, and ensures refreshState() behaves consistently."
        print ""
        print "Full report: **docs/reports/DEV41_ORACLE_REGRESSION.md**"
        print ""
        inserted = 1
      }
    }
  ' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

done

echo "✓ Whitepapers updated with DEV-41 summary and cross-link."
