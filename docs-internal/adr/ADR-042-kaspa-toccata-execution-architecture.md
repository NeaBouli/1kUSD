# ADR-042: Kaspa Toccata Execution Architecture

Status: **Proposed — Gio decision required**
Date: **2026-08-13**
Decision owner: **Gio**
Recorded by: **Codex Sol**
Independent review: **Kimi K3, 2026-08-16 (`APPROVE` after publication-consistency corrections)**
Tracking issue: [1K-P1-012 / #112](https://github.com/NeaBouli/1kUSD/issues/112)

## Context

ADR-041 selected Kaspa as the primary 1kUSD product track and retained the EVM
contracts only as an executable economic reference. This ADR decides which
Toccata execution model should be tested first. It does not authorize code,
deployment, wallets, real collateral, or a production claim.

The source state verified on 2026-08-13 is materially newer than the repository
baseline:

- [`rusty-kaspa` v2.0.0](https://github.com/kaspanet/rusty-kaspa/releases/tag/v2.0.0)
  introduced the mainnet Toccata activation at DAA score `474,165,565`; v2.0.1
  added RPC, lane-proof, wallet, and covenant-binding improvements.
- [KIP-16, KIP-17, KIP-20, and KIP-21](https://github.com/kaspanet/kips)
  are `Active` and provide ZK verification, covenant opcodes, covenant IDs, and
  partitioned sequencing commitments.
- Transaction v1 and compute-budget behavior exist in `rusty-kaspa`, but their
  specification PRs [KIP-24](https://github.com/kaspanet/kips/pull/41) and
  [KIP-25](https://github.com/kaspanet/kips/pull/42) remain open. Implementation
  behavior, not an unmerged draft, is therefore the execution reference.
- [Silverscript](https://github.com/kaspanet/silverscript) is the intended
  covenant authoring path but is experimental and recommends Testnet-10 until a
  stable v1 release. [vProgs](https://github.com/kaspanet/vprogs) is also an
  evolving prototype, not a stable external SDK.

Toccata is UTXO-native. Covenant state lives in the current redeem-script
preimage. Spending that UTXO reveals the old state and must validate the exact
successor output. A covenant ID gives stable lineage and prevents unauthorized
entrance into a covenant family, but it does not validate the application state
transition; the script must do that.

## Decision drivers

The first architecture must preserve these properties without importing EVM
storage or role assumptions:

1. collateral receipt, 1kUSD issuance, and liability increase are atomic;
2. redemption, 1kUSD destruction, and collateral release are atomic;
3. every transition preserves local conservation and contributes to a globally
   reconstructible reserve/supply invariant;
4. double-spent or forged successors are rejected by consensus plus script;
5. missing, stale, replayed, or non-quorate oracle data fails closed;
6. emergency authority can only reduce capabilities and expires permanently;
7. all live state is discoverable and independently reconstructible;
8. transaction construction fits the pinned compute and storage mass limits;
9. the smallest architecture that carries these invariants is preferred.

## Options considered

### A. L1 covenant family

State is represented by covenant UTXOs. A mint or redeem transaction consumes
the relevant old states and creates their validated successors in one
transaction. The first safe topology is deliberately a singleton control/reserve
state plus independent 1kUSD bearer boxes.

Proposed protocol family:

- **control/reserve state:** collateral amount, issued liability, issuance cap,
  configuration epoch, policy/oracle commitments, governance delay,
  emergency-key sunset, nonce, and paused state;
- **1kUSD bearer boxes:** owner commitment and 1kUSD amount, with transfer and
  merge/split conservation;
- **oracle report witness:** signed external input checked by the transition;
  it is not trusted merely because an indexer observed it.

A mint consumes collateral plus the singleton control/reserve state and creates
its exact successor plus the user's 1kUSD box. A redeem consumes 1kUSD boxes plus
that same state and creates the reduced-liability successor plus collateral
release. Transfer consumes and recreates only 1kUSD boxes while conserving the
sum.

Mint, redeem, pause, resume, and governance all consume the current singleton
control/reserve UTXO. They therefore validate the current policy and epoch
directly; there is no unconsumed global configuration object to read and no old
configuration shard that remains independently usable. This intentionally
serializes those operations in the PoC. Bearer-box transfers remain independent
and continue while issuance/redemption is paused; pause is not a transfer freeze.

No transition in the PoC may create a second control/reserve state or a new
issuance shard. The launch proof commits the sole covenant identity and initial
state, and every control transition requires exactly one successor of that same
family. Production fan-out, a shard registry/root, deterministic shard creation,
aggregate cap allocation, mixed-epoch behavior, and complete multi-shard pause
are unresolved. They require a later ADR and may not be inferred from this one.

Advantages:

- closest match to asset issuance, custody, and release conditions;
- consensus prevents double-spending of each current state;
- independent bearer-box transfers can progress without consuming control state;
- no proof operator or shared off-chain execution state is required;
- failure behavior is easier to inspect in a first PoC.

Costs and risks:

- the control/reserve state is sequential and may experience contention;
- cross-template successor validation and large redeem scripts can exceed mass
  limits, so every route requires measured on-node evidence;
- aggregate supply is reconstructed from bearer boxes and reconciled to the one
  control/reserve liability;
- production fan-out and global pause propagation are not solved by this ADR;
- wallets and indexers need launch proofs and covenant-aware state decoding.

### B. Based app with L1 proof settlement

Users submit v1 payload operations to an application lane. An off-chain runtime
executes shared state and a settlement covenant verifies proofs anchored to
KIP-21 sequencing commitments.

Advantages:

- natural shared state and batching;
- high concurrency at the user-operation layer;
- one proven state root can cover reserves, liabilities, balances, and policy.

Costs and risks:

- introduces executor, prover, witness-serving, settlement, fee-bumping, and
  reorg-recovery infrastructure before the basic asset invariant is proven;
- settlement cadence changes user-visible finality and exit behavior;
- vProgs APIs and operational workflows remain explicitly early;
- L1 composability is exit/permission-output oriented rather than immediate;
- proof correctness does not by itself guarantee data availability or liveness.

This is disproportionate for the first value-capped experiment.

### C. Hybrid covenant and based-app topology

Collateral custody and issuance authority remain in L1 covenants while balances,
batching, or policy accounting move into a based app and settle through proofs.

Advantages:

- retains L1 custody while allowing shared-state execution and batching;
- may become appropriate if measured covenant contention is unacceptable.

Costs and risks:

- combines both operational models and adds a bridge invariant between them;
- requires proof-bound mint/burn exits and unambiguous failure recovery;
- creates the largest first-review surface and the hardest atomicity story.

The hybrid option is retained as a later escalation path, not a first PoC.

## Proposed decision

Adopt **Option A, an L1 covenant family with one singleton control/reserve
state**, as the primary 1kUSD PoC architecture.

The first PoC uses exactly one control/reserve state and a small number of
1kUSD boxes. This deliberately proves the transition and conservation model.
It makes no safety, compatibility, or throughput claim for later shard fan-out.

Use Silverscript source plus reproducibly pinned compiler output. Raw script is
permitted only for a documented compiler limitation and requires equivalent
tests. Use Testnet-10 because the current Silverscript repository explicitly
recommends it; the execution ticket must revalidate that choice immediately
before running because testnet support can change.

Do not use a based app, vProgs runtime, KIP-21 user lane, or inline ZK in the
first PoC. Reconsider a hybrid or based-app path only if measured evidence shows
that covenant state cannot meet an approved concurrency, mass, or UX bound.

## Transition requirements

### Mint

The transaction must prove all of the following or fail atomically:

- the collateral asset and amount are allowed and actually received;
- the signed oracle report is valid for this network, protocol, asset, action,
  and validity interval;
- output, fee, reserve delta, and liability delta reconcile under deterministic
  rounding;
- the old control/reserve state authorizes exactly one valid successor with increased reserve
  and liability, within its cap;
- the issued 1kUSD output amount equals the liability delta;
- no unrelated output can enter either covenant family.

### Transfer

The sum of consumed 1kUSD amounts must equal the sum of successor 1kUSD amounts.
Ownership changes must be authorized, covenant lineage must continue, and no
reserve/issuance state may change.

### Redeem

The transaction must destroy the redeemed 1kUSD amount, reduce liability by the
same amount, release the correctly rounded collateral amount, apply the approved
fee policy, and create exactly one permitted control/reserve successor plus any
permitted bearer-box change successors.

### Governance and emergency state

EVM roles are not copied. Authority is expressed as spend conditions and valid
successor states:

- governance changes require a queued operation, an explicit delay, and the
  approved threshold authorization before the control/reserve successor can
  carry a new configuration epoch;
- a pre-sunset Guardian may only move the control/reserve state from operational to
  paused and may never release collateral, mint, redeem, change policy, create
  a shard, or resume;
- at and after sunset, Guardian signatures confer no authority;
- resume requires the delayed governance path;
- there is no separate recovery transition in the PoC;
- the PoC has exactly one pausable control/reserve state. Multi-shard emergency
  completeness is outside scope and requires a later architecture decision.

## Oracle model

The PoC uses signed reports as transaction witnesses, not an admin-set on-chain
price. The signed message must domain-separate at least:

- network/genesis identifier;
- 1kUSD protocol and configuration epoch;
- collateral asset identifier and decimals;
- price, quote unit, and rounding convention;
- observation time/DAA reference, validity bounds, and report id;
- permitted action (`mint`, `redeem`, or both).

The covenant validates the approved threshold, uniqueness of signers, report
domain, and freshness window. A report id identifies the signed observation but
is not single-use: the same report may authorize multiple bounded operations
only inside its validity window and configuration epoch. Reuse on another
network, protocol, asset, action, epoch, or outside that window fails. A reorg
does not consume a report, but a rebuilt transaction must revalidate it against
the current state and validity bounds. Missing or invalid reports halt the
affected operation. The exact provider set, threshold, heartbeat, deviation,
and fallback policy remain #106 decisions and are not silently fixed here.
For mechanism testing only, the bounded PoC uses three deterministic test keys,
requires two distinct valid signatures, accepts no fallback price, and tests
validity boundaries selected against the pinned node's available time/DAA
introspection. These are test parameters, not production oracle policy.

## Indexing and reorg recovery

Consensus correctness must not depend on a hosted indexer. Indexers are required
for discovery and UX and must reconstruct:

- covenant genesis derivation and covenant IDs;
- pinned template and bytecode hashes;
- all created, spent, and currently live control/reserve and bearer-box UTXOs;
- decoded state, issuance cap, reserves, liabilities, and 1kUSD box amounts;
- configuration epochs, oracle report ids, pause state, and governance actions.

The launch bundle contains the genesis outpoint, authorized genesis outputs,
templates, compiler/toolchain identities, and initial states. A client must
re-query live outpoints immediately before transaction construction. On reorg,
it rolls back derived state to a common accepted checkpoint and deterministically
replays; pending spends are rebuilt rather than assumed valid. Public balances
must distinguish provisional acceptance from the project-approved finality
policy.

## Toolchain and reproducibility policy

The PoC execution ticket must pin, record, and hash:

- the selected `rusty-kaspa` release and exact source commit;
- the Silverscript commit, compiler binary, source, generated script, ABI, and
  bytecode artifact;
- the transaction builder/SDK commit;
- the network id, node configuration, consensus activation data, and genesis;
- every test vector, generated transaction, compute budget, compute mass,
  storage mass, fee, txid, and accepted block reference.

Because KIP-24 and KIP-25 are still open, the implementation and generated test
vectors control. Their eventual merge is a compatibility review trigger.

## Consequences

- The project gains a concrete Kaspa-native path without porting Solidity.
- The EVM suite remains useful only for economic invariants and negative cases.
- Based-app infrastructure is deferred, reducing the first PoC trust surface.
- Covenant/indexer/toolchain risk becomes explicit and must be measured.
- No production collateral, mainnet issuance, stable-value claim, or audit claim
  follows from accepting this ADR.
- A later architecture ADR is required before migrating to hybrid or based-app
  execution.

## Reconsideration triggers

Reopen this decision if any of the following occurs:

- mint/redeem routes cannot maintain safe mass headroom on the pinned node;
- cross-template output validation cannot be made explicit and reproducible;
- approved throughput requires shared mutable state that cannot be safely
  partitioned;
- singleton control-state discovery or reserve/supply reconstruction cannot be
  proven complete;
- Silverscript, transaction-v1, covenant, or fee semantics change materially;
- vProgs reaches a reviewed stable interface and its operational benefits exceed
  its additional trust and liveness costs.

## Sources

Primary references reviewed on 2026-08-13:

- [Kaspa Toccata agent brief](https://docs.kaspa.org/toccata/agent-brief)
- [Covenant state](https://docs.kaspa.org/toccata/covenant-state)
- [Transaction v1](https://docs.kaspa.org/toccata/transaction-v1)
- [Script pricing](https://docs.kaspa.org/toccata/script-pricing)
- [Based apps](https://docs.kaspa.org/toccata/based-apps)
- [Inline ZK](https://docs.kaspa.org/toccata/inline-zk)
- [Silverscript guide](https://docs.kaspa.org/toccata/silverscript)
- [Toccata decision guide](https://docs.kaspa.org/toccata/decision-guide)
- [Toccata source map](https://docs.kaspa.org/toccata/references)
- [`rusty-kaspa` v2.0.0](https://github.com/kaspanet/rusty-kaspa/releases/tag/v2.0.0)
- [`rusty-kaspa` v2.0.1](https://github.com/kaspanet/rusty-kaspa/releases/tag/v2.0.1)
- [Kaspa Improvement Proposals](https://github.com/kaspanet/kips)
- [Silverscript repository](https://github.com/kaspanet/silverscript)
- [vProgs repository](https://github.com/kaspanet/vprogs)

## Deferred production-sharding questions

This ADR does not authorize or claim a safe production sharding scheme. A later
ADR must specify at least a consensus-enforced registry/root or factory
transition, deterministic shard identity derivation, aggregate cap allocation,
configuration-epoch migration, mixed-epoch behavior, and a pause protocol whose
completeness is independently derivable from genesis and accepted history. An
indexer may demonstrate that history; it may not be the authority that makes the
history complete.
