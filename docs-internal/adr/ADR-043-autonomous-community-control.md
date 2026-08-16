# ADR-043: Autonomous Community Control and Privilege Minimization

Status: **Proposed — decision requested from Gio**
Date: **2026-08-16**
Decision owner: **Gio**
Recorded by: **Codex Sol**
Independent analysis: **Kimi K3, 2026-08-16**
Tracking issue: [1K-P1-016 / #127](https://github.com/NeaBouli/1kUSD/issues/127)
Blocks implementation issue: [1K-P1-007 / #107](https://github.com/NeaBouli/1kUSD/issues/107)

## Decision boundary

This ADR proposes a control architecture. It does not authorize contract or
Silverscript implementation, role transfers, multisig setup, a DAO launch,
voting-token design, deployment, wallets, real funds, or production use.

The objective is technically autonomous, non-custodial, transparent,
community-maintained operation with minimized persistent privileges and no
hidden control points. It is not an objective or claim that 1kUSD is immune
from law or regulation. Legal classification, disclosures, authorization,
redemption obligations, and jurisdiction-specific compliance remain independent
release gates. Architecture must not be designed or described as a means of
regulatory evasion.

## Context

ADR-041 selected Kaspa Toccata as the primary product track and retained the
EVM implementation as an executable reference. ADR-042 selected a singleton
control/reserve L1 covenant family for a separately approved Testnet-10 proof of
concept. Neither ADR decided the protocol's long-term control model.

The current EVM reference is not autonomous:

- the governance timelock is a non-functional stub;
- several modules use a single mutable `admin` or `dao` address;
- `SafetyAutomata` initially grants deployer-held admin and Guardian roles;
- parameter setters are not consistently range-bounded or timelocked;
- deployment role handoff has not been verified end to end.

The Kaspa architecture cannot copy those EVM roles. Authority must be expressed
as spend conditions and valid successor states. ADR-042 already requires a
queued governance operation, delay, configuration epoch, and a permanently
expiring pause-only Guardian. This ADR defines which powers may exist at all,
who may exercise them during each stage, and which powers must disappear.

## Decision drivers

1. No person, deployer key, maintainer, interface operator, or hidden recovery
   path may unilaterally mint, burn, release collateral, change prices, upgrade
   the value path, or bypass governance delay.
2. Solvency, atomic mint/redeem, liability conservation, deterministic rounding,
   and authorized successor validation must remain outside governance control.
3. Necessary configuration changes must be bounded, observable, delayed, and
   reproducible from accepted history.
4. Emergency authority may only reduce capabilities, must never move funds, and
   must expire permanently.
5. Users must have time to observe a queued change and stop using or exit the
   protocol before it becomes executable.
6. Immutability must not be activated before quality, audit, deployment, legal,
   and operational evidence makes an irreversible step defensible.
7. Community development must not imply that source maintainers automatically
   receive protocol authority.
8. Consensus correctness must not depend on the project website, a hosted
   interface, one indexer, one builder, or one release operator.

## Options considered

### A. Fully immutable and governance-free

All value-path code and configuration are fixed at launch and every privileged
role is removed.

Advantages:

- no governance capture or administrator compromise;
- no malicious upgrade or hidden parameter change;
- simple authority model.

Costs and risks:

- an immutable defect can make the protocol unsafe or permanently unusable;
- oracle, collateral, limits, and incident policy cannot adapt;
- safe launch would require substantially stronger evidence than the current
  prototype provides.

This option is rejected as the complete control model, but its immutability
property is applied to the economic core.

### B. Unbounded DAO governance

A DAO may change parameters, upgrade code, replace modules, move treasury or
reserve assets, and manage emergency powers.

Advantages:

- maximum adaptability;
- operational recovery from defects is possible.

Costs and risks:

- governance capture becomes equivalent to protocol capture;
- token voting can create plutocracy and bribery markets;
- an upgrade path is a permanent hidden-control surface even when rarely used;
- the DAO can silently invalidate the protocol's economic promises.

This option is rejected.

### C. Bounded timelocked community governance

The economic core is immutable. Governance may only change an explicit,
range-bounded parameter allowlist through queue, public delay, and single-use
execution. It cannot upgrade the value path, arbitrarily mint or burn, move
collateral, bypass solvency checks, remove the delay floor, or extend an expired
Guardian.

Advantages:

- preserves necessary operational adaptability without granting constitutional
  rewrite power;
- gives users and reviewers an exit/containment window;
- makes every permitted authority enumerable and testable.

Costs and risks:

- the community-mandate mechanism can still be captured or become unavailable;
- parameter ranges and delay tiers become security-critical;
- immutable core defects still require a new, opt-in system rather than an
  in-place upgrade.

### D. Progressive control minimization

Bootstrap authority begins with a distributed multisig and is reduced in
measured stages until only bounded community governance and the time-limited
emergency path remain.

Advantages:

- avoids irreversible renunciation before the implementation is proven;
- turns decentralization into verifiable gates instead of a launch claim;
- supports clean rollback before each irreversible transition.

Costs and risks:

- temporary power tends to persist unless every stage has an explicit deadline,
  owner, and stop condition;
- early stages retain identifiable control and key-compromise risk;
- transition evidence and independent review add operational cost.

### E. Permanent emergency council

A council permanently retains pause, resume, or recovery power.

This option is rejected. A permanent emergency council is a permanent control
point. Emergency authority is retained only as pause-only, capability-reducing,
and irreversibly expiring.

## Proposed decision

Adopt a composed model:

1. **Option C is the target control model.** The value path is immutable and
   governance is limited to an explicit, range-bounded parameter constitution.
2. **Option D is the transition mechanism.** Each stage removes authority and
   requires evidence before the next irreversible step.
3. **Option A applies to the economic core.** No proxy, upgrade hook, arbitrary
   recovery call, governance-controlled mint/burn, or reserve sweep exists in
   the production value path.
4. **Emergency authority is pause-only and time-bounded.** It may transition an
   operational module to paused before sunset and do nothing else. It cannot
   resume, move funds, change configuration, create shards, or extend its own
   lifetime.
5. **Community development and protocol authority are separated.** Anyone may
   review, fork, reproduce, or contribute code. Maintainer status alone grants
   no on-chain authority. Release artifacts require reproducible builds and
   independent verification.

The community-mandate mechanism is intentionally not selected here. Naive
transferable-token voting is not a default because it introduces plutocracy,
delegation concentration, flash-borrowing, and bribery risks. A later ADR must
select the mandate mechanism and its Sybil/capture assumptions before community
governance is implemented. Once respecified against an accepted ADR-043 and
separately approved for execution, #107 may implement and test only the bounded
timelock, distributed bootstrap proposer, and complete role handoff on the EVM
reference; it may not launch a DAO or voting token.

## Constitutional boundary

### Immutable economic core

Governance must never be able to change or bypass:

- supply and bearer-amount conservation;
- mint liability equals issued user amount;
- redeem liability reduction equals destroyed user amount;
- collateral release is atomic with authorized redemption;
- solvency and approved haircut enforcement;
- deterministic units, decimals, and rounding direction;
- authorization of the exact successor state and covenant lineage;
- single-use governance operation identity and configuration-epoch monotonicity;
- the minimum governance-delay floor;
- the Guardian sunset and pause-only boundary;
- the prohibition on arbitrary collateral sweeps and arbitrary mint/burn;
- the absence of an in-place upgrade path for the value system.

If an immutable-core defect is found, the recovery mechanism is not a hidden
upgrade. The protocol halts affected operations, publishes evidence, and may
propose a separately audited replacement system. Users opt into any migration;
no administrator may forcibly rewrite balances or reserve claims.

### Governable parameter constitution

Only documented parameter families may be governed, each with hard bounds and
an assigned delay tier:

- issuance and rolling-volume caps;
- fee and spread values within immutable maxima;
- approved collateral identifiers, decimals commitments, haircuts, and
  per-asset exposure caps;
- oracle signer set, threshold, freshness, deviation, and outage policy within
  immutable safety floors;
- pause/resume state through the approved authority paths;
- governance proposer membership, threshold, and delays without crossing
  immutable decentralization and delay floors;
- treasury/buyback policy only for assets explicitly designated as surplus,
  never user redemption collateral.

Every parameter key not present in the allowlist fails closed. Adding a new
parameter family changes the constitutional surface and requires a new ADR,
security review, and user-visible migration or replacement design.

### Prohibited powers

No stage may introduce:

- an undisclosed deployer or default-admin role;
- an unrestricted delegate call or arbitrary target executor outside the
  bounded governance allowlist;
- a governance-controlled reserve sweep;
- a governance-controlled arbitrary mint, burn, balance rewrite, or seizure;
- an extendable or renewable emergency sunset;
- a privileged price setter in a production profile;
- a hosted indexer, interface, or builder as consensus authority;
- a production release key held by one maintainer.

## Track mapping

### EVM executable reference

DEC-003 describes the current pre-timelock reference lifecycle: direct
ADMIN/DAO resume with no Guardian resume authority. The target state preserves
governance-only resume but places it behind the approved timelock.

#107 must replace the current timelock stub with a real queue/execute/cancel
lifecycle, bind execution to the exact committed target/value/calldata/salt,
enforce delay and expiry, and prove replay resistance. It must add two-step role
handoff and post-deploy assertions showing that the deployer holds no residual
admin, minter, burner, DAO, Guardian, treasury, oracle, registry, vault, limits,
or timelock authority.

The EVM reference does not gain a production commitment from this ADR. No
upgradeable proxy is authorized.

### Kaspa Toccata primary track

Governance is a valid control/reserve-state transition, not an EVM role. The
queued operation commits the permitted parameter delta, earliest execution
point, nonce, and current configuration epoch. Execution consumes that queued
state and creates exactly one successor with a monotonically increased epoch.

The covenant template and constitutional bounds are fixed by the launch proof.
The Guardian transition is operational-to-paused only, expires at the committed
sunset, and cannot be renewed. Resume uses the delayed governance transition.
Indexers and builders reconstruct and propose transactions but cannot confer
authority or determine valid state.

ADR-042's Testnet-10 PoC remains separately gated and does not become authorized
by this ADR.

## End-state authority matrix

| Action | End-state classification | Required mechanism |
|---|---|---|
| Mint or burn | No human/DAO authority | Only validated PSM/covenant transition |
| Release redemption collateral | No human/DAO authority | Atomic authorized redemption only |
| Sweep backing reserves | Prohibited | No route exists |
| Set a price | No privileged setter | Threshold-signed, domain-separated report |
| Change bounded fees/limits/oracle/collateral policy | Delayed community authority | Allowlisted, range-bounded, timelocked operation |
| Add a new parameter family | Prohibited in place | New ADR and opt-in replacement/migration design |
| Pause | Bounded emergency or delayed community authority | Guardian before sunset; governance through its delayed path |
| Resume | Delayed community authority | Governance only |
| Upgrade value-path logic | Prohibited | No proxy or replacement hook |
| Change governance delay/threshold | Longest-delay community authority | Self-administered path with immutable floors |
| Treasury/buyback surplus | Delayed and capped | Explicit surplus policy; never backing reserves |
| Publish code or operate an interface | Permissionless | No protocol authority follows from publication |
| Release canonical artifacts | No single maintainer | Reproducible build plus independent verification |

## Security impact

Positive effects:

- removes unilateral mint, custody, pricing, upgrade, and parameter authority;
- limits governance capture to a bounded surface and gives users an observation
  window;
- makes deployer residue, emergency sunset, and role handoff testable release
  gates;
- reduces dependence on project-hosted infrastructure and maintainers.

New or retained risks:

- an immutable defect cannot be repaired in place;
- the future community-mandate mechanism may be captured or become unavailable;
- parameter bounds, delay tiers, and surplus classification are critical policy;
- a timelock only delays a malicious decision; it does not make the decision
  benevolent;
- a public interface or service operator can remain regulated or operationally
  concentrated even when the protocol has no privileged key;
- experimental Kaspa tooling and community-maintainer supply chains remain
  independent attack surfaces.

Detailed controls are specified in
[`GOVERNANCE_CONTROL_THREAT_MODEL.md`](../core/GOVERNANCE_CONTROL_THREAT_MODEL.md).
The staged handoff is specified in
[`GOVERNANCE_TRANSITION_PLAN.md`](../planning/GOVERNANCE_TRANSITION_PLAN.md).

## Compatibility impact

- Existing contracts, tests, and historical evidence remain unchanged.
- #107 must be respecified as a bounded-governance reference implementation and
  role-handoff task after this ADR is accepted.
- #106, #108, #109, and DEC-004 remain owners of oracle, fees, collateral, and
  surplus-policy details; this ADR only constrains their authority surfaces.
- Any production sharding or based-app architecture still requires the later ADR
  already required by ADR-042.

## Regulatory and public-claim boundary

The absence of an identifiable protocol administrator is not a legal opinion or
safe harbor. A USD-referenced crypto-asset, an offer, an interface, custody,
redemption service, exchange service, or active promotion may carry obligations
independent of source-code control. The project must obtain qualified legal
review for intended jurisdictions before any public offer or production launch.

Project material must describe verified technical properties only. It must not
claim that decentralization makes 1kUSD unregulatable, legally immune, guaranteed,
ownerless before evidence, or exempt from issuer/service-provider rules.

Primary regulatory references used for this boundary:

- [EU Regulation 2023/1114 (MiCA)](https://eur-lex.europa.eu/eli/reg/2023/1114/oj)
- [EBA: asset-referenced and e-money tokens](https://www.eba.europa.eu/regulation-and-policy/asset-referenced-and-e-money-tokens-mica)
- [ESMA Q&A on crypto-assets without an identifiable issuer](https://www.esma.europa.eu/publications-data/questions-answers/2552)

These references are release-gate inputs, not legal conclusions in this ADR.

## Consequences

- 1kUSD gains a concrete autonomy target without pretending that all governance
  can safely disappear immediately.
- #107 remains blocked until Gio accepts or rejects this proposal and separately
  approves implementation under revised acceptance criteria.
- A separate ADR is required for the community-mandate mechanism.
- A separate legal/compliance decision is required before any production or
  public-offer action.
- Irreversible privilege removal occurs only after the transition plan's
  evidence gates pass.

## Decision requested from Gio

Accept or reject the following package:

1. immutable economic core with no in-place upgrade path;
2. bounded, range-validated, timelocked governance for an explicit parameter
   allowlist only;
3. progressive, evidence-gated removal of deployer and bootstrap authority;
4. permanently expiring pause-only Guardian and governance-only resume;
5. separation of community maintenance from on-chain authority;
6. separate future decision for the community-mandate mechanism;
7. independent legal/compliance launch gate and no regulatory-immunity claim.

Acceptance approves the architecture only. It does not approve #107 execution,
deployment, multisig setup, voting-token design, wallets, real funds, or release.

## Sources

- [OpenZeppelin Contracts 5.x governance](https://docs.openzeppelin.com/contracts/5.x/api/governance)
- [OpenZeppelin Contracts 5.x access control](https://docs.openzeppelin.com/contracts/5.x/api/access)
- [Kaspa Toccata agent brief](https://docs.kaspa.org/toccata/agent-brief)
- [ADR-041](ADR-041-kaspa-primary-product-track.md)
- [ADR-042](ADR-042-kaspa-toccata-execution-architecture.md)
