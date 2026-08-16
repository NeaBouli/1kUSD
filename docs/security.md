# Security and verified limits

Security claims on this site follow evidence, not roadmap intent. The current
prototype must not custody real funds.

## Verified baseline

| Metric | Result / evidence date |
|---|---|
| Foundry tests | 229 passed / 0 failed / 0 skipped (#124, 2026-08-16) |
| Placeholder tests | 8 (#124, 2026-08-16) |
| Line coverage | 78.92% (2026-08-05) |
| Branch coverage | 57.63% (2026-08-05) |
| External audit | Not completed |

A passing suite is useful evidence, not certification.

## Open release blockers

- Guardian registration/revocation and the direct DAO resume lifecycle are
  merged and test-verified; deployment role wiring and E2E handoff verification
  remain required before release.
- Oracle prices are admin-set mocks, not production feeds.
- DAO timelock execution is not implemented.
- Fee routing and production deployment/role handoff are incomplete.
- Audit freeze, dependency, Slither, and license metadata need reconciliation.

## Intended defenses

The target design includes mandatory limits, slippage/deadline checks, stale and
deviation-aware pricing, per-module pause, delayed governance, multisig execution,
reserve/supply monitoring, and reproducible releases.

These controls are considered delivered only after their focused tests, full
suite, static analysis, deployment E2E, and independent review pass.

## Report privately

Use [GitHub Private Vulnerability Reporting](https://github.com/NeaBouli/1kUSD/security/advisories/new).
Do not publish exploit details in issues.

Technical references:

- [Known limitations](https://github.com/NeaBouli/1kUSD/blob/main/audit/KNOWN_LIMITATIONS.md)
- [Audit follow-up](https://github.com/NeaBouli/1kUSD/blob/main/docs-internal/reports/AUDIT_REVIEW_2026-08-05.md)
- [Master plan](https://github.com/NeaBouli/1kUSD/blob/main/docs-internal/planning/MASTER_PLAN_2026.md)
