# Historical archive

This directory preserves files that are useful for provenance but should not be
mistaken for active source, tests, workflows, or release outputs.

Nothing in this archive is part of the deployable protocol.

| Directory | Contents | Active? |
|---|---|---|
| `generated/` | Previously tracked Foundry `out/` and `cache/` artifacts | No; regenerate locally |
| `backups/` | Historical source, test, README, and MkDocs backups | No |
| `pr-bodies/` | Historical pull-request body drafts | No |
| `logs/` | Historical CI output | No |
| `workflows/` | Disabled or non-production workflow sketches | No |

The root `.gitignore` prevents regenerated Foundry output from being committed
again. Historical patch scripts and project logs remain in their original paths
for now because old runbooks still reference them; their migration is tracked as
a separate, link-checked task.
