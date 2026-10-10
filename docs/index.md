---
title: 1kUSD — Stablecoin research for Kaspa
description: Open research program for a fully collateralized, USD-targeting stablecoin. Kaspa is the primary target; the Solidity code is an executable reference. Not a live stablecoin.
hide:
  - navigation
  - toc
---

<div class="kusd-home">
  <section class="kusd-hero" aria-labelledby="kusd-hero-title">
    <div class="kusd-hero-grid" aria-hidden="true"></div>
    <div class="kusd-hero-copy">
      <p class="kusd-status-pill"><span aria-hidden="true"></span> Research project · status as of 2026-10-10</p>
      <p class="kusd-eyebrow">Open stablecoin research</p>
      <h1 id="kusd-hero-title">Stable value,<br><strong>designed for Kaspa.</strong></h1>
      <p class="kusd-hero-lead">
        1kUSD is an open research program for a fully collateralized,
        USD-targeting stablecoin with two-way mint and redemption through a Peg
        Stability Module. Kaspa is the primary target. The Solidity code is an
        executable reference, not a product.
      </p>
      <div class="kusd-actions">
        <a class="kusd-button kusd-button-primary" href="#status-title">Read the current status</a>
        <a class="kusd-button kusd-button-quiet" href="how-it-works/">How the mechanism works</a>
        <a class="kusd-button kusd-button-quiet" href="https://github.com/NeaBouli/1kUSD">Source on GitHub</a>
      </div>
    </div>
    <figure class="kusd-coin-stage">
      <div class="kusd-coin-halo" aria-hidden="true"></div>
      <img src="assets/1kusd-logo.jpg" alt="1kUSD coin mark" width="330" height="330">
      <figcaption>
        <span>Design target — not a live peg</span>
        <strong>1 1kUSD ≈ 1 USD</strong>
      </figcaption>
    </figure>
    <dl class="kusd-hero-facts" aria-label="Project facts with their source">
      <div><dt>Kaspa</dt><dd>Primary target · ADR-041, 2026-08-05</dd></div>
      <div><dt>EVM</dt><dd>Executable reference · no production commitment</dd></div>
      <div><dt>Testnet-10</dt><dd>PoC design accepted · execution not approved</dd></div>
      <div><dt>0</dt><dd>Deployments, live reserves or completed external audits</dd></div>
    </dl>
  </section>

  <aside class="kusd-truth-banner" aria-label="Important project status">
    <strong>Research system — not a live stablecoin.</strong>
    <span>There is no mainnet deployment, no live reserve, no completed external audit and no guaranteed peg. Do not use the prototype with real funds.</span>
    <a href="security/">Security &amp; limits →</a>
  </aside>

  <section class="kusd-section" aria-labelledby="status-title">
    <header class="kusd-section-head kusd-head-wide">
      <div>
        <p class="kusd-eyebrow">Status ledger · 2026-10-10</p>
        <h2 id="status-title">Where the project<br>stands today.</h2>
      </div>
      <p>Each line names its state and its evidence. A decision on paper is not code. Merged code is not deployed. Nothing on this page is deployed or live.</p>
    </header>
    <ol class="kusd-ledger">
      <li>
        <h3>Product boundary</h3>
        <span class="kusd-chip is-done">Accepted</span>
        <p>Kaspa is the primary target and the EVM code stays a reference. <a href="https://github.com/NeaBouli/1kUSD/blob/main/docs-internal/adr/ADR-041-kaspa-primary-product-track.md">ADR-041</a>, 2026-08-05.</p>
      </li>
      <li>
        <h3>Kaspa execution architecture</h3>
        <span class="kusd-chip is-done">Accepted</span>
        <p>A singleton control/reserve covenant family for the first proof of concept. <a href="https://github.com/NeaBouli/1kUSD/blob/main/docs-internal/adr/ADR-042-kaspa-toccata-execution-architecture.md">ADR-042</a>, accepted 2026-08-16.</p>
      </li>
      <li>
        <h3>Governance architecture</h3>
        <span class="kusd-chip is-done">Accepted · design only</span>
        <p>Bounded, timelocked governance and progressive privilege removal. No implementation is authorized. <a href="https://github.com/NeaBouli/1kUSD/blob/main/docs-internal/adr/ADR-043-autonomous-community-control.md">ADR-043</a>, 2026-08-16.</p>
      </li>
      <li>
        <h3>ADR-042 revalidation</h3>
        <span class="kusd-chip is-review">In review</span>
        <p>Checked against SilverScript v1 and Kaspa node v2.1.0. Prepared 2026-10-10. Independent review and gate G3 are still open. <a href="https://github.com/NeaBouli/1kUSD/issues/131">Issue #131</a>.</p>
      </li>
      <li>
        <h3>Testnet-10 proof of concept</h3>
        <span class="kusd-chip is-neutral">Not approved</span>
        <p>Needs G3 plus a separate execution ticket and owner approval. Nothing has run on any network.</p>
      </li>
      <li>
        <h3>EVM reference tests</h3>
        <span class="kusd-chip is-neutral">Historical result</span>
        <p>229 passed, 0 failed, of which 8 are placeholders. Recorded at <a href="https://github.com/NeaBouli/1kUSD/pull/124">#124</a> on 2026-08-16. This is not a live counter.</p>
      </li>
      <li>
        <h3>Production</h3>
        <span class="kusd-chip is-blocked">No-go</span>
        <p>No deployment, reserves, production oracle, working timelock or external audit. See <a href="security/">Security &amp; limits</a>.</p>
      </li>
    </ol>
  </section>

  <section class="kusd-band" aria-labelledby="mechanism-title">
    <div class="kusd-section">
      <header class="kusd-section-head kusd-head-wide">
        <div>
          <p class="kusd-eyebrow">Mechanism vs implementation</p>
          <h2 id="mechanism-title">What is intended.<br>What exists.</h2>
        </div>
        <p>1kUSD avoids user debt positions and liquidation auctions. Supply should be created and destroyed only through collateral-backed conversion. The steps below are the design. The second list shows how much of that design the EVM reference implements today.</p>
      </header>
      <div class="kusd-split">
        <div>
          <p class="kusd-card-label">Intended design</p>
          <ol class="kusd-flow">
            <li><span>01</span><h3>Deposit</h3><p>A user supplies approved collateral to the protocol reserve.</p></li>
            <li><span>02</span><h3>Validate</h3><p>Asset, oracle, limits, fees, deadline, pause state and received value are checked.</p></li>
            <li><span>03</span><h3>Issue</h3><p>The PSM creates net 1kUSD against reconciled collateral value.</p></li>
            <li><span>04</span><h3>Redeem</h3><p>Returned 1kUSD is burned and the matching net collateral is released.</p></li>
          </ol>
        </div>
        <div>
          <p class="kusd-card-label">EVM reference today</p>
          <ul class="kusd-impl">
            <li><span class="kusd-chip is-done">Prototype</span><p>Token, PSM, collateral vault and limits — implemented and tested, hardening still required</p></li>
            <li><span class="kusd-chip is-done">Merged</span><p>Safety sunset precedence and Guardian lifecycle fixes (#120, #124)</p></li>
            <li><span class="kusd-chip is-blocked">Mock</span><p>Oracle prices are admin-set; no production feed system exists</p></li>
            <li><span class="kusd-chip is-blocked">Stub</span><p>DAO timelock execution is not implemented</p></li>
            <li><span class="kusd-chip is-review">Incomplete</span><p>Fee routing and the deployment role handoff are not finished</p></li>
          </ul>
        </div>
      </div>
      <div class="kusd-inline-link"><a href="how-it-works/">Full mint and redemption flow →</a></div>
    </div>
  </section>

  <section class="kusd-section" aria-labelledby="tracks-title">
    <header class="kusd-section-head kusd-head-wide">
      <div>
        <p class="kusd-eyebrow">Two tracks, one design</p>
        <h2 id="tracks-title">Kaspa-native target.<br>EVM reference.</h2>
      </div>
      <p>Kaspa uses UTXOs and covenants, not EVM accounts. The Solidity contracts will not be ported line by line. They stay a runnable model of the economics while the Kaspa design is specified and checked.</p>
    </header>
    <div class="kusd-tracks">
      <article class="kusd-track is-target" aria-labelledby="track-kaspa">
        <p class="kusd-card-label">Primary target · design stage</p>
        <h3 id="track-kaspa">Kaspa</h3>
        <ul>
          <li>Covenant-native state transitions with validated successor outputs.</li>
          <li>First proof of concept: one singleton control/reserve covenant family on Testnet-10, with synthetic zero-value collateral and a hard cap. The design is accepted; execution is not approved.</li>
          <li>Candidate SilverScript compiler and node versions are recorded as <strong>non-adopted</strong>. Compatibility and runtime behaviour are <strong>not verified</strong>.</li>
          <li>A KCC20-shaped interface, vProgs and Zelcore tooling are <strong>not adopted</strong>. Each needs evidence and an owner decision.</li>
        </ul>
        <p class="kusd-track-note">This site makes no claim about Kaspa network activation or Testnet-10 liveness.</p>
      </article>
      <article class="kusd-track" aria-labelledby="track-evm">
        <p class="kusd-card-label">Executable reference · no production commitment</p>
        <h3 id="track-evm">EVM / Solidity</h3>
        <ul>
          <li>Solidity 0.8.30, built and tested with Foundry.</li>
          <li>Runs the PSM, vault, limits and pause lifecycle in tests to check the economic model.</li>
          <li>229 passed / 0 failed with 8 placeholders (2026-08-16). Coverage was 78.92% of lines and 57.63% of branches (2026-08-05).</li>
          <li>No EVM mainnet plan. A passing suite is evidence for the reference, not certification.</li>
        </ul>
        <p class="kusd-track-note"><a href="what-is-1kusd/">Read about the product boundary →</a></p>
      </article>
    </div>
  </section>

  <section class="kusd-band" aria-labelledby="progress-title">
    <div class="kusd-section">
      <header class="kusd-section-head kusd-head-wide">
        <div>
          <p class="kusd-eyebrow">Dated progress</p>
          <h2 id="progress-title">What changed,<br>and when.</h2>
        </div>
        <p>Dates are evidence dates from the public record. "Merged" means on the main branch. None of these steps deployed anything.</p>
      </header>
      <ol class="kusd-timeline">
        <li><time datetime="2026-08-05">2026-08-05</time><div><h3>Kaspa-primary scope accepted</h3><p>ADR-041; repository review recorded. <a href="https://github.com/NeaBouli/1kUSD/issues/101">#101</a></p></div></li>
        <li><time datetime="2026-08-13">2026-08-13</time><div><h3>Safety sunset role precedence corrected</h3><p>Merged. <a href="https://github.com/NeaBouli/1kUSD/pull/120">#120</a></p></div></li>
        <li><time datetime="2026-08-16">2026-08-16</time><div><h3>Kaspa execution architecture accepted</h3><p>ADR-042, singleton control/reserve covenant family. <a href="https://github.com/NeaBouli/1kUSD/issues/112">#112</a></p></div></li>
        <li><time datetime="2026-08-16">2026-08-16</time><div><h3>Guardian lifecycle repaired</h3><p>Merged; 229 passed, 8 placeholders. <a href="https://github.com/NeaBouli/1kUSD/pull/124">#124</a></p></div></li>
        <li><time datetime="2026-09-01">2026-09-01</time><div><h3>Governance architecture published</h3><p>ADR-043 (accepted 2026-08-16), merged as design only. <a href="https://github.com/NeaBouli/1kUSD/pull/128">#128</a></p></div></li>
        <li><time datetime="2026-10-10">2026-10-10</time><div><h3>ADR-042 revalidation prepared</h3><p>Against SilverScript v1 and node v2.1.0; in review, G3 open. <a href="https://github.com/NeaBouli/1kUSD/issues/131">#131</a></p></div></li>
      </ol>
    </div>
  </section>

  <section class="kusd-section" aria-labelledby="roadmap-title">
    <header class="kusd-section-head kusd-head-wide">
      <div>
        <p class="kusd-eyebrow">Readiness-gated next steps</p>
        <h2 id="roadmap-title">Evidence before launch.<br>No dates.</h2>
      </div>
      <p>There is no mainnet date. Each step starts only after the previous gates pass and the owner explicitly approves it. This order is a plan, not an approval.</p>
    </header>
    <ol class="kusd-roadmap">
      <li><span>01</span><div><p>Kaspa evidence gate (G3)</p><strong>Independent review of the ADR-042 revalidation · #131</strong></div><small class="kusd-chip is-review">In review</small></li>
      <li><span>02</span><div><p>Release hygiene</p><strong>License decision, reproducible freeze, dependencies · #104</strong></div><small class="kusd-chip is-neutral">Owner decision</small></li>
      <li><span>03</span><div><p>Quality gates</p><strong>Static-analysis triage, placeholder replacement · #105</strong></div><small class="kusd-chip is-neutral">Proposed</small></li>
      <li><span>04</span><div><p>Offline compile proof</p><strong>Minimal singleton transition, no value, no network</strong></div><small class="kusd-chip is-neutral">Not authorized</small></li>
      <li><span>05</span><div><p>Testnet-10 proof of concept</p><strong>Value-capped, synthetic collateral, singleton design</strong></div><small class="kusd-chip is-neutral">Approval required</small></li>
      <li><span>06</span><div><p>Protocol hardening</p><strong>Oracle, governance, fees, collateral · #106–#109</strong></div><small class="kusd-chip is-neutral">Owner decisions</small></li>
      <li><span>07</span><div><p>Operations &amp; assurance</p><strong>Deployment, monitoring, external audit, bounty · #110 #111 #114</strong></div><small class="kusd-chip is-blocked">Blocked</small></li>
      <li><span>08</span><div><p>Production readiness</p><strong>Legal, reserve, redemption, incident response</strong></div><small class="kusd-chip is-blocked">Blocked</small></li>
    </ol>
    <div class="kusd-inline-link"><a href="roadmap/">Open the complete roadmap →</a></div>
  </section>

  <section class="kusd-cta" aria-labelledby="resources-title">
    <div>
      <p class="kusd-eyebrow">Open research</p>
      <h2 id="resources-title">Inspect the design.<br>Challenge the assumptions.</h2>
      <p>The code, the known limits, the architecture decisions and the work queue are public. Report security issues privately. Do not file them as issues.</p>
    </div>
    <ul class="kusd-resource-grid">
      <li><a href="https://github.com/NeaBouli/1kUSD/security/advisories/new"><span>01</span><strong>Report a vulnerability</strong><small>Private GitHub advisory</small></a></li>
      <li><a href="security/"><span>02</span><strong>Security &amp; limits</strong><small>Dated evidence and open blockers</small></a></li>
      <li><a href="https://github.com/NeaBouli/1kUSD/blob/main/CONTRIBUTING.md"><span>03</span><strong>Contribute</strong><small>Ticket, threat-model and review rules</small></a></li>
      <li><a href="https://github.com/NeaBouli/1kUSD/issues"><span>04</span><strong>Issues &amp; work queue</strong><small>The execution record</small></a></li>
      <li><a href="https://github.com/NeaBouli/1kUSD/tree/main/docs-internal/adr"><span>05</span><strong>Architecture decisions</strong><small>ADR-041, ADR-042, ADR-043</small></a></li>
      <li><a href="whitepaper/WHITEPAPER_1kUSD_EN/"><span>06</span><strong>Whitepaper</strong><small>Concept and specification</small></a></li>
    </ul>
  </section>
</div>
