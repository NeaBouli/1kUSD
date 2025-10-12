# Governance Hooks & Parameter Flow — Specification

**Scope:** Defines how DAO/Timelock mutates protocol parameters and how Safety-Automata applies them.  
**Status:** Spec (no code). **Language:** EN.

---

## 1. Roles & Executors
- **DAO Governor** creates proposals; **Timelock** executes after delay.
- **Executor** (Timelock) holds `ROLE_PARAMS` and `ROLE_RESUME`, and can assign `ROLE_PAUSE` to Guardian for limited time.

## 2. Parameter Registry (Concept)
A logical registry mapping canonical parameter names to module-level setters:
- `"psm.feeBps" -> Safety.setPSMFeeBps` *(or direct PSM if allowed, preferred via Safety for single entry point)*  
- `"psm.cap.USDC" -> Safety.setCap(target="PSM", key=USDC)`  
- `"psm.rateLimit" -> Safety.setRateLimit(target="PSM", ... )`  
- `"oracle.guard.USDC" -> Safety.setOracleGuards(USDC, ... )`

**Principle:** All critical runtime parameters are routed through Safety to ensure uniform auditability.

## 3. Execution Flow
1. Proposal queued with calls to Safety setters (or Governor proxies).
2. After timelock delay: `Timelock.execute()` invokes setters.
3. Safety emits events (`CapSet`, `RateLimitSet`, …). Modules observe via reads on next call.

## 4. Fast-Track / Emergency
- Optional **Emergency Pause** capability: Guardian only `pause()`; no resume or parameter changes.
- DAO can schedule parameter reductions (e.g., caps ↓) with shorter delay than increases (policy decision).

## 5. Invariants (Gov Layer)
- Only Timelock or designated Executor can change parameters.
- No parameter path can bypass Safety when related to runtime risk (caps/limits/oracle guards).
- Guardian sunset timestamp must be in the future when assigning Guardian; assignment emits an event (in Safety).

## 6. Events (Complementary)
- Reuse Safety events for parameter changes; Governance emits:
  - `ProposalCreated`, `ProposalQueued`, `ProposalExecuted`
  - `ParameterChanged(name (indexed) string, value bytes, ts uint256)` for meta-tracking.

## 7. Testing Guidance
- Differential tests: parameter updates via Safety vs. direct module setters must result in identical runtime behavior.
- Timelock delay honored; no execution before ETA.
