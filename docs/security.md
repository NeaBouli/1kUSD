# Security and verified limits

Status as of **2026-10-10**. Security claims on this site follow evidence, not
roadmap intent. The prototype must not hold real funds. There is no mainnet
deployment, no live reserve, no completed external audit and no guaranteed
peg.

## Verified baseline (EVM reference)

Each number below is a historical result with its evidence date. None is a
live counter.

| Metric | Result · evidence |
|---|---|
| Foundry tests | 229 passed / 0 failed / 0 skipped · #124, 2026-08-16 |
| Placeholder tests | 8 of the 229 · #124, 2026-08-16 |
| Line coverage | 78.92% · 2026-08-05 |
| Branch coverage | 57.63% · 2026-08-05 |
| External audit | Not completed |
| Production deployment | None |

A passing suite is useful evidence, not certification. The historical
`audit-final-v0.51.5` tag is not a production certification.

## Open release blockers

- Oracle prices are admin-set mocks, not production feeds.
- DAO timelock execution is not implemented.
- Fee routing and the production deployment role handoff are incomplete.
- The Guardian lifecycle fixes are merged and covered by tests. Deployment
  role wiring and end-to-end handoff checks are still required.
- Audit freeze, dependency, static-analysis and license metadata still need
  reconciliation.

## Kaspa track

No Kaspa code has been executed for 1kUSD. The `ADR-042` revalidation is in
review (#131), and gate G3 is open. Candidate toolchain versions are
non-adopted, and their compatibility and runtime behaviour are not verified.
Until then, no security property of a Kaspa implementation is claimed.

## Intended defenses

The target design includes:

- mandatory limits and slippage/deadline checks;
- stale- and deviation-aware pricing;
- per-module pause;
- delayed governance and multisig execution;
- reserve and supply monitoring;
- reproducible releases.

A control counts as delivered only after its focused tests, the full suite,
static analysis, deployment end-to-end checks and independent review all pass.

## Report privately

Use [GitHub Private Vulnerability Reporting](https://github.com/NeaBouli/1kUSD/security/advisories/new).
Do not publish exploit details in issues. Read
[SECURITY.md](https://github.com/NeaBouli/1kUSD/blob/main/SECURITY.md) before
testing.

Technical references:

- [Known limitations](https://github.com/NeaBouli/1kUSD/blob/main/audit/KNOWN_LIMITATIONS.md)
- [Audit follow-up](https://github.com/NeaBouli/1kUSD/blob/main/docs-internal/reports/AUDIT_REVIEW_2026-08-05.md)
- [Master plan](https://github.com/NeaBouli/1kUSD/blob/main/docs-internal/planning/MASTER_PLAN_2026.md)
