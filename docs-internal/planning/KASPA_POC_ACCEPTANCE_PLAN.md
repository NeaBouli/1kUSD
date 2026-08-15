# Kaspa Testnet PoC Acceptance Plan

Status: **Proposed — execution requires a separate approved ticket**
Date: **2026-08-13**
Parent decision: [`ADR-042`](../adr/ADR-042-kaspa-toccata-execution-architecture.md)

## Objective

Test whether one L1 covenant family with a singleton control/reserve state can
enforce atomic collateral deposit, 1kUSD issuance, transfer conservation,
redemption, pause, and governance resume within current Toccata resource limits.

## Hard boundaries

- Testnet-10 only, revalidated immediately before execution.
- Synthetic collateral with no market or redemption claim.
- Zero real-money value at risk.
- Maximum test issuance: `10,000` synthetic 1kUSD units.
- One singleton control/reserve state and at most 100 live 1kUSD boxes.
- No shard creation, fan-out, registry, or mixed configuration epochs.
- No production keys, wallets, domains, reserves, integrations, or mainnet use.
- No based app, user lane, vProgs runtime, bridge, or production oracle.

## Required artifacts

- pinned `rusty-kaspa`, Silverscript, SDK/builder, and Rust toolchain identities;
- compiler and generated-bytecode hashes;
- network/genesis and node configuration manifest;
- covenant source, ABI, templates, covenant IDs, and genesis derivation;
- three deterministic oracle test keys, a two-signature test threshold, no
  fallback price, and canonical signed-report vectors;
- transaction corpus with compute budget, compute/storage mass, fee, txid, and
  acceptance/rejection result;
- indexer replay database or deterministic state export;
- clean-room reproduction instructions for a second operator.

## Required functional evidence

1. Bootstrap creates only the documented covenant families and initial state.
2. Mint accepts a valid fresh report and reconciles collateral, liability, fee,
   and issued amount exactly.
3. Transfer split, merge, and change routes conserve 1kUSD amounts.
4. Redeem burns the exact amount, lowers liability, and releases the expected
   rounded collateral amount atomically.
5. Pause blocks mint/redeem through every documented route.
6. Guardian can pause before sunset, cannot resume, and has no authority at or
   after sunset.
7. Delayed governance can consume the current control state, resume, and advance
   a test configuration epoch without bypassing conservation or caps; the old
   epoch/outpoint and old oracle key set cannot authorize another operation.
8. A clean indexer reconstructs the same reserves, liabilities, boxes, pause
   state, and configuration from genesis.

## Adversarial cases

- forged covenant id, wrong authorizing input, wrong template, or extra successor;
- double spend, stale outpoint, concurrent control-state spend, and replay after
  reorg;
- mint or transfer inflation by one unit and by rounding boundary;
- redeem without equivalent burn or with excess collateral output;
- missing, duplicate, unauthorized, stale, future, wrong-network, wrong-asset,
  wrong-action, and wrong-epoch oracle signatures; valid in-window reuse and
  invalid out-of-window reuse;
- Guardian pause at `sunset - 1`, exactly `sunset`, and `sunset + 1`;
- Guardian attempt to resume, move collateral, change cap, or create control state;
- governance operation before delay, twice, with wrong nonce, or wrong epoch;
- maximum allowed box fan-in/fan-out, minimum amount, and dust attempts;
- compute budget one step below measured need and excessive-budget fee behavior;
- mass-boundary transactions and builder refusal above the approved headroom;
- indexer restart, duplicate notification, missed notification, and rollback to a
  common checkpoint after a controlled testnet/devnet reorg simulation.

## Resource and reproducibility gates

- Every accepted route must pass both script/debugger tests and real-node
  mempool/consensus validation; debugger success alone is insufficient.
- The largest accepted transaction must remain at least 20% below each pinned
  node compute and storage mass limit. Reducing this floor requires explicit Gio
  approval and a new independent security review; otherwise the PoC stops.
- Source-to-bytecode reproduction must match exactly on a second clean machine.
- Two independent indexer replays must produce identical canonical state hashes.
- Any unavailable, failed, or skipped check is reported as such and never as a
  clean result.

## Exit criteria

The PoC may be called successful only when all functional, adversarial, resource,
and reproduction checks pass and an independent security review records no open
High/Medium result within the PoC scope.

Success authorizes only a subsequent design review. It does not authorize more
value, more shards, mainnet deployment, a peg claim, or production readiness.

## Stop conditions

Stop and return to architecture review if:

- cross-template successor validation cannot fit with safe mass headroom;
- supply/reserve equality depends on an unprovable absence of other UTXOs;
- singleton control-state or pause completeness cannot be reconstructed;
- compiler artifacts are not reproducible;
- testnet/toolchain behavior diverges from the pinned implementation;
- a safe route requires based-app or hybrid assumptions not approved by ADR-042.
