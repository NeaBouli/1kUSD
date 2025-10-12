# Secrets Handling — Specification
**Scope:** Keys, RPC tokens, CI secrets, incident hygiene.  
**Status:** Spec (no code). **Language:** EN.

## Keys
- HW wallets for deploy; CI never holds private keys
- Multisig: ≥3/5; rotation plan documented

## CI Secrets
- Store only RPC URLs/tokens in GitHub Actions
- Use per-env secret names; short TTL; least privilege

## Local .env
- Provide templates at ops/config/.env.example
- Do not commit real secrets

## Incident Hygiene
- Revoke leaked RPC/API tokens immediately
- If key compromise suspected: rotate multisig signer; re-seat Timelock executor
