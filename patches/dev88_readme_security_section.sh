#!/bin/bash
set -e

# DEV-88: Add Security & Risk section to README.md

mkdir -p logs

python - <<'PY'
from pathlib import Path

readme_path = Path("README.md")
text = readme_path.read_text(encoding="utf-8")

marker = "## Security & Risk"
if marker in text:
    # Section already present; do nothing
    raise SystemExit(0)

section = """
## Security & Risk

The 1kUSD protocol ships with a dedicated security and risk layer around the Economic Layer v0.51.0. Core specifications are documented in:

- [Security audit plan](docs/security/audit_plan.md)
- [Bug bounty program](docs/security/bug_bounty.md)
- [Proof-of-reserves specification](docs/risk/proof_of_reserves_spec.md)
- [Collateral risk profile](docs/risk/collateral_risk_profile.md)
- [Emergency depeg runbook](docs/risk/emergency_depeg_runbook.md)
- [Stress-test suite plan](docs/testing/stress_test_suite_plan.md)
- [Governance handover v0.51.0](docs/reports/DEV87_Governance_Handover_v051.md)
"""

anchors = ["## Architecture & Modules", "## Architecture"]
insert_pos = -1
for anchor in anchors:
    idx = text.find(anchor)
    if idx != -1:
        # insert right after the heading line
        endline = text.find("\n", idx)
        if endline == -1:
            endline = len(text)
        insert_pos = endline + 1
        break

if insert_pos == -1:
    # Fallback: append at the end
    new_text = text.rstrip() + "\n\n" + section.strip() + "\n"
else:
    new_text = text[:insert_pos] + "\n" + section.strip() + "\n\n" + text[insert_pos:]

readme_path.write_text(new_text, encoding="utf-8")
PY

echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") DEV-88 add Security & Risk section to README" >> logs/project.log
