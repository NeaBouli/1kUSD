# 1kUSD Token — Functional Specification
**Scope:** Canonical ERC-20-compatible stable token with controlled mint/burn via protocol modules and pause-interop with Safety-Automata.  
**Status:** Spec (no code). **Language:** EN.

## 1. Goals
- Strict **mint/burn gates** (only PSM and approved modules).
- ERC-20 compatibility (transfer, approve, allowance) with **non-custodial** semantics.
- **Pause interop**: transfers may continue, but mint/burn blocked on protocol pause (policy-driven).
- Optional **EIP-2612 permit** for UX; optional **EIP-712 domain**.

## 2. Interfaces (high-level)
- `mint(to, amount)` — **only MinterRole** (PSM/Safety-approved modules).
- `burn(from, amount)` — **only BurnerRole** (PSM/Safety-approved modules).
- `setMinter(address, bool)` / `setBurner(address, bool)` — **Safety/Timelock** (through Governance Hooks).
- `pause()` / `unpause()` — **Safety**; affects `mint`/`burn` (transfers policy: unaffected by default).
- `permit(owner, spender, value, deadline, v,r,s)` — optional; EIP-2612.

## 3. Supply & Accounting
- `totalSupply()` reflects active 1kUSD in circulation.
- Invariant (I1): **Vault USD value ≥ totalSupply** (checked outside token; token enforces gate-only mint/burn).

## 4. Events
- `Transfer(from,to,amount)` (ERC-20)
- `Approval(owner,spender,amount)` (ERC-20)
- `MinterSet(account, enabled)`
- `BurnerSet(account, enabled)`
- `Paused(account)` / `Unpaused(account)`

## 5. Errors
- `NOT_AUTHORIZED` (no role)
- `PAUSED` (mint/burn while paused)
- `INVALID_PERMIT` (sig, nonce, deadline)
- `BURN_EXCEEDS_BALANCE`

## 6. Security Notes
- **Non-upgradeable** by default; if upgradeable later, governance delay + audits.
- Reentrancy not applicable on ERC-20 std; still use checks for hooks if any.
- Permit nonces per owner; chainId in domain separator.

## 7. Testing Guidance
- Gate enforcement: only PSM can mint/burn during swaps.
- Permit vectors: valid/expired/wrong signer.
- Pause effects: mint/burn blocked; transfers policy verified (allowed by default).
