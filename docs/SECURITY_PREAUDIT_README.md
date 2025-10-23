
Security Pre-Audit Pack (v1)

Purpose: Provide auditors with a consistent, minimal, and reproducible bundle.

Contents:

Threat Model (docs/THREAT_MODEL.md)

Static-Analysis Baselines (security/baselines/)

Build/Run instructions (this file)

Submission bundle script (scripts/make-preaudit-bundle.sh)

Version manifest (security/submission/MANIFEST.json)

How to use:

Ensure repo compiles (forge or hardhat).

Regenerate baselines (optional): scripts/gen-static-baselines.sh

Create submission bundle: scripts/make-preaudit-bundle.sh v0.1.0

Attach resulting ZIP from security/submission/
