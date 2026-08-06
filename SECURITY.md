# Security Policy

## Current status

1kUSD is a research/testnet prototype under remediation. It is not mainnet-ready,
has no production deployment documented by this repository, and has not completed
an independent external audit. Do not use it with real funds.

## Reporting a vulnerability

Use [GitHub Private Vulnerability Reporting](https://github.com/NeaBouli/1kUSD/security/advisories/new).

Do not open a public issue containing exploit details, private keys, wallet data,
RPC credentials, production addresses, or sensitive reproduction material.

Include:

- affected commit and component;
- impact and assumptions;
- minimal private reproduction;
- environment/tool versions;
- suggested mitigation if known.

We aim to acknowledge complete reports within 72 hours. This target is not a
guarantee of a remediation or disclosure date.

## In-scope security areas

- token mint/burn and supply conservation;
- PSM pricing, rounding, fees, limits, and atomicity;
- vault solvency and collateral accounting;
- oracle freshness, deviation, quorum, and fallback behavior;
- pause/guardian/timelock/access-control semantics;
- deployment role handoff and configuration;
- monitoring, release integrity, and dependency security.

## Known non-production components

- admin-set mock oracle;
- non-functional DAO timelock stub;
- incomplete fee-routing path;
- demo/testnet deployment with mock collateral;
- placeholder tests and incomplete branch coverage;
- unresolved Guardian/Safety role findings.

The public [known limitations](audit/KNOWN_LIMITATIONS.md) and
[2026 audit follow-up](docs-internal/reports/AUDIT_REVIEW_2026-08-05.md) are part
of the security context, not evidence of certification.

## Disclosure and safe harbor

Coordinate disclosure privately. Do not test against systems or funds you do not
own or have explicit permission to test. Avoid privacy violations, service
disruption, social engineering, and asset movement.
