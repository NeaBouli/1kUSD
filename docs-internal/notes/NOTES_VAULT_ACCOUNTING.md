# Notes — Vault Accounting (DEV51)
- Vault stores raw token units per asset; no rescaling.
- Fees are tracked per-asset in `pendingFees[asset]` and swept via Timelock.
- Fee-on-transfer tokens rejected by balance delta guard.
- Caps enforced on **ingress**; egress unrestricted except for balance/paused checks.
