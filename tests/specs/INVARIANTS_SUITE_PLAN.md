
Invariants Suite Plan (v1)

Status: Spec (no code). Language: EN.

Structure

Unit suites: token_authz, psm_accounting, safety_pause, rate_limit

Integration: psm_vault_oracle, treasury_flow, governance_params

Property/Fuzz: psm_vault_invariants, oracle_invariants

Execution Order (CI)

unit (fast)

integration (medium)

invariants (long/fuzz) — separate job with artifacts

Reporting

invariants.json: { "invariants":[{ "name": "I1", "checks": N, "violations": 0, "maxSteps": S, "seed": "0x..." }] }

Attach decoded event trails on failure for I2/I11–I13.

Seeds & Steps

Default seed from CI env; allow override via INVARIANTS_SEED and INVARIANTS_STEPS.

Minimum: 100k steps per suite before release.

Failure Policy

Any violation → job red; capture failing trace and state dump under reports/invariants/
