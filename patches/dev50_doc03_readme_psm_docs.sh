#!/usr/bin/env bash
set -euo pipefail

FILE="README.md"

echo "== DEV50 DOC03: append PSM architecture docs summary to README =="

cat <<'EOL' >> "$FILE"

---

### PSM Architecture (DEV-43 → DEV-50)

The PSM stack is now documented in dedicated architecture notes:

- `docs/architecture/psm_dev43-45.md`  
  Canonical IPSM façade, notional layer, vault wiring and initial Guardian/Safety integration.

- `docs/architecture/psm_parameters.md`  
  Registry keys, PSMLimits parameters and the split between on-chain registry vs. dedicated limits contract.

- `docs/architecture/psm_flows_invariants.md`  
  End-to-end mint/redeem flows, notional accounting, limits and fee invariants, plus the linked Foundry regression suites.

These documents are the primary reference for auditors, governance and core devs extending the PSM with additional collaterals or economic features.
EOL

echo "✓ PSM architecture docs summary appended to $FILE"
