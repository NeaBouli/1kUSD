# Governance and Control-Minimization Threat Model

Status: **Proposed with ADR-043**
Date: **2026-08-16**
Scope: **control architecture and future implementation gates**

This document supplements the EVM and Kaspa-native threat models. It does not
authorize a governance deployment, DAO, role transfer, voting token, wallet, or
production action.

## Security objectives

- no single person or key can mint, burn, release collateral, set prices, change
  critical policy, upgrade the value path, or bypass delay;
- governance can change only explicitly allowlisted, range-bounded parameters;
- every privileged operation is committed, delayed, observable, single-use,
  reproducible, and attributable to accepted history;
- deployer and bootstrap privileges are completely enumerated and removed before
  an irreversible handoff;
- emergency authority can only reduce capabilities and expires permanently;
- maintainers, interfaces, indexers, builders, and release operators are not
  consensus authorities;
- immutable value-path logic is activated only after the evidence gates in the
  transition plan pass.

## Assets

- backing collateral and valid redemption claims;
- 1kUSD supply, ownership, and liability accounting;
- immutable economic and covenant-transition invariants;
- configuration state, parameter bounds, delay floors, and epochs;
- governance proposal identity and execution integrity;
- emergency pause state and sunset;
- reproducible source, build, launch, and role-handoff evidence;
- availability of independent clients, indexers, builders, and maintainers.

## Trust boundaries

| Boundary | Trusted for | Not trusted for |
|---|---|---|
| Immutable value path | Enforcing encoded conservation and transition rules | Correctness without review, tests, and audit |
| Timelock | Enforcing the committed delay and operation identity | Deciding whether a proposal is beneficial |
| Bootstrap multisig | Proposing bounded operations during transition | Permanent unilateral policy, custody, or upgrades |
| Future community mandate | Authorizing proposals under its accepted rules | Bypassing the constitution, delay, or hard bounds |
| Guardian | Pre-sunset capability reduction by pausing | Resume, funds, policy, mint/redeem, upgrades, or sunset extension |
| Maintainers | Reviewing and publishing source proposals | On-chain authority by virtue of repository access |
| Release builders | Producing reproducible artifacts | Correctness without independent reproduction |
| Interfaces/indexers | Discovery, UX, proposal presentation, and reconstruction | Consensus validity, mandatory routing, or legal immunity |
| Legal/compliance review | Assessing intended activities and jurisdictions | Proving technical correctness or solvency |

## Adversaries

- compromised, coerced, unavailable, or colluding signers;
- a malicious or mistaken deployer retaining undisclosed authority;
- governance-majority capture, delegation concentration, plutocracy, bribery,
  flash-borrowed influence, or Sybil manipulation;
- a proposer substituting execution calldata after community review;
- an executor replaying, reordering, censoring, or partially executing actions;
- an emergency actor attempting to resume, move funds, or extend authority;
- maintainers or dependency publishers introducing malicious source or artifacts;
- an interface or indexer censoring proposals or presenting false state;
- an attacker exploiting an immutable defect after privileges are removed;
- a regulator, litigant, or service provider treating economic activity
  differently from the project's technical characterization.

## Threats and required controls

| Threat | Failure | Required control and evidence |
|---|---|---|
| Key compromise | One key changes policy or captures funds | Distributed threshold; no single proposer/executor/admin; delay as second factor; signer replacement before final handoff; compromise rehearsal |
| Deployer residue | Hidden admin remains after announced decentralization | Complete role/function inventory; two-step transfers; post-handoff assertions; independent node queries; zero deployer authority before renunciation |
| Governance capture | Majority authorizes harmful but valid configuration | Immutable core; narrow parameter allowlist; hard ranges; tiered delay; published exit/containment window; no arbitrary target calls |
| Plutocracy and bribery | Capital buys or rents community control | No default transferable-token voting; separate mandate ADR; historical voting power; delegation concentration and bribery analysis; quorum and participation floors |
| Sybil capture | One actor simulates broad community support | Mandate-specific Sybil assumptions and admission/revocation controls in the later ADR; no production community handoff before they are reviewed |
| Proposal/execution mismatch | Reviewed proposal executes different calls | Operation id commits chain/network, target, value, exact calldata, predecessor, salt/nonce, earliest time, expiry, and epoch; execution recomputes equality |
| Partial/batched execution | Only favorable parts of a proposal execute | Atomic batch or separately committed dependencies; explicit predecessor graph; fail whole batch on any mismatch |
| Replay or stale execution | Old proposal executes again or under a new epoch | Single-use consumed state/operation status; nonce; epoch binding; expiry; cross-network domain separation |
| Delay bypass | Admin reduces delay and immediately attacks | Immutable minimum floor; delay change uses longest tier and becomes effective only after its own delayed execution |
| Malicious upgrade | Governance replaces value logic or steals reserves | No proxy or arbitrary delegate call in the value path; no upgrade key; replacement requires new ADR, audit, and user opt-in migration |
| Emergency abuse | Guardian pauses indefinitely, resumes, or changes state | Pause-only route; immutable sunset; governance-only resume; no fund movement; exact sunset boundary tests |
| Permanent freeze | Guardian or unavailable governance leaves system paused | Guardian cannot resume; documented delayed governance resume; liveness drills; no safety bypass; remain testnet-only if governance availability is unproven |
| Immutable defect | Funds or accounting become unsafe after renunciation | No irreversible handoff before quality/audit gates; fail-closed pause; public incident evidence; separately audited opt-in replacement, never hidden repair |
| Parameter griefing | Valid extreme value disables or drains protocol | Immutable minima/maxima and relational constraints; simulation vectors; parameter-class delay tiers; fail closed on absent configuration |
| Treasury/reserve confusion | Governance labels backing as surplus and sweeps it | Separate accounting domains; backing reserves have no sweep route; surplus proof and caps; DEC-004 required before treasury authority |
| Oracle-set capture | Governance installs malicious signers/threshold | Immutable threshold/freshness floors; longest delay for signer-set changes; domain separation; independent monitoring and outage policy |
| Interface concentration | One UI censors exits or hides changes | Permissionless direct protocol use; open schemas; multiple independently hosted clients; signed/reproducible interface releases |
| Indexer equivocation | Users see false reserves, proposals, or roles | Deterministic replay from launch proof; at least two independent indexers/nodes; mismatch alert; indexer never authoritative |
| Builder/release compromise | Published artifact differs from reviewed source | Pinned toolchain; reproducible build; artifact hashes; two-person release review; independent clean-machine reproduction |
| Maintainer capture | Repository access becomes de facto control | Protected review workflow; least-privilege GitHub roles; no maintainer protocol keys; forks remain viable; release provenance |
| Dependency compromise | Governance or covenant toolchain injects behavior | Pinned commits/versions; checksums/SBOM; minimal dependencies; change review; no lifecycle scripts without explicit approval |
| Governance liveness failure | Quorum or signers disappear | Replacement process through delayed governance; staged drills; no irreversible handoff until availability target is met; production blocked if deadlock persists |
| Regulatory-immunity misclaim | Users rely on false claim; services or team face avoidable exposure | Explicit non-evasion language; qualified legal review; honest risk/role disclosures; no guarantee or immunity marketing |

## Required security properties

1. The enumerated privileged-function set is complete for every deployed module.
2. An unlisted target or parameter key cannot be reached through governance.
3. No operation executes before its delay or after its expiry.
4. Execution exactly matches the reviewed commitment and current epoch.
5. An operation executes no more than once.
6. The immutable delay, parameter, oracle, collateral, and exposure floors cannot
   be weakened by governance.
7. No administrator can mint, burn, seize balances, release backing collateral,
   or rewrite liabilities.
8. Guardian authority is pause-only before sunset and nonexistent at/after it.
9. Resume remains possible only through the delayed governance path.
10. Deployer, maintainer, interface, indexer, and builder identities confer no
    protocol authority in the end state.
11. Current roles, queued operations, epochs, reserves, liabilities, and pause
    state are independently reconstructible.
12. An immutable defect cannot be concealed behind an upgrade; any successor
    system is explicit, separately reviewed, and opt-in.

## EVM-reference checks required for #107

- enumerate `DEFAULT_ADMIN_ROLE`, `ADMIN_ROLE`, `DAO_ROLE`, Guardian, token
  minter/burner, registry, oracle, limits, vault, fee, treasury, and timelock
  authority;
- implement real queue, execute, cancel, expiry, replay, predecessor, value, and
  exact-calldata semantics;
- prove no direct setter or alternate call path bypasses the timelock;
- prove two-step handoff and zero residual deployer privilege;
- prove the timelock cannot execute an unallowlisted target/function;
- prove delay floors and parameter hard bounds survive self-administration;
- test signer loss, malicious proposals, cancellation, pause/resume, and role
  revocation in focused and stateful suites;
- run full tests, static analysis, deployment rehearsal, and independent review.

## Kaspa/Toccata checks required before a governance PoC

- queued state commits exact delta, nonce, epoch, earliest point, and expiry;
- governance execution consumes the current state and creates exactly one valid
  successor with a monotonic epoch;
- replay, mixed-epoch, alternate-network, and changed-calldata variants fail;
- Guardian pause creates only the approved paused successor before sunset;
- Guardian signatures fail at and after sunset;
- governance resume and parameter changes respect the delay;
- compiler output, scripts, builder, transactions, and launch proof reproduce;
- two independent indexers reconstruct identical governance and reserve state.

## Residual risks

- bounded governance can still make harmful choices inside valid bounds;
- the community-mandate mechanism is unresolved and may introduce new capture
  assumptions;
- an immutable-core defect may require a new system and user migration;
- legal characterization can depend on activity, promotion, services, and
  jurisdiction, not only protocol keys;
- early Kaspa tooling and community-maintained dependencies remain evolving;
- decentralization evidence can become stale as signers, delegates, interfaces,
  and maintainers change.

These risks block production claims until the Master Plan's assurance, external
review, legal, reserve, redemption, and operational gates pass.
