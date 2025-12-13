#!/usr/bin/env bash
set -euo pipefail

# DEV-94 gate step03: reposition OracleRequired gate block before success message
cd "$(dirname "$0")/.."

python3 << 'PY'
from pathlib import Path

path = Path("scripts/check_release_status.sh")
text = path.read_text(encoding="utf-8")

marker = "# OracleRequired release gate (r1)"

# 1) Falls der Block schon am Ende hängt: ab dort nach unten abschneiden
idx = text.find(marker)
if idx != -1:
    # alles bis kurz vor dem Marker behalten
    text_wo = text[:idx].rstrip() + "\n"
else:
    text_wo = text

# 2) OracleRequired-Gate-Block definieren
block = """
# OracleRequired release gate (r1)
# DEV-94: v0.51+ releases MUST have the OracleRequired docs bundle present
# This gate is intentionally text-only and does not perform on-chain checks.

ORACLE_REQUIRED_REPORTS="
docs/reports/ARCHITECT_OracleRequired_OperationsBundle_v051_r1.md
docs/reports/DEV94_Release_Status_Workflow_Report.md
docs/reports/BLOCK_DEV49_DEV11_OracleRequired_Block_r1.md
docs/reports/DEV11_OracleRequired_Handshake_r1.md
docs/governance/GOV_Oracle_PSM_Governance_v051_r1.md
"

missing_oracle_reports=0

for path in $ORACLE_REQUIRED_REPORTS; do
  if [ ! -s "$path" ]; then
    echo "[ERROR] OracleRequired release gate: missing or empty report: $path" >&2
    missing_oracle_reports=1
  else:
    echo "[OK] OracleRequired release gate: report present: $path"
  fi
done

if [ "$missing_oracle_reports" -ne 0 ]; then
  echo "[ERROR] OracleRequired release gate failed." >&2
  exit 1
fi

"""

# 3) Anker: vor der finalen Erfolgsmeldung einfügen
anchor = "All required status/report files are present and non-empty."
pos = text_wo.find(anchor)
if pos == -1:
    raise SystemExit("Anchor for success message not found in check_release_status.sh")

line_start = text_wo.rfind("\\n", 0, pos) + 1
new_text = text_wo[:line_start] + block.lstrip("\\n") + "\\n" + text_wo[line_start:]

path.write_text(new_text, encoding="utf-8")
print("OracleRequired gate block positioned before final success message.")
PY

echo "[DEV-94] $(date -u +"%Y-%m-%dT%H:%M:%SZ") reposition OracleRequired gate block before success message" >> logs/project.log

echo "== DEV-94 gate step03: OracleRequired gate block repositioned =="
