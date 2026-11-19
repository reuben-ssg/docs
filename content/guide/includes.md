---
title: Includes
weight: 3
description: Write a Rhai function once and call it from any page or layout.
---

An include is a Rhai file in `includes/` that defines functions.
Reuben loads every include before it builds any page, so every page, sidecar script, and layout can call the functions.

Use an include for markup you repeat, such as a card, a button, or a note.

## Write an include

Put a `.rhai` file directly in `includes/`.
Reuben reads every `.rhai` file in that folder, and none in its subfolders.
The file's name doesn't matter, because a function is called by its own name.

This include, `includes/card.rhai`, defines two functions, and the second calls the first:

```rhai
// A link styled as a card.
fn card(title, url) {
    raw(`<a class="card" href="${escape(url)}">${escape(title)}</a>`)
}

// Calls a function from this file.
fn card_row(cards) {
    let html = "";
    for c in cards {
        html += card(c.title, c.url).to_string();
    }
    raw(`<div class="row">${html}</div>`)
}
```

As in any [Rhai](https://rhai.rs/book/) function, the value of the last expression is the return value.
Both functions return `raw(...)`, which marks the text as HTML so Reuben doesn't escape it when the page outputs it.
Each one escapes its own inputs with `escape()` first, because an include is where a stray `&` or `<` in a title would otherwise reach the page.

A second include, `includes/note.rhai`, renders Markdown inside an HTML wrapper:

```rhai
fn note(text) {
    raw(`<aside class="note">${markdown(text).to_string()}</aside>`)
}

// An include can't see the page's variables, so pass them in.
fn page_note(page) {
    note("This page is **" + page.title + "**.")
}
```

## Call an include

Call a function from any block:

```markdown
---
title: Includes demo
---
{{ card("About", "/about/") }}

{{ card_row([#{ title: "Home & away", url: "/" }, #{ title: "About", url: "/about/" }]) }}

{{ note("Remember to *check* the build.") }}

{{ page_note(page) }}
```

Reuben builds that into this HTML:

```html
<a class="card" href="/about/">About</a>
<div class="row"><a class="card" href="/">Home &amp; away</a><a class="card" href="/about/">About</a></div>
<aside class="note"><p>Remember to <em>check</em> the build.</p>
</aside>
<aside class="note"><p>This page is <strong>Includes demo</strong>.</p>
</aside>
```

A layout calls the same functions, and so does a sidecar script and every other include.
Files load in sorted order, but order doesn't matter, because Reuben compiles every file before it runs any function.

## What an include can see

A function can read only its parameters, the built-in helpers, and other include functions.
It can't read `page`, `site`, `data`, or `collections`, and it can't read a page's variables.
Pass what the function needs, as `page_note(page)` does above.

## Override an include from a theme

A [theme](@/theming.md) can have its own `includes/` folder.
Reuben loads the theme's includes first and the site's includes after them.
A function in the site replaces a theme function that has the same name and the same number of parameters.
[Theming](@/theming.md#override-the-theme-from-your-site) shows an example.

## Errors

A syntax error in an include names the include file and the line.
A runtime error names the call in the page and the include it happened in.
This include reads `page`, which a function can't see:

```rhai
fn title_of_page() {
    page.title
}
```

A page that calls `title_of_page()` gets this error:

```text
error: Variable not found: page (line 2, position 5)
  --> content/index.md:4:4
  |
4 | {{ title_of_page() }}
  |    ^
  = in include `title_of_page` (includes/bad.rhai:2:5)
```

Two functions that call each other forever, or a function that calls itself, stop at a depth of 32 calls:

```text
error: include call depth limit (32) exceeded; an include probably calls itself
  --> content/index.md:6:4
  |
6 | {{ ping(0) }}
  |    ^
```

[`reuben explain`](@/guide/explain.md) lists every include function a page can call, as `name/arity`, with its parameters and the line that defines it:

```text
card/2           (title, url)                                                     includes/card.rhai:2
card_row/1       (cards)                                                          includes/card.rhai:7
note/1           (text)                                                           includes/note.rhai:1
page_note/1      (page)                                                           includes/note.rhai:6
```
