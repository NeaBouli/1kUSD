---
title: 1kUSD — Stable value, built for Kaspa
description: A Kaspa-primary research program for a fully collateralized, USD-targeting stablecoin.
hide:
  - navigation
  - toc
---

<div class="kusd-home">
  <section class="kusd-hero" aria-labelledby="kusd-hero-title">
    <div class="kusd-hero-grid" aria-hidden="true"></div>
    <div class="kusd-hero-copy">
      <div class="kusd-status-pill"><span></span> Kaspa-primary · research &amp; testnet</div>
      <p class="kusd-eyebrow">Open stablecoin protocol</p>
      <h1 id="kusd-hero-title">Stable value,<br><strong>built for Kaspa.</strong></h1>
      <p class="kusd-hero-lead">
        1kUSD is an open-source program for a fully collateralized,
        USD-targeting stablecoin with direct mint and redemption through a Peg
        Stability Module.
      </p>
      <div class="kusd-actions">
        <a class="kusd-button kusd-button-primary" href="how-it-works/">Explore the mechanism</a>
        <a class="kusd-button kusd-button-quiet" href="https://github.com/NeaBouli/1kUSD">View the source</a>
      </div>
    </div>
    <div class="kusd-coin-stage" aria-label="1kUSD project mark">
      <div class="kusd-coin-halo"></div>
      <img src="assets/1kusd-logo.jpg" alt="1kUSD coin mark">
      <p>Target unit</p>
      <strong>1 1kUSD ≈ 1 USD</strong>
    </div>
    <div class="kusd-hero-facts" aria-label="Verified project facts">
      <div><strong>229</strong><span>Foundry tests passing</span></div>
      <div><strong>0</strong><span>production deployments</span></div>
      <div><strong>Kaspa</strong><span>approved primary track</span></div>
      <div><strong>EVM</strong><span>executable reference</span></div>
    </div>
  </section>

  <aside class="kusd-truth-banner" aria-label="Important project status">
    <strong>Research system — not a live stablecoin.</strong>
    <span>No mainnet deployment, live reserves, completed external audit, or guaranteed peg exists today. Do not use the prototype with real funds.</span>
    <a href="security/">Read the verified limits →</a>
  </aside>

  <section class="kusd-section kusd-intro" aria-labelledby="mechanism-title">
    <header class="kusd-section-head">
      <p class="kusd-eyebrow">The intended mechanism</p>
      <h2 id="mechanism-title">Simple conversion.<br>Strict accounting.</h2>
      <p>1kUSD avoids user debt positions and liquidation auctions. The target design creates and destroys supply only through collateral-backed conversion.</p>
    </header>
    <div class="kusd-flow" role="list">
      <article role="listitem">
        <span>01</span>
        <h3>Deposit</h3>
        <p>A user supplies approved collateral to the protocol reserve.</p>
      </article>
      <article role="listitem">
        <span>02</span>
        <h3>Validate</h3>
        <p>Asset, oracle, limits, fees, deadline, pause state, and received value are checked.</p>
      </article>
      <article role="listitem">
        <span>03</span>
        <h3>Issue</h3>
        <p>The PSM creates net 1kUSD against reconciled collateral value.</p>
      </article>
      <article role="listitem">
        <span>04</span>
        <h3>Redeem</h3>
        <p>Returned 1kUSD is burned and the corresponding net collateral is released.</p>
      </article>
    </div>
    <div class="kusd-inline-link"><a href="how-it-works/">See the complete mint and redemption flow →</a></div>
  </section>

  <section class="kusd-band" aria-labelledby="architecture-title">
    <div class="kusd-section kusd-architecture">
      <header class="kusd-section-head">
        <p class="kusd-eyebrow">Kaspa-native architecture</p>
        <h2 id="architecture-title">Designed for UTXOs.<br>Not copied from Ethereum.</h2>
        <p>The accepted product direction targets Kaspa Toccata. ADR-042 selects a singleton control/reserve L1 covenant family for the value-capped Testnet-10 proof; production sharding remains deferred.</p>
      </header>
      <div class="kusd-layers">
        <article>
          <span class="kusd-layer-index">L1</span>
          <p class="kusd-card-label">Target settlement</p>
          <h3>Kaspa Toccata</h3>
          <ul>
            <li>Covenant-native state transitions</li>
            <li>Native asset issuance and redemption</li>
            <li>Successor-output validation</li>
            <li>Reorg-aware state discovery</li>
          </ul>
        </article>
        <article>
          <span class="kusd-layer-index">P</span>
          <p class="kusd-card-label">Protocol controls</p>
          <h3>PSM &amp; reserve</h3>
          <ul>
            <li>Collateral and liability reconciliation</li>
            <li>Oracle freshness and deviation policy</li>
            <li>Bounded issuance and redemption</li>
            <li>Guardian and delayed governance</li>
          </ul>
        </article>
        <article>
          <span class="kusd-layer-index">O</span>
          <p class="kusd-card-label">Operational assurance</p>
          <h3>Evidence &amp; monitoring</h3>
          <ul>
            <li>Reserve and supply observability</li>
            <li>Reproducible deployments</li>
            <li>Incident response and recovery</li>
            <li>Independent security review</li>
          </ul>
        </article>
      </div>
      <div class="kusd-reference-note">
        <span>EVM reference</span>
        <p>The existing Solidity system remains a testable economic specification. It is not the primary production target and will not be ported line by line.</p>
        <a href="what-is-1kusd/">Understand the product boundary →</a>
      </div>
    </div>
  </section>

  <section class="kusd-section" aria-labelledby="principles-title">
    <header class="kusd-section-head kusd-head-wide">
      <div>
        <p class="kusd-eyebrow">Protocol principles</p>
        <h2 id="principles-title">The peg is a system,<br>not a promise.</h2>
      </div>
      <p>Stable value depends on redeemable reserves, correct pricing, reliable conversion, bounded authority, liquid markets, and observable operation. Every layer must remain independently verifiable.</p>
    </header>
    <div class="kusd-principles">
      <article><span>01</span><h3>Fully collateralized</h3><p>Every redeemable unit must be backed by approved collateral under an explicit reserve and haircut policy.</p></article>
      <article><span>02</span><h3>Two-way conversion</h3><p>Credible mint and redemption provide the primary economic pressure toward the USD target.</p></article>
      <article><span>03</span><h3>Bounded operation</h3><p>Limits, deadlines, fail-closed configuration, and narrow emergency authority contain failures.</p></article>
      <article><span>04</span><h3>Transparent control</h3><p>Timelocked multisig governance, visible reserves, monitoring, and incident evidence replace hidden trust.</p></article>
    </div>
  </section>

  <section class="kusd-band kusd-status-section" aria-labelledby="status-title">
    <div class="kusd-section">
      <header class="kusd-section-head kusd-head-wide">
        <div>
          <p class="kusd-eyebrow">Verified project truth</p>
          <h2 id="status-title">What works.<br>What does not.</h2>
        </div>
        <p>Status is evidence-based and deliberately conservative. Passing tests describe the reference implementation; they do not prove production readiness.</p>
      </header>
      <div class="kusd-status-grid">
        <article class="kusd-status-card kusd-status-positive">
          <p class="kusd-card-label">Verified now</p>
          <ul>
            <li><strong>Build:</strong> Solidity reference compiles</li>
            <li><strong>Tests:</strong> 229 passing, 0 failing</li>
            <li><strong>Mechanism:</strong> PSM, vault, limits, module pause lifecycle</li>
            <li><strong>Direction:</strong> Kaspa-primary scope accepted</li>
            <li><strong>Program:</strong> tracked master plan and issue queue</li>
          </ul>
        </article>
        <article class="kusd-status-card kusd-status-blocked">
          <p class="kusd-card-label">Still blocking release</p>
          <ul>
            <li><strong>Oracle:</strong> admin-set mock only</li>
            <li><strong>Governance:</strong> timelock execution is a stub</li>
            <li><strong>Safety:</strong> lifecycle fixes merged; deployment role handoff still gated</li>
            <li><strong>Assurance:</strong> 8 placeholder tests; audit incomplete</li>
            <li><strong>Operations:</strong> no live reserves or production deployment</li>
          </ul>
        </article>
      </div>
      <div class="kusd-inline-link"><a href="security/">Review security evidence and open blockers →</a></div>
    </div>
  </section>

  <section class="kusd-section" aria-labelledby="roadmap-title">
    <header class="kusd-section-head kusd-head-wide">
      <div>
        <p class="kusd-eyebrow">Readiness-gated roadmap</p>
        <h2 id="roadmap-title">Evidence before launch.</h2>
      </div>
      <p>There is no mainnet date. Each phase begins only after its decision, security, and verification gates are explicitly approved.</p>
    </header>
    <div class="kusd-roadmap">
      <article class="is-complete"><span>01</span><div><p>Product boundary</p><strong>Kaspa primary · EVM reference</strong></div><small>Accepted</small></article>
      <article class="is-complete"><span>02</span><div><p>Execution architecture</p><strong>Singleton control/reserve covenant family</strong></div><small>Accepted</small></article>
      <article><span>03</span><div><p>Isolated Testnet-10 proof</p><strong>Value-capped vault and issuance</strong></div><small>Approval required</small></article>
      <article class="is-next"><span>04</span><div><p>Protocol hardening</p><strong>Oracle, governance, accounting, safety</strong></div><small>In progress</small></article>
      <article><span>05</span><div><p>Independent assurance</p><strong>Deployment evidence, audit, bounty</strong></div><small>Blocked</small></article>
      <article><span>06</span><div><p>Production readiness</p><strong>Legal, reserve, redemption, operations</strong></div><small>Blocked</small></article>
    </div>
    <div class="kusd-inline-link"><a href="roadmap/">Open the complete roadmap →</a></div>
  </section>

  <section class="kusd-cta" aria-labelledby="resources-title">
    <div>
      <p class="kusd-eyebrow">Open research</p>
      <h2 id="resources-title">Inspect the design.<br>Challenge the assumptions.</h2>
      <p>The code, known limitations, security reporting channel, architecture decisions, and delivery plan are public.</p>
    </div>
    <div class="kusd-resource-grid">
      <a href="whitepaper/WHITEPAPER_1kUSD_EN/"><span>01</span><strong>Read the whitepaper</strong><small>Concept &amp; implementation specification</small></a>
      <a href="https://github.com/NeaBouli/1kUSD"><span>02</span><strong>Review the repository</strong><small>Source, tests, issues &amp; decisions</small></a>
      <a href="community/"><span>03</span><strong>Join the work</strong><small>Contributing and project channels</small></a>
    </div>
  </section>
</div>
