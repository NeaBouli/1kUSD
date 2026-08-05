# Codex Findings

Source: repository/GitHub/Kaspa audit performed 2026-08-05 with an independent
Kimi K3 review.

## Release blockers

| ID | Severity | Finding | Status |
|---|---|---|---|
| `AUD-H01` | High | Published code is not a complete production stablecoin | Open |
| `AUD-H02` | High | Kaspa requires a new UTXO/covenant architecture, not a direct port | Open |
| `AUD-H03` | High | Default admin cannot pause after guardian sunset | Open |
| `AUD-M01` | Medium | Guardian self-registration/resume role flow is not executable as documented | Open |
| `AUD-M02` | Medium | Freeze commit, dependency version, and Slither metadata are inconsistent | Open |
| `AUD-M03` | Medium | Root license, package metadata, and SPDX identifiers conflict | Open |
| `AUD-M04` | Medium | Test count includes ten placeholders; branch coverage is insufficient | Open |
| `AUD-M05` | Medium | Deployment verification omits required module wiring and role handoff | Open |
| `AUD-M06` | Medium | Missing decimals/limits configuration can fail open or disable operation | Open |
| `AUD-M07` | Medium | GitHub merge/security checks are not aligned with actual CI | Open |
| `AUD-M08` | Medium | Slither reports eight Medium results requiring focused triage | Open |

Detailed evidence and remediation are recorded in
[`AUDIT_REVIEW_2026-08-05.md`](../../docs-internal/reports/AUDIT_REVIEW_2026-08-05.md).

Findings remain open until a focused fix, exact tests, full relevant suite, and
Codex recheck are recorded. Documentation changes alone do not close a contract
finding.
