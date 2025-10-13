# Payout Map — Guidance (Non-binding)
**Status:** Info (no code). **Language:** EN.

| Severity | Example | Reward (indicative) |
|----------|---------|---------------------|
| Critical | Mint without deposit; Vault egress without Timelock; unbounded fee drain | $$$$ |
| High     | Rate-limit/cap bypass; pause evasion; oracle guard bypass enabling unsafe mint | $$$ |
| Medium   | Accounting drift (fees/decimals); event inconsistencies; partial bypass with mitigations | $$ |
| Low/Info | Gas inefficiency; doc inconsistencies | $ |

**Notes**
- Multiple root causes fixed from one finding may increase payout.
- Duplicates split at maintainers’ discretion (quality/PoC first).
- Clear, minimal-diff fixes and systemic insight are valued higher.
