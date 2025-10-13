# Integrations — Wallets & Payment Processors (Blueprint)
**Scope:** Wallet-kompatibilität, Switch/Detect, Sign-Flows, Fiat On/Off-Ramps (reines Spec).  
**Status:** Spec (no code). **Language:** EN.

## Wallet Support
- EIP-1193 providers (MetaMask, Rabby, Coinbase Wallet)
- WalletConnect v2 deep link (desktop/mobile)
- Chain detection & switch (addChain + switchChain)

## Signing & UX
- Tx simulation (SDK) → sign → broadcast → receipt
- Permit (EIP-2612) optional for allowances
- Hardware wallets: ensure legacy + EIP-1559 paths

## On/Off-Ramp Touchpoints
- Read-only quotes for buy/sell 1kUSD via supported stablecoins
- Non-custodial handoff (no keys, no KYC in app)
- Webhook-free; use partner redirect & query params

## Required Docs for Partners
- Token: symbol "1kUSD", decimals 18, logo assets (SVG/PNG)
- Contracts & chain IDs per stage (ops/config/addresses.*.json)
- Risk & freeze policy: pause affects mint/burn only

## Testing Checklist
- Network mismatch prompts
- Reorg-resilient tx status
- Permit invalid/expired signatures
- Slippage/minOut honored (no hidden fees)
