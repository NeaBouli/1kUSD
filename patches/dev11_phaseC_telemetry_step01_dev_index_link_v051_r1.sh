#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

python3 - << 'PY'
from pathlib import Path

path = Path("docs/dev/index.md")
path.parent.mkdir(parents=True, exist_ok=True)

if not path.exists():
    base = """# Developer documentation

This directory contains developer-facing design and planning documents
for the 1kUSD economic layer and its tooling.

"""
    path.write_text(base, encoding="utf-8")

text = path.read_text(encoding="utf-8")

marker = "## DEV-11 - OracleRequired telemetry & indexer plan (v0.51.x)"

block = """
## DEV-11 - OracleRequired telemetry & indexer plan (v0.51.x)

- **DEV11_PhaseB_Telemetry_TestPlan_r1.md** - Phase B telemetry test plan
  for OracleRequired-related observability (preview).
- **DEV11_PhaseC_Telemetry_ImplementationPlan_v051_r1.md** - implementation
  plan for a minimal OracleRequired telemetry/indexer stack (Phase C),
  defining ingestion, storage, aggregation and preparation for dashboards.
"""

if marker not in text:
    if not text.endswith("\n"):
        text += "\n"
    text += block.lstrip("\n") + "\n"
    path.write_text(text, encoding="utf-8")
    print("OK: DEV-11 telemetry section appended to docs/dev/index.md")
else:
    print("OK: DEV-11 telemetry section already present (no changes)")
PY

ts="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-11] ${ts} link DEV-11 Phase B/C telemetry docs from dev index v0.51 (r1)" >> logs/project.log

echo "== DEV-11 PhaseC step01: docs/dev/index.md updated with DEV-11 telemetry links (v0.51.x) =="
