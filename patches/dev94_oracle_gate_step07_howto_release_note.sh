#!/usr/bin/env bash
set -euo pipefail

FILE="docs/dev/DEV94_How_to_cut_a_release_tag_v051.md"

if [ ! -f "$FILE" ]; then
  echo "ERROR: $FILE not found (run from repo root)" >&2
  exit 1
fi

python3 - << 'PY'
from pathlib import Path
from datetime import datetime, timezone

guide_path = Path("docs/dev/DEV94_How_to_cut_a_release_tag_v051.md")
text = guide_path.read_text(encoding="utf-8")

block = """
## OracleRequired docs gate (v0.51+)

For all v0.51+ release tags, the release manager MUST:

1. Run `./scripts/check_release_status.sh` and ensure it exits with code 0.
2. Check that the output includes the OracleRequired docs gate summary lines:
   - `ARCHITECT_OracleRequired_OperationsBundle_v051_r1.md`
   - `DEV94_Release_Status_Workflow_Report.md`
   - `BLOCK_DEV49_DEV11_OracleRequired_Block_r1.md`
   - `DEV11_OracleRequired_Handshake_r1.md`
   - `GOV_Oracle_PSM_Governance_v051_r1.md`
3. Treat any non-zero exit code or \`[ERROR] OracleRequired release gate\` output
   as a **hard block** for cutting a v0.51+ tag. Fix the underlying reports
   before proceeding.

This OracleRequired docs gate complements the economic/test status checks
but does not replace them.
"""

marker = "## OracleRequired docs gate (v0.51+)"
if marker not in text:
    if not text.endswith("\\n"):
        text += "\\n"
    text += block.lstrip("\\n") + "\\n"
    guide_path.write_text(text, encoding="utf-8")
    print("OracleRequired docs gate section appended to DEV94 How-to release guide.")
else:
    print("OracleRequired docs gate section already present; no changes made.")

log_path = Path("logs/project.log")
ts = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
with log_path.open("a", encoding="utf-8") as f:
    f.write(f"[DEV-94] {ts} document OracleRequired docs gate in DEV94 How-to release guide (r1)\\n")

print("== DEV-94 gate step07: DEV94 How-to release guide updated ==")
PY
