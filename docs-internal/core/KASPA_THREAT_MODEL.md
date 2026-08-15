# Kaspa-native Threat Model

Status: **Proposed with ADR-042**
Date: **2026-08-13**
Scope: **architecture and future testnet PoC only**

This model supplements the EVM threat model. It does not treat Solidity roles,
storage, calls, or reentrancy as Kaspa controls.

## Assets and security objectives

- collateral locked in reserve covenant UTXOs;
- valid 1kUSD box supply and ownership;
- equality between issued liabilities and circulating 1kUSD amounts;
- authorized covenant lineage and configuration epochs;
- oracle, governance, pause, and resume authority;
- availability and integrity of launch, index, and reproducibility evidence.

## Trust boundaries

| Boundary | Trusted for | Not trusted for |
|---|---|---|
| Kaspa consensus | UTXO existence, double-spend exclusion, covenant-family admission | application transition correctness |
| Covenant script | permitted transition and successor validation | off-chain data availability or oracle truth |
| Oracle quorum | signed price observation under approved policy | custody, governance, or transaction construction |
| Governance threshold | delayed policy and resume transitions | bypassing invariant checks |
| Guardian | bounded pre-sunset pause only | resume, transfer, mint, redeem, or policy change |
| Indexer | discovery, decoding, reconciliation, UX | consensus validity or authority |
| Compiler/builder | reproducible translation and transaction creation | correctness without pinned artifacts and tests |

## Primary threats and required controls

| Threat | Failure | Required control |
|---|---|---|
| Forged covenant entry | attacker creates a lookalike protocol UTXO | KIP-20 genesis/continuation rules, recorded covenant IDs, launch proof |
| Invalid successor | valid family id but false state transition | script validates exact state, amount, output layout, template, and binding |
| Double spend or stale state | two operations consume the current control state | UTXO consensus rejection; builder refreshes live outpoints and retries safely |
| Supply inflation | output amounts exceed consumed supply plus authorized mint | conservation on every transfer; mint delta equals control-state liability delta |
| Insolvent redemption | liability or released collateral does not reconcile | atomic burn/liability/release transition and deterministic rounding |
| Unauthorized control state | attacker adds issuance capacity | fixed singleton family; every transition requires exactly one successor; no PoC shard-creation route |
| Oracle forgery | fabricated or insufficiently signed price | approved unique-signature threshold and canonical message encoding |
| Oracle replay/domain confusion | valid report reused on another network, asset, epoch, or action | network/protocol/asset/action domain separation, validity bounds, report id |
| Stale/divergent oracle | unsafe mint/redeem under old or inconsistent price | fail-closed freshness, quorum, deviation, and outage rules from #106 |
| Guardian persistence | emergency key acts after sunset or resumes | sunset checked in spend condition; pause-only successor; governance-only resume |
| Incomplete pause | an issuance path remains operational | singleton control/reserve state; all mint/redeem routes consume it; fan-out is excluded |
| Governance bypass/replay | policy changes without delay or executes twice | queued operation commitment, threshold, delay, nonce, epoch, and consumed state |
| Indexer omission/equivocation | wallet misses live control/bearer state or shows false reserves | independent nodes/indexers, launch proof, deterministic replay, reconciliation |
| Reorg state corruption | derived state or pending spend follows displaced history | checkpoint rollback, deterministic replay, provisional/final state separation |
| Template/compiler substitution | source differs from live bytecode | pinned commits, reproducible compiler, artifact hashes, genesis manifest |
| Arithmetic/encoding error | overflow, sign, width, decimals, or canonical-encoding mismatch changes value | bounded checked arithmetic, canonical encoders, boundary and differential vectors |
| Resource exhaustion | valid route exceeds compute/storage mass or fee limit | on-node measurement, bounded inputs/outputs, headroom gate, adversarial mass tests |
| Dust/fragmentation | many tiny boxes harm usability or exceed storage mass | minimum box amount, bounded fan-in/fan-out, consolidation route and fee policy |
| Non-standard collateral | received amount/decimals differ from assumptions | initial synthetic asset only; later allowlist and actual-received policy from #109 |
| Liveness failure | oracle, builders, indexers, or governance unavailable | halt issuance safely; documented governance resume or reorg rebuild; no safety bypass for liveness |

## Kaspa-native invariants

1. A protocol successor belongs to the expected covenant family and is
   explicitly authorized by a consumed protocol input.
2. Every consumed state has only the successors allowed by its route.
3. A transfer preserves the sum of 1kUSD amounts.
4. A mint increases circulating 1kUSD and control-state liability by the same amount.
5. A redeem decreases circulating 1kUSD and control-state liability by the same amount.
6. Released collateral never exceeds the approved, rounded redemption amount.
7. The control state's liability never exceeds its cap or accounted reserve value.
8. Guardian authority can only change `operational` to `paused` before sunset.
9. Governance operations are domain-separated, delayed, single-use, and
   monotonically advance the configuration epoch.
10. The complete live UTXO set can be reconstructed from the launch proof and
    accepted transaction history.
11. Mint/redeem consumes the singleton control/reserve state and therefore
    validates the current policy hash and configuration epoch.
12. No PoC transition creates a second control/reserve state or issuance shard.

Kaspa has no EVM event log to inherit. Protocol observability must come from
unambiguous accepted transaction fields, successor state, and a documented
payload/manifest schema; those records must not be part of consensus authority.

## Residual risks

- Experimental compiler and builder defects remain possible even with pinned
  artifacts and differential tests.
- The singleton control state limits concurrency. Production sharding remains an
  unresolved architecture and must not inherit the PoC's safety conclusion.
- The final oracle, collateral, fee, legal redemption, signer, and monitoring
  policies remain separate decisions.
- This threat model has not been validated by a deployed PoC or external audit.
