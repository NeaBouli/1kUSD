# Security Policy

## Reporting a Vulnerability
- Please use **GitHub Security Advisories** (Private vulnerability reporting) for sensitive issues.
- Do **not** open public issues for vulnerabilities or share exploit details publicly.
- Provide: affected component, impact, minimal PoC, environment details.

## Scope & principles
- On-chain contracts: ownerless/Timelock, pause-only safety automata, no custodied withdrawals.
- Oracles/PSM/Vault: economic and technical invariants must hold under reorgs and stale/deviation conditions.
- Bridges: message/proof verification with replay protection and emergency pause.

## Disclosure
- We aim to acknowledge within 72h and provide a remediation plan/patch timeline.
- Credit will be given unless anonymity is requested.

## Secrets
- Never commit private keys, API tokens, or credentials.
- Use local environment variables and `.env.example` patterns where necessary.

Thank you for helping keep 1kUSD safe.
