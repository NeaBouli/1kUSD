# Project State

Last reviewed: **2026-09-13**

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
- Public status documentation is aligned through merged PR #128 (`2a5ec38`).
- `ADR-043` is accepted under documentation ticket `1K-P1-016` / #127:
  immutable value logic, bounded timelocked governance, progressive privilege
  removal, and an expiring pause-only Guardian. No implementation is authorized.

## Current phase

`target_stop_1k_p1_016_complete`

`1K-P1-016` / #127 and bounded review follow-up `1K-P1-016-R1` are `done`.
Gio accepted ADR-043 / DEC-007 on 2026-08-16. The five validated CodeRabbit
documentation findings were corrected in `c6ef0c1`, all five review threads
were resolved, and Kimi K3 returned final `APPROVE` with no blocking finding.
Local validation passed with 229/229 Foundry tests, strict MkDocs, Docs
Watchdog, and diff checks.

PR #128 was merged by repository owner `NeaBouli` on 2026-09-01 as
`2a5ec38ecef51bff1beb745173e7229a603458b6`; Forge Build, Forge Test, and
docs-check were successful. GitHub retained `REVIEW_REQUIRED` as the review
decision at merge time. Codex did not use an admin flag, change protection
settings, or force the merge. Issue #127 was closed after the merge.

The accepted scope remains architecture/documentation only. No contract, role,
DAO, deployment, wallet, token-economics, PoC, production, or public-offer
action is authorized by this completion.

`1K-P0-003` / #103 remains `done`; its canonical merged baseline is 229 passing
tests across 35 suites with eight remaining placeholders.

`1K-P1-012` / #112 remains `done`: accepted ADR-042 was published through
merged PR #122. PoC implementation still requires a separate approved ticket.

`1K-P1-007` / #107 remains blocked pending respecification against ADR-043 and a
later, separate execution approval.

## Release status

- `audit-final-v0.51.5` is a historical freeze with inconsistent metadata.
- The tag must not be rewritten.
- A new external-audit candidate requires a new reproducible freeze after all P0
  and required P1 tickets pass.

## Addendum — 2026-10-10 public entrypoint refresh

A refresh of the public landing page, README, roadmap and security page is
**implemented on a worker branch only**: not merged, not deployed, not live.
The public copy now dates every status claim and labels the 229-test result as
historical. It keeps the ADR-042 revalidation in review (G3 open) and the
Testnet-10 PoC not approved. It makes no claim about Kaspa network activation.
The public documentation path is mapped in `docs/architecture/MAP.md`. No
product, governance, economic, license or deployment state changed.
