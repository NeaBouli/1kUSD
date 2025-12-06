#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "== DEV-11 A02: append backlog skeleton for oracle/health gate =="

cat <<'MD' >> docs/dev/DEV11_Implementation_Backlog_SolidityTrack_r1.md

## DEV-11 A02 – Oracle/Health gate for buybacks (Phase A)

Status: planned

Summary:
- Enforce that buyback execution is only allowed when oracle health is "good" and guardian/safety flags allow buybacks.
- Integrate with existing oracle health/guardian signals without changing v0.51 baseline behaviour unless explicitly enabled.

Implementation hints:
- Introduce a dedicated check function in BuybackVault that is called from executeBuyback paths.
- Emit explicit events and/or use reason codes for blocked buybacks (oracle_stale, oracle_diff_too_large, guardian_block).

Expected deliverables:
- Solidity implementation in BuybackVault (or dedicated StrategyEnforcement helper).
- Foundry tests covering happy-path and blocked buybacks (oracle unhealthy, guardian stop).
- Telemetry entries wired into DEV11_Telemetry_Events_Outline_r1.md.

MD

date -u +"%Y-%m-%dT%H:%M:%SZ dev11-A02: add backlog skeleton for oracle/health gate" >> logs/project.log

mkdocs build

echo "== DEV-11 A02 backlog skeleton done =="
