# Gas Policy & Optimizations — Specification
**Scope:** Targets, patterns, and review checklist for gas efficiency.  
**Status:** Spec (no code). **Language:** EN.

## Targets
- Hot paths: PSM swap, Vault deposit/withdraw — aim < 150k gas typical.
- Views: O(1) storage reads; no loops over unbounded arrays.
- Events: minimal fields, index only high-cardinality topics.

## Patterns (Do)
- Use `unchecked` blocks for arithmetic with prior bounds checks.
- Pull vs push: prefer pull-from-user (approve/permit + transferFrom) once.
- Store decimals & scale factors once; reuse normalized 18-dec values.
- Cache storage reads to memory; write back once.
- Use custom errors; no revert strings.

## Patterns (Avoid)
- Unbounded iteration over lists/maps.
- External calls inside loops.
- Writing zero to storage when already zero.
- Redundant SafeMath (Solidity ≥0.8 has built-in checks).

## Tooling
- Gas snapshots per commit (`reports/gas.json`).
- Track top-N worst regressions; fail CI if >10% on hot methods.

## Review Checklist
- SLOAD/SSTORE count stable? Any new mappings?
- Event payload sizes reduced?
- Permit path vs approve path gas comparison recorded?
