# Math & Rounding Rules — Specification
**Scope:** Canonical integer math and rounding policies across modules.  
**Status:** Spec (no code). **Language:** EN.

- Use `mulDiv(x, y, d)`-style helpers to avoid intermediate overflow.
- Prefer `floor` rounding for user-visible amounts; never exceed quoted `minOut`.
- Boundary tests: amounts near 1 wei/unit; cross-decimal (6↔18) conversions.
- Quote endpoints must reflect **post-fee** numbers and rounding.
