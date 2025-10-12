# DAO & Timelock — Functional Specification

**Scope:** Governance proposal lifecycle and delayed execution for parameter updates and privileged operations (no direct fund custody).
**Status:** Spec (no code). **Language:** EN.

---

## 1. Goals
- On-chain governance with **timelocked execution** for safety.
- Clear roles: Governor (proposal), Timelock (execute), Executor (role holder).
- Emergency pause via Safety-Automata guardian (no asset control).

## 2. Roles
- **Governor:** creates proposals; defines calls (targets, calldata, value).
- **Timelock:** queue/execute after `minDelaySec`; can cancel if preconditions fail.
- **Executor (Timelock address):** holds protocol roles (`ROLE_PARAMS`, `ROLE_RESUME`) per Safety spec.
- **Proposer Set:** Governor; optional allowlist.
- **Canceller:** Governor (if needed).

## 3. Parameters
- `minDelaySec` (e.g., 48–96h).
- Optional `shortDelaySec` for **reductions** of risk (e.g., caps ↓), longer delay for increases (policy).
- `gracePeriodSec` for execution window.

## 4. Lifecycle
1. **Create:** Governor proposes calls to Safety/Modules (prefer Safety as the single param entry).
2. **Vote:** Off-chain or on-chain voting (implementation-tbd; out of scope here).
3. **Queue:** Timelock stores `eta = now + delay(name)`.
4. **Execute:** After `eta`, perform calls. Emit `ProposalExecuted`.
5. **Cancel:** If proposal fails quorum, becomes obsolete, or security incident.

## 5. Interfaces (Concept)
- `queue(targets[], values[], calldatas[], predecessor?:bytes32, salt:bytes32) -> operationId`
- `execute(operationId)`
- `cancel(operationId)`
- Views: `isOperationPending|Ready|Done(opId)`, `getTimestamp(opId)`, `minDelay()`

## 6. Events (align with ONCHAIN_EVENTS.md)
- `ProposalCreated(id, proposer, ipfsHash, eta)`
- `ProposalQueued(id, eta)`
- `ProposalExecuted(id, txHash, ts)`
- `ParameterChanged(name, value, ts)` (meta-tracking, optional mirror)

## 7. Safety Notes
- Timelock **does not** hold funds; only parameters/pauses.
- Executor must be a multisig; keys rotation procedure documented.
- Operations should target Safety setters or module-safe admin functions only.
