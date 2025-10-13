# Legal Stance — Informational Notes (Non-Legal Advice)
**Scope:** High-level positioning for decentralized/ownerless protocol; for partners/exchanges.  
**Status:** Info (no code). **Language:** EN.

## Positioning
- Smart contracts are **ownerless** or controlled by **DAO/Timelock**; no custodial control over user funds.
- **No promise of returns**; protocol charges minimal swap fees for peg operations (see FEE_ACCOUNTING_SPEC).
- **Open-source** (AGPL-3.0); community forks allowed; no exclusive rights.

## Roles
- **DAO**: parameter governance via Timelock delays.
- **Guardians**: temporary pause right; **sunset** enforced (see SAFETY_AUTOMATA_SPEC).
- **Contributors**: no unilateral control; changes via on-chain governance.

## Operational Notes
- Collateral sits **on-chain in Vault**; Proof-of-Reserves published by indexer.
- Protocol can **pause mint/burn paths**; transfers of token are standard ERC-20 and typically continue.

> These notes are informational and do **not** constitute legal advice. Projects should consult qualified counsel in relevant jurisdictions.
