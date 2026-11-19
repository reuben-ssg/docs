---
title: Accessibility checks
weight: 8
description: The 12 accessibility rules Reuben checks on every build, and how to switch each one off.
---

Every build checks each page for common accessibility problems.
Reuben runs five rules on the page's content before it becomes HTML, and seven on the final HTML of the built page.
A finding prints as a warning with the file and line that caused it, and findings never fail `reuben build`.

[Configuration](@/configuration.md#a11y) shows the `[a11y]` setting.
This page lists each rule and shows what one finding looks like.

## The rules

Each rule has an id.
You use the id in a finding and when you switch the rule off.

| Rule                | What it checks                                                     |
| ------------------- | ------------------------------------------------------------------ |
| `heading-order`     | Headings don't skip a level on the way down.                       |
| `link-text`         | Links have text that says where they go.                           |
| `img-alt`           | Images have an alt attribute, which may be empty for decoration.   |
| `heading-id-unique` | No two headings on a page share an id.                             |
| `table-header`      | Tables have a header row or column.                                |
| `html-lang`         | The html element declares a language.                              |
| `page-title`        | The page has a non-empty title.                                    |
| `single-h1`         | The page has exactly one h1.                                       |
| `main-landmark`     | The page has a main landmark.                                      |
| `id-unique`         | No two elements on a page share an id.                             |
| `form-label`        | Form controls have a label.                                        |
| `link-target`       | Internal links point at a page or file that is built.              |

The first five rules read the page's headings, links, images, and tables.
The last seven read the built HTML, including your layout, so a layout is where you fix `html-lang`, `page-title`, `single-h1`, and `main-landmark`.

Some rules have details you can rely on:

- `heading-order` lets the first heading in a page's content be a level 2, because the layout supplies the page's `<h1>`.
- `link-text` flags a link with no text, and a link whose text is only `click here`, `here`, `read more`, `more`, `learn more`, or `link`.
  Capital letters and trailing punctuation don't matter.
- `form-label` accepts a wrapping `<label>`, a `<label for>` that matches the control's `id`, and a non-blank `aria-label`, `aria-labelledby`, or `title`.
  It skips hidden, submit, reset, button, and image inputs, and disabled inputs.
- `main-landmark` accepts a `<main>` element or a `role="main"`.
- `link-target` checks links that point into your site, and it skips external links, `mailto:` links and links that are only a `#fragment`.

## See the findings

This page uses a bare layout that has no `lang`, no `<title>` text, and no `<main>`.
The layout is `layouts/bare.html`:

```html
<html>
<head><title></title></head>
<body>
{{ content }}
</body>
</html>
```

And this is `content/problems.md`, which breaks the other rules too:

```markdown
---
title: Problems
layout: bare
---
# First heading

# Second heading

### Skipped a level

[click here](/nowhere/)

<img src="/logo.png">

<h2 id="same">One</h2>

<h2 id="same">Two</h2>

<table><tr><td>cell</td></tr></table>

<input type="text" name="q">

<p id="dup">a</p>
<p id="dup">b</p>
```

The site also has a clean `content/index.md` that says "Fine.", so Reuben builds two pages.
`reuben build` prints a warning for each problem and still builds the site:

```text
Built 2 pages, copied 0 static files in 1ms
warning[html-lang]: the <html> element has no lang attribute
  --> content/problems.md (built as problems/index.html, line 1)
warning[page-title]: the page has no <title> text
  --> content/problems.md (built as problems/index.html, line 1)
warning[main-landmark]: the page has no <main> landmark
  --> content/problems.md (built as problems/index.html, line 1)
warning[single-h1]: found 2 <h1> elements, expected 1
  --> content/problems.md (built as problems/index.html, line 5)
warning[link-target]: links to `/nowhere/`, which isn't built
  --> content/problems.md (built as problems/index.html, line 7)
warning[form-label]: <input> has no label
  --> content/problems.md (built as problems/index.html, line 12)
warning[id-unique]: id "dup" is used more than once on this page
  --> content/problems.md (built as problems/index.html, line 14)
warning[heading-order]: heading level 3 skips level 2
  --> content/problems.md:9:1
  |
9 | ### Skipped a level
  | ^
warning[link-text]: link text "click here" doesn't say where the link goes
   --> content/problems.md:11:1
   |
11 | [click here](/nowhere/)
   | ^
warning[img-alt]: image has no alt text
   --> content/problems.md:13:1
   |
13 | <img src="/logo.png">
   | ^
warning[heading-id-unique]: heading id "same" is already used by an earlier heading
   --> content/problems.md:17:1
   |
17 | <h2 id="same">Two</h2>
   | ^
warning[table-header]: table has no header cells
   --> content/problems.md:19:1
   |
19 | <table><tr><td>cell</td></tr></table>
   | ^
12 accessibility warnings in 1 file
```

Each finding names its rule in brackets, so you know which id to switch off.
The first group points into the built HTML, with the output file and the line in it.
The second group points at your source, with the line and column.

## Check in CI

`reuben check` loads and renders the site the way `reuben build` does, but writes nothing.
It prints every error and every finding, then a summary line:

```text
Found 12 accessibility findings in 1 file
```

It exits with status 0 only when it finds no errors and no findings, and with status 1 otherwise.
That makes it a gate for a CI job:

```sh
npx reuben check
```

Add `--drafts` to check draft pages too.
Add `--env <name>` to check with `reuben.<name>.toml` merged in.
A site with nothing to report prints `No problems found in 1 page`.

## Switch rules off

List rule ids under `a11y.disable`.
You can do it at three levels.

For the whole site, put the table in `reuben.toml`:

```toml
[a11y]
disable = ["main-landmark", "html-lang"]
```

For every page in a folder and the folders below it, put the same table in that folder's `_dir.toml`:

```toml
[a11y]
disable = ["single-h1", "link-target"]
```

For one page, put it in the page's front matter:

```markdown
---
title: Gallery
a11y:
  disable: [img-alt]
---
```

Each level adds to the ones above it.
A page skips every rule switched off in `reuben.toml`, in any `_dir.toml` on its path and in its own front matter.
A rule that a higher level switched off can't be switched back on below it.

An id that isn't a rule is an error, reported against the file it is in:

```text
error: reuben.toml: config: unknown accessibility rule `bogus`
```

Switching rules off in all three places for the page above silences every finding.
The site switches off `html-lang`, `page-title`, and `main-landmark`.
The folder `content/legacy/` switches off `single-h1`, `link-target`, `form-label`, and `id-unique`.
The page `content/legacy/problems.md` switches off the other five in its front matter:

```markdown
---
title: Problems
layout: bare
a11y:
  disable: [heading-order, link-text, img-alt, heading-id-unique, table-header]
---
```

Then `reuben check` reports:

```text
No problems found in 1 page
```

Broken source links such as `@/missing.md` are errors, not findings, so `a11y.disable` doesn't switch them off.
See [Linking to pages](@/guide/linking.md).
