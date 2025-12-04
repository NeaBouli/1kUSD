#!/bin/bash
set -e

echo "== DEV-9 02: Create DEV9_InfrastructurePlan.md =="

# 1) Ensure docs/dev exists
mkdir -p docs/dev

# 2) Write infrastructure plan document
cat <<'EOD' > docs/dev/DEV9_InfrastructurePlan.md
# DEV-9 Infrastructure Plan (CI / Docker / Docs / Monitoring)

## Context & Scope

This document describes the working scope and initial priorities for DEV-9 AAAAAAAA
on the 1kUSD project. It complements the DEV9_Onboarding.md file and focuses on
infrastructure and CI-related decisions.

Scope of DEV-9:
- CI (GitHub Actions)
- Docker / Multi-Arch infrastructure
- MkDocs / Pages / Navigation / Link Cleanup
- Release-Status / Docs-Build
- Monitoring Preparation

Out of scope (frozen):
- contracts/
- Solidity logic
- Economic Layer (PSM, Oracle, BuybackVault, Strategy)
- Tokenomics / Parameters

## Initial Priority Order (DEV-9 Proposal)

1. CI Hardening
   - Pin Foundry version(s)
   - Add caching where useful
   - Keep existing workflows functional (no regressions)

2. MkDocs Link & Index Cleanup
   - Reduce mkdocs warnings
   - Provide a proper landing page for the docs

3. Docker / Multi-Arch
   - Start with local Dockerfile(s) and local builds
   - Later integrate Docker builds into CI as non-deploy checks

4. Pages Hardening
   - Keep deploys manual
   - Optionally add a CI preview build (artifact only, no auto gh-deploy)

5. Monitoring Preparation
   - Document which events / metrics should be exposed
   - Describe how off-chain indexers could consume on-chain events

## Docker Strategy (Proposal, pending Architect confirmation)

- Base image: ubuntu:22.04 (or equivalent LTS Ubuntu image)
- Rationale:
  - Good tooling support and compatibility
  - Fewer surprises compared to minimal images (e.g. Alpine)
- Target architectures:
  - Phase 1: linux/amd64
  - Phase 2: add linux/arm64 via buildx / multi-arch, once the Dockerfiles are stable

## Pages & MkDocs Strategy (Proposal)

- GitHub Pages:
  - Remain manual (no automatic deploys from CI)
  - CI may run `mkdocs build` and publish the result as an artifact for preview

- MkDocs Index:
  - Create a proper docs/index.md / landing page for the documentation
  - Keep link cleanup conservative:
    - Prefer adding/redirecting to valid sections over removing links
    - Avoid breaking existing navigation without explicit Architect approval

## Monitoring Preparation (High-Level)

- DEV-9 will not implement backend or indexers in this repo, but:
  - Document expected on-chain events that are useful for monitoring:
    - PSM operations (swaps, limits, fees)
    - Oracle updates / health status
    - Guardian / enforcement actions
  - Describe possible integration points for:
    - Off-chain indexers
    - Alerting systems
    - Dashboards

## Coordination Notes

- All points above are proposals by DEV-9 and subject to Architect confirmation.
- No CI workflow, Dockerfile, or docs navigation will be changed in a breaking
  way without an explicit, isolated patch and clear communication.
EOD

# 3) Log message
LOG_FILE="logs/project.log"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-9 02] ${timestamp} Added DEV9_InfrastructurePlan.md" >> "$LOG_FILE"

echo "== DEV-9 02 done =="
