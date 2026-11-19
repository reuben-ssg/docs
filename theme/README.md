# deli

The theme for the Reuben documentation site.
It lives in this repo for now and is built to be moved out unchanged.

## The boundary rule

Nothing under `theme/` names a docs page or contains docs prose.
The theme reads site values only from `site` (the `[params]` table in `reuben.toml`) and from collections.
If a layout needs a word, a link or an ordering, the site supplies it; the theme never hard-codes it.

Review checks this on every change, so that extraction stays a move and not a rewrite.

## Extraction checklist

Extract when the Tokyo Night theme (`reuben-ssg/theme-nvim`) exists, so there are two themes to compare, and Reuben has decided how themes are distributed (path, git or npm package).

- [ ] Split `theme/` into `reuben-ssg/theme-deli` with its history (`git subtree split` or equivalent).
- [ ] Confirm the boundary rule still holds: no docs page names or docs prose under `theme/`.
- [ ] Keep `LICENSE-MIT`, `LICENSE-APACHE` and each font's OFL file with the theme.
- [ ] Publish it the way Reuben decides.
- [ ] Point the docs site's `theme` at it.
- [ ] Delete `theme/` from the docs repo.

## Using the theme

- `layout: home` gives a page the header and footer with no sidebar; every other page uses `default`.
- A page inside a top-level `content/` folder gets that collection's tree as a sidebar and a breadcrumb.
- A page with three or more `h2`s gets an "on this page" list.
- The layout adds the page title as the `h1` unless the body has its own.
- `[params]` keys the theme reads: `nav_order` (collection or root-level page slugs, in order), `repo_url` and `license` (footer).
- A collection's index page can set `nav_title` to shorten its header link; a root-level page's link is its slug with a capital first letter.
- `data/release.toml` `version` fills the "Now serving" ticket.
- Includes for content: `logo()` and `sandwich()`.
- `logo()` uses the id prefix `logo` and the header brand uses `brand`, so call `logo()` once per page; `logo_svg(prefix)` takes a prefix of your own for more.
- Classes for content: `hero`, `hero-art`, `btn-row`, `btn`, `btn-alt`, `cards`, `card`, `order-label`, `install`, `ticket`.

The logo and favicons draw Pacifico's letters as outline paths, since an SVG used as an image can't load a web font.
The favicon links are `favicon.svg`, a 32 px PNG and a 180 px `apple-touch-icon.png`.

## Fonts

Fonts are self-hosted from `static/fonts/` as Latin-subset WOFF2 files, and each family carries its OFL licence file.
Nunito keeps its full `wght` axis; DM Mono ships as 400 and 500.
`Pacifico-OFL.txt` stays because the logo and favicon paths are derived glyph outlines, but the Pacifico font file itself is not shipped.
No page requests a third-party font or stylesheet.
Theme assets use root-relative paths so previews stay self-contained.

## Licence

Licensed under either of

- Apache License, Version 2.0 ([LICENSE-APACHE](LICENSE-APACHE) or <http://www.apache.org/licenses/LICENSE-2.0>)
- MIT license ([LICENSE-MIT](LICENSE-MIT) or <http://opensource.org/licenses/MIT>)

at your option.
The bundled fonts are under the SIL Open Font License; see the `*-OFL.txt` files in `static/fonts/`.
