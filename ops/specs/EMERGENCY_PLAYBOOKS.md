# Emergency Playbooks — Specification
**Scope:** Operational response for protocol incidents.  
**Status:** Spec (no code). **Language:** EN.

## Categories
A) Funds at risk (exploit)  
B) Oracle/Safety malfunction  
C) Governance/Timelock misconfig  
D) Infra outage (RPC/Indexer)

## Actions (A)
- Pause affected modules (Safety)
- Freeze fees/limits via short-delay Timelock if available
- Publish advisory; prepare patched release; reopen with staged caps

## Actions (B)
- Enforce allowSingleSource=false; lower caps; pause mint
- Require "safe" finality reads

## Actions (C)
- Cancel queued Timelock op; if executed, corrective param set

## Actions (D)
- Fail closed on writes; degraded UI mode; backup RPCs

## Postmortem
- Timeline, root cause, params diff, reproducer, follow-ups
