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

## Fonts

Fonts are self-hosted from `static/fonts/` and each carries its OFL licence file.
No page requests a third-party font or stylesheet.
Theme assets use root-relative paths so previews stay self-contained.

## Licence

Licensed under either of

- Apache License, Version 2.0 ([LICENSE-APACHE](LICENSE-APACHE) or <http://www.apache.org/licenses/LICENSE-2.0>)
- MIT license ([LICENSE-MIT](LICENSE-MIT) or <http://opensource.org/licenses/MIT>)

at your option.
The bundled fonts are under the SIL Open Font License; see the `*-OFL.txt` files in `static/fonts/`.
