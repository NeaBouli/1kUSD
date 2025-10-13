# Disclosures — User-Facing (Informational)
**Scope:** Transparent risks & behaviors users should understand.  
**Status:** Info (no code). **Language:** EN.

## Key Disclosures
- **Peg Mechanism**: 1kUSD aims to track 1 USD via PSM arbitrage and fully reserved Vault.
- **Pause Behavior**: Mint/burn/PSM may pause in emergencies; **transfers usually continue**.
- **Oracle Risk**: Price feeds aggregated from multiple sources; stale/deviation guards can halt mint.
- **Smart Contract Risk**: Audited and tested, but risk cannot be eliminated; use at your own risk.
- **Bridge Risk**: If used, bridges introduce additional trust/finality assumptions.
- **Governance Risk**: Parameters may change via DAO/Timelock after public delay.

## User Responsibilities
- Verify contract addresses from `ops/config/addresses.*.json`.
- Keep wallets secure; beware of phishing/cloned UIs.
- Understand network fees and slippage before swapping.

> This document is **not** legal advice. For any regulatory questions, consult professional counsel.
