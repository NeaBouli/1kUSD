#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

python3 - << 'PY'
from pathlib import Path

path = Path("README.md")
text = path.read_text(encoding="utf-8")

block = """
## OracleRequired governance & telemetry toolkit (v0.51.x)

For the oracle-dependent design of 1kUSD (Economic Layer v0.51.x), there is a
dedicated OracleRequired governance & operations toolkit. It is documented in:

- Governance & runbooks: see \`docs/governance/index.md\`
- Status & reports: see \`docs/reports/REPORTS_INDEX.md\`

This toolkit covers, among others:

- OracleRequired operations bundle and the docs gate
  (checked via \`./scripts/check_release_status.sh\`),
- incident handling for oracle-related failures
  (\`PSM_ORACLE_MISSING\`, \`BUYBACK_ORACLE_REQUIRED\`,
  \`BUYBACK_ORACLE_UNHEALTHY\`),
- runtime configuration checklist and status reports for v0.51.x.
"""

marker = "## OracleRequired governance & telemetry toolkit (v0.51.x)"
if marker not in text:
    if not text.endswith("\\n"):
        text += "\\n"
    text += block.lstrip("\\n") + "\\n"
    path.write_text(text, encoding="utf-8")
    print("OracleRequired governance & telemetry toolkit section appended to README.md.")
else:
    print("OracleRequired toolkit section already present; no changes made.")
PY

echo "[DEV-12] $(date -u +"%Y-%m-%dT%H:%M:%SZ") add OracleRequired governance & telemetry toolkit hint to README (v0.51)" >> logs/project.log
echo "== DEV-12 step08: README updated with OracleRequired governance & telemetry toolkit hint v051 r1 =="
