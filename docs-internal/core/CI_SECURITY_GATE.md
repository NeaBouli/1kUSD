
CI Security Gate (v1)

Purpose

Block merges/releases unless minimum security conditions pass.

Gate Inputs (artifacts)

unit.json, invariants.json, slither.json, mythril.json

security-findings.json (rollup), gas.json (baseline diff)

abi lock checks (scripts/check-abi-lock.js)

Pass Criteria

No Critical/High in security-findings.json

Invariants total violations == 0; steps ≥ 100k/suite

Static analysis completed (tools responsive), findings triaged

ABI lock checks OK for Token/PSM events

Optional: gas regressions within agreed thresholds

Failure Handling

CI annotates PR; requires explicit risk waiver label by CODEOWNERS to override
