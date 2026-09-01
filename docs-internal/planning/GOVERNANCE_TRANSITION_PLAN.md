# Governance Control-Minimization Transition Plan

Status: **Proposed with ADR-043**
Date: **2026-08-16**
Tracking: **1K-P1-016 / Issue #127**

## Purpose

Define measurable stages for moving from the current administrator-controlled
research prototype to an immutable economic core with bounded, timelocked
community governance and no persistent personal control. This document is a
plan, not execution authorization.

## Global rules

- Authority may stay equal or decrease between stages; it may not silently
  expand.
- One ticket owns each irreversible transition.
- Every stage requires a published pre/post authority snapshot and independent
  recheck.
- Deployer renunciation, Guardian sunset, immutable deployment, and production
  launch are irreversible gates and require explicit Gio approval.
- Failure of a gate keeps the project in the last verified stage. Deadlines do
  not justify bypassing security requirements.
- No stage claims regulatory immunity. Legal/compliance approval is independent
  and required before any public offer or production activity.

## Stage 0 — Current research baseline

Authority state:

- EVM modules contain direct admin/DAO surfaces;
- `DAO_Timelock` is a stub;
- oracle pricing is admin-set test infrastructure;
- role handoff and production deployment are unverified;
- Kaspa governance exists only as ADR-042 architecture.

Exit criteria:

- ADR-043 accepted by Gio;
- DEC-007 records the exact accepted scope;
- #107 is respecified against ADR-043 and separately approved;
- community-mandate design remains explicitly deferred rather than assumed.

Abort criteria:

- ADR-043 rejected or unresolved constitutional boundary;
- request would add an upgrade, reserve sweep, arbitrary executor, or permanent
  emergency authority.

## Stage 1 — Bounded governance reference implementation

Scope owner: future respecified #107.

Authority state:

- distributed bootstrap multisig proposes operations;
- real timelock enforces exact commitment, delay, expiry, and replay protection;
- direct deployer control remains only during the measured handoff rehearsal;
- EVM remains a reference unless a separate production-track decision is made.

Entry criteria:

- Stage 0 complete;
- threshold, signer independence, minimum delay tiers, cancellation policy, and
  allowed target/function/key set explicitly approved;
- threat-model and implementation acceptance tests attached to #107.

Exit evidence:

- queue/execute/cancel/expiry/replay/value/batch tests pass;
- every privileged function is mapped to immutable, removed, bounded-timelock,
  or time-bounded-emergency classification;
- malicious unallowlisted target/function/key calls fail;
- the launch proof or deployment manifest commits the non-governable minimum
  signer-set size and authorization threshold, and tests prove governance cannot
  reduce either floor;
- two-step role transfers and post-handoff assertions pass;
- signer loss/rotation and cancellation rehearsals pass;
- full suite and static analysis pass with no untriaged High/Medium finding in
  the changed governance surface;
- independent review approves the complete diff.

Abort criteria:

- any direct setter or alternate path bypasses delay;
- deployer retains an undocumented role;
- timelock can make arbitrary calls outside the constitutional allowlist;
- delay or hard bounds can be reduced below their immutable floor.

## Stage 2 — Quality and immutable-core candidate

Authority state:

- value-path implementation is frozen as an audit candidate;
- only bounded configuration remains mutable;
- no privilege is renounced yet.

Entry criteria:

- Stage 1 complete;
- #105 quality work complete;
- all placeholder production-scope tests removed;
- coverage, invariant, mutation, economic, and static-analysis floors approved
  and passing;
- oracle, collateral, fee/surplus, and parameter policies decided through their
  owning tickets;
- complete deployment/role manifest reproducible on a clean environment.

Exit evidence:

- new reproducible audit freeze;
- professional audit and remediation complete for the immutable core and
  governance boundary;
- public bug bounty complete or operating for the approved period;
- no open High/Medium finding;
- independent reproduction of source-to-artifact hashes.

Abort criteria:

- any unresolved value-path ambiguity or upgrade dependency;
- backing reserve can be swept or reclassified by governance;
- production policy depends on an unset or fail-open parameter.

## Stage 3 — Kaspa Testnet-10 governance proof

Authority state:

- singleton control/reserve covenant carries queued operation and epoch state;
- Guardian is pause-only before sunset;
- all assets and keys are deterministic test fixtures only.

Entry criteria:

- separate PoC execution ticket approved;
- Testnet-10/toolchain choice revalidated;
- Stage 1 governance semantics and ADR-042 transition invariants translated to
  Kaspa-native tests;
- no real funds or production claims.

Exit evidence:

- exact operation commitment, delay, expiry, nonce, epoch, and single-successor
  tests pass on a real pinned node;
- changed-calldata, replay, mixed-epoch, alternate-network, and unauthorized
  successor attacks fail;
- Guardian succeeds only before sunset for pause and fails at/after sunset;
- governance-only resume passes after delay;
- two independent indexers reconstruct identical control, reserve, liability,
  governance, and pause history;
- clean-machine toolchain and transaction reproduction succeeds.

Abort criteria:

- any ADR-042 PoC stop condition;
- compiler/template mismatch;
- governance transition can create another control state or issuance shard;
- safety depends on a hosted indexer, builder, or interface.

## Stage 4 — Community-mandate selection and rehearsal

Authority state:

- bootstrap multisig remains the bounded proposer;
- no community handoff occurs yet.

Entry criteria:

- separate community-mandate ADR approved;
- voting/admission, delegation, Sybil, plutocracy, bribery, quorum, cancellation,
  capture-recovery, and inactivity assumptions explicitly reviewed;
- the mechanism introduces no token-economic change without separate approval.

Exit evidence:

- public proposal/vote/queue/execute rehearsal completes under adversarial tests;
- concentration and participation metrics meet approved floors for an approved
  observation period;
- no single person, entity, or maintainer can reach proposal or execution
  threshold;
- a second independent operator can reproduce and execute the workflow.

Abort criteria:

- voter/delegate concentration exceeds the approved ceiling;
- bribery/Sybil/capture assumptions are unmitigated;
- community inactivity prevents safe resume or signer rotation;
- repository or interface control becomes de facto governance authority.

## Stage 5 — Irreversible privilege reduction

Authority state after completion:

- deployer has no role;
- bootstrap proposer is removed or reduced exactly as approved;
- timelock is self-administered within immutable floors;
- community mandate controls only the bounded allowlist;
- Guardian remains pause-only until its already committed sunset;
- no upgrade, arbitrary mint/burn, reserve sweep, or hidden recovery authority
  exists.

Entry criteria:

- Stages 1–4 complete;
- external audit rechecks the exact handoff transactions and final bytecode;
- incident, signer-loss, pause/resume, governance-deadlock, and replacement
  runbooks rehearsed;
- legal/compliance, reserve, redemption, monitoring, and operations gates pass;
- Gio explicitly approves each irreversible transaction.

Required evidence for each transaction:

- exact target, value, calldata/script delta, operation id, nonce, epoch, delay,
  expiry, and expected post-state;
- pre-state authority snapshot;
- independent reviewer approval;
- accepted transaction identifier and block/DAA reference;
- post-state authority snapshot proving the intended reduction;
- append-only Bridge and release-manifest record.

For Kaspa/Toccata, `script delta` is not a textual or mutable-state patch. It is
a hash commitment to a versioned canonical byte encoding that the separately
approved PoC execution ticket must pin before first use. The committed fields
must include the domain tag, network/genesis identifier, covenant-family and
template identifiers, consumed control/reserve state commitments, current epoch
and nonce, queued operation id, canonically ordered parameter delta, exact
successor script and amount commitments, earliest execution point, and expiry.
Execution must rebuild this encoding from the actual consumed and created state
and require byte-for-byte encoding and commitment equality. An unspecified or
ambiguous encoding blocks the transition.

Abort criteria:

- pre-state differs from the reviewed snapshot;
- transaction data differs from the approved commitment;
- any required monitor, indexer, signer, or legal/operational gate is unavailable;
- a new security finding affects the handoff or immutable core.

There is no rollback after a correctly executed renunciation or immutable
sunset. A discovered defect triggers containment and a separately reviewed,
opt-in successor proposal; it does not justify an undisclosed recovery key.

## Stage 6 — Autonomous community-maintained operation

End state:

- users interact directly with immutable rules;
- bounded governance changes only the constitutional parameter allowlist;
- maintainers propose source changes but hold no protocol authority;
- builders, interfaces, and indexers are replaceable and independently
  reproducible;
- emergency authority is expired or on its committed path to expiry;
- ongoing reserve, liability, governance, oracle, and concentration monitoring
  is public.

Continuing evidence:

- periodic authority and role snapshots;
- proposal, delegation/signer, and interface concentration reports;
- reproducible release checks;
- reserve/liability reconciliation;
- dependency and maintainer-access review;
- incident and liveness drills;
- current legal/compliance review for the actual offered activities.

Autonomy is a continuously evidenced technical property, not a permanent legal
or marketing label.

## Authority reduction matrix

Stage 2 changes evidence, not authority. Stage 4 rehearses a community mandate
while the Stage 1 bounded bootstrap proposer remains in control; neither stage
is omitted as an authorization shortcut.

| Authority | Stage 0 | Stage 1 | Stage 3 | Stage 5/6 target |
|---|---|---|---|---|
| Deployer admin | Direct | Handoff rehearsal only | None in PoC protocol | Removed |
| Bootstrap multisig | Not implemented | Bounded proposer | Test proposer | Removed/reduced by accepted community ADR |
| Timelock | Stub | Enforced | Covenant queued transition | Self-administered with immutable floors |
| Community mandate | None | Deferred | None | Bounded proposer only |
| Guardian | Temporary role | Pause-only | Pause-only | Permanently expired |
| Resume | Direct admin/DAO | Timelocked governance | Delayed governance | Delayed community governance |
| Parameter writes | Direct admin surfaces | Allowlisted/bounded | Epoch transition | Allowlisted/bounded only |
| Value-path upgrade | None assumed | Prohibited | Prohibited | Prohibited |
| Reserve movement | Admin-capable reference paths remain | Redemption/surplus separation tested | Validated covenant transition | Redemption only for backing reserves |
| Maintainer/release power | Repository-centric | Two-person review/reproduction | Pinned toolchain | No on-chain authority; reproducible releases |

## Dependencies and decision queue

- ADR-043 must be accepted before #107 implementation.
- #107 must be respecified and separately approved.
- #105 gates the immutable-core candidate.
- #106, #108, #109, and DEC-004 own oracle, fee/surplus, collateral, and treasury
  policy inputs.
- ADR-042 and a separate execution ticket gate the Kaspa PoC.
- A later ADR selects the community-mandate mechanism.
- Production remains blocked by the Master Plan's audit, legal, reserve,
  redemption, monitoring, and operational gates.

## Open decisions for Gio

1. Bootstrap signer set, threshold, and the non-governable minimum signer-count
   and authorization-threshold floors committed in the launch proof.
2. Minimum delay tiers and cancellation authority.
3. Whether EVM governance remains reference-only or may ever become a separate
   production candidate.
4. Direction for the later community mandate: contributor/reputation,
   token/delegation, elected council, bicameral, or another model.
5. Guardian sunset policy for any future deployment.
6. DEC-004 fee/surplus destination and proof that backing is never treasury.
7. Maintainer/release review quorum and artifact-provenance policy.
