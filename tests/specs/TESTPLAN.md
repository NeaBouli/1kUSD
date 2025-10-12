# 1kUSD Test Plan — Specification
**Scope:** End-to-end validation strategy for 1kUSD protocol.
**Status:** Spec (no code). **Language:** EN.

## 1. Test Layers
- Unit: math, access control, errors
- Integration: PSM <-> Vault <-> Oracle/Safety
- Property/Fuzz: invariants (xref: contracts/specs/INVARIANTS.md)
- System: peg, caps/rate-limits, pause/resume, guardian sunset
- Regression: decimals 6/18, fee rounding, events
- Gas/Perf: hot paths (PSM swap, Vault withdraw)
- Reorg/Finality: replay, reconciliation, confirmations watermark
- Upgrade/Config: Timelock/Safety parameter changes

## 2. Coverage Targets
- Statements ≥ 90%, Branches ≥ 85%, Functions ≥ 90%
- Event emission parity 100% on specified paths

## 3. Scenarios (selected)
- PSM Mint/Redeem: cap headroom, rate window, oracle healthy/unhealthy
- Vault Egress: GOV_SPEND buffer; insufficient balance; decimal mismatch
- Safety: pause blocks state change; resume ok; guardian sunset respected
- Oracle: median vs trimmed-mean; single-source toggle; staleness/deviation
- AutoConverter: best-exec; minLiquidityUSD; slippage guard; thin-liquidity reject

## 4. Reorg Handling
- Simulate reorg; indexer reconciliation idempotent; finality respected

## 5. Tooling
- Foundry/Hardhat; Echidna/Foundry invariants; Slither/Mythril; gas snapshots

## 6. Exit Criteria
- ≥100k steps fuzz each suite; no Critical/High; coverage met; gas baseline logged

## 7. CI Integration
- lint → unit → property-fuzz → static-an → build-docs → publish-reports
- JSON reports per reports/SCHEMA.md
