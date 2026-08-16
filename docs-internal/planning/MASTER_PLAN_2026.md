# 1kUSD Master Plan — Functional Stablecoin Program

Status: **Kaspa-primary direction, ADR-042, and ADR-043 approved**
Last updated: **2026-08-16**
Accountable lead: **Codex Sol**
Product authority: **Gio**

## 1. Objective

Turn the existing research/testnet prototype into a fully functional,
Kaspa-native collateralized stablecoin while preserving the project's core ideas:

- one unit targets one US dollar of redeemable collateral value;
- two-way conversion through a Peg Stability Module;
- no CDP debt or liquidation engine;
- transparent on-chain reserves and liabilities;
- fail-closed oracle, asset, and volume controls;
- time-limited emergency pause authority without fund custody;
- immutable value logic with bounded, timelocked community governance and
  progressive removal of deployer and bootstrap control;
- deterministic fee and treasury accounting;
- a Kaspa-primary implementation built for Toccata rather than copied from the
  EVM account model.

This document is a program plan, not permission to change contract semantics.

The product-track decision is accepted in
[`ADR-041`](../adr/ADR-041-kaspa-primary-product-track.md): Kaspa Toccata is the
primary target; EVM remains an executable reference without a current production
commitment.

## 2. Baseline

The EVM code compiles and the last merged security task verified 229 passing
tests, but eight counted tests are placeholders. Safety/Guardian lifecycle
remediations #120 and #124 are merged. The current implementation still contains
an admin-set mock oracle, a timelock stub, incomplete fee routing, an unverified
production role handoff, and an incomplete deployment path. It is not a
production stablecoin and must not be marketed or deployed as one.

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

## 4. Reference architecture — EVM track

The EVM implementation supplies testable economic behavior, invariants, and
failure cases. It is not the primary production target. Each EVM ticket must be
reclassified after the Kaspa ADR as portable specification work, reference-only
maintenance, or unnecessary.

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

A reviewed timelock plus distributed bootstrap proposer, staged role transfer,
parameter bounds, emergency procedures, and no residual deployer privileges.
[`ADR-043`](../adr/ADR-043-autonomous-community-control.md) proposes an
immutable economic core, a bounded governance allowlist, progressive control
minimization, and a permanently expiring pause-only Guardian. The community
mandate mechanism remains a later decision; no DAO or voting-token design is
authorized by this plan.

See the
[`governance/control threat model`](../core/GOVERNANCE_CONTROL_THREAT_MODEL.md)
and
[`transition plan`](GOVERNANCE_TRANSITION_PLAN.md). Issue #107 remains blocked
until ADR-043 is accepted and implementation is separately approved.

### Fees and treasury

One router interface, explicit asset movement, treasury/reserve policy selected
through `DEC-004`, accounting events, and invariant reconciliation.

### Operations

Reproducible deployment, address manifest, verified source, role matrix,
monitoring, alerting, incident response, reserve attestation, bug bounty, and
release rollback/containment procedures.

## 5. Primary architecture — Kaspa Toccata track

The EVM implementation is an executable specification, not port source.

Toccata is active on Kaspa mainnet, but its application tooling remains early.
Mainnet consensus activation does not make 1kUSD production-ready. ADR-042
compares the execution models and proposes an L1 covenant family with one
singleton control/reserve state for the first separately approved,
Testnet-10-only experiment. Production sharding is deferred.

Kaspa design requires:

- covenant-state topology and successor validation;
- covenant IDs and transaction-v1 compute/storage mass;
- native-asset issuance and redemption policy;
- sharded reserve/PSM UTXOs versus based-app shared state;
- signed oracle reports and freshness;
- guardian/timelock spend conditions;
- indexing, reorg recovery, and live-state discovery;
- proof/settlement assumptions;
- experimental Silverscript/vProgs version pinning.

See [`ADR-042`](../adr/ADR-042-kaspa-toccata-execution-architecture.md), the
[`Kaspa threat model`](../core/KASPA_THREAT_MODEL.md), and the
[`PoC acceptance plan`](KASPA_POC_ACCEPTANCE_PLAN.md). ADR acceptance does not
authorize PoC implementation or deployment.

The first implementation is an isolated, value-capped testnet vault/issuance
proof of concept. ADR-042 selects Testnet-10 from current official tooling
evidence; that selection must be revalidated before any separately approved PoC
execution. It must not hold production funds or dictate the full design.

## 6. Program phases

| Phase | Goal | Exit criteria |
|---|---|---|
| 0 — Truth and hygiene | Honest status, Bridge, plan, issues, Pages/README, active-tree cleanup | `1K-P1-013` merged with green checks |
| 1 — Product boundary | Accept Kaspa-primary scope and invariants | `ADR-041`; `1K-P0-001` complete |
| 2 — Kaspa architecture | Compare covenant, based-app, and hybrid designs | `1K-P1-012` ADR approved; trust and state model explicit |
| 3 — Isolated Kaspa PoC | Value-capped vault/issuance experiment | Separate approved task; reproducible testnet evidence |
| 4 — Protocol hardening | Resolve safety, governance, collateral, fee, and oracle specifications | Threat models and portable invariants approved; ADR-043 control decision resolved |
| 5 — Deployment and operations | Reproducible Kaspa testnet candidate | Clean-room deploy, manifest, monitoring, and role E2E |
| 6 — Assurance | Coverage, static analysis, fuzz/invariant, economic simulations | No open High/Medium; agreed quality floors |
| 7 — External review | New freeze, professional audit, bug bounty | Findings remediated and re-audited |
| 8 — Production readiness | Legal, reserve, redemption, and incident gates | All mainnet gates evidenced; explicit launch approval |

## 7. Mainnet release gates

Mainnet is blocked until all are true:

- all P0 and required P1 issues closed and independently rechecked;
- no open High/Medium Slither or external-audit findings;
- production-scope tests contain no placeholders;
- approved coverage and mutation-testing thresholds pass;
- real oracle, timelock, multisig, fee router, limits, and monitoring operate;
- no residual deployer authority, hidden upgrade path, or arbitrary reserve
  movement exists;
- every governable parameter is allowlisted, range-bounded, and delayed;
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
