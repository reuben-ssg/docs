---
title: Page links
weight: 7
description: Link to a page by its source file, so links keep working when a page moves.
---

Link to a page by naming its source file, and Reuben writes the page's real URL into the built site.
Links then keep working when a page moves or its URL changes, and Reuben reports every link that doesn't resolve.

## Write a source link

Use a normal Markdown link, and put a path to a `.md` file where the URL goes:

```markdown
Refer to the [scope guide](@/writing-guide/style/scope.md#assumptions).
```

Reuben builds that into `<a href="/writing-guide/style/scope/#assumptions">`.

There are two forms:

- `@/path.md` starts at `content/`, so `@/writing-guide/style/scope.md` always means that file.
- A relative path such as `scope.md`, `./scope.md`, or `../style/scope.md` starts at the folder of the page that contains the link.

A destination is a source link when it starts with `@/`, or when it has no scheme, doesn't start with `/` or `#`, and its path ends in `.md`.
A fragment such as `#assumptions` or a query such as `?x=1` stays as you wrote it.
Any other link builds exactly as before.
A link that starts with `/` is a plain URL even if it ends in `.md`.

Raw HTML links aren't rewritten.
Use `url_for()`, which the next section describes, when you need a source link in HTML.

## See it build

This example site has a `base_url` of `https://example.test/sub/`.
`content/index.md` links to two pages, `content/guide/intro.md` and `content/guide/next.md`:

```markdown
Read the [introduction](@/guide/intro.md) or jump to its [setup section](@/guide/intro.md#setup).

A relative link works too: visit [the next page](guide/next.md).

A link with a query keeps it: [search](@/guide/intro.md?q=1).
```

`content/guide/intro.md` has a `## Setup` heading and links back with relative paths:

```markdown
---
title: Introduction
---
## Setup

Go on to [the next page](next.md) or back [home](../index.md).
```

The built `index.html` holds:

```html
<p>Read the <a href="/sub/guide/intro/">introduction</a> or jump to its <a href="/sub/guide/intro/#setup">setup section</a>.</p>
<p>A relative link works too: visit <a href="/sub/guide/next/">the next page</a>.</p>
<p>A link with a query keeps it: <a href="/sub/guide/intro/?q=1">search</a>.</p>
```

The built `guide/intro/index.html` holds:

```html
<h2 id="setup">Setup</h2>
<p>Go on to <a href="/sub/guide/next/">the next page</a> or back <a href="/sub/">home</a>.</p>
```

A Markdown link gets only the base path, such as `/sub/`, so the built site stays portable between hosts.

## Link from a layout or an include

A layout, an include, or a block can't use Markdown link syntax, so call `url_for()` instead.
It takes the same forms, which is how you link from outside Markdown, such as a navigation bar:

```html
<a href="{{ url_for("@/portfolio/index.md") }}">Portfolio</a>
```

`url_for()` joins the full `base_url`, so the result also works in feeds.
With the `base_url` above, `url_for("@/guide/next.md")` gives `https://example.test/sub/guide/next/`.
A path that isn't a source link, such as `url_for("/style.css")`, is joined to `base_url` as it is.

A relative path in `url_for()` resolves against the page being built, including inside an include or layout that the page uses.
Use `@/` in includes and layouts that several folders share.
A relative path in the output of `markdown()` resolves the same way.

Outside a page being built, such as in a `data/` file, `url_for()` and `markdown()` can't resolve a source link, so a source link there is an error.

## What Reuben checks

Reuben resolves every source link on every build, and it reports every link that can't be resolved.
These are errors, not accessibility findings, so `a11y.disable` doesn't switch them off.

Here is a page with six bad links:

```markdown
1. A missing page: [intro](@/guide/intro-page.md).

2. Near miss: [index](@/_index.md).

3. A draft: [secret](@/secret.md).

4. Outside content: [out](../../x.md).

5. Not Markdown: [file](@/notes.txt).

6. A missing id: [section](@/about.md#nope).
```

The build fails with all six errors at once:

```text
error: no page `guide/intro-page.md`
  --> content/index.md:4:20
  |
4 | 1. A missing page: [intro](@/guide/intro-page.md).
  |                    ^
error: no page `_index.md`; did you mean `index.md`?
  --> content/index.md:6:15
  |
6 | 2. Near miss: [index](@/_index.md).
  |               ^
error: links to `secret.md`, a draft that isn't built without --drafts
  --> content/index.md:8:13
  |
8 | 3. A draft: [secret](@/secret.md).
  |             ^
error: link `../../x.md` points outside content/
   --> content/index.md:10:21
   |
10 | 4. Outside content: [out](../../x.md).
   |                     ^
error: link `@/notes.txt` must name a .md file
   --> content/index.md:12:18
   |
12 | 5. Not Markdown: [file](@/notes.txt).
   |                  ^
error: links to `#nope` on `about.md`, which has no such id
   --> content/index.md:14:18
   |
14 | 6. A missing id: [section](@/about.md#nope).
   |                  ^
Found 6 errors in 1 file
```

Each message has one cause:

| Message                                                 | Cause                                                              |
| ------------------------------------------------------- | ------------------------------------------------------------------ |
| ``no page `x.md` ``                                     | No such file under `content/`, with a suggestion when one is near. |
| ``links to `x.md`, a draft that isn't built ...``       | The target is a draft and the build isn't using `--drafts`.        |
| ``link `../../x.md` points outside content/``           | The path climbs above `content/`.                                  |
| ``link `@/x.txt` must name a .md file``                 | An `@/` link to something that isn't Markdown.                     |
| ``links to `#id` on `x.md`, which has no such id``      | The target page's built HTML has no element with that id.          |

There is no `_index.md` alias, so link to `index.md`.

The fragment check covers only the Markdown of a page.
It doesn't cover `url_for()` results or links inside `markdown()` output, because that text can land anywhere on the page.
A `markdown()` link is still resolved, and a missing file there is an error, but its `#fragment` isn't checked.

Reuben also checks the built HTML for links that point at nothing, with the `link-target` accessibility rule.
That rule covers links you wrote as plain URLs, such as `/about/`.
Refer to [Accessibility checks](@/guide/checks.md).
