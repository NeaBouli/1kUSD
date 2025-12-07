#!/usr/bin/env bash
set -euo pipefail

echo "== DEV-11 A01/A02: update telemetry events outline =="

cd "$(git rev-parse --show-toplevel)"

cat <<'DOC' >> docs/dev/DEV11_Telemetry_Events_Outline_r1.md

---

## DEV-11 A01 – Per-operation treasury cap

Component: BUYBACK_VAULT

- Error: `BuybackPerOpTreasuryCapExceeded`
  - Trigger:
    - Requested buyback amount (stable) would consume more than `maxBuybackSharePerOpBps`
      of the configured buyback treasury.
  - Semantics:
    - Economic safety guard, protects treasury from oversized single operations.
  - Suggested indexer tag:
    - `reason = "BUYBACK_TREASURY_CAP_SINGLE"`

Notes:

- When the per-operation cap is not configured or set to zero, behaviour is identical
  to v0.51 baseline.
- When configured, any attempt above the cap MUST revert with this error.

## DEV-11 A02 – Oracle / health gate (skeleton, planned)

Component: BUYBACK_VAULT + GUARDIAN / SAFETY

Planned reasons (to be implemented in subsequent DEV-11 A02 coding steps):

- `BUYBACK_ORACLE_UNHEALTHY`
  - Trigger:
    - Underlying price feed or oracle aggregation reports unhealthy state
      for the buyback asset or the reference stable.
  - Semantics:
    - Buyback operations must be blocked while oracle health is not acceptable.

- `BUYBACK_GUARDIAN_STOP`
  - Trigger:
    - Guardian / Safety automata mark the BUYBACK module as paused or blocked.
  - Semantics:
    - Higher-priority safety rule from Guardian; buyback execution must be rejected
      regardless of local vault parameters.

Notes:

- DEV-11 A02 wiring will connect buyback execution paths with existing oracle
  health and guardian/safety state. This section defines the telemetry vocabulary
  so indexers and dashboards can prepare before the code changes land.
DOC

printf '%s\n' "$(date -u +'%Y-%m-%dT%H:%M:%SZ') DEV11 A01/A02: update telemetry events outline" >> logs/project.log

mkdocs build >/dev/null

echo "== DEV-11 A01/A02 telemetry outline done =="
