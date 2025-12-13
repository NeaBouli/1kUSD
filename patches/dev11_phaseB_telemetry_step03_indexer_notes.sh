#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

python - << 'PY'
from pathlib import Path

# 1) BuybackVault indexer: OracleRequired-Signale dokumentieren
idx_path = Path("docs/indexer/indexer_buybackvault.md")
idx_text = idx_path.read_text(encoding="utf-8")

idx_block = """
## OracleRequired telemetry signals (v0.51+)

For v0.51+ the BuybackVault indexer must treat **OracleRequired** as a
first-class operational axis:

- **Revert reasons (BuybackVault)**
  - \`BUYBACK_ORACLE_REQUIRED()\` – strict-mode BuybackVault was called
    without a configured oracle health module or with enforcement active
    but no module set.
  - \`BUYBACK_ORACLE_UNHEALTHY()\` – the configured oracle health module
    reported an unhealthy state for the relevant asset pair.

- **Revert reason (PSM)**
  - \`PSM_ORACLE_MISSING()\` – PegStabilityModule was called without a
    configured oracle for the asset/stable pair.

Indexers SHOULD:

- decode these reason codes as structured fields (e.g. \`reason_code\`,
  \`severity = "critical"\`);
- surface them in dashboards and logs as **OracleRequired violations**;
- wire alerts so that any occurrence in production is treated as a
  hard incident (e.g. pager / on-call notification);
- correlate occurrences with:
  - Guardian pause / unpause events for PSM and BuybackVault,
  - OracleAggregator health changes and config updates.

This is the operational face of the OracleRequired invariant – a build
that passes tests but hides these reason codes from monitoring is **not**
acceptable.

**Related documents**

- \`ARCHITECT_OracleRequired_OperationsBundle_v051_r1.md\`
- \`DEV11_PhaseB_Telemetry_Concept_r1.md\`
- \`GOV_Oracle_PSM_Governance_v051_r1.md\`
"""

if "OracleRequired telemetry signals (v0.51+)" not in idx_text:
    if not idx_text.endswith("\n"):
        idx_text += "\n"
    idx_text += "\n" + idx_block.lstrip("\n") + "\n"
    idx_path.write_text(idx_text, encoding="utf-8")


# 2) Oracle-Integrator-Guide: kurze OracleRequired-Notiz ergänzen
ora_path = Path("docs/integrations/oracle_aggregator_guide.md")
if ora_path.exists():
    ora_text = ora_path.read_text(encoding="utf-8")
    marker = "## Operational considerations"
    block = """
### OracleRequired & health propagation (v0.51+)

From v0.51 onwards, the OracleAggregator and its health / watcher layer
are part of the **OracleRequired operations bundle**:

- If the aggregator or watcher configuration makes it impossible to
  compute a healthy price, downstream components MUST be allowed to:
  - revert with \`PSM_ORACLE_MISSING()\` (PSM side), or
  - revert with \`BUYBACK_ORACLE_REQUIRED()\` / \`BUYBACK_ORACLE_UNHEALTHY()\`
    (BuybackVault side).

- Integrations SHOULD treat these reason codes as **critical signals**:
  - do *not* retry blindly on-chain;
  - surface them to monitoring / incident response;
  - coordinate with Guardian / governance flows to restore a healthy
    oracle configuration.

See also:
- \`ARCHITECT_OracleRequired_OperationsBundle_v051_r1.md\`
- \`DEV11_PhaseB_Telemetry_Concept_r1.md\`
"""
    if "OracleRequired & health propagation (v0.51+)" not in ora_text:
        if marker in ora_text:
            # Anhängen ans Ende des Operational-Blocks
            if not ora_text.endswith("\n"):
                ora_text += "\n"
            ora_text += "\n" + block.lstrip("\n") + "\n"
        else:
            # Fallback: einfach ans Dateiende anhängen
            if not ora_text.endswith("\n"):
                ora_text += "\n"
            ora_text += "\n" + block.lstrip("\n") + "\n"
        ora_path.write_text(ora_text, encoding="utf-8")

PY

# DEV-11 Log-Eintrag
echo "[DEV-11] $(date -u +"%Y-%m-%dT%H:%M:%SZ") add PhaseB indexer notes for OracleRequired signals (v0.51+)" >> logs/project.log

echo "== DEV-11 PhaseB step03: indexer notes for OracleRequired signals added =="
