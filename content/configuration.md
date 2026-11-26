---
title: Configuration
description: Every reuben.toml key, front matter field, _dir.toml default and command-line flag in Reuben 0.2.0.
---

This page is the reference for what you can set in a Reuben site and how you run Reuben.
It covers Reuben {{ data.release.version }}.
To build your first site, start with the [Quickstart](@/quickstart.md).

## Site folders

The [Site structure](@/site-structure.md) page lists the files and folders Reuben reads from the site root.

## reuben.toml

`reuben.toml` sits in the site root.
A site without one builds with the defaults in the table below.
Reuben treats an unknown key as an error and names it, so a typo can't pass silently:

```text
error: reuben.toml: config: unknown field `titel`, expected one of `title`, `base_url`, `theme`, `params`, `collections`, `sitemap`, `css`, `markdown`, `assets`, `a11y`
Found 1 error in 1 file
```

| Key           | Type             | Default      | What it does                                                         |
| ------------- | ---------------- | ------------ | -------------------------------------------------------------------- |
| `title`       | text             | empty        | The site title, available to scripts as `site.title`.                |
| `base_url`    | text             | `"/"`        | The address the site is served from, available as `site.base_url`.   |
| `theme`       | path             | none         | A folder of layouts, includes, and static files.                      |
| `params`      | table            | empty        | Your own values, available to scripts as `site.params`.              |
| `collections` | table of tables  | none         | Settings for the top-level folders of `content/`.                    |
| `sitemap`     | true or false    | `false`      | Whether Reuben writes `sitemap.xml`.                                 |
| `css`         | table            | see below    | How Reuben processes CSS files.                                      |
| `markdown`    | table            | see below    | Which optional Markdown features Reuben turns on.                    |
| `assets`      | table            | see below    | Whether Reuben hashes static file names and writes cache headers.    |
| `a11y`        | table            | see below    | Which accessibility rules to switch off.                             |
| `include`     | list of globs    | none         | More TOML files to merge into the configuration.                     |

### title and base_url

`title` is the site title.
A site without a `title` has an empty one.

`base_url` is where the site lives, such as `"https://example.com/"`.
Markdown links get only the path part of `base_url`, such as `/sub/`, so the same output works on any host.
The `url_for` helper joins the whole `base_url`.

### theme

`theme` is the path to a theme folder, relative to the site root:

```toml
theme = "theme"
```

If the path isn't a folder, Reuben stops with an error:

```text
error: reuben.toml: config: theme `./nope` is not a directory
```

[Theming](@/theming.md) explains what a theme folder holds.

### params

`params` holds any values you want your layouts and pages to read.
Reuben passes the table to scripts as `site.params`:

```toml
[params]
tagline = "Stacked high"
```

A page then reads it as `{{ site.params.tagline }}`.

### collections

A [collection](@/guide/collections.md) is a top-level folder of `content/` that holds at least one page.
Pages directly in `content/`, such as `index.md`, belong to no collection.
To change how a collection behaves, add a table named after its folder:

```toml
[collections.guide]
name = "docs"
layout = "doc"
sort = "weight"
```

| Key      | What it does                                                                                           |
| -------- | ------------------------------------------------------------------------------------------------------ |
| `name`   | The name scripts use for the collection, as in `collections.docs`. It defaults to the folder name.     |
| `layout` | The layout for every page in the collection that doesn't set its own `layout`.                         |
| `sort`   | The page field that orders the collection. Put `-` before the name for descending order.               |

Pages that tie on the `sort` field, and every page when `sort` isn't set, are ordered by their path.
A page without the field comes after the pages that have it.

If two collections end up with the same name, Reuben reports this error:

```text
two collections are named "docs"; rename one under [collections.<folder>]
```

### sitemap

Reuben writes no `sitemap.xml` unless you set `sitemap = true`:

```toml
sitemap = true
```

The file lists every HTML page except `404.html`.
It needs an absolute `base_url`, one that starts with `http://` or `https://`.
Otherwise, Reuben skips the file and prints a warning:

```text
warning: sitemap.xml skipped: base_url must be absolute (http:// or https://)
```

To supply your own sitemap, add a page or static file named `sitemap.xml`, and it replaces the generated one.
To have no sitemap, leave `sitemap = false`, which is the default.

Each URL in the sitemap gets a `<lastmod>` date.
The date is the day, in UTC, of the last commit that touched the page's source file.
Without git, or for a file git has no commit for, it is the file's modification time.
A page you edited but haven't committed keeps the date of its last commit, because Reuben reads only git's history and index, never your working files through git.
In a shallow clone, such as many CI jobs make by default, every page gets the date of the one commit that was fetched.
Fetch the full history if the dates matter.

### markdown

The `[markdown]` table turns optional Markdown features on and off.
Reuben adds nothing to the HTML of your Markdown unless you ask for it, so highlighting and math are off by default.
An unknown key in the table is a config error.

```toml
[markdown]
highlight = true
```

| Key                  | Type          | Default | What it does                                                                     |
| -------------------- | ------------- | ------- | -------------------------------------------------------------------------------- |
| `highlight`          | true or false | `false` | Highlights fenced code blocks in a known language.                               |
| `math`               | true or false | `false` | Reads `$…$` and `$$…$$` as math and renders it as MathML.                        |
| `footnote_backlinks` | true or false | `true`  | Links each footnote back to where the page cites it; an accessibility feature.   |

With `highlight` on, tokens in a fenced code block get `hl-` classes, and [`reuben css highlight`](@/cli.md#reuben-css-highlight) prints the CSS for them.
With it off, a fenced block is written as `<pre><code class="language-x">`, where `x` is the language, with the code escaped.

With `math` off, a `$` is plain text.
A `{{ … }}` inside `$…$` then runs as a block like any other, so `$x^{{2}}$` prints `$x^2$`, and `{{n}}` fails if `n` is undefined.
Turn `math` on to keep the braces literal.

Setting `footnote_backlinks = false` turns off an accessibility feature.
It removes the links from each footnote back to where the page cited it, which screen-reader and keyboard users rely on.

### css

The `[css]` table controls how Reuben processes every CSS file in the output.

| Key       | Type          | Default      | What it does                                                          |
| --------- | ------------- | ------------ | --------------------------------------------------------------------- |
| `minify`  | true or false | `true`       | Minifies the CSS.                                                     |
| `targets` | text          | `"defaults"` | A Browserslist query that names the browsers the CSS is lowered for.  |
| `bundle`  | true or false | `true`       | Inlines local `@import` rules.                                        |

```toml
[css]
minify = false
targets = "last 2 versions"
```

A `targets` query that Reuben can't read is an error that names `css.targets`.
Unknown keys in `[css]` are errors too.

### assets

The `[assets]` table controls the names of your static files and the cache rules that go with them.
Everything in it is off by default, so a site without the table builds as it always did.
An unknown key in the table is a config error.

```toml
[assets]
hash = true
headers = true
```

| Key       | Type          | Default | What it does                                                              |
| --------- | ------------- | ------- | ------------------------------------------------------------------------- |
| `hash`    | true or false | `false` | Adds a hash of each static file's content to its name.                    |
| `headers` | true or false | `false` | Writes a `_headers` file that tells the host to cache hashed files.       |
| `keep`    | list of globs | empty   | Static files that keep their names even when `hash` is on.                |

With `hash` on, Reuben renames each static file to `<stem>.<8-hex>.<ext>`, where the hex is a hash of the file's content.
A file named `css/site.css` becomes something like `css/site.d3c65ad5.css`.
A changed file gets a new name, so a browser can keep the old one for as long as it likes.
The [`asset()` helper](@/theming.md#link-to-static-files) gives a template the current name, and Reuben rewrites each `url()` in your CSS to match.

Some files keep their names, because browsers and hosts ask for them by name:

- Static files at the root of `static/`, such as `robots.txt` and `favicon.ico`.
- Everything under `.well-known/`.
- Files that match a glob in `keep`.

A `keep` glob is relative to the merged `static/` folder, after the site's files have replaced the theme's.
For example, `keep = ["fonts/*.woff2"]` leaves every font in `static/fonts/` under its own name.
Pages, `sitemap.xml`, and the other files Reuben builds are never renamed.

With `headers` on, Reuben writes a `_headers` file in the output.
Each hashed file gets `Cache-Control: public, max-age=31536000, immutable`, which lets a browser keep it for a year.
When every file in a folder is hashed, one rule covers the folder, and otherwise each hashed file gets its own rule.
Cloudflare Workers, Cloudflare Pages, and Netlify read this file.
If your `static/` folder has its own `_headers`, Reuben keeps it and adds its rules after yours.
A site with `base_url = "https://example.com/docs/"` gets rules that start with `/docs/`.

Two settings are config errors, because without them hashing isn't safe or `headers` has nothing to cache:

```text
error: reuben.toml: config: assets: `headers = true` needs `hash = true`
```

```text
error: reuben.toml: config: assets: `hash = true` needs `[css] bundle = true`
```

A host limits a `_headers` file to 100 rules, and Reuben reports an error if the file would need more:

```text
error: reuben.toml: config: `_headers` would need 122 rules; Cloudflare allows 100
```

To get under the limit, add `keep` globs for files that don't need a long cache.

### a11y

Every build checks each page against 12 accessibility rules.
[Accessibility checks](@/guide/checks.md) describes each rule.
List rule ids under `a11y.disable` to switch rules off for the whole site:

```toml
[a11y]
disable = ["main-landmark", "html-lang"]
```

The rule ids are:

- `heading-order`
- `link-text`
- `img-alt`
- `heading-id-unique`
- `table-header`
- `html-lang`
- `page-title`
- `single-h1`
- `main-landmark`
- `id-unique`
- `form-label`
- `link-target`

An id that isn't a rule is an error:

```text
error: reuben.toml: config: unknown accessibility rule `bogus`
```

You can also switch rules off for one folder, in its `_dir.toml`, or for one page, in its front matter.
Each level adds to the ones above it, and a level can't switch back on a rule that a higher level switched off.
Accessibility findings print as warnings and never fail `reuben build`.
`reuben check` fails on them.

### include

`include` is a list of globs, relative to the site root.
Reuben merges the files each glob matches into the configuration after `reuben.toml`, taking the globs in order and the matches of each glob in sorted path order:

```toml
include = ["config/*.toml"]
```

Tables merge key by key, and any other value replaces the one before it.
`include` works only in `reuben.toml`.
An included file that has its own `include` is an error with this message:

```text
`include` is only allowed in `reuben.toml`
```

### Environment overlays

Pass `--env <name>` to merge `reuben.<name>.toml` over the configuration.
`--env` takes one name.
The merge order is `reuben.toml`, then the files that `include` matches, in glob order with each glob's matches sorted by path, then `reuben.<name>.toml`.
The overlay merges last, so the result is the same on every run.
A missing overlay file is not an error.

For example, to set the real address only for production builds, put this in `reuben.production.toml`:

```toml
base_url = "https://example.com/"
```

Then build with the overlay.
Installed with npm? [Run these with `npx` in front](@/quickstart.md#install-reuben), as in `npx reuben build --env production`.

```sh
reuben build --env production
```

An overlay can't use `include`.

## Front matter

Every Markdown page starts with front matter, which is a block of settings at the very top of the file.
Write it as YAML between two `---` lines, or as TOML between two `+++` lines:

```markdown
---
title: Rye bread
date: 2024-03-01
weight: 3
tags: [bread, rye]
---
```

```markdown
+++
title = "Rye bread"
date = 2024-03-01
+++
```

A Markdown file that doesn't start with front matter is an error with this message:

```text
file must start with front matter between `---` (YAML) or `+++` (TOML) lines
```

An opening line without a closing one is an error too: ``no closing `---` line``.
In YAML front matter, only `true` and `false` count as booleans, so `on` and `off` stay text.

| Field         | Type          | What it does                                                                                    |
| ------------- | ------------- | ----------------------------------------------------------------------------------------------- |
| `title`       | text          | The page title. It is required and can't be blank.                                              |
| `draft`       | true or false | Marks the page as a draft. The default is `false`.                                              |
| `description` | text          | A short description. Reuben uses it as the page's summary in collections and in the built-in page shell's `description` meta tag. |
| `date`        | text          | A date or timestamp, such as `2024-03-01`. Scripts read it as `page.date`.                      |
| `layout`      | text          | The name of the layout that wraps the page.                                                     |
| `weight`      | integer       | A number for ordering pages. Set a collection's `sort` to `weight` to use it.                   |
| `a11y`        | table         | `disable`, a list of accessibility rule ids to switch off for this page.                        |

A missing title is an error:

```text
error: content/index.md: front matter: `title` is required
```

A field that isn't in the table is yours.
Reuben passes it to scripts untouched, so `tags` in the example above becomes `page.tags`.

Reuben also sets some names itself, and they win over front matter of the same name:

| Name              | What it holds                                                         |
| ----------------- | --------------------------------------------------------------------- |
| `page.url`        | The page's URL, such as `/guide/intro/`.                              |
| `page.path`       | The source path under `content/`, such as `guide/intro.md`.           |
| `page.slug`       | The last part of the URL, such as `intro`.                            |
| `page.collection` | The name of the page's collection, or an empty string for none.       |
| `page.toc`        | The page's headings, as a list.                                       |

To format a date, call the `format_date` helper in a Rhai block, as in `{{ format_date(page.date, "%B %Y") }}`.
For `date: 2024-03-01`, that block outputs `March 2024`.

### Layouts

Reuben picks a page's layout in this order:

1. The page's `layout` field, which can also come from a `_dir.toml`.
2. The `layout` of the page's collection in `reuben.toml`.
3. A layout named `default`.

A layout name is a file name in `layouts/`, with or without `.html`.
Reuben looks in the site's `layouts/` first and then in the theme's.
If no layout is found and none was named, Reuben wraps the page in a plain built-in page shell.
If you name a layout that doesn't exist, Reuben reports an error:

```text
error: content/index.md: layout `missing` not found in the site or its theme
```

A layout name can't contain `/`, `\` or `..`.
[Layouts](@/guide/layouts.md) shows how to write a layout.

### Drafts

A draft page is left out of `reuben build`, `reuben serve`, and `reuben check` unless you pass `--drafts`.
Reuben leaves a draft out of the sitemap, the collections, and the navigation your theme builds from them.
A link to a draft page is an error when the drafts aren't built.

A folder is a draft when its `_dir.toml` sets `draft = true`, or when the `index.md` inside it is a draft.
Every page and file below that folder is hidden too.
A draft `index.md` directly in `content/` hides only itself.

`reuben build` counts what it skipped: `Built 2 pages, copied 0 static files (1 draft skipped)`.

## _dir.toml

A `_dir.toml` file in a folder of `content/` sets front matter defaults for every page in that folder and the folders below it.
It takes the same fields as front matter, plus any field of your own.
Reuben doesn't publish it.

```toml
description = "A page in the guide."
audience = "beginners"
```

Defaults layer from the outside in.
The `_dir.toml` in `content/` applies first, then the one in each folder on the way down, and the page's own front matter applies last.
Tables merge key by key, and any other value replaces the one before it.
A `title` can come from a `_dir.toml`, so pages in that folder don't need their own.

A `draft` in a `_dir.toml` must be `true` or `false`, or Reuben reports this error:

```text
`draft` must be true or false
```

A `_dir.toml` that fails to load is reported against its own file, and Reuben doesn't repeat the problem on every page below it.

To see which file set each value, run `reuben explain`, which [Explain a page](@/guide/explain.md) describes.
For example, suppose `content/guide/intro.md` starts like this:

```markdown
---
title: Intro
weight: 1
description: Start here.
---
```

Then `reuben explain guide/intro.md` shows that the page's `audience` comes from the `_dir.toml` above, and that the page's own `description` replaced the folder's:

```text
page.audience        "beginners"       content/guide/_dir.toml:2
page.description     "Start here."     content/guide/intro.md:4
page.title           "Intro"           content/guide/intro.md:2
page.weight          1                 content/guide/intro.md:3
```

The [`reuben explain` command](@/cli.md#reuben-explain) lists the rest of the names.

## Commands

The [CLI reference](@/cli.md) lists every command with its options.
