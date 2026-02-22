
PSM Quote Test Vectors — Usage

Files:

tests/vectors/psm_quote_vectors.json — machine-readable cases (du=18)

docs/PSM_QUOTE_MATH.md — normative math & rounding

Guidelines:

Unit tests MUST assert equality with these vectors (grossOut, feeOut, netOut, feeAsset when applicable).

Invariants should fuzz around these baselines (vary decimals, prices, fees).

Any change to math requires: update docs, vectors, and a CHANGELOG entry.
