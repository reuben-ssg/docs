// The skip link, the awning and the masthead: brand, "Now serving" ticket and the main navigation.

fn skip_link() {
    raw(`<a class="skip-link" href="#main">Skip to content</a>`)
}

// Lifted from the agreed mockup: Magenta and white canopy stripes shaded toward the top, a seam, then a valance
// with one rounded scallop per stripe.
fn awning() {
    raw(`<svg class="awning" width="100%" height="76" aria-hidden="true" focusable="false">
<defs>
<pattern id="awning-stripes" width="68" height="76" patternUnits="userSpaceOnUse">
<rect x="0" y="0" width="34" height="38" fill="#e0177a"/>
<rect x="34" y="0" width="34" height="38" fill="#ffffff"/>
<path d="M0 38 h34 v14 a17 17 0 0 1 -34 0 z" fill="#e0177a" stroke="#2a1420" stroke-width="2.5" stroke-linejoin="round"/>
<path d="M34 38 h34 v14 a17 17 0 0 1 -34 0 z" fill="#ffffff" stroke="#2a1420" stroke-width="2.5" stroke-linejoin="round"/>
</pattern>
<linearGradient id="awning-slope" x1="0" y1="0" x2="0" y2="1">
<stop offset="0" stop-color="#2a1420" stop-opacity=".30"/>
<stop offset="1" stop-color="#2a1420" stop-opacity="0"/>
</linearGradient>
</defs>
<rect x="0" y="0" width="100%" height="38" fill="url(#awning-stripes)"/>
<rect x="0" y="0" width="100%" height="38" fill="url(#awning-slope)"/>
<rect x="0" y="38" width="100%" height="38" fill="url(#awning-stripes)"/>
<rect x="0" y="0" width="100%" height="6" fill="#2a1420"/>
<line x1="0" y1="38" x2="100%" y2="38" stroke="#2a1420" stroke-width="3"/>
</svg>`)
}

// The version comes from `data/release.toml`; without it the ticket is left out.
fn ticket(data) {
    if !("release" in data) || !("version" in data.release) {
        return ();
    }
    let version = escape(data.release.version.to_string());
    raw(`<p class="ticket">Now serving: <b>v${version}</b></p>`)
}

fn main_nav(page, site, collections) {
    let items = nav_items(site, collections);
    if items.len() == 0 {
        return "";
    }
    let html = `<nav class="main-nav" aria-label="Main"><ul>`;
    for item in items {
        let current = "";
        if item.url == page.url {
            current = ` aria-current="page"`;
        } else if item.section && page.collection == item.slug {
            current = ` aria-current="true"`;
        }
        html += `<li><a href="${escape(item.url)}"${current}>${escape(item.title)}</a></li>`;
    }
    html + `</ul></nav>`
}

// The home page carries the big logo in its hero, so only other pages get the small brand link.
fn header(page, site, data, collections) {
    let brand = "";
    if page.url != "/" {
        brand = `<a class="brand" href="/">${logo_svg("brand").to_string()}</a>`;
    }
    let ticket_html = "";
    let t = ticket(data);
    if type_of(t) != "()" {
        ticket_html = t.to_string();
    }
    raw(`<header class="site-header">
${awning().to_string()}
<div class="masthead">
${brand}${ticket_html}
${main_nav(page, site, collections)}
</div>
</header>`)
}
