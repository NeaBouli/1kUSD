# Indexer — Ingestion & Reorg Handling
**Scope:** Data flow, checkpoints, idempotency, reconciliation.  
**Status:** Spec (no code). **Language:** EN.

## Pipeline Stages
1) **Source**: JSON-RPC WS for newHeads/logs + HTTP for backfill.
2) **Decoder**: ABI-based event/tx decoding (xref: clients/specs/EVENT_DECODING_SPEC.md).
3) **Normalizer**: map raw logs → entities; enrich with oracles (for USD).
4) **Store**: upsert idempotently; maintain cursors and watermarks.

## Cursors & Watermarks
- `cursor.tip` = highest seen block; `cursor.safe` = highest finalized (N confirmations).
- `finality.confirmations` default 12 (configurable per chain).
- Entities carry `finalityMark` based on `cursor.safe`.

## Reorg Handling
- On reorg detection (parentHash mismatch or chain reorg signal):
  - Roll back to common ancestor: delete/mark reorged for blocks > ancestor.
  - Re-ingest forward; recompute derived snapshots for affected range.
- Idempotency keys = entity natural IDs (e.g., txHash:logIndex).

## Backfill
- Range scanner: batch by 2k–5k blocks; parallelizable with shard ranges.
- Respect rate limits; exponential backoff on RPC errors.

## Derived Data
- `ReserveSnapshot` computed from Vault balance events + direct `balanceOf` checks periodically.
- `PegSnapshot` from SDK/oracle + PSM quotes (advisory); tag with data sources.

## Health & Telemetry
- `/health` endpoint publishes lag to tip/safe, queue sizes, last error.
