---
title: CLI reference
description: Every Reuben command, with its options and what it prints.
---

This page is the reference for the `reuben` commands.
To set up a site, refer to [Configuration](@/configuration.md).

Every command takes `-h` and `--help`.
`reuben --version` and `reuben -V` print the version.
Every command that reads a site takes `--root <ROOT>`, the site root, which defaults to `.`.

## reuben build

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

## reuben serve

```sh
reuben serve [OPTIONS]
```

`reuben serve` builds the site in memory, serves it, rebuilds when a file changes, and reloads the browser.
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

It watches `content/`, `includes/`, `layouts/`, `data/`, and `static/`, the theme folder, `reuben.toml`, every `reuben.<name>.toml`, and the files that `include` pulls in.
After each rebuild it prints `Rebuilt 2 pages in 1 ms`.
If a rebuild fails, Reuben prints the errors and keeps serving the last good build.
If the first build fails, the server doesn't start and Reuben exits with status 1.

The server adds a live-reload script to the HTML it serves.
Your built site never contains it.
The path `__reuben/` is reserved for the server, so no page or file may build to it.

## reuben check

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

## reuben explain

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

The list covers the page's front matter and computed names, `site`, `data`, `collections`, the variables a sidecar script sets (a `.rhai` file next to the page, with the same name, that runs before the page's blocks), the functions your includes define, and the built-in helpers.
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

## reuben css highlight

```sh
reuben css highlight [--theme <THEME>]
```

Fenced code blocks in a known language build with `hl-` classes on their tokens, but only when `[markdown] highlight = true` is set.
`reuben css highlight` prints the CSS for those classes.
`--theme` takes a built-in theme name or the path to a `.tmTheme` file, and defaults to `base16-ocean.dark`.
The built-in themes are `InspiredGitHub`, `Solarized (dark)`, `Solarized (light)`, `base16-eighties.dark`, `base16-mocha.dark`, `base16-ocean.dark`, and `base16-ocean.light`.
Save the output in a stylesheet in your `static/` folder, or write your own rules for the same classes.
