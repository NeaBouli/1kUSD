# Post-Freeze Remediation Addenda

The audit artifacts for tag `audit-final-v0.51.5` remain historical and are not
rewritten by post-freeze fixes. This file records changes made after that tag.

## 2026-08-13 — 1K-P0-002 / Issue #102

### Approved policy

- Guardian-only pause authority is valid only before `guardianSunset`.
- At `block.timestamp >= guardianSunset`, Guardian-only pause attempts revert.
- Guardian-only callers cannot resume modules at any time.
- Existing `ADMIN_ROLE` or `DAO_ROLE` authority remains valid at and after
  sunset, including when the same caller also holds `GUARDIAN_ROLE`.

| Caller roles | Before sunset: pause | At/after sunset: pause | Resume |
|--------------|----------------------|------------------------|--------|
| Guardian only | Allowed | `GuardianExpired` | Denied |
| ADMIN/DAO only | Allowed | Allowed | Allowed |
| ADMIN/DAO + Guardian | Allowed | Allowed | Allowed |
| No authorized role | Denied | Denied | Denied |

### Implementation and verification

- `SafetyAutomata.pauseModule` evaluates permanent ADMIN/DAO authority before
  applying the temporary Guardian sunset gate.
- Function signatures, events, storage layout, and resume authorization are
  unchanged.
- Focused configuration tests: 17 passed.
- SafetyAutomata invariants: 5 passed with 256 runs and depth 64.
- Full post-freeze Foundry suite: 207 passed across 35 suites.
- Targeted Slither analysis of `SafetyAutomata.sol`: 0 findings.
- The repository-wide Slither baseline still reports pre-existing findings
  outside this ticket; this addendum does not treat them as resolved.

No deployment, wallet action, token-economics change, or unrelated governance
change is part of this remediation.
