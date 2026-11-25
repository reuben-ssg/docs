---
title: Explain a page
weight: 9
description: List every name a page can use, with its value and the file and line that set it.
---

`reuben explain` answers two questions about one page: which names can it use, and where did each value come from.
It lists every name in scope for the page, with the name's value and the file and line that set it.
Use it when a block prints nothing, when a value isn't the one you expected, or when you want to know which `_dir.toml` or sidecar script a field comes from.

## Run it

Give the command a page.
Installed with npm? [Run these with `npx` in front](@/quickstart.md#install-reuben), as in `npx reuben explain docs/order.md`.
You can name the page in three ways, and all three explain the same page:

```sh
reuben explain content/docs/order.md
reuben explain docs/order.md
reuben explain /docs/order/
```

The first form is the page's source path, the second is its path under `content/`, and the third is its URL.
`reuben explain` finds a draft page too, without `--drafts`.

Add `--root <ROOT>` to explain a site in another folder, and `--env <name>` to merge `reuben.<name>.toml` over `reuben.toml` first.

## Read the output

This example site has a `reuben.toml`, a `data/menu.json`, an include, a `_dir.toml`, and a sidecar script:

```text
reuben.toml
data/menu.json
includes/badge.rhai
content/docs/_dir.toml
content/docs/order.md
content/docs/order.rhai
```

`data/menu.json` lists two dishes:

```json
[{ "name": "Reuben", "price": 12 }, { "name": "Pickle plate", "price": 6 }]
```

`includes/badge.rhai` defines one function:

```rhai
fn badge(text) {
    raw(`<span class="badge">${escape(text)}</span>`)
}
```

`reuben.toml` sets a title, an absolute `base_url`, a `params` value, and a collection:

```toml
title = "Deli docs"
base_url = "https://deli.example/"

[params]
author = "Ada"

[collections.docs]
sort = "weight"
```

The folder default, `content/docs/_dir.toml`, sets a field of your own:

```toml
audience = "customers"
```

The page, `content/docs/order.md`, has front matter and one block:

```markdown
---
title: Ordering
weight: 2
description: How to place an order.
---
{{ badge("new") }} The cheapest dish costs {{ cheapest.price }}.
```

The sidecar, `content/docs/order.rhai`, sets `cheapest`:

```rhai
let cheapest = data.menu.sort_by("price")[0];
```

`reuben explain docs/order.md` prints this:

```text
content/docs/order.md (/docs/order/)

page.audience       "customers"                                                      content/docs/_dir.toml:1
page.description    "How to place an order."                                         content/docs/order.md:4
page.title          "Ordering"                                                       content/docs/order.md:2
page.weight         2                                                                content/docs/order.md:3
page.draft          false                                                            computed
page.url            "/docs/order/"                                                   computed
page.path           "docs/order.md"                                                  computed
page.slug           "order"                                                          computed
page.collection     "docs"                                                           computed
page.toc            []                                                               computed
site.title          "Deli docs"                                                      reuben.toml:1
site.base_url       "https://deli.example/"                                          reuben.toml:2
site.params.author  "Ada"                                                            reuben.toml:5
data.menu           [2 items]                                                        data/menu.json
collections.docs    1 page                                                           collection docs
cheapest            #{"name": "Pickle plate", "price": 6}                            content/docs/order.rhai:1
badge/1             (text)                                                           includes/badge.rhai:1
helpers             raw, escape, markdown, sort_by, load_data, url_for, format_date  built-in
```

The first line names the page's source file and its URL.
Each row after it has three columns: the name, its value, and its source.

| Source                            | Meaning                                                              |
| --------------------------------- | -------------------------------------------------------------------- |
| `content/docs/order.md:4`         | A file and line, such as a front matter field, a config key, or a sidecar variable. |
| `content/docs/_dir.toml:1`        | A folder default. The page's own value wins when it sets the same field. |
| `computed`                        | Reuben set the value itself, such as `page.url` and `page.toc`.      |
| `collection docs`                 | A collection. The value is its page count.                           |
| `built-in`                        | A built-in helper.                                                   |

Each group of rows tells you something:

- `page.*` rows hold the page's front matter fields first, and then Reuben's computed fields.
  `page.audience` shows that the folder's `_dir.toml` supplied a field the page never wrote.
- `site.*` rows hold the site's title, base URL, and each `params` value.
- `data.*` rows hold one row for each data file, and for each [data script](@/guide/data.md).
- `collections.*` rows list each [collection](@/guide/collections.md) with its page count.
- Rows with no prefix are variables from the page's [sidecar script](@/guide/sidecars.md), such as `cheapest`.
- `name/arity` rows are [include](@/guide/includes.md) functions, such as `badge/1`.
  The number is how many parameters the function takes, and the parentheses list their names.
- The last row lists the built-in helpers.

The value column shows each value in its Rhai form, so text has quotes and a map starts with `#{`.
A value longer than 60 characters doesn't fit a row.
Reuben counts a long list or map instead, as in `[2 items]` and `#{3 keys}`, and it cuts any other long value and ends it with `…`.
`data.menu` shows `[2 items]` for that reason.

## Find the cause of a problem

A name that isn't in the list is a name the page can't use.
That is how you find a misspelled field: `{{ page.titel }}` prints nothing, and `reuben explain` shows `page.title` and no `page.titel`.

A value that comes from the wrong place shows in the source column.
If a page's `description` is the folder's, the source says `_dir.toml`, and the page needs its own `description`.

Reuben builds the page to explain it, so errors in the page, its sidecar script, its `_dir.toml` files, the includes, and the data appear too.
When the page can't build, `reuben explain` prints the names it found, then the errors, and exits with status 1.
This is a page whose sidecar reads past the end of a list:

```text
content/broken.md (/broken/)

page.title       "Broken"                                                         content/broken.md:2
page.draft       false                                                            computed
page.url         "/broken/"                                                       computed
page.path        "broken.md"                                                      computed
page.slug        "broken"                                                         computed
page.collection  ""                                                               computed
page.toc         []                                                               computed
site.title       ""                                                               computed
site.base_url    "/"                                                              computed
helpers          raw, escape, markdown, sort_by, load_data, url_for, format_date  built-in
error: Array index 5 out of bounds: only 2 elements in array
  --> content/broken.rhai:2:18
  |
2 | let third = jobs[5];
  |                  ^
Found 1 error in 1 file
```

The sidecar's variables are missing from the list, because the sidecar failed.

## When no page matches

If the argument matches no page, Reuben says so and exits with status 1:

```text
error: .: no page matches `nope.md`: give a path like content/blog/x.md, a path under content/ like blog/x.md, or a URL like /blog/x/
```

The `.` at the start of the message is the site root, which is `.` when you run the command from it.
