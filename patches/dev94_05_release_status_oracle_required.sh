#!/usr/bin/env bash
set -euo pipefail

# DEV-94 step05: OracleRequired note in release status workflow

cd "$(dirname "$0")/.."

python3 << 'PY'
from pathlib import Path

path = Path("docs/reports/DEV94_Release_Status_Workflow_Report.md")
text = path.read_text(encoding="utf-8")

marker = "## OracleRequired checks for v0.51+"

# Idempotent: wenn der Block schon existiert, nichts tun
if marker in text:
    raise SystemExit(0)

block = """
## OracleRequired checks for v0.51+

Starting with Economic Layer v0.51, releases are no longer allowed to treat
oracles as an optional convenience. For the PSM and strict BuybackVault the
presence of a healthy oracle (or oracle health module) is a **hard**
precondition for any legal configuration.

In practice, this means:

- **No "oracle-free" release state**
  - A PSM without a configured oracle is an *illegal* configuration.
    - Expected behaviour: swaps must revert with `PSM_ORACLE_MISSING`.
  - A strict-mode BuybackVault without a configured oracle health module is
    also an *illegal* configuration.
    - Expected behaviour: buybacks must revert with `BUYBACK_ORACLE_REQUIRED`.

- **Reason codes as release gates**
  - `PSM_ORACLE_MISSING` and `BUYBACK_ORACLE_REQUIRED` are first-class
    operational signals and must be visible in logs/telemetry.
  - A release candidate where these reason codes are silently ignored or
    hidden in monitoring is **not acceptable**.

- **Mandatory reports for OracleRequired**
  For v0.51+ the following reports must exist and be up to date before a
  release tag is cut:
  - `ARCHITECT_BULLETIN_OracleRequired_Impact_v2.md`
  - `DEV11_OracleRequired_Handshake_r1.md`
  - `BLOCK_DEV49_DEV11_OracleRequired_Block_r1.md`
  - `GOV_Oracle_PSM_Governance_v051_r1.md`

These documents together describe:

- Why oracles are now a root safety layer for the Economic Core.
- How PSM, BuybackVault, Guardian and Governance are wired under
  OracleRequired.
- Which configurations are considered illegal/hazardous and must never be
  tagged as a valid release state.

Future DEV-94/DEV-95 patches may extend `scripts/check_release_status.sh`
to enforce the presence of these reports programmatically, but the
requirement is already **normative** at the documentation level.
"""

if not text.endswith("\n"):
    text += "\n"
text += block.lstrip("\n") + "\n"

path.write_text(text, encoding="utf-8")
PY

echo "[DEV-94] $(date -u +"%Y-%m-%dT%H:%M:%SZ") document OracleRequired release gating in DEV94 workflow report" >> logs/project.log

echo "== DEV-94 step05: OracleRequired note added to release status workflow =="
