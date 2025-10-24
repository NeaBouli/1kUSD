
PSM Quote/Exec Alignment — Executable Invariants (v1)

Language: EN. Status: Normative + tooling.

Objective
Ensure execution-time outputs (gross, fee, net) exactly match quote-time semantics for identical inputs and snapshot assumptions (see docs/PSM_QUOTE_MATH.md, docs/ROUNDING_RULES.md).

Scope

Deterministic arithmetic: floor at each division; fee charged in in/out asset.

Snapshot consistency: same DU/D_in/D_out and feeBps.

Exec guards do not alter amounts (only allow/revert).

Invariants
I-QE-1: quoteTo1kUSD(amountIn, D_in, feeBps) == execTo1kUSD(amountIn, D_in, feeBps) amounts.
I-QE-2: quoteFrom1kUSD(amountIn1k, D_out, feeBps) == execFrom1kUSD(amountIn1k, D_out, feeBps) amounts.
I-QE-3: Fee conservation — fee is added to the correct asset fee-bucket without changing netOut.
I-QE-4: Rounding — divisions are floored, never rounded up.

Verification Tooling

scripts/psm-crosscheck.mjs reads tests/vectors/psm_quote_vectors.json.

Re-computes amounts using the exact same integer math as the PSM formulae.

Emits JSON report with pass/fail per vector and a summary.

Outputs

reports/psm_quote_exec_report.json (machine-readable)

reports/psm_quote_exec_summary.txt (human-readable)
