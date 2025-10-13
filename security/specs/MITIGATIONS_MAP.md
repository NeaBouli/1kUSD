# Mitigations Map — Cross-Reference
**Status:** Spec (no code). **Language:** EN.

| Risk | Primary Control | Secondary | Spec Refs | Test Refs |
|------|------------------|-----------|-----------|-----------|
| R1 Reentrancy | CEI + nonReentrant | No external callbacks | PSM_SPEC §10 | TESTPLAN unit/reentrancy |
| R2 Free Mint | Gate mint via PSM | Invariants I1–I3 | TOKEN_SPEC, PSM_SPEC | FORMAL_INVARIANTS_MAP |
| R3 Cap Bypass | Safety caps on Vault | Exposure views/indexer | COLLATERAL_VAULT_SPEC | safety_caps |
| R4 Rate Limits | Shared limiter | Window telemetry | RATE_LIMITS_SPEC | safety_rate_limit |
| R5 Oracle Issues | maxAge/deviation | Pause mint | ORACLE_AGGREGATOR_SPEC | oracle_guards/deviation |
| R6 ERC-20 Quirks | Normalization + adapters | Allowlist | VAULT_SPEC | regressions (decimals/fee) |
| R7 Gov Capture | Timelock delay | Quorum/threshold | DAO_TIMELOCK_SPEC | governance_params |
| R8 Pause Evasion | Guardian sunset | Timelock resume only | SAFETY_AUTOMATA_SPEC | safety_pause |
| R9 Reorg Desync | Finality watermark | Rollback | INGESTION_PIPELINE | reorg tests |
| R10 RPC Outage | Multi-RPC | Degraded UI | OPS SPECS | n/a |
| R11 Fee Drift | Accounting in Vault | Indexer reconciliation | TREASURY_SPEC | psm_accounting |
| R12 Permit Replay | Nonces/Domain | Deadline checks | TOKEN_SPEC | permit tests |
