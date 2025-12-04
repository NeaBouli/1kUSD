# DEV-9 Onboarding / Handover from DEV-7

## Purpose
This document captures the complete onboarding for DEV-9 AAAAAAAA and the handover from DEV-7 AAAAAAAA.

## Working Environment
- Local path: ~/Desktop/1kUSD
- Shell: zsh
- Python env: .venv
- Repo: github.com/NeaBouli/1kUSD
- Branch strategy: 
  - main = protected
  - dev9/docker-infra = DEV-9 working branch

## Patch Workflow
- One small patch per task
- Patches stored under patches/dev9_XX_*.sh
- Execution: bash patches/<patch>
- Commit & push by Owner
- Each patch writes one log entry into logs/project.log (UTC)

## Scope of DEV-9
Allowed:
- CI (GitHub Actions)
- Docker / Multi-Arch infrastructure
- MkDocs / Pages / Navigation / Link Cleanup
- Release-Status / Docs-Build
- Monitoring Preparation

Forbidden:
- contracts/
- Solidity logic
- Economic Layer mechanics

## Status Handover from DEV-7
- CI base (docs-build + release-status) complete
- Strategy Enforcement Phase 1 implemented and documented
- Docker not implemented
- Pages manual only
- Monitoring not implemented
- Many mkdocs warnings remain

