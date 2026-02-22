
Oracle Test Guide — Aggregation & Guards

Unit tests

Normalization: ensure decimals conversion to d_p exact with floor.

Staleness: reject when now - updatedAt > MAX_AGE_SEC.

Non-positive: reject price <= 0.

Aggregation

MEDIAN with odd/even n cases.

TRIMMED_MEAN with t=1 and n>=3; fallback to MEDIAN when n < 2*t+1.

Deviation

Compute mid as MEDIAN(A); assert any |a-mid|/mid * 10_000 > maxDeviationBps flips healthy=false.

Ensure dispersion check runs on accepted sources only.

Health output

healthy = accepted>0 && deviation-ok.

updatedAt = min(updatedAt_i among accepted).

Fuzz

Random prices around baseline with occasional outliers; random staleness.

Ensure no panics with large values and mixed decimals.
