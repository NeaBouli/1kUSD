
Security Checklist — Pre-Deploy (v1)

Scope

Final checks before deploying/upgrading 1kUSD contracts.

Code & Build

 Tags frozen (git tag -a), reproducible build recorded

 Compiler settings pinned (Solc version, optimizations)

 No unchecked inline assembly; CEI pattern verified

 Ownerless or DAO/Timelock ownership configured

Reviews & Analysis

 Static analysis (Slither/Mythril) reports triaged (no Critical/High)

 Invariant fuzz runs (≥100k steps) pass; seeds archived

 Gas profiles reviewed for hot paths

 External audits signed off (links + commit hash)

Parameters & Safety

 SafetyAutomata caps/rate-limits configured (doc link)

 Guardian sunset timestamp set and verified

 Oracle sources healthy; maxAge/maxDeviation configured

 Treasury address validated against cold wallet checklist

Integration

 PSM↔Vault permissions (MINTER/BURNER/GOV_SPEND) correct

 Indexer PoR pipeline dry-run OK

 SDKs decode latest ABIs and events

Runbooks & Rollback

 Incident & rollback plan attached

 Timelock delays and fast-track documented

 Emergency comms channels prepared

Artifacts to attach

build/ manifests, ABI locks, audit PDFs, CI reports JSON, seeds list
