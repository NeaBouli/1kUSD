
Incident Response Runbook (v1)

Trigger Examples

Oracle anomaly; cap/limit bypass attempt; reentrancy alarm; large peg deviation.

Immediate Actions (T+0)

 Engage comms (internal bridge + public status)

 Evaluate need to pause module(s) via SafetyAutomata

 Snapshot telemetry (events window, PoR rollup, health)

Stabilization (T+30min)

 Lock governance pipeline; freeze non-essential deploys

 If oracle issue: switch to validated backup or increase confirmations

 Raise rate-limit/cap guards as needed (least risky first)

Triage & Fix (T+2h)

 Minimal fix proposal drafted; risk reviewed

 Timelock fast-track path invoked if configured

 Prepare hotfix tags + reproducible builds

Postmortem (D+1)

 Root cause; blast radius; timeline

 Permanent controls added; tests covering incident

 Community report published; learnings documented
