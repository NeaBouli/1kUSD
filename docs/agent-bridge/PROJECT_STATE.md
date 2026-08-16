# Project State

Last reviewed: **2026-08-16**

## Current truth

- The repository is an **EVM research/testnet prototype**, not a production or
  mainnet-ready stablecoin.
- Solidity compiler target: `0.8.30`; Foundry is the canonical test tool.
- Last verified result for merged #120: **207 passed, 0 failed**.
- Ten counted tests are placeholders.
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

`protocol_hardening_guardian_lifecycle`

`1K-P0-003` / #103 is `in_progress` under explicit Gio approval. The active
scope is the EVM-reference Guardian registration, revocation, direct-governance
resume, and sunset lifecycle. No deployment execution, wallet, token-economics,
Kaspa PoC, or production action is authorized. The last merged test baseline
remains 207; branch-local verification is recorded in the Action Log and does
not become canonical until normal review and merge complete. The current branch
has 229 passing tests, targeted Slither with zero findings on both changed
contracts, strict docs success, and an independent Kimi `APPROVE` verdict.
The implementation is published in PR #124. Its CI checks are green, but the PR
remains blocked pending the repository-required independent GitHub approval.

`1K-P1-012` / #112 remains `done`: accepted ADR-042 was published through
merged PR #122. PoC implementation still requires a separate approved ticket.

## Release status

- `audit-final-v0.51.5` is a historical freeze with inconsistent metadata.
- The tag must not be rewritten.
- A new external-audit candidate requires a new reproducible freeze after all P0
  and required P1 tickets pass.
