# Freeze Gates & Checklist (v0)
**Status:** Info (no code). **Language:** EN.

## Freeze Types
- **Spec Freeze:** no breaking spec changes; only clarifications.
- **Param Freeze:** parameter set captured for target stage.
- **Ops Freeze:** release branch protected; CI gates enforced.

## Checklist
- [ ] Spec freeze announced in repo `logs/project.log`
- [ ] Risk register reviewed; mitigations mapped; owners assigned
- [ ] CI passing on main; artifacts uploaded
- [ ] CHANGELOG updated with RC section
- [ ] Ops rehearsal done (RELEASE_REHEARSAL)
- [ ] Emergency playbooks validated
- [ ] Partner docs bundle ready (addresses, logos, whitepaper links)

## Unfreeze Conditions
- Critical/High issue discovered
- Governance decision to alter scope
