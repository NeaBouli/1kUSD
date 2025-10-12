# Indexer — Storage Schema (Concept)
**Scope:** Logical tables/indices; implementation-agnostic (SQL/NoSQL).  
**Status:** Spec (no code). **Language:** EN.

## Tables (suggested SQL)
- blocks(block_number PK, hash, parent_hash, ts, reorged)
- txs(hash PK, block_number, tx_index, from_addr, to_addr, status, gas_used)
- events(id PK, tx_hash, log_index, block_number, contract, topic0, decoded_json JSONB)

- psm_trades(id PK, side, user, token, amount_in_raw, amount_out_raw, fee_raw, fee_usd, block_number, ts)
  * index: (user), (token), (block_number DESC)

- vault_balances(id PK, asset, amount_raw, amount_usd, block_number, ts)
  * latest per asset via view

- reserve_snapshots(ts PK, total_usd, finality_mark)
- reserve_assets(ts, asset, amount_raw, amount_usd)  // composite key (ts, asset)

- oracle_snapshots(asset, block_number, price, decimals, healthy, ts)
  * index: (asset, block_number DESC)

- safety_states(block_number PK, paused_json, caps_json, rate_limits_json, ts)

- gov_proposals(id PK, status, proposer, ipfs, eta, queued_at, executed_at, canceled_at)
- timelock_ops(id PK, eta, status, executed_tx, ts)

## Views
- reserves_latest ← last reserve_snapshots + assets
- peg_latest ← last oracle/peg snapshot

## Migrations
- Declarative migrations with backward-compatible changes; avoid destructive ops on hot tables.
