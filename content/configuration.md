---
title: Configuration
description: Every reuben.toml key, front matter field, _dir.toml default and command-line flag in Reuben 0.1.1.
---

This page is the reference for what you can set in a Reuben site and how you run Reuben.
It covers Reuben 0.1.1.
To build your first site, start with the [Quickstart](@/quickstart.md).

## Site folders

Reuben reads a site from the folder you run it in, or from the folder you give to `--root`.
It looks for these files and folders in the site root.

| Path           | What it holds                                                                                     |
| -------------- | ------------------------------------------------------------------------------------------------- |
| `reuben.toml`  | The site configuration. It is optional.                                                           |
| `content/`     | The pages, as Markdown files. Reuben copies any other file in it to the output beside its pages. |
| `static/`      | Files Reuben copies to the root of the output, such as images and stylesheets.                    |
| `data/`        | Data files (`.json`, `.toml`, `.yaml`, `.yml` and `.rhai`) that become the `data` value in pages. |
| `includes/`    | Rhai files (`.rhai`) whose functions pages and layouts can call.                                  |
| `layouts/`     | HTML layouts that wrap pages.                                                                     |
| `dist/`        | The output. `reuben build` writes it, and you can change it with `--out`.                         |

Reuben ignores files and folders under `content/` whose names start with a dot.
It never publishes `.DS_Store`, `Thumbs.db`, `.swp` files or files whose names end in `~`.

## reuben.toml

`reuben.toml` sits in the site root.
A site without one builds with the defaults in the table below.
Reuben treats an unknown key as an error and names it, so a typo can't pass silently:

```text
error: reuben.toml: config: unknown field `titel`, expected one of `title`, `base_url`, `theme`, `params`, `collections`, `sitemap`, `css`, `a11y`
```

| Key           | Type             | Default      | What it does                                                         |
| ------------- | ---------------- | ------------ | -------------------------------------------------------------------- |
| `title`       | text             | empty        | The site title, available to scripts as `site.title`.                |
| `base_url`    | text             | `"/"`        | The address the site is served from, available as `site.base_url`.   |
| `theme`       | path             | none         | A folder of layouts, includes and static files.                      |
| `params`      | table            | empty        | Your own values, available to scripts as `site.params`.              |
| `collections` | table of tables  | none         | Settings for the top-level folders of `content/`.                    |
| `sitemap`     | true or false    | `true`       | Whether Reuben writes `sitemap.xml`.                                 |
| `css`         | table            | see below    | How Reuben processes CSS files.                                      |
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

A collection is a top-level folder of `content/` that holds at least one page.
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

Pages that tie on the `sort` field, and every page when `sort` is empty, are ordered by their path.
A page without the field comes after the pages that have it.

If two collections end up with the same name, Reuben reports this error:

```text
two collections are named "docs"; rename one under [collections.<folder>]
```

### sitemap

Reuben writes `sitemap.xml` to the output when `sitemap` is true, which is the default.
It lists every HTML page except `404.html`.
It needs an absolute `base_url`, one that starts with `http://` or `https://`.
Otherwise, Reuben skips the file and prints a warning:

```text
warning: sitemap.xml skipped: base_url must be absolute (http:// or https://)
```

A page or static file named `sitemap.xml` replaces the generated one.
Set `sitemap = false` to switch the file off.

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

### a11y

Every build checks each page against 12 accessibility rules.
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
It merges last, after `reuben.toml` and its included files.
A missing overlay file is not an error.

For example, to set the real address only for production builds, put this in `reuben.production.toml`:

```toml
base_url = "https://example.com/"
```

Then build with the overlay:

```sh
npx reuben build --env production
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

### Drafts

A draft page is left out of `reuben build`, `reuben serve` and `reuben check` unless you pass `--drafts`.
Reuben leaves a draft out of the sitemap, the collections and the navigation your theme builds from them.
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

To see which file set each value, run `reuben explain`.
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

The [`reuben explain` command](#reuben-explain) lists the rest of the names.

## Commands

Every command takes `-h` and `--help`.
`reuben --version` and `reuben -V` print the version.
Every command that reads a site takes `--root <ROOT>`, the site root, which defaults to `.`.

### reuben build

```sh
reuben build [OPTIONS]
```

`reuben build` builds the site into the output folder.
It loads the whole site, renders every page, and only then swaps the result into place.
If the build fails, Reuben leaves the previous output as it was.
Reuben collects every independent error and reports them together, so you see all of them in one run.

| Option          | What it does                                                                  |
| --------------- | ----------------------------------------------------------------------------- |
| `--root <ROOT>` | The site root, which contains `content/` and optionally `static/`. Default `.`. |
| `--out <OUT>`   | The output folder. It defaults to `<root>/dist`.                              |
| `--drafts`      | Includes pages marked as drafts.                                              |
| `--env <ENV>`   | Merges `reuben.<name>.toml` over `reuben.toml` if it exists.                  |
| `--jobs <N>`    | Renders with this many threads. It defaults to one per core.                  |

A successful build prints a summary and exits with status 0:

```text
Built 2 pages, copied 0 static files in 1ms
```

CSS files go through the `[css]` settings, and Reuben doesn't count them as copied static files.
Accessibility findings print as warnings after the summary, followed by a count such as `1 accessibility warning in 1 file`.

A failed build prints each error, then `Found 1 error in 1 file`, and exits with status 1.

Reuben refuses to replace an output folder that isn't empty and doesn't hold a `.reuben-output` file, which Reuben writes into every folder it builds:

```text
error: ../nonempty: output directory isn't empty and wasn't created by Reuben (no `.reuben-output` file), so it won't be cleared
```

### reuben serve

```sh
reuben serve [OPTIONS]
```

`reuben serve` builds the site in memory, serves it, rebuilds when a file changes and reloads the browser.
It writes nothing to `dist/`.

| Option          | What it does                                                                    |
| --------------- | ------------------------------------------------------------------------------- |
| `--root <ROOT>` | The site root. Default `.`.                                                     |
| `--port <PORT>` | The port to listen on, on 127.0.0.1 only. `0` picks a free one. Default `1111`. |
| `--drafts`      | Includes pages marked as drafts.                                                |
| `--env <ENV>`   | Merges `reuben.<name>.toml` over `reuben.toml` if it exists.                    |
| `--jobs <N>`    | Renders with this many threads. It defaults to one per core.                    |

Reuben prints the address when the server starts:

```text
Serving at http://127.0.0.1:1111
```

It watches `content/`, `includes/`, `layouts/`, `data/` and `static/`, the theme folder, `reuben.toml`, every `reuben.<name>.toml`, and the files that `include` pulls in.
After each rebuild it prints `Rebuilt 2 pages in 1 ms`.
If a rebuild fails, Reuben prints the errors and keeps serving the last good build.
If the first build fails, the server doesn't start and Reuben exits with status 1.

The server adds a live-reload script to the HTML it serves.
Your built site never contains it.
The path `__reuben/` is reserved for the server, so no page or file may build to it.

### reuben check

```sh
reuben check [OPTIONS]
```

`reuben check` loads and renders the site like `reuben build`, but it writes nothing.
It prints every error and every accessibility finding, and then a summary line.

| Option          | What it does                                                 |
| --------------- | ------------------------------------------------------------ |
| `--root <ROOT>` | The site root. Default `.`.                                  |
| `--drafts`      | Includes pages marked as drafts.                             |
| `--env <ENV>`   | Merges `reuben.<name>.toml` over `reuben.toml` if it exists. |
| `--jobs <N>`    | Renders with this many threads. It defaults to one per core. |

The command exits with status 0 only when it finds no errors and no findings, and with status 1 otherwise.
That makes it suitable for CI.
The summary line is `No problems found in 2 pages` or a count such as `Found 1 error and 2 accessibility findings in 2 files`.

### reuben explain

```sh
reuben explain [OPTIONS] <PAGE>
```

`reuben explain` lists every name in scope for one page, with its value and the file and line that set it.
`<PAGE>` is a path such as `content/blog/x.md`, a path under `content/` such as `blog/x.md`, or a URL such as `/blog/x/`.

| Option          | What it does                                                 |
| --------------- | ------------------------------------------------------------ |
| `<PAGE>`        | The page to explain.                                         |
| `--root <ROOT>` | The site root. Default `.`.                                  |
| `--env <ENV>`   | Merges `reuben.<name>.toml` over `reuben.toml` if it exists. |

The list covers the page's front matter and computed names, `site`, `data`, `collections`, the variables a sidecar script sets, the functions your includes define, and the built-in helpers.
It also finds draft pages.
Here is the output for the `guide/intro.md` page described above, in a site whose `reuben.toml` is:

```toml
title = "Deli"
base_url = "https://example.com/"

[params]
tagline = "Stacked high"

[collections.guide]
name = "docs"
sort = "weight"
```

The output is:

```text
content/guide/intro.md (/guide/intro/)

page.audience        "beginners"                                                      content/guide/_dir.toml:2
page.description     "Start here."                                                    content/guide/intro.md:4
page.title           "Intro"                                                          content/guide/intro.md:2
page.weight          1                                                                content/guide/intro.md:3
page.draft           false                                                            computed
page.url             "/guide/intro/"                                                  computed
page.path            "guide/intro.md"                                                 computed
page.slug            "intro"                                                          computed
page.collection      "docs"                                                           computed
page.toc             [#{"id": "intro", "level": 1, "text": "Intro"}]                  computed
site.title           "Deli"                                                           reuben.toml:1
site.base_url        "https://example.com/"                                           reuben.toml:2
site.params.tagline  "Stacked high"                                                   reuben.toml:5
collections.docs     1 page                                                           collection docs
helpers              raw, escape, markdown, sort_by, load_data, url_for, format_date  built-in
```

If the site has errors, `reuben explain` prints them after the list and exits with status 1.
If no page matches, Reuben reports an error that ends with the forms it accepts:

```text
no page matches `nope.md`: give a path like content/blog/x.md, a path under content/ like blog/x.md, or a URL like /blog/x/
```

### reuben css highlight

```sh
reuben css highlight [--theme <THEME>]
```

Fenced code blocks in a known language build with `hl-` classes on their tokens.
`reuben css highlight` prints the CSS for those classes.
`--theme` takes a built-in theme name or the path to a `.tmTheme` file, and defaults to `base16-ocean.dark`.
The built-in themes are `InspiredGitHub`, `Solarized (dark)`, `Solarized (light)`, `base16-eighties.dark`, `base16-mocha.dark`, `base16-ocean.dark` and `base16-ocean.light`.
Save the output in a stylesheet in your `static/` folder, or write your own rules for the same classes.
