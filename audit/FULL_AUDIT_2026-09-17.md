# 1kUSD Audit Status Report — Corrected Edition

| Field | Value |
|---|---|
| Original report date | 2026-09-17 (PR [#130](https://github.com/NeaBouli/1kUSD/pull/130), commit `6d3145e`) |
| Correction date | 2026-10-10 |
| Repository baseline | `main` at `2a5ec38` |
| Nature | Documentation correction of an internal, AI-assisted review. **Not an external or professional security audit.** |
| Codex Security | **NOT RUN** |
| Independent review of this correction | **Pending** — required before publication or merge |
| Production verdict | **NO-GO** for production, mainnet, public issuance, and real reserves |

---

## 1. Correction Notice

The 2026-09-17 edition of this file listed 5 Critical, 10 High, 16 Medium and
18 Low findings. A later cross-check against the repository and earlier verified
evidence showed that the report:

- overstated several severities and counted the same root cause more than once;
- contained claims that the repository state at `2a5ec38` does not support;
- used stale counts for tests, placeholders, dependencies and documentation;
- read like a formal audit even though it was not one.

This edition replaces that content with a short status report. It does not add
new findings, does not assign new severities, and gives no exploit details. The
original text is still available unchanged in Git history at commit `6d3145e`.

## 2. What the Project Is Today

| Layer | State |
|---|---|
| EVM reference (Solidity 0.8.30, Foundry, Paris EVM) | Research/testnet prototype. It is useful for economic rules and negative tests. It is not a production stablecoin (`AUD-H01`). |
| Kaspa Toccata architecture | Design accepted (UTXO/covenant-native, not a Solidity port; `AUD-H02`). |
| Kaspa implementation | **Not built.** The repository contains no covenant scripts, Rust workspace, transaction builder, indexer, or Testnet-10 deploy path. |

Oracle, timelock, fee routing, monitoring and deployment verification are
incomplete in the EVM reference. This is documented and blocks production.

## 3. Evidence Baseline

All counts below are historical and apply only to the stated commit and tool
versions. A passing count does **not** prove the system is safe.

| Evidence | Value | Date / commit |
|---|---|---|
| Foundry suite | 229 passed, 0 failed, 0 skipped, 35 suites | 2026-10-03, `2a5ec38`, Foundry 1.5.0, solc 0.8.30 |
| Placeholder tests counted in that total | 8 (the original report said 11) | 2026-10-03, `2a5ec38` |
| Slither 0.11.5 (full repository) | 8 Medium, 0 High; Mediums still untriaged (`AUD-M08`, #105) | 2026-10-03, `2a5ec38` |
| Coverage | 78.92% lines, 57.63% branches (not re-measured since) | 2026-08-05 |
| Earlier suite | 198 passed, 10 placeholders | 2026-08-05 |
| OpenZeppelin | One submodule, v5.4.0 per prior verification; docs citing v4.8 are stale | 2026-08-05 |

This correction did not run new tests, scans or coverage measurements.

## 4. Remediated Items

| Item | Remediation |
|---|---|
| `AUD-H03` — default admin vs. guardian sunset precedence (original M-02) | `1K-P0-002`, [#102](https://github.com/NeaBouli/1kUSD/issues/102) / PR #120 |
| `AUD-M01` — guardian registration/resume lifecycle | `1K-P0-003`, [#103](https://github.com/NeaBouli/1kUSD/issues/103) / PR #124 |

The guardian/role-lifecycle issues are fixed. The remaining role and
governance work is a production blocker under #107, not a reopened finding.

## 5. Remaining Production Blockers

Each item maps to an existing ticket or AUD ID. No new tickets are proposed.

| Area | Open gap (generic) | Tracking |
|---|---|---|
| Release integrity | Freeze/tag metadata, compiler alignment across toolchains, JS lockfile, dependency docs, SBOM, license conflict | #104, `AUD-M02`, `AUD-M03` |
| Quality gates | Placeholder replacement, permit/treasury tests, multi-decimal and non-standard-token tests, Slither triage and CI gate, aligned required checks | #105, `AUD-M04`, `AUD-M07`, `AUD-M08` |
| Oracle | Production trust model, sources and price plausibility bounds; current oracle is a mock | #106 |
| Governance and roles | Working timelock and complete role handoff; no roles may be moved to the current timelock skeleton | #107 (ADR-043) |
| Fees and treasury | One canonical fee path, fee/reserve accounting, rounding policy, unused-allowance hygiene | #108 |
| Collateral | Fail-closed decimals and limits, limit range validation, actual-received accounting | #109, `AUD-M06` |
| Deployment | Production deploy with constructor validation, fail-closed key configuration, post-deploy wiring and role verification | #110, `AUD-M05` |
| Operations | Reserve, oracle, pause and solvency monitoring, plus watcher initial-state validation | #111 |
| External assurance | New reproducible freeze, professional external audit, bug bounty | #114 |
| Repository hygiene | Legacy patch/archive migration, stub and WIP contracts out of the release scope | #115 |

## 6. Disposition of the Original Findings

Classifications come from the 2026-09-19 Bridge correction matrix. Items marked
† were re-checked against the code at `2a5ec38` during this correction (symbols
only). All other items carry the matrix result without re-verification. The
matrix has a single author and has **not yet been independently cross-reviewed**.

| Disposition | Original IDs |
|---|---|
| Confirmed gap, tracked above | C-01†, H-01, H-02† (five constructor dependencies, not eight), H-06, H-07, H-08†, M-03, M-04, M-06, M-09 (count corrected to 8), M-10, M-11, L-04, L-09 (partial), L-10, L-11, L-12, L-15 (monitor is a stub), L-16 |
| Conditionally or partially confirmed | C-04 (handoff/misconfiguration risk, not every contract), H-03 (rounding to zero possible; claimed economic impact not substantiated), H-04, H-05 (depends on the key), M-01, M-07, L-01, L-14 (document intent) |
| Reclassified: real topic, but not the security finding as stated | C-02† (burn is restricted to the burner role; integration semantics only), C-03 (allowance hygiene/interface mismatch, not a drain), H-10 (publicly known local development key, no leaked secret; still needs fail-closed config), M-12 (archive hygiene), M-13 (test-only, informational) |
| Duplicate | M-08 → C-04; M-14 → M-10 |
| Remediated | M-02 (§4) |
| Not supported by repository state | C-05†, H-09†, M-05†, M-15, M-16 (stale docs only), L-02, L-03, L-05, L-06†, L-08, L-13†, L-17, L-18 |
| Unverified / unsubstantiated | L-07; the original SLoC figure, invariant counts and "~30 of 40 invariants tested" estimate; the dependency-confusion claim under M-11 |

The original report's description of the project's audit documentation, role
separation, SafeERC20 and ReentrancyGuard usage, and fuzz configuration is
broadly accurate. Several of its quantitative statements are not.

## 7. Decisions That Remain Open

This report decides none of the following. They stay with the project owner
and, where stated, with legal or independent review:

- license (`DEC-005`);
- oracle trust model;
- fee policy and destination (`DEC-004`);
- collateral policy;
- governance signer set, threshold and delays;
- wallet and custody arrangements;
- any production, mainnet or public-issuance decision.

Nothing in this report implies that the stablecoin is ready for production, and
nothing in it implies that any live secret has been compromised.

## 8. Limitations

- Sensitive acceptance criteria for a private audit are owned by the private
  operator. This public report does not and cannot satisfy private audit acceptance.
- This report gives no exploit paths, payloads, raw scanner output,
  infrastructure addresses or private audit locations.
- The original findings were not reproduced in full. Only the symbols marked †
  were re-checked.
- Codex Security has not been run. Independent review of this correction is
  pending.
- The historical freeze `audit-final-v0.51.5` must not be rewritten. A new
  external-audit candidate needs a new reproducible freeze (#114).

## 9. Sources

- [Codex findings and AUD IDs](../docs/agent-bridge/CODEX_FINDINGS.md)
- [Audit follow-up, 2026-08-05](../docs-internal/reports/AUDIT_REVIEW_2026-08-05.md)
- [Ticket list](../docs/agent-bridge/TICKET_LIST.md)
- [Audit scope](AUDIT_SCOPE.md), [Threat model](THREAT_MODEL.md),
  [Trust model](TRUST_MODEL.md), [Role matrix](ROLE_MATRIX.md),
  [Known limitations](KNOWN_LIMITATIONS.md)
- Bridge correction matrix: `docs/agent-bridge/PROJECT_STATUS_2026-09-19.md`
  §9, and checkpoint `docs/agent-bridge/PROJECT_STATUS_2026-10-03.md`, both at
  commit `d7bff0b` (publication pending)
- Original 2026-09-17 report: Git history, commit `6d3145e`
