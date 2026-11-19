# docs

The Reuben documentation site, [reuben-ssg.dev](https://reuben-ssg.dev), built with Reuben itself.

## Build and preview

Install dependencies once with `npm ci`, then:

```sh
npm run dev      # reuben serve: preview with live rebuilds
npm run build    # reuben build: write the site to dist/
npm run check    # reuben check: run the site checks
npx reuben check --drafts   # include draft pages
```

## Layout

- `content/` holds the pages.
- `data/release.toml` holds the current Reuben version, read as `data.release.version`.
- `reuben.toml` holds the site title, base URL and `[params]`.
- `theme/` is the `deli` theme.
  It is self-contained and names no docs page, so it can move to its own repo unchanged; see `theme/README.md`.
- `wrangler.jsonc` and `scripts/` deploy `dist/` to Cloudflare Workers static assets.

## Licence

Licensed under either of

- Apache License, Version 2.0 ([LICENSE-APACHE](LICENSE-APACHE) or <http://www.apache.org/licenses/LICENSE-2.0>)
- MIT license ([LICENSE-MIT](LICENSE-MIT) or <http://opensource.org/licenses/MIT>)

at your option.

### Contribution

Unless you explicitly state otherwise, any contribution intentionally submitted for inclusion in the work by you, as defined in the Apache-2.0 license, shall be dual licensed as above, without any additional terms or conditions.
