#!/usr/bin/env bash
set -euo pipefail

FILE="README.md"

echo "== DEV50 DOC03: reference new PSM docs in README =="

cat <<'EOL' >> "$FILE"

---

### PSM Documentation (DEV-43 → DEV-50)

The PegStabilityModule (PSM) and its surrounding components are documented in
the dedicated architecture notes under `docs/architecture/`:

- `psm_dev43-45.md` — PSM façade, limits wiring and price/notional layer.
- `psm_parameters.md` — Registry keys, PSMLimits caps and governance-facing parameter map.
- `psm_flows_invariants.md` — End-to-end mint/redeem flows and the invariants enforced by the regression test suites.

These documents are intended as the primary reference for auditors and
governance when reasoning about the PSM’s behaviour, risk surface and
upgrade paths.
EOL

echo "✓ PSM documentation references appended to $FILE"
