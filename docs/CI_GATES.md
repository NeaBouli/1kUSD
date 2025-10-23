
CI Gates — Red/Green Criteria (v1)

Status: Docs. Language: EN.

Jobs & Pass Criteria

lint

Pass: exit 0 (placeholder now).

compile

Pass: toolchain compile succeeds (forge or hardhat).

unit

Pass: unit.json present; failed==0.

invariants

Pass: invariants.json present; for all entries violations==0.

static-analysis

Pass: slither.json + mythril.json present; no findings with severity in {CRITICAL, HIGH}.

gas

Pass: gas.json present; file parse ok (no threshold enforced yet).

collate (summary)

Aggregates above into security-findings.json and ci-summary.json.

Overall pass: all upstream jobs green + summary.ok=true.

Artifacts

unit.json, invariants.json, slither.json, mythril.json, gas.json, security-findings.json, ci-summary.json

Notes

Placeholders emit minimal JSON so pipeline stays green until tests land.

Tighten thresholds as suites are implemented.
