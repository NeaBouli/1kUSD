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

## 2026-08-16 — 1K-P0-003 / Issue #103

### Approved lifecycle

- Safety `ADMIN_ROLE` directly grants and revokes the temporary Guardian role.
- The Guardian contract cannot register itself or receive permanent ADMIN/DAO
  authority merely to relay resume calls.
- DAO/Timelock resumes modules by calling `SafetyAutomata.resumeModule()`
  directly.
- Revocation is immediate; Guardian-only authority also expires at the exact
  `block.timestamp >= guardianSunset` boundary.
- Guardian and Safety sunset timestamps must match when they are wired.

### Implementation and verification

- Legacy `selfRegister()` is retained only as a non-mutating registration
  assertion; legacy `resumeOracle()` fails explicitly with
  `DirectResumeRequired`.
- Focused Guardian/Safety tests: 53 passed. Full Foundry suite: 229 passed
  across 35 suites. Two Guardian placeholders were replaced with real tests.
- Stateful revocation and re-registration invariant coverage passed with 256
  runs and depth 64.
- Targeted Slither: 0 findings for `SafetyAutomata.sol` and `Guardian.sol`.
- Independent Kimi K3 final review: `APPROVE`. Claude Code was unavailable due
  to expired OAuth and produced no review output.

This remains post-freeze, pre-merge evidence. No deployment, wallet action,
token-economics change, Kaspa PoC, or production action is part of this work.

### Merge confirmation

- PR #124 merged at `b5a2bc9aecd1dc316262a9dcdb38ba0d8158208a`.
- Issue #103 closed with reason `completed`.
- The final GitHub head passed Forge Build, Forge Test, docs-check, and the
  configured CodeRabbit status; all three actionable review threads were
  resolved before merge.
- This confirmation does not alter the historical freeze or authorize a
  deployment, wallet action, token-economics change, Kaspa PoC, or production
  action.
