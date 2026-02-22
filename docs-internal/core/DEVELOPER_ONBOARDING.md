
1kUSD — External Developer Onboarding

Project repo: https://github.com/NeaBouli/1kUSD

Docs (GitHub Pages): https://neabouli.github.io/1kUSD/

What is 1kUSD?

Spec-first stablecoin/PSM protocol design with clear module boundaries, governance-gated parameter writes (DAO/Timelock), central safety controls (pause/caps/rate-limits), and reorg-aware indexing. Current repo delivers complete specifications, testing/security plans, docs site, and CI skeletons.

Architecture (high level)

Token (OneKUSD), PSM, Collateral Vault, Safety Automata (pause/caps/rate-limits, guardian sunset), Oracle Aggregator & Feeds, Proof of Reserves, AutoConverter & Routing Adapters, Governance (DAO/Timelock, Parameter Registry, Treasury).
Read the normative specs in contracts/specs/*.md first.

Invariants & Testing

I1–I17 cover conservation, safety, governance exclusivity, oracle coherence, CEI/reentrancy. Test plan and exit criteria in tests/specs/.

Repository (essentials)

contracts/specs/: normative module specs.

contracts/core/, contracts/interfaces/: minimal skeletons/interfaces.

docs/: docs site sources (MkDocs).

interfaces/, integrations/specs/, schemas/.

.github/workflows/: CI skeleton + Pages deploy.

How to contribute

Open an issue to propose changes; reference the spec(s).

Fork → topic branch (use conventional commits).

Implement strictly per spec (events, errors, CEI, guards, decimals).

Add tests aligned with invariants & test plan; produce JSON reports per reports/SCHEMA.md where possible.

Keep docs in sync (docs/*, mkdocs.yml when adding pages).

Open a PR with rationale, coverage and analysis notes.

Quality expectations

Spec compliance; CEI ordering; nonReentrant if required.

Invariants (I1–I17) hold in fuzz.

Coverage guideline: ≥90% statements / ≥85% branches / ≥90% functions.

Static analysis: no Critical/High open.

CI green; docs updated.

Useful links

Repo: https://github.com/NeaBouli/1kUSD

Docs: https://neabouli.github.io/1kUSD/

CONTRIBUTING: ./CONTRIBUTING.md

Security policy: ./SECURITY.md
