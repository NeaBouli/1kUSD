# 1kUSD Concept and Implementation Specification

Version: remediation draft, 2026-08-16

> This is a product and architecture specification, not evidence of production
> deployment, audit certification, reserves, liquidity, or a guaranteed peg.

## Abstract

1kUSD is intended to be a fully collateralized USD-targeting token with two-way
conversion through a Peg Stability Module. The design avoids user CDP debt and
liquidation positions. Its security depends on collateral quality, accounting,
oracles, limits, governance, liquidity, operations, and independently verified
software.

## Core mechanism

Approved collateral enters a vault. After asset, price, limit, fee, deadline, and
pause checks, the PSM mints net 1kUSD. Redemption burns 1kUSD and releases net
collateral. Fees follow an explicitly approved reserve/treasury policy.

Required invariants include supply conservation, reserve solvency, atomic swaps,
bounded issuance, deterministic rounding, and reconciliation of fees and assets.

## Governance and safety

The production target uses timelocked multisig governance, bounded parameters,
two-step role transfer, and a time-limited Guardian that can pause defined modules
but cannot move funds. Resume and post-sunset authority must follow one reviewed
role truth table.

## Oracle

Production pricing requires independent real feeds or another approved trust
model, with freshness, deviation, quorum, fallback, monitoring, and incident
rules. The current admin-set mock is test-only.

## Current implementation status

The EVM prototype builds and has a meaningful Foundry suite, but contains eight
placeholder tests, incomplete branch coverage, a mock oracle, timelock and fee
stubs, and testnet/demo deployment wiring. The Safety/Guardian lifecycle is
test-hardened, but production role handoff and deployment E2E remain gated. It
is not a production system.

## Kaspa Toccata

Kaspa's Toccata stack is UTXO/covenant-native. A Kaspa 1kUSD must model state as
covenant UTXOs or an approved based-app state root, validate successor outputs,
define native-asset issuance, shard hot PSM state, verify oracle reports, and
support indexer/reorg recovery. The Solidity contracts provide economic
specification and invariants, not portable runtime code.

The first milestone is a pinned, value-capped proof of concept on Testnet-10
under a separate approved execution ticket. The architecture is accepted in
ADR-042; no Kaspa mainnet date is claimed.

## Release requirements

No mainnet release occurs before production oracle/governance/fees/monitoring,
full deployment E2E, agreed coverage and static-analysis gates, no open
High/Medium findings, legal/reserve approval, independent audit, and bug bounty.

See the [master plan](https://github.com/NeaBouli/1kUSD/blob/main/docs-internal/planning/MASTER_PLAN_2026.md)
for the executable program.
