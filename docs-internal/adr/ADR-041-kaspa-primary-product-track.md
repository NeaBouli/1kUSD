# ADR-041: Kaspa-primary Product Track

Status: **Accepted**
Date: **2026-08-05**
Decision owner: **Gio**
Recorded by: **Codex Sol**
Tracking issue: [1K-P0-001 / #101](https://github.com/NeaBouli/1kUSD/issues/101)

## Context

The repository contains an EVM research/testnet prototype, while the intended
product is a stablecoin for the Kaspa ecosystem. Kaspa Toccata uses a UTXO-native
covenant and proof model rather than EVM-style globally mutable account
contracts. Continuing both implementations as equal production targets would
split security review, deployment, governance, and operational effort before the
Kaspa architecture is understood.

## Decision

1. **Kaspa Toccata is the primary target system for 1kUSD.**
2. **The EVM implementation remains an executable reference and test model.** It
   has no current production or EVM-mainnet commitment.
3. **1kUSD remains a fully collateralized PSM design:** approved collateral is
   deposited for issuance and released on redemption. User CDPs and liquidation
   positions are outside the product scope.
4. **The Kaspa implementation must be UTXO/covenant-native.** Solidity contracts
   are not ported line by line. The EVM code contributes economic invariants,
   threat cases, and behavioral tests only where they remain valid.
5. **The first implementation is testnet-only and value-capped.** It may not hold
   production funds or be described as a production stablecoin.
6. **No upgrade or execution model is assumed.** Sharded L1 covenants, a based
   app, or a hybrid require the architecture decision in `1K-P1-012` / #112.
7. **One 1kUSD targets one USD of approved redeemable collateral value.** Exact
   collateral assets, haircuts, oracle policy, legal redemption obligations, and
   reserve attestations remain separate approval gates.

The ten product invariants in `MASTER_PLAN_2026.md` are accepted as program
requirements. They are not evidence that the current implementation satisfies
them.

## Alternatives considered

- **EVM production first:** rejected because it would spend assurance effort on
  a deployment track that is not the primary product target.
- **Equal dual-production track:** rejected because it doubles critical
  implementation and operational scope too early.
- **Direct Solidity-to-Silverscript port:** rejected because the state and
  concurrency models are incompatible.
- **Based app selected immediately:** rejected because #112 must compare it with
  covenant and hybrid topologies using current Toccata constraints.

## Security impact

- Reduces immediate attack surface by allowing only one primary production
  architecture.
- Prevents EVM assumptions about storage, calls, roles, and reentrancy from being
  silently transferred to Kaspa.
- Keeps production claims and real funds blocked until oracle, governance,
  reserve, monitoring, audit, and incident-response gates pass.
- Introduces dependence on early Toccata tooling; versions and trust assumptions
  must therefore be pinned and reviewed in #112.

## Compatibility and execution impact

- Existing EVM contracts and history are preserved; this ADR does not authorize
  contract changes or deletion.
- EVM tickets must be classified as portable specification work, reference-only
  maintenance, or unnecessary before implementation.
- The next candidate task is #112, limited first to the Kaspa architecture ADR.
  Its proof of concept requires a separately bounded execution step.

## Production claim policy

Until every release gate is evidenced, project material must say
"research/testnet implementation" and must not claim mainnet availability,
guaranteed value, completed audit, live reserves, or production readiness.
