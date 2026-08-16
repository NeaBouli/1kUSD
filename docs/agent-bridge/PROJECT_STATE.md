# Project State

Last reviewed: **2026-08-16**

## Current truth

- The repository is an **EVM research/testnet prototype**, not a production or
  mainnet-ready stablecoin.
- Solidity compiler target: `0.8.30`; Foundry is the canonical test tool.
- Last verified result for merged #124: **229 passed, 0 failed**.
- Eight counted tests are placeholders.
- Default coverage: **78.92% lines / 57.63% branches**.
- Slither 0.11.5 currently blocks on eight Medium results requiring triage.
- The oracle is admin-set mock infrastructure, the DAO timelock is a stub, and
  fee routing is incomplete.
- No production deployment or proof-of-reserves system is documented.
- Toccata activated on Kaspa mainnet at DAA score `474,165,565`. Its covenant
  and ZK consensus primitives are active, but Silverscript and vProgs remain
  experimental; mainnet activation is not application production readiness.
- The EVM implementation is not directly portable to the UTXO/covenant model.
- `ADR-041` approves Kaspa Toccata as the primary product track. EVM remains an
  executable reference without a current production commitment.
- `ADR-042` is accepted: the first separately approved Testnet-10 PoC will use
  a singleton control/reserve L1 covenant family. Production sharding requires
  a later ADR.

## Current phase

`target_stop_1k_p0_003_complete`

`1K-P0-003` / #103 is `done`. PR #124 merged at `b5a2bc9` with 229 passing
tests, targeted Slither with zero findings on both changed contracts, strict
docs success, resolved CodeRabbit findings, and an independent Kimi `APPROVE`
verdict. Issue #103 closed as `completed`. No deployment, wallet,
token-economics, Kaspa PoC, or production action was performed.

`1K-P1-012` / #112 remains `done`: accepted ADR-042 was published through
merged PR #122. PoC implementation still requires a separate approved ticket.

## Release status

- `audit-final-v0.51.5` is a historical freeze with inconsistent metadata.
- The tag must not be rewritten.
- A new external-audit candidate requires a new reproducible freeze after all P0
  and required P1 tickets pass.
