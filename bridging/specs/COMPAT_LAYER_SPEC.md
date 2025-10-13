# Compatibility Layer & Cutover Protocol — Specification
**Scope:** Maintaining API/data compatibility across EVM, Kasplex, and future Kaspa L1; orchestrating a safe cutover.  
**Status:** Spec (no code). **Language:** EN.

## SDK Compatibility
- Chain-agnostic interfaces: PSM, Vault, Oracle, Safety, Gov.
- Per-chain adapters with identical method signatures and error taxonomy.
- Feature flags (capabilities matrix) exposed via `getChainFeatures()`.

## Indexer/Data
- Unified schema; chainId column added to all entities.
- Cursoring per chain; cross-chain join views (reserves_total_by_chain).

## Cutover Protocol (high-level)
1) Announce target chain, publish addresses and feature matrix.
2) Freeze parameter changes on source (DAO timelock) except safety-critical.
3) Reduce PSM caps on source; enable PSM on target with staged caps.
4) Open bridge with conservative rate-limits.
5) Monitor peg/reserves parity; raise caps gradually.
6) Declare target **primary**; update canonical registry; archive source write-paths.

## Rollback Protocol
- If health checks fail: pause target mint; re-open source caps; reconcile bridge intents; publish postmortem.

## User Experience
- Reference dApp auto-detects primary chain; offers guided migration.
- Display finality and ETA; never custody keys; on-chain proofs preferred.

## Governance Controls
- Proposals for: bridge allowlist updates, cap schedules, primary chain switch.
- Minimum review window before execution (e.g., ≥72h mainnet).
