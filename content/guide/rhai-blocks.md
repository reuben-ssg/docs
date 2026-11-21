---
title: Rhai blocks
weight: 1
description: Put computed values into a page with output blocks and setup blocks.
---

A Rhai block is a piece of code inside a page.
Reuben runs it when it builds the page and puts the result in its place.
[Rhai](https://rhai.rs/book/) is the small scripting language Reuben uses.
You only need its expressions to start: numbers, text, lists, and field access such as `page.title`.
The Rhai book covers the whole language.

There are two kinds of block.

| Block              | What it does                                                         |
| ------------------ | -------------------------------------------------------------------- |
| `{{ expression }}` | An output block. Reuben replaces it with the value of the expression. |
| `{% statements %}` | A setup block. Reuben runs it and outputs nothing.                    |

## Output blocks

An output block holds one expression, and the page shows its value.
This page declares three tags in its front matter and prints them:

```markdown
---
title: Blocks demo
tags: [soup, sandwich, pickle]
---
{% let count = page.tags.len(); %}

{% let names = page.tags.map(|t| t.to_upper()); %}

The page "{{ page.title }}" has {{ count }} tags: {{ names }}.

Sum: {{ 6 * 7 }}.

{{ if count > 2 { "Many tags." } else { "Few tags." } }}
```

Reuben builds it into this HTML, and it turns the straight quotes in Markdown text into curly quotes:

```html
<p>The page “Blocks demo” has 3 tags: SOUPSANDWICHPICKLE.</p>
<p>Sum: 42.</p>
<p>Many tags.</p>
```

The list of names prints with nothing between the items, because Reuben outputs each item of a list in turn.
The last block shows that a block can hold more than a single value: here it holds an `if` expression.

Reuben finds the end of a block by reading the Rhai code in it, so a `}}` inside a string or a comment doesn't close the block early.
A block with no closing `}}` is an error.

## Setup blocks

A setup block runs statements, such as `let`, and outputs nothing.
Variables a setup block creates stay available to every later block on the page, and to the page's layout.

Put each setup block in its own paragraph, with a blank line before and after it.
A setup block that shares a paragraph with other text leaves that text's line break behind.

## What a block can output

Reuben turns the value of an output block into page content by its type:

| Value                                   | What Reuben outputs                                                           |
| --------------------------------------- | ----------------------------------------------------------------------------- |
| Text                                    | The text, with `<`, `>`, `&`, `"`, and `'` escaped. Reuben doesn't read it as Markdown. |
| A number, `true` or `false`, or a character | Its text.                                                                |
| The result of `raw()` or `markdown()`   | HTML, as it is.                                                               |
| A list                                  | Each item in turn, with nothing between them.                                 |
| `()`                                    | Nothing.                                                                      |
| A map                                   | An error, because Reuben can't tell which field you want.                     |

Text is escaped, so this block outputs the markup as visible characters:

```markdown
A string with markup: {{ "<b>bold</b> & **not bold**" }}.
```

```html
<p>A string with markup: &lt;b&gt;bold&lt;/b&gt; &amp; **not bold**.</p>
```

To output HTML you built yourself, wrap it in `raw()`:

```markdown
Raw HTML: {{ raw("<b>bold</b>") }}.
```

```html
<p>Raw HTML: <b>bold</b>.</p>
```

Use `raw()` only on markup you wrote.
It skips the escaping that protects the page from stray `<` and `&` characters.
To turn Markdown text into HTML, use the `markdown()` helper, which the [Sidecar scripts](@/guide/sidecars.md) page shows.

## What a block can use

Every block on a page can read these names:

| Name          | What it holds                                                          |
| ------------- | ---------------------------------------------------------------------- |
| `page`        | The page's front matter and its computed fields, such as `page.url`.  |
| `site`        | The site's `title`, `base_url`, and `params`.                           |
| `data`        | The files in `data/`. See [Data](@/guide/data.md).                     |
| `collections` | Every collection. See [Collections](@/guide/collections.md).           |

A block can also use the variables the page's [sidecar script](@/guide/sidecars.md) sets, every function from [Includes](@/guide/includes.md), and these built-in helpers:

| Helper                    | What it does                                                                 |
| ------------------------- | ---------------------------------------------------------------------------- |
| `raw(text)`               | Marks text as HTML, so Reuben doesn't escape it.                              |
| `escape(text)`            | Escapes `<`, `>`, `&`, and `"`, for text you put inside HTML you build by hand. |
| `markdown(text)`          | Renders Markdown text as HTML. It doesn't run `{{ }}` blocks inside the text. |
| `list.sort_by(field)`     | Sorts a list of maps, such as pages, by a field. Put `-` before the name to reverse it.      |
| `load_data(path)`         | Reads a `.json`, `.toml`, `.yaml`, or `.yml` file inside the site.             |
| `url_for(path)`           | Gives the URL of a page, from its source file. See [Linking to pages](@/guide/linking.md). |
| `format_date(date, format)` | Formats a date, such as `format_date(page.date, "%B %Y")`.                  |

## Show a block without running it

Reuben doesn't run blocks inside code.
A fenced code block, an indented code block, and inline code all stay as you wrote them.
That is how this page shows `{{ page.title }}` without printing a title.

Math stays as you wrote it only when you set `math = true` in the `[markdown]` table of `reuben.toml`.
With math off, which is the default, `$…$` is ordinary text, so a block inside it runs.

Everywhere else, including raw HTML in the page, Reuben runs the block.
To show a literal `{{` in running text, output it from a block:

```markdown
A literal pair of braces: {{ "{{" }} and {{ "}}" }}.
```

```html
<p>A literal pair of braces: {{ and }}.</p>
```

A lone `}}` outside a block is plain text, so only the opening `{{` and `{%` need this escape.

## Errors

A block that fails is an error at the block's file, line, and column.
Reuben reports every failing block in one run:

```text
error: can't output a map; output one of its fields
  --> content/index.md:9:3
  |
9 | {{ #{ a: 1 } }}
  |   ^
error: Variable not found: undefined_name
   --> content/index.md:11:4
   |
11 | {{ undefined_name + 1 }}
   |    ^
error: Script is incomplete
   --> content/index.md:13:8
   |
13 | {{ 1 + }}
   |        ^
Found 3 errors in 1 file
```

A field that doesn't exist on a map is not an error.
`{{ page.titel }}` outputs nothing, because a missing field is `()`.
If a block prints nothing, run [`reuben explain`](@/guide/explain.md) to see which names the page has.

Two limits keep a script from hanging a build.
Reuben stops a block that does too much work, and it disables `eval`:

```text
error: Too many operations
error: reserved keyword 'eval' is disabled
```

A script can print to the terminal while it runs.
`print("hello")` writes the page's path and the text to Reuben's output, and it adds nothing to the page:

```text
./content/index.md: hello from print
```
