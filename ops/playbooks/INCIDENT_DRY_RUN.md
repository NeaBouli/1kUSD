# Playbook — Incident Dry-Run (SEV1/SEV2)
**Scope:** Tabletop + live simulation of major/medium incidents.  
**Status:** Spec (no code). **Language:** EN.

## Scenarios
- S1 Peg deviation > 100 bps and oracle stale
- S2 Indexer unsafe lag > 600 blocks; swaps degrade > 10% fail

## Drill Steps
1) **Detection**: trigger via telemetry simulators; confirm alerts fire
2) **Response**: Safety pause (mint path); announce status page
3) **Diagnosis**: verify oracle sources; RPC provider health; caps headroom
4) **Mitigation**: tighten caps; switch oracle policy; reduce PSM fees temporarily if needed
5) **Validation**: peg returns < 50 bps; lag < threshold
6) **Recovery**: resume modules; restore params stepwise; monitor for 2h

## Postmortem Template
- Timeline; root cause; param diffs; what worked/failed; action items
