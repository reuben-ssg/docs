---
title: Layouts
weight: 6
description: Wrap pages in HTML, choose a layout per page or folder, and publish non-Markdown pages.
---

A layout is an HTML file in `layouts/` that wraps a page.
Reuben turns the page's Markdown into HTML, then puts that HTML into the layout at the place where you write `{{ content }}`.

[Configuration](@/configuration.md#layouts) describes how Reuben picks a layout, and [Theming](@/theming.md) covers layouts that ship in a theme.
This page shows how to write layouts and what they can read.

## Write a layout

A layout is plain HTML with Rhai blocks in it.
This is `layouts/default.html`:

```html
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{{ page.title }} | {{ site.title }}</title>
</head>
<body>
<main>
<h1>{{ page.title }}</h1>
{{ content }}
</main>
<footer>{{ site.params.tagline }}</footer>
</body>
</html>
```

With `title = "Layouts demo"` at the top of `reuben.toml` and `tagline = "Fresh bread daily"` under `[params]`, a page titled "Home" builds into this:

```html
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Home | Layouts demo</title>
</head>
<body>
<main>
<h1>Home</h1>
<p>This page uses the default layout.</p>

</main>
<footer>Fresh bread daily</footer>
</body>
</html>
```

A layout is where you add the `lang` attribute, the `<title>`, and the `<main>` landmark.
Reuben's [accessibility checks](@/guide/checks.md) look for all three in the built page.

## What a layout can read

A layout reads the same names as a page's blocks, and one more:

| Name          | What it holds                                                            |
| ------------- | ------------------------------------------------------------------------ |
| `content`     | The page's body as HTML.                                                 |
| `page`        | The page's front matter and its computed fields.                         |
| `site`        | The site's `title`, `base_url`, and `params`.                             |
| `data`        | The files in `data/`. See [Data](@/guide/data.md).                       |
| `collections` | Every collection. See [Collections](@/guide/collections.md).             |

A layout also sees every variable the page's [sidecar script](@/guide/sidecars.md) and setup blocks created, and it can call every [include](@/guide/includes.md) function and built-in helper.

A layout can use `{% %}` setup blocks as well as `{{ }}` output blocks.
Output is escaped as HTML, so `{{ page.title }}` is safe in text and in attributes.
`content` is already HTML, so Reuben outputs it as it is.
To output HTML you built yourself, wrap it in `raw()`.

A layout runs every block it holds, including blocks inside inline code and `<code>` elements, because a layout has no Markdown.
If you need to show `{{ }}` in a layout, output it as text, as in `{{ "{{" }}`.

## Choose a layout

A page uses the layout named by its `layout` field, which can also come from a folder's `_dir.toml`.
`layout: wide` selects `layouts/wide.html`.

This layout, `layouts/wide.html`, prints a variable that the page sets:

```html
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>{{ page.title }}</title>
</head>
<body class="wide">
<main>
<h1>{{ page.title }}</h1>
<p class="kicker">{{ kicker }}</p>
{{ content }}
</main>
</body>
</html>
```

The page `content/gallery.md` asks for the layout and sets `kicker` in a setup block:

```markdown
---
title: Gallery
layout: wide
---
{% let kicker = "Set in the page, read in the layout"; %}

This page asks for the `wide` layout.
```

Reuben builds `dist/gallery/index.html` with the kicker filled in:

```html
<main>
<h1>Gallery</h1>
<p class="kicker">Set in the page, read in the layout</p>
<p>This page asks for the <code>wide</code> layout.</p>

</main>
```

A page with no `layout` uses its collection's `layout` from `reuben.toml`, and then the layout named `default`.
To give every page in a folder the same layout, set `layout` in the folder's `_dir.toml`, or set it for the whole collection.

Reuben looks in the site's `layouts/` first and in the theme's `layouts/` second, so a site can replace a theme's layout by using the same file name.

## When there is no layout

If a page names no layout and no `default` layout exists, Reuben wraps the page in a plain built-in page shell.
The shell is a complete HTML page with a language, a `<title>`, a `<main>` landmark, and one line of CSS.
It adds the page's title as an `<h1>` unless the page's own body has one.

## Pages that aren't Markdown

Reuben treats a file in `content/` that starts with front matter as a template, even when it isn't Markdown.
A template runs its blocks and is published without Markdown processing and without a layout.

This `content/feed.xml` is a template:

```xml
---
title: Feed
---
<?xml version="1.0"?>
<feed><title>{{ "Fish & Chips" }}</title></feed>
```

Reuben publishes it as `dist/feed.xml` with the output escaped for XML:

```xml
<?xml version="1.0"?>
<feed><title>Fish &amp; Chips</title></feed>
```

Output is escaped for `.html`, `.htm`, `.xml`, and `.svg` templates.
For any other extension, such as `.json` or `.txt`, Reuben writes strings as they are, so you have to produce valid output yourself.

An `.html` template is published as a page at `dist/<name>/index.html`, so `content/hello.html` becomes `dist/hello/index.html`.
Reuben doesn't wrap it in a layout, so the template has to hold the whole page, including `<html lang>`, a `<title>`, a `<main>` landmark, and one `<h1>`.
Reuben's [accessibility checks](@/guide/checks.md) warn about each one that is missing.
Any other extension keeps its path, so `content/feed.xml` is `dist/feed.xml`.

## Errors

A layout that doesn't exist is an error, whether a page or a collection names it:

```text
error: content/index.md: layout `missing` not found in the site or its theme
Found 1 error in 1 file
```

A block in a layout that fails is an error at the layout's file and line, the same as a block in a page.
Every failing block in the layout is reported in one run.
