# Security and verified limits

Security claims on this site follow evidence, not roadmap intent. The current
prototype must not custody real funds.

## Verified baseline

| Metric | Result / evidence date |
|---|---|
| Foundry tests | 207 passed / 0 failed / 0 skipped (#120, 2026-08-13) |
| Placeholder tests | 10 (2026-08-05) |
| Line coverage | 78.92% (2026-08-05) |
| Branch coverage | 57.63% (2026-08-05) |
| External audit | Not completed |

A passing suite is useful evidence, not certification.

## Open release blockers

- Admin/Guardian role precedence prevents the default admin from pausing after
  Guardian sunset.
- Guardian self-registration and resume do not follow the documented role flow.
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
