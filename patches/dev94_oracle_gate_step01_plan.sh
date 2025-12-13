#!/usr/bin/env bash
set -euo pipefail

# Go to repo root
cd "$(dirname "$0")/.."

python - << 'PY'
from pathlib import Path

path = Path("docs/dev/DEV94_ReleaseFlow_Plan_r2.md")
text = path.read_text(encoding="utf-8")
marker = "## OracleRequired release gate (r1 plan)"

if marker in text:
    print("OracleRequired release gate plan already present; nothing to do.")
else:
    block = """
## OracleRequired release gate (r1 plan)

This section defines the first implementation step for enforcing the
OracleRequired invariants in the release flow for v0.51+.

### Goal

Connect the existing documentation and status reports to the technical
release gate implemented via `scripts/check_release_status.sh`, without
changing the script yet.

OracleRequired is already documented in:

- `docs/reports/ARCHITECT_BULLETIN_OracleRequired_Impact_v2.md`
- `docs/reports/ARCHITECT_OracleRequired_OperationsBundle_v051_r1.md`
- `docs/reports/DEV94_Release_Status_Workflow_Report.md`
- `docs/reports/BLOCK_DEV49_DEV11_OracleRequired_Block_r1.md`
- `docs/reports/DEV11_OracleRequired_Handshake_r1.md`
- `docs/governance/GOV_Oracle_PSM_Governance_v051_r1.md`

For a v0.51+ release candidate, the release manager MUST verify that
these reports exist and are up to date before cutting a tag.

### Planned script changes (r1)

The next DEV-94/95 steps will:

1. Extend `scripts/check_release_status.sh` with an
   "OracleRequired release gate" that:
   - checks the presence and non-emptiness of the reports above, and
   - fails the script (exit code != 0) if any of them is missing.
2. Keep the new gate behind the existing release checks, so that
   OracleRequired becomes an additional hard requirement rather than
   replacing any current checks.
3. Keep the gate logic simple and text-only (no on-chain calls),
   aligned with the existing pattern of the script.

The concrete shell changes will be introduced in a separate
`dev94_oracle_required_stepXX_*` patch, once this plan has been
reviewed.

"""
    if not text.endswith("\\n"):
        text += "\\n"
    text += block.lstrip("\\n") + "\\n"
    path.write_text(text, encoding="utf-8")
    print("OracleRequired release gate plan appended.")
PY

echo "[DEV-94] $(date -u +"%Y-%m-%dT%H:%M:%SZ") add OracleRequired release gate (r1) plan to DEV94 ReleaseFlow" >> logs/project.log

echo "== DEV-94 gate step01: OracleRequired release gate plan appended to DEV94_ReleaseFlow_Plan_r2 =="
