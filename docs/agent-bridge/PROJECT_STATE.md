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
- Public status documentation is aligned through merged PR #126 (`12c189f`).
- `ADR-043` is proposed under approved documentation ticket `1K-P1-016` / #127:
  immutable value logic, bounded timelocked governance, progressive privilege
  removal, and an expiring pause-only Guardian. No implementation is authorized.

## Current phase

`architecture_1k_p1_016_control_minimization`

`1K-P1-016` / #127 is `in_progress` under Gio's explicit approval. Scope is
limited to ADR-043, a governance/control threat-model delta, a staged
bootstrap-to-community transition plan, and necessary planning/Bridge updates.
Kimi K3 completed the independent architecture analysis and returned final
`APPROVE` on the complete draft diff. Claude Code was attempted but unavailable
because it was not authenticated; no Claude review credit is claimed. No
contract, role, DAO, deployment, wallet, token-economics, PoC, or production
action is authorized.

Draft PR #128 publishes the decision-ready proposal. The PR remains under
normal review; Issue #127 remains open and DEC-007 remains proposed pending
Gio's explicit accept/reject decision.

`1K-P0-003` / #103 remains `done`; its canonical merged baseline is 229 passing
tests across 35 suites with eight remaining placeholders.

`1K-P1-012` / #112 remains `done`: accepted ADR-042 was published through
merged PR #122. PoC implementation still requires a separate approved ticket.

`1K-P1-007` / #107 remains `proposed` and is blocked by the ADR-043 decision and
a later, separate execution approval.

## Release status

- `audit-final-v0.51.5` is a historical freeze with inconsistent metadata.
- The tag must not be rewritten.
- A new external-audit candidate requires a new reproducible freeze after all P0
  and required P1 tickets pass.
