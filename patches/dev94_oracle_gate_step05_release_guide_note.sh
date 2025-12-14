#!/usr/bin/env bash
set -euo pipefail

FILE="docs/logs/RELEASE_TAGGING_GUIDE_v0.51.x.md"
test -f "$FILE" || { echo "ERROR: $FILE not found"; exit 1; }

python3 - <<'PY'
from pathlib import Path

path = Path("docs/logs/RELEASE_TAGGING_GUIDE_v0.51.x.md")
text = path.read_text(encoding="utf-8")

block = """
## OracleRequired docs gate (v0.51+)

For all v0.51+ release tags, the release manager MUST:

1. Run `./scripts/check_release_status.sh` and ensure it exits with code 0.
2. Verify that the output contains the OracleRequired docs gate summary:
   - `ARCHITECT_OracleRequired_OperationsBundle_v051_r1.md`
   - `DEV94_Release_Status_Workflow_Report.md`
   - `BLOCK_DEV49_DEV11_OracleRequired_Block_r1.md`
   - `DEV11_OracleRequired_Handshake_r1.md`
   - `GOV_Oracle_PSM_Governance_v051_r1.md`
3. Treat a non-zero exit code or any `[ERROR] OracleRequired release gate` line as a **hard block** for tagging. The underlying reports MUST be fixed before the tag is cut.

This gate is intentionally docs-only and does not perform on-chain checks. It complements the economic/test status checks but does not replace them.
"""

if "OracleRequired docs gate (v0.51+)" not in text:
    if not text.endswith("\n"):
        text += "\n"
    text += block.lstrip("\n") + "\n"
    path.write_text(text, encoding="utf-8")
    print("OracleRequired docs gate section appended to release tagging guide.")
else:
    print("OracleRequired docs gate section already present; no changes made.")
PY

echo "[DEV-94] $(date -u +"%Y-%m-%dT%H:%M:%SZ") add OracleRequired docs gate section to release tagging guide" >> logs/project.log
echo "== DEV-94 gate step05: RELEASE_TAGGING_GUIDE_v0.51.x.md updated =="
