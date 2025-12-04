# Integrations & Developer Guides

This section is maintained by **DEV-10** and is intended for external
integrators building on top of the 1kUSD Economic Core.

If you are developing:

- front-ends or dApps that swap collateral <-> 1kUSD,
- indexers or monitoring systems,
- operational tooling around buybacks, oracles or safety mechanisms,

this is your primary starting point.

---

## 1. How this section is organised

The integration docs are split into a few core guides, each focusing on a
specific part of the Economic Core:

- **PSM Integration Guide**
  - How to interact with the Peg Stability Module (PSM) from wallets,
    dApps or backend services.
  - Covers:
    - swap flows (collateral <-> 1kUSD),
    - fees, spreads and limits (conceptual level),
    - basic failure handling and operator considerations.
  - See: `psm_integration_guide.md`

- **Oracle Aggregator Integration Guide**
  - How to correctly consume prices and health information from the
    Oracle Aggregator.
  - Covers:
    - reading prices and health flags,
    - handling staleness and diff violations,
    - failure scenarios and monitoring patterns.
  - See: `oracle_aggregator_guide.md`

- **Guardian & Safety Events Guide**
  - How to observe and react to Guardian / Safety related events from an
    operational or monitoring perspective.
  - Covers:
    - key event types and their meaning,
    - pause / unpause and emergency flows (observer view),
    - alerting and incident timelines.
  - See: `guardian_and_safety_events.md`

- **BuybackVault Observer Guide**
  - How to watch buyback-related activity without participating in
    governance.
  - Covers:
    - funding and buyback events,
    - strategy-level views,
    - KPIs and monitoring ideas.
  - See: `buybackvault_observer_guide.md`

All guides are **read-only** from a protocol perspective: they explain how
to *use* and *observe* existing contracts – they do not change protocol
behaviour.

---

## 2. Relationship to other docs

For deeper background, you may also want to consult:

- **Architecture docs**
  - `docs/architecture/` – detailed design of the Economic Layer,
    BuybackVault StrategyEnforcement Phase 1, Oracle and Guardian
    components.

- **Security & Risk docs**
  - `docs/security/` and `docs/risk/` – audit plans, PoR specs, collateral
    risk profile, depeg runbooks and more.

- **Reports & Status**
  - `docs/reports/REPORTS_INDEX.md` – overview of major reports and status
    documents (Economic Layer v0.51.0, governance, infra & integrations).

- **DEV-9 / DEV-10 role docs**
  - `docs/dev/DEV9_Status_Infra_r2.md` – infra/CI snapshot.
  - `docs/dev/DEV10_Status_Integrations_r1.md` – integrations/DevEx
    snapshot.
  - `docs/dev/DEV9_Backlog.md` and `docs/dev/DEV10_Backlog.md` – future
    work items for infra and integrations.

---

## 3. How to work with these guides

When integrating with 1kUSD:

1. **Identify your scope**
   - swaps via PSM,
   - price consumption via Oracle,
   - safety monitoring,
   - buyback observability.

2. **Start with the relevant guide(s) above**
   - read the conceptual explanations,
   - note the recommended patterns and checklists.

3. **Cross-check with architecture and security docs**
   - ensure your assumptions match the current Economic Layer version and
     risk posture.

4. **Add your own internal runbooks**
   - document how your system uses 1kUSD,
   - record expected behaviours and failure modes,
   - keep your own procedures in sync with protocol updates.

As the protocol and ecosystem evolve, this index and the guides it points
to may be extended with:

- concrete function and event signatures,
- code snippets for common client stacks,
- example dashboards, queries and alerting rules.
