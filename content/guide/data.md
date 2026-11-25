---
title: Data
weight: 4
description: Load JSON, TOML, YAML, and Rhai files from data/ into every page and layout.
---

Reuben loads the files in `data/` into one value called `data`, which every page, layout, and sidecar script can read.
Use data for facts that don't belong in a page, such as a menu, a team list, or a release number.

## Add data files

Put files in `data/`.
Reuben reads files that end in `.json`, `.toml`, `.yaml`, `.yml`, and `.rhai`, and it skips every other file.

The file's path becomes its place in `data`.
A file directly in `data/` becomes a key named after the file, without its extension.
A file in a folder nests under the folder's name:

| File                      | Where you read it       |
| ------------------------- | ----------------------- |
| `data/menu.yaml`          | `data.menu`             |
| `data/team/members.toml`  | `data.team.members`     |
| `data/stats.rhai`         | `data.stats`            |

Reuben skips files and folders whose names start with a dot, and junk files such as `Thumbs.db`.

## Plain data files

The example site has two plain data files.
`data/team/members.toml` lists two people:

```toml
[[people]]
name = "Ada"
role = "Slicer"

[[people]]
name = "Grace"
role = "Cashier"
```

`data/menu.yaml` lists two dishes:

```yaml
- name: Reuben
  price: 12
  vegetarian: no
- name: Pickle plate
  price: 6
  vegetarian: true
```

A page reads them by path:

```markdown
The first person is {{ data.team.members.people[0].name }}, a {{ data.team.members.people[0].role }}.

The first dish is vegetarian: {{ data.menu[0].vegetarian }}.
```

Reuben builds this HTML:

```html
<p>The first person is Ada, a Slicer.</p>
<p>The first dish is vegetarian: no.</p>
```

An array reads like a list in any language: `[0]` is the first item, and `.len()` counts the items.

The value `no` printed as the text `no`, because in YAML only `true` and `false` count as booleans.
Write `vegetarian: false` when you want a boolean.

## Data scripts

A `.rhai` file in `data/` is a data script.
Reuben runs it once, and the last expression of the script becomes the value at the script's key.
Use a script to compute a value from the other data files.

A data script sees two names:

- `data`, which holds the plain data files, but not other data scripts.
- `site`, which holds the site's `title`, `base_url`, and `params`.

This script, `data/stats.rhai`, returns a map:

```rhai
// `data` holds the plain files (not other scripts); `site` is available too.
#{
    staff: data.team.members.people.len(),
    cheapest: data.menu.sort_by("price")[0].name,
    shop: site.params.shop,
}
```

With `shop = "Reuben's Deli"` under `[params]` in `reuben.toml`, a page reads the result as `data.stats`:

```markdown
{{ data.stats.shop }} has {{ data.stats.staff }} people.
The cheapest dish is the {{ data.stats.cheapest }}.
```

```html
<p>Reuben&#39;s Deli has 2 people.
The cheapest dish is the Pickle plate.</p>
```

Reuben escapes the apostrophe in the shop's name as `&#39;`, which browsers show as `'`.

The `#{ … }` in the script is Rhai's object-map syntax.
It is a map literal: a list of `key: value` pairs between braces, such as `#{ name: "Ada", role: "Slicer" }`.
The `#` tells Rhai it is a map and not a block of statements, so a bare `{ … }` doesn't work in its place.

## Read a file on demand

The `load_data(path)` helper reads one data file from a script or a block.
The path is relative to the site root, and the file must end in `.json`, `.toml`, `.yaml`, or `.yml`:

```rhai
let jobs = load_data("data/jobs.json");
```

Use `load_data()` for a file outside `data/` or for a file you only want on some pages.
The path must stay inside the site.
A path that leaves it, such as `../secret.json`, is an error.

## Errors

Reuben reports every data problem in one run, and a file that fails leaves out only its own key.
A file that doesn't parse names the file and the parser's message:

```text
error: data/broken.json: data: expected value at line 1 column 8
```

Two files that want the same key conflict.
Here `data/team.json` and the folder `data/team/` both claim `data.team`:

```text
error: data/team.json: data: `team` is a file here but a folder at ./data/team
```

A `load_data()` call that fails is an error at the block that called it:

```text
error: Runtime error: load_data("../secret.json"): path is outside the site
  --> content/index.md:4:4
  |
4 | {{ load_data("../secret.json") }}
  |    ^
error: Runtime error: load_data("data/missing.json"): No such file or directory (os error 2)
  --> content/index.md:6:4
  |
6 | {{ load_data("data/missing.json") }}
  |    ^
```

[`reuben explain`](@/guide/explain.md) shows each `data` key with the file that set it.
For the example above it prints:

```text
data.menu          [2 items]                                                        data/menu.yaml
data.stats         #{3 keys}                                                        data/stats.rhai
data.team.members  #{1 keys}                                                        data/team/members.toml
```
