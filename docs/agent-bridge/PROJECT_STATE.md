# Project State

Last reviewed: **2026-08-05**

## Current truth

- The repository is an **EVM research/testnet prototype**, not a production or
  mainnet-ready stablecoin.
- Solidity compiler target: `0.8.30`; Foundry is the canonical test tool.
- Last verified local result: **198 passed, 0 failed, 0 skipped across 35 suites**.
- Ten counted tests are placeholders.
- Default coverage: **78.92% lines / 57.63% branches**.
- Slither 0.11.5 currently blocks on eight Medium results requiring triage.
- The oracle is admin-set mock infrastructure, the DAO timelock is a stub, and
  fee routing is incomplete.
- No production deployment or proof-of-reserves system is documented.
- Kaspa Toccata programmability remains a testnet/pre-mainnet dependency under
  active development; the EVM implementation is not directly portable to its
  UTXO/covenant model.
- `ADR-041` approves Kaspa Toccata as the primary product track. EVM remains an
  executable reference without a current production commitment.

## Current phase

`product_scope_approved`

No contract or governance change is approved merely by inclusion in the master
plan. `1K-P1-012` / #112 is the next candidate task, but remains proposed until
Gio explicitly marks it `approved_for_execution`.

## Release status

- `audit-final-v0.51.5` is a historical freeze with inconsistent metadata.
- The tag must not be rewritten.
- A new external-audit candidate requires a new reproducible freeze after all P0
  and required P1 tickets pass.
