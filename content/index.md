---
title: Reuben
head_title: "Reuben: the tastiest static site generator"
description: "The tastiest static site generator: Markdown with Rhai scripting, accessibility checks, and every build error in one run."
layout: home
---

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "SoftwareApplication",
  "name": "Reuben",
  "description": "A static site generator: Markdown with Rhai scripting, every build error in one run, accessibility checks on every build, and no JavaScript unless you add it.",
  "url": "https://reuben-ssg.dev/",
  "applicationCategory": "DeveloperApplication",
  "operatingSystem": "macOS, Linux, Windows",
  "license": "https://github.com/reuben-ssg/reuben/blob/main/LICENSE-MIT",
  "codeRepository": "https://github.com/reuben-ssg/reuben",
  "offers": { "@type": "Offer", "price": "0", "priceCurrency": "USD" }
}
</script>

<div class="hero">
<div class="hero-art">
{{ logo() }}
{{ sandwich() }}
</div>

# The tastiest static site generator.

<div class="hero-row">
<div class="hero-pitch">

Markdown with Rhai scripting stacked inside, every build error served in one run, and not a crumb of JavaScript on the side.

<div class="btn-row">
<a class="btn" href="/quickstart/">Quickstart</a>
<a class="btn btn-alt" href="/why/">Why Reuben?</a>
</div>
</div>
<div class="hero-order">
<p class="order-label">Order your Reuben today:</p>
<p class="install" tabindex="0" role="region" aria-label="Install with Cargo"><code>cargo install reuben</code></p>
<p class="install" tabindex="0" role="region" aria-label="Install with npm"><code>npm install --save-dev @reuben-ssg/reuben</code></p>
</div>
</div>
</div>

<h2 id="features">Why Reuben?</h2>

<ul class="cards">
<li class="card"><h3>Rhai in your Markdown</h3><p>Script right where you write.</p></li>
<li class="card"><h3>Every error, one run</h3><p>No fix-one, rebuild, repeat.</p></li>
<li class="card"><h3>Accessible by default</h3><p>Checks baked into every build.</p></li>
<li class="card"><h3>Zero JavaScript</h3><p>Unless you add it yourself.</p></li>
</ul>

<p class="made-by">Made with love by <a href="https://github.com/nickvigilante">@nickvigilante</a>.</p>
