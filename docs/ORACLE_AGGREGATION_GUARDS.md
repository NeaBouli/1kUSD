
Oracle Aggregation Guards (v1)

Status: Docs (normative). Language: EN. Audience: Core devs, auditors, SDK.

0) Scope

Defines multi-source price aggregation with guards: staleness, deviation, health flags. Supports MEDIAN (default) and TRIMMED_MEAN (k-of-n).

1) Inputs & Semantics

Each source i provides:

price_i (signed int), decimals_i

updatedAt_i (unix sec)

healthy_i (bool from adapter)

Global params (registry):

PARAM_ORACLE_MAX_AGE_SEC (max staleness)

PARAM_ORACLE_MAX_DEVIATION_BPS (max allowed deviation across accepted sources)

Mode: MEDIAN (default) or TRIMMED_MEAN with trim = floor(n/4) unless configured

Output decimals d_p (e.g., 8)

2) Normalization

Normalize to d_p:
norm_i = floor( price_i * 10^(d_p - decimals_i) )

Reject source if:

healthy_i == false

now - updatedAt_i > MAX_AGE_SEC

price_i <= 0 (non-positive)

Let A = sorted(norm_i) from accepted sources (n = |A|). If n == 0: unhealthy.

3) Aggregation

MEDIAN:

if n odd: p = A[(n-1)/2]

if n even: p = floor( (A[n/2 - 1] + A[n/2]) / 2 )

TRIMMED_MEAN (k-of-n):

trim t = min(config_t, floor(n/4))

if n < 2*t+1 → fall back to MEDIAN

slice B = A[t .. n-1-t]

p = floor( sum(B) / |B| )

4) Deviation Guard (cross-source dispersion)

Compute dispersion on accepted A before final p:

mid = MEDIAN(A)

maxDevBps = PARAM_ORACLE_MAX_DEVIATION_BPS

For each a in A: devBps = abs(a - mid) * 10_000 / mid

If any devBps > maxDevBps → unhealthy (reject output p)

5) Output

Return struct:

price = p (signed int)

decimals = d_p

healthy = (n > 0) AND (deviation guard passes)

updatedAt = min(updatedAt_i across accepted sources)

6) Re-read/Snapshot

PSM quotes MUST:

Use a snapshot (p, updatedAt, healthy) taken at quote time, or

Enforce re-read at exec and assert equality within strict rules.

7) Examples & Vectors

See tests/vectors/oracle_guard_vectors.json for exact cases (stale, outlier, trimmed).
