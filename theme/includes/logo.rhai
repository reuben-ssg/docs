// The wordmark, lifted from the agreed mockup. It is SVG text in the self-hosted Pacifico, inlined so it uses the
// page's fonts and CSS hover animation. `prefix` keeps its ids unique when a page shows it more than once.

fn logo_svg(prefix) {
    let p = escape(prefix);
    raw(`<svg class="logo" viewBox="0 0 600 220" role="img" aria-label="Reuben">
<defs>
<path id="${p}-arc" d="M190 150 Q 360 112 560 140"/>
<g id="${p}-glyphs">
<text x="40" y="168" font-size="168" transform="skewX(-10)">R</text>
<text font-size="112"><textPath href="#${p}-arc">euben</textPath></text>
</g>
<clipPath id="${p}-clip"><use href="#${p}-glyphs"/></clipPath>
</defs>
<g transform="translate(7 8)"><use href="#${p}-glyphs" class="wm-shadow"/></g>
<use href="#${p}-glyphs" class="wm-border"/>
<use href="#${p}-glyphs" class="wm-fill"/>
<g clip-path="url(#${p}-clip)" class="shines">
<rect class="shine" x="78" y="44" width="40" height="15" rx="7.5" transform="rotate(-24 98 52)"/>
<circle class="shine" cx="128" cy="40" r="6"/>
<rect class="shine" x="402" y="62" width="20" height="10" rx="5" transform="rotate(-20 412 67)"/>
<circle class="shine" cx="430" cy="58" r="3.5"/>
</g>
</svg>`)
}

fn logo() {
    logo_svg("logo")
}
