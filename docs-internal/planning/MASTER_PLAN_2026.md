# 1kUSD Master Plan — Functional Stablecoin Program

Status: **Proposed; execution requires ticket-by-ticket approval**  
Last updated: **2026-08-05**  
Accountable lead: **Codex Sol**  
Product authority: **Gio**

## 1. Objective

Turn the existing research/testnet prototype into a fully functional,
collateralized stablecoin while preserving the project's core ideas:

- one unit targets one US dollar of redeemable collateral value;
- two-way conversion through a Peg Stability Module;
- no CDP debt or liquidation engine;
- transparent on-chain reserves and liabilities;
- fail-closed oracle, asset, and volume controls;
- time-limited emergency pause authority without fund custody;
- timelocked, multisig-backed governance;
- deterministic fee and treasury accounting;
- an eventual Kaspa-native implementation built for Toccata rather than copied
  from the EVM account model.

This document is a program plan, not permission to change contract semantics.

## 2. Baseline

The EVM code compiles and 198 tests pass, but ten tests are placeholders. The
current implementation contains an admin-set mock oracle, a timelock stub,
incomplete fee routing, role-flow inconsistencies, and an incomplete deployment
path. It is not a production stablecoin and must not be marketed or deployed as
one.

The historical `audit-final-v0.51.5` tag remains immutable evidence. A future
audit candidate receives a new version and freeze.

Slither 0.11.5 now runs with a valid Medium-blocking configuration and reports
eight open Medium results. They require focused triage and cannot be waived by
this planning change.

## 3. Non-negotiable product invariants

1. **Solvency:** supported collateral value must cover redeemable 1kUSD supply
   under the approved valuation and haircut model.
2. **Atomicity:** mint/redeem either completes fully or leaves no partial state.
3. **No silent configuration fallback:** missing decimals, oracle, limits, or
   asset policy must fail closed in production profiles.
4. **Bounded issuance:** per-transaction and rolling limits constrain exposure.
5. **Redeemability:** a holder can redeem through the documented mechanism while
   the protocol is solvent and the relevant safety state is operational.
6. **Least privilege:** no single EOA controls funds, prices, upgrades, and pause.
7. **Pause without custody:** emergency actors may stop bounded actions but may
   not move reserves or resume after their authority expires.
8. **Delayed governance:** sensitive changes are queued, visible, and delayed.
9. **Deterministic fees:** user output, reserve delta, and treasury delta reconcile.
10. **Observable operation:** reserve, supply, price, pause, limit, and governance
    state can be independently monitored.

## 4. Target architecture — EVM track

### Token

Restricted mint/burn, standards-compliant transfers and permit, explicit pause
semantics, two-step administration, and supply conservation properties.

### Collateral vault

Supported-asset policy, actual-received accounting or explicit rejection of
non-standard assets, balance reconciliation, least-privilege withdrawal paths,
and defense-in-depth reentrancy controls.

### Peg Stability Module

Atomic mint/redeem, validated decimals and prices, deterministic rounding,
slippage/deadline protection, mandatory production limits, and explicit fee
accounting.

### Oracle

Multiple independent production feeds or an explicitly approved alternative,
freshness/deviation/quorum rules, fail-closed fallback behavior, monitoring, and
incident runbooks. The current mock setter remains test-only.

### Safety and Guardian

One approved role truth table, correct sunset precedence, bounded pause scope,
DAO/multisig-controlled resume, and deploy-time role assertions.

### Governance

A reviewed timelock plus multisig execution authority, staged role transfer,
parameter bounds, emergency procedures, and no residual deployer privileges.
The exact implementation is a decision gate, not fixed by this plan.

### Fees and treasury

One router interface, explicit asset movement, treasury/reserve policy selected
through `DEC-004`, accounting events, and invariant reconciliation.

### Operations

Reproducible deployment, address manifest, verified source, role matrix,
monitoring, alerting, incident response, reserve attestation, bug bounty, and
release rollback/containment procedures.

## 5. Kaspa Toccata track

The EVM implementation is an executable specification, not port source.

Kaspa design begins with an ADR covering:

- covenant-state topology and successor validation;
- covenant IDs and transaction-v1 compute/storage mass;
- native-asset issuance and redemption policy;
- sharded reserve/PSM UTXOs versus based-app shared state;
- signed oracle reports and freshness;
- guardian/timelock spend conditions;
- indexing, reorg recovery, and live-state discovery;
- proof/settlement assumptions;
- experimental Silverscript/vProgs version pinning.

The first implementation is an isolated, value-capped testnet-10 vault/issuance
proof of concept. It must not hold production funds or dictate the full design.

## 6. Program phases

| Phase | Goal | Exit criteria |
|---|---|---|
| 0 — Truth and hygiene | Honest status, Bridge, plan, issues, Pages/README, active-tree cleanup | `1K-P1-013` merged with green checks |
| 1 — Safety correctness | Resolve sunset and Guardian lifecycle | Focused + full tests; threat model/review complete |
| 2 — Governance foundation | Functional timelock/multisig and role handoff | No deployer privilege; delayed execution E2E |
| 3 — Economic core | Collateral, decimals, limits, rounding, fee accounting | Solvency and conservation invariants pass |
| 4 — Production oracle | Approved real feeds and incident behavior | Stale/deviation/quorum/fallback tests and monitoring |
| 5 — Deployment and operations | Reproducible testnet release | Clean-room deploy, verified manifest, role and swap E2E |
| 6 — Assurance | Coverage, Slither, fuzz/invariant, economic simulations | No open High/Medium; agreed coverage floors |
| 7 — External review | New freeze, professional audit, bug bounty | Findings remediated and re-audited |
| 8 — Kaspa validation | Toccata ADR and isolated PoC | Testnet evidence; no production claim |

## 7. Mainnet release gates

Mainnet is blocked until all are true:

- all P0 and required P1 issues closed and independently rechecked;
- no open High/Medium Slither or external-audit findings;
- production-scope tests contain no placeholders;
- approved coverage and mutation-testing thresholds pass;
- real oracle, timelock, multisig, fee router, limits, and monitoring operate;
- clean-room deployment and role handoff are reproducible;
- reserve, redemption, legal, operational, and incident obligations are approved;
- external audit and public bug bounty are complete;
- release artifacts, dependencies, addresses, and source verification match.

## 8. Change strategy

- One ticket and one security concern per implementation PR.
- Tests accompany semantics; documentation never substitutes for tests.
- No migration, proxy, or upgrade pattern is assumed without an ADR.
- Historical contracts remain clearly marked and cannot enter deployment bundles.
- EVM and Kaspa share economic specifications and invariants, not runtime code.

## 9. Tracking

The canonical ticket index is
[`docs/agent-bridge/TICKET_LIST.md`](../../docs/agent-bridge/TICKET_LIST.md).
GitHub issues carry execution state, dependencies, acceptance criteria, and
verification evidence.
