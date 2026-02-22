# PSM vs CDP — Short Explainer

- **PSM (1kUSD)**: Parity engine; converts non-stable assets on ingress; no debt, no CR target; swaps gated by Safety/Oracle guards.
- **CDP (e.g., DAI)**: Vaulted collateral, debt minting, liquidation mechanics, explicit CR targets.

Operationally this means 1kUSD focuses on execution correctness, oracle freshness, and flow controls — not liquidation auctions or CR monitoring.
