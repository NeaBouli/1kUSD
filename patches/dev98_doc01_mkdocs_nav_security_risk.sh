#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

MKDOCS="mkdocs.yml"
LOG_FILE="logs/project.log"

if [ ! -f "$MKDOCS" ]; then
  echo "ERROR: $MKDOCS not found. Aborting."
  exit 1
fi

python3 - << 'PY'
from pathlib import Path

path = Path("mkdocs.yml")
text = path.read_text()

marker = "Security & Risk:"

if marker in text:
    print("Security & Risk nav section already present; no change.")
else:
    snippet = """
  - Security & Risk:
      - Security audit plan: security/audit_plan.md
      - Bug bounty: security/bug_bounty.md
      - Proof of reserves: risk/proof_of_reserves_spec.md
      - Collateral risk profile: risk/collateral_risk_profile.md
      - Emergency depeg runbook: risk/emergency_depeg_runbook.md
      - Stress test suite plan: testing/stress_test_suite_plan.md
"""

    if "nav:" not in text:
        raise SystemExit("ERROR: 'nav:' section not found in mkdocs.yml; aborting.")

    if not text.endswith("\n"):
        text += "\n"
    text = text + snippet.lstrip("\n")
    path.write_text(text)
    print("✓ Security & Risk nav section appended to mkdocs.yml")
PY

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-98] ${timestamp} MkDocs: added 'Security & Risk' section to nav (security/risk/testing docs)." >> "$LOG_FILE"

echo "✓ Log updated at $LOG_FILE"
echo "== DEV98 DOC01: done =="
