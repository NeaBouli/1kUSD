# Ticket List

The GitHub issue is the execution record. This file is the stable cross-agent
index. `approved_for_execution` must be set explicitly before implementation.

| ID | Priority | Track | Title | Depends on | Status | GitHub |
|---|---|---|---|---|---|---|
| `1K-P0-001` | P0 | Program | Approve product scope and EVM/Kaspa dual-track decision | — | proposed | [#101](https://github.com/NeaBouli/1kUSD/issues/101) |
| `1K-P0-002` | P0 | Safety | Correct SafetyAutomata sunset role precedence | 001 | proposed | [#102](https://github.com/NeaBouli/1kUSD/issues/102) |
| `1K-P0-003` | P0 | Safety | Define and repair Guardian registration/resume lifecycle | 001 | proposed | [#103](https://github.com/NeaBouli/1kUSD/issues/103) |
| `1K-P0-004` | P0 | Release | Reconcile freeze, dependencies, license, and SBOM | 001 | proposed | [#104](https://github.com/NeaBouli/1kUSD/issues/104) |
| `1K-P0-005` | P0 | Quality | Triage Slither Mediums, replace placeholders, enforce production quality gates | 002–004 | proposed | [#105](https://github.com/NeaBouli/1kUSD/issues/105) |
| `1K-P1-006` | P1 | Oracle | Specify and integrate production oracle trust model | 001 | proposed | [#106](https://github.com/NeaBouli/1kUSD/issues/106) |
| `1K-P1-007` | P1 | Governance | Implement timelocked multisig governance and role handoff | 001–003 | proposed | [#107](https://github.com/NeaBouli/1kUSD/issues/107) |
| `1K-P1-008` | P1 | Economics | Unify FeeRouter, treasury accounting, and fee policy | 001 | proposed | [#108](https://github.com/NeaBouli/1kUSD/issues/108) |
| `1K-P1-009` | P1 | Collateral | Fail-closed asset decimals, limits, and vault accounting | 001 | proposed | [#109](https://github.com/NeaBouli/1kUSD/issues/109) |
| `1K-P1-010` | P1 | Deployment | Build production deployment and post-deploy verification | 006–009 | proposed | [#110](https://github.com/NeaBouli/1kUSD/issues/110) |
| `1K-P1-011` | P1 | Operations | Implement reserve, oracle, pause, and solvency monitoring | 006–010 | proposed | [#111](https://github.com/NeaBouli/1kUSD/issues/111) |
| `1K-P1-012` | P1 | Kaspa | Write Toccata ADR and isolated covenant proof of concept | 001 | proposed | [#112](https://github.com/NeaBouli/1kUSD/issues/112) |
| `1K-P1-013` | P1 | GitHub | Repair Pages, CI gates, repository metadata, and active-tree hygiene | — | in_progress | [#113](https://github.com/NeaBouli/1kUSD/issues/113) |
| `1K-P2-014` | P2 | Audit | Create reproducible freeze, external audit package, and bug bounty | 002–011 | blocked | [#114](https://github.com/NeaBouli/1kUSD/issues/114) |
| `1K-P2-015` | P2 | Archive | Migrate referenced legacy patches/logs with link validation | 013 | proposed | [#115](https://github.com/NeaBouli/1kUSD/issues/115) |

No issue may close merely because code was written. Validation and review are
part of every ticket's definition of done.
