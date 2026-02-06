#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

python3 - << 'PY'
from pathlib import Path

path = Path("docs/indexer/telemetry_oracle_required_datamodel_v051_r1.md")
path.parent.mkdir(parents=True, exist_ok=True)

content = r"""# OracleRequired Telemetry Data Model (v0.51.x) — Skeleton

## Purpose

This document defines a **vendor-agnostic**, **revert-first** data model for observing
OracleRequired-related failures in v0.51.x **without any on-chain changes**.

Design goals:

- **Primary signal source:** transaction reverts / traces (reason codes), plus existing events if present.
- **No vendor lock-in:** works with any stack capable of decoding reverts/traces and writing to a relational store.
- **Future-proof:** events can be added in v0.52+ without breaking the core schema.
- **Strict scope:** only signals that already exist in v0.51.x are considered normative.

Non-goals (v0.51.x):

- No staleness / deviation / multi-feed consensus requirements.
- No new on-chain events.
- No mandates on specific indexer providers or hosted services.

## Canonical signals (v0.51.x)

### PSM

- **PSM_ORACLE_MISSING** — PSM operation blocked due to missing oracle pricefeed.

### BuybackVault (strict mode)

- **BUYBACK_ORACLE_REQUIRED** — buyback blocked because oracle/health module is not configured.
- **BUYBACK_ORACLE_UNHEALTHY** — buyback blocked because configured health module reports unhealthy state.

## Observation taxonomy

All observations should be stored as normalized records:

- **OracleRequiredObservation** (core): a single blocked operation attempt.
- **ConfigChangeObservation** (optional): changes in configuration that affect OracleRequired semantics
  (e.g., oracle wiring, strict mode toggle), using existing events or periodic state snapshots where feasible.

## Recommended relational schema (example)

> This is an example in relational terms. Any equivalent storage model is acceptable.

### Table: `oracle_required_observations`

Minimum fields:

- `id` (pk) — unique identifier (db-generated)
- `chain_id` (int)
- `block_number` (bigint)
- `block_timestamp` (timestamptz)
- `tx_hash` (bytes32 / text)
- `tx_from` (address)
- `tx_to` (address)
- `contract_name` (text) — e.g., `PegStabilityModule`, `BuybackVault`
- `method_sig` (text) — e.g., `executeBuybackPSM(uint256,address,uint256,uint256)`
- `reverted` (bool) — always true for v0.51.x OracleRequired core signals
- `revert_reason` (text) — decoded reason code, e.g. `PSM_ORACLE_MISSING`
- `reason_domain` (text) — `PSM` | `BUYBACK`
- `oracle_required_blocked` (bool) — always true for these records
- `metadata` (jsonb) — optional structured extras (decoded args, etc.)

Optional but useful fields:

- `gas_used` (bigint)
- `effective_gas_price` (bigint)
- `caller_category` (text) — e.g., `EOA`, `ROUTER`, `KEEPER` (heuristic)
- `route_hint` (text) — if can be inferred (optional)

Indexes:

- (`chain_id`, `block_timestamp`)
- (`chain_id`, `revert_reason`, `block_timestamp`)
- (`tx_hash`)

### Table: `oracle_required_config_observations` (optional)

Purpose: capture configuration state that frames the meaning of reverts.

Minimum fields:

- `id` (pk)
- `chain_id`
- `block_number`
- `block_timestamp`
- `contract_name`
- `config_type` (text) — e.g. `PSM_ORACLE`, `BUYBACK_HEALTH_MODULE`, `STRICT_MODE`
- `config_payload` (jsonb) — normalized payload (addresses, flags)
- `source` (text) — `event` | `snapshot`

Indexes:

- (`chain_id`, `contract_name`, `config_type`, `block_timestamp`)

## Decoding guidance (revert-first)

Implementations SHOULD:

1. Detect failed calls (receipt status = 0) to known contracts.
2. Decode revert data into the canonical reason codes above.
3. Store a normalized observation record.

Implementations MAY:

- Enrich with method decoding (4-byte selector) and decoded inputs where safe.
- Maintain a mapping from selectors → method signatures.
- Attach optional `config_observations` if events exist or snapshots are feasible.

## Metrics (minimum set)

Recommended baseline aggregations:

- `oracle_required_blocks_total{reason_code,contract,chain}`
- `oracle_required_blocks_1h{reason_code,contract,chain}`
- `oracle_required_blocks_by_sender{reason_code,tx_from,chain}` (top-N)
- Time-to-recovery style views (optional): first/last occurrence in rolling windows.

## Extensibility to events (v0.52+)

When/if v0.52+ introduces explicit events, the model should extend by:

- Adding optional fields to `oracle_required_observations`:
  - `event_type` (text, nullable)
  - `event_payload` (jsonb, nullable)

or by adding:

- `oracle_required_event_observations` table keyed by `(tx_hash, log_index)` that references the core observation.

## Checklist

- [ ] Revert decoding supports: `PSM_ORACLE_MISSING`, `BUYBACK_ORACLE_REQUIRED`, `BUYBACK_ORACLE_UNHEALTHY`
- [ ] Schema is revert-first and works without new on-chain events
- [ ] Vendor-agnostic wording; examples are non-binding
- [ ] Extensible to events later without breaking changes
"""
path.write_text(content.strip() + "\n", encoding="utf-8")
print(f"OK: wrote {path}")

PY

ts="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-11] ${ts} add OracleRequired telemetry data model skeleton v0.51 (r1)" >> logs/project.log

echo "== DEV-11 PhaseC step02: added telemetry_oracle_required_datamodel_v051_r1.md (docs-only) =="
