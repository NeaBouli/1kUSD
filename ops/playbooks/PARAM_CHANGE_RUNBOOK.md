# Playbook — Parameter Change (DAO/Timelock)
**Scope:** Safe parameter updates via on-chain governance.  
**Status:** Spec (no code). **Language:** EN.

## Inputs
- Change set: caps, rate limits, fees, oracle guards (diff vs current)
- Risk assessment: blast radius, backout values

## Procedure
1) **Prepare Proposal**: encode Registry/Safety/PSM setter calls
2) **Simulate**: on fork; ensure no reverts and effects as expected
3) **Create Proposal**: submit via Governor; record `proposalId`
4) **Vote Window**: monitor participation & quorum
5) **Queue**: Timelock ETA recorded; announce ETA in repo log
6) **Execute**: at ETA; immediately verify resulting state
7) **Post-Checks**: run smoke tests; confirm indexer reflects changes

## Backout
- Pre-authorize revert proposal (reverse diff) if feasible
- If incident: use Safety pause for affected modules before backout

## Artifacts
- Proposal calldata JSON; receipts; final param snapshot
