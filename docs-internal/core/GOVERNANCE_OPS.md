
Governance Ops (v1)

Artifacts

Proposal schema: governance/schemas/proposal.schema.json

Example proposals: governance/examples/*.json

Queue/Execute helpers: scripts/gov-queue.mjs, scripts/gov-exec.mjs

Workflow (conceptual)

Draft a proposal JSON and validate it against the schema.

Queue via Timelock (script prints descHash and planned ETA).

After delay, execute (script prints execution steps).

Indexer records events (proposal queued/executed).

Validation

Use AJV validator (scripts/validate-json.mjs):
node scripts/validate-json.mjs governance/schemas/proposal.schema.json governance/examples/proposal.increase-psm-fee.json
