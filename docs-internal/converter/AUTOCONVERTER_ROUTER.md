# AutoConverter Router

The **AutoConverter Router** coordinates token conversions between collateral assets and 1kUSD.  
It ensures deterministic routing and executes via the Peg Stability Module (PSM) and Vault adapters.

---

## ⚙️ Functional Overview

1. Selects route based on asset whitelist and liquidity.
2. Applies rate limits and SafetyAutomata guards.
3. Calls PSM.swap() or Vault.ingress() depending on direction.

---

## 🔗 Repository Reference

[View Full Spec on GitHub →](https://github.com/NeaBouli/1kUSD/blob/main/docs/converter/AUTOCONVERTER_ROUTER.md)

Back to [Home](../INDEX.md)
