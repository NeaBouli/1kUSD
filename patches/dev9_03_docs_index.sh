#!/bin/bash
set -e

echo "== DEV-9 03: Create docs/index.md landing page =="

# 1) Ensure docs directory exists (it should, but be defensive)
mkdir -p docs

# 2) Write minimal landing page for MkDocs
cat <<'EOD' > docs/index.md
# 1kUSD Documentation

Welcome to the 1kUSD documentation.

This site describes the architecture, economic layer, security model,
risk framework, governance processes and infrastructure/CI setup of
the 1kUSD stablecoin project.

## High-level structure

The documentation is roughly organized into:

- Architecture and design documents
- Economic layer and protocol behavior (READ-ONLY for DEV-9)
- Security and risk documentation
- Governance and strategy reports
- Infrastructure, CI, and tooling documentation
- Project status and release reports

DEV-9 AAAAAAAA is responsible for infrastructure-related aspects only
(CI, Docker, Docs build, Pages hardening, monitoring preparation) and
must not modify the Solidity contracts or economic layer logic.

For more detailed dev-specific information, see the DEV-9 documents in
`docs/dev/` (especially DEV9_Onboarding.md and DEV9_InfrastructurePlan.md).
EOD

# 3) Log message
LOG_FILE="logs/project.log"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-9 03] ${timestamp} Added docs/index.md landing page" >> "$LOG_FILE"

echo "== DEV-9 03 done =="
