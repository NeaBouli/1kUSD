# Risk Register — Specification
**Scope:** Canonical list of risks with severity, likelihood, owner, mitigation, and test links.  
**Status:** Spec (no code). **Language:** EN.

| ID | Title | Asset | Severity | Likelihood | Owner | Mitigation | Tests/Refs | Status |
|----|-------|-------|----------|------------|-------|------------|------------|--------|
| R1 | Reentrancy on PSM | Vault funds | High | Medium | Protocol | CEI + nonReentrant; unit tests | TESTPLAN §1, PSM_SPEC §10 | Open |
| R2 | Mint without deposit | Supply | Critical | Low | Protocol | Gate mint via PSM only; invariants I1–I3 | FORMAL_INVARIANTS_MAP | Open |
| R3 | Cap bypass | Vault exposure | High | Low | Safety | Cap checks in Safety/Vault; tests | SAFETY_AUTOMATA_SPEC; COLLATERAL_VAULT_SPEC | Open |
| R4 | Rate-limit bypass | Flow control | High | Low | Safety | Shared limiter (RATE_LIMITS_SPEC); audit window rollover | RATE_LIMITS_SPEC §4 | Open |
| R5 | Oracle stale/deviation | Peg | High | Medium | Oracle | maxAgeSec + deviationBps; fail-closed | ORACLE_AGGREGATOR_SPEC | Open |
| R6 | Malicious ERC-20 | Funds | Medium | Medium | Protocol | Normalize decimals; handle fee-on-transfer; allowlists | VAULT_SPEC; TESTPLAN regressions | Open |
| R7 | Governance capture | Params | High | Low | DAO | Timelock delay; quorum/threshold; guardian sunset | DAO_TIMELOCK_SPEC | Open |
| R8 | Pause evasion after sunset | Safety | High | Low | Safety | Enforce sunset; disable guardian; tests | SAFETY_AUTOMATA_SPEC | Open |
| R9 | Indexer reorg desync | Data | Medium | Medium | Indexer | finality watermark; rollback to ancestor | INGESTION_PIPELINE | Open |
| R10 | RPC outage | Availability | Medium | Medium | Ops | multi-RPC; degraded mode; retries/backoff | DEPLOYMENT_ENVIRONMENTS; EMERGENCY_PLAYBOOKS | Open |
| R11 | Fee accounting drift | Treasury | Medium | Low | Protocol | Fees retained in Vault; reconciliation | TREASURY_SPEC; events | Open |
| R12 | Permit replay | Token | Medium | Low | Protocol | EIP-2612 nonce/domain checks | TOKEN_SPEC | Open |
