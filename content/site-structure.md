---
title: Site structure
description: The files and folders Reuben reads from a site's root, and what each one holds.
---

Reuben reads a site from the folder you run it in, or from the folder you give to `--root`.
It looks for these folders and files in the site root, folders first, each group in alphabetical order.

| Path           | What it holds |
| -------------- | ------------- |
| `content/`     | The pages, as Markdown files. Reuben copies other files in it to the output beside their pages, except `.rhai` sidecar scripts, which it never publishes, and files that start with front matter, which it renders as templates. |
| `data/`        | Data files (`.json`, `.toml`, `.yaml`, `.yml`, and `.rhai`) that become the `data` value in pages. |
| `dist/`        | The output. `reuben build` writes it, and you can change it with `--out`. |
| `includes/`    | Rhai files (`.rhai`) whose functions pages and layouts can call. |
| `layouts/`     | HTML layouts that wrap pages. |
| `static/`      | Files Reuben copies to the root of the output, such as images and stylesheets. Files that start with front matter are rendered as templates, and CSS files named `_name.css` are import-only partials that Reuben never writes out. |
| `reuben.toml`  | The site configuration. It is optional. |

The Feature guide explains how pages use these folders: [Data](@/guide/data.md) covers `data/`, [Includes](@/guide/includes.md) covers `includes/`, and [Layouts](@/guide/layouts.md) covers `layouts/`.
[Configuration](@/configuration.md) covers `reuben.toml`.

Reuben ignores files and folders under `content/` whose names start with a dot.
It never publishes `.DS_Store`, `Thumbs.db`, `.swp` files or files whose names end in `~`.
