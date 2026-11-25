---
title: Theming
description: How Reuben themes work, what a theme folder holds, and how a site overrides its theme.
---

A theme is a folder of layouts, includes, and static files that gives a site its look.
This page explains what goes in a theme folder, how Reuben combines a theme with your site, and how your site overrides it.
It covers Reuben 0.2.0.
You need a site that builds, so start with the [Quickstart](@/quickstart.md) if you don't have one.

## What a theme holds

A theme folder has the same three folders that a site can have:

| Folder      | What it holds                                                        |
| ----------- | -------------------------------------------------------------------- |
| `layouts/`  | HTML layouts that wrap pages.                                        |
| `includes/` | Rhai files (`.rhai`) whose functions layouts and pages can call.     |
| `static/`   | Files that Reuben copies to the root of the output, such as CSS.     |

All three are optional.
Reuben reads nothing else from a theme folder.

For example, a theme in a folder named `theme` looks like this:

```text
my-site/
├── content/
├── reuben.toml
└── theme/
    ├── includes/
    │   └── footer.rhai
    ├── layouts/
    │   └── default.html
    └── static/
        └── style.css
```

## Use a theme

Set `theme` in `reuben.toml` to the path of the theme folder, relative to the site root:

```toml
title = "Theme demo"
theme = "theme"
```

The folder can live outside the site, such as `theme = "../shared/theme"`.
If the path isn't a folder, Reuben stops the build and names it:

```text
error: reuben.toml: config: theme `./nope` is not a directory
```

A site without a `theme` setting can still have its own `layouts/`, `includes/`, and `static/` folders.
They work the same way.
A theme only adds a second place for Reuben to look.

## Write a layout

A [layout](@/guide/layouts.md) is an HTML file in `layouts/` that wraps a page.
Reuben picks the layout from the page's front matter `layout` field, then from its collection's `layout` setting, and then falls back to a layout named `default`.
[Configuration](@/configuration.md#layouts) describes that order and the errors you get when a layout is missing.

Write the layout as HTML with Rhai blocks in it.
This is `theme/layouts/default.html` for the theme above:

```html
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{{ page.title }} · {{ site.title }}</title>
<link rel="stylesheet" href="/style.css">
</head>
<body>
<main>
{{ content }}
</main>
{{ footer() }}
</body>
</html>
```

A layout can read these names:

| Name          | What it holds                                                                      |
| ------------- | ---------------------------------------------------------------------------------- |
| `content`     | The page's body, already built into HTML.                                          |
| `page`        | The page's front matter, plus `url`, `path`, `slug`, `collection`, and `toc`.       |
| `site`        | The site's `title`, `base_url`, and `params`.                                       |
| `data`        | The files in `data/`.                                                              |
| `collections` | Every collection, by name.                                                         |

A layout can also call any include function and any built-in helper, and it sees the variables a page's sidecar script sets.
A [sidecar script](@/guide/sidecars.md) is a `.rhai` file next to a page, with the same name, that runs before the page's blocks and whose top-level variables the page can use.

The output of a `{{ }}` block is escaped as HTML, so `{{ page.title }}` is safe to use in text and attributes.
`content` is already HTML, so Reuben doesn't escape it.
To output HTML you built yourself, wrap it in the `raw()` helper.

The layout is also where you add the `<main>` landmark, the `lang` attribute, and a `<title>`.
Reuben's accessibility checks look for them in the built page, as the rules `main-landmark`, `html-lang`, and `page-title`.

## Write an include

An [include](@/guide/includes.md) is a Rhai file in `includes/` that defines functions.
Reuben loads every `.rhai` file directly in the folder, not in subfolders, before it renders any page.
Any layout or page can then call the functions.

This is `theme/includes/footer.rhai`, which defines the `footer()` function that the layout above calls:

```rhai
fn footer() {
    raw("<footer>Theme footer</footer>")
}
```

## Add static files

Put files that belong in the output as they are in `static/`.
`theme/static/style.css` becomes `/style.css` in the built site, and the layout above links to it.
Reuben keeps the folder structure, so `theme/static/img/logo.svg` becomes `/img/logo.svg`.

Reuben runs every CSS file through the `[css]` settings in `reuben.toml`, so a theme stylesheet is minified by default:

```css
body{font-family:sans-serif}
```

[Configuration](@/configuration.md#css) lists the settings.

For highlighted code, set `highlight = true` in the `[markdown]` table of `reuben.toml`.
Then fenced code blocks in a known language build with `hl-` classes on their tokens.
Run `reuben css highlight` and save the output in your theme's `static/` folder to style those classes.
[Configuration](@/configuration.md#markdown) describes the setting, and [`reuben css highlight`](@/configuration.md#reuben-css-highlight) lists the built-in color themes.

## Build with the theme

Build the site as usual.
Installed with npm? [Run these with `npx` in front](@/quickstart.md#install-reuben), as in `npx reuben build`.

```sh
reuben build
```

For the theme above and a `content/index.md` that has the title `Home` and a heading, the built page is:

```html
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Home · Theme demo</title>
<link rel="stylesheet" href="/style.css">
</head>
<body>
<main>
<h1 id="hello">Hello</h1>
<p>A page wrapped by the theme.</p>

</main>
<footer>Theme footer</footer>
</body>
</html>
```

While you work on a theme, run `reuben serve`.
It watches the theme folder along with the site, so every change rebuilds the site and reloads the browser.

## Override the theme from your site

Your site's own files win over the theme's.
Each kind of file has its own rule.

| Kind     | Rule                                                                                                                      |
| -------- | ------------------------------------------------------------------------------------------------------------------------- |
| Layouts  | Reuben looks in the site's `layouts/` first and uses the theme's layout only when the site has none of that name.         |
| Includes | Reuben loads the theme's includes first and the site's after. A site function replaces a theme function with the same name and the same number of parameters. |
| Static   | A file in the site's `static/` replaces a theme file at the same path.                                                    |

To override one include, define a function with the same name and the same number of parameters in the site's `includes/` folder.
A site file with the same name as a theme file doesn't replace the theme file as a whole, and the theme file's other functions stay available.
This `includes/footer.rhai` replaces the theme's `footer()`:

```rhai
fn footer() {
    raw("<footer>Site footer</footer>")
}
```

To override a stylesheet, put a file at the same path in the site's `static/` folder.
A theme stylesheet that uses `@import` also looks in your site's `static/` folder first, so you can replace a partial without touching the rest.
A partial is a CSS file whose name starts with `_`, such as `_colors.css`, that other CSS files import and that Reuben never writes to the output.

To use a different layout for one page, add a layout to the site's `layouts/` folder and name it in the page's front matter.
With `layouts/wide.html` in the site, this page uses it instead of the theme's `default.html`:

```markdown
---
title: Wide
layout: wide
---

# Wide
```

Run `reuben explain` on any page to see which include won.
It lists each include function as `name/arity`, then its parameters, then the file and line that declare it:

```text
footer/0         ()                                                               includes/footer.rhai:1
```

Here `()` means that `footer` takes no parameters.

## When no layout exists

If neither the site nor the theme has a layout for a page, and the page doesn't name one, Reuben wraps the page in a plain built-in page shell.
The shell is semantic HTML with a `lang` attribute, a viewport tag, the page's `description` as a meta tag when it has one, a line of inline CSS, and a `<main>` landmark.
It has no JavaScript.
It adds the page's title as an `h1` unless the body already has its own.

## What Reuben doesn't read

Reuben 0.2.0 has no theme manifest.
It never reads a `theme.toml` file, so a `theme.toml` in a theme folder has no effect.
A theme's name, version, and license belong in the theme's own README.
