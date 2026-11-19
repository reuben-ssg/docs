---
title: Collections
weight: 5
description: Turn a top-level folder of pages into a sorted list and a tree that layouts can read.
---

A collection is a top-level folder of `content/` that holds at least one page.
Reuben gives every collection to every page and layout as `collections.<name>`, with its pages in order and its folder structure as a tree.
Use a collection to build a blog index, a list of recent posts or a sidebar.

[Configuration](@/configuration.md#collections) lists the settings a collection takes.
This page shows how to use the collection from a page.

## Make a collection

A folder directly under `content/` is a collection, and you don't have to declare it.
`content/posts/` is the collection `posts`.
Pages directly in `content/`, such as `index.md`, belong to no collection.

To change how a collection behaves, add a table for it in `reuben.toml`:

```toml
[collections.posts]
name = "blog"
sort = "-date"
layout = "post"
```

This renames the collection to `blog`, so scripts read `collections.blog`.
It sorts the pages by `date`, newest first, because the `-` in front of the field reverses the order.
It also gives every page in the folder the `post` [layout](@/guide/layouts.md).

## Read a collection

Take this site, which has four pages in `content/posts/`:

```text
content/
├── index.md
└── posts/
    ├── archive/
    │   └── old.md
    ├── first.md
    ├── index.md
    └── second.md
```

The three posts have a `title` and a `date`.
`second.md` also has a `description`.
`content/posts/index.md` lists them:

```markdown
---
title: Blog
---
{%
let items = "";
for post in collections.blog {
    if post.path != page.path {
        items += `- [${post.title}](${post.url}), ${post.date}: ${post.summary}` + "\n";
    }
}
%}

{{ markdown(items) }}

The newest post is {{ collections.blog[0].title }}.
The oldest is {{ collections.blog.sort_by("date")[0].title }}.
```

The setup block loops over the collection, skips the index page itself, and builds a Markdown list.
`markdown()` turns the list into HTML.
Reuben builds this HTML for the page:

```html
<ul>
<li><a href="/posts/second/">Second post</a>, 2024-03-01: A short summary.</li>
<li><a href="/posts/first/">First post</a>, 2024-01-05: The first body paragraph.</li>
<li><a href="/posts/archive/old/">Old post</a>, 2023-06-01: An old paragraph.</li>
</ul>
<p>The newest post is Second post.
The oldest is Old post.</p>
```

The newest post comes first because of `sort = "-date"`.
The `sort_by("date")` call in the last line makes a second, oldest-first list without changing the collection.

## What a collection holds

A collection works like a list of pages, and it has a few extras:

| Use                                  | What it gives                                                     |
| ------------------------------------ | ----------------------------------------------------------------- |
| `collections.blog.len()`             | The number of pages.                                              |
| `collections.blog[0]`                | One page, by position. An index past the end is an error.         |
| `for post in collections.blog { }`   | Each page in order.                                               |
| `collections.blog.pages`             | The pages as a list.                                              |
| `collections.blog.tree`              | The folder structure as nested maps. See below.                   |

A collection also has three methods, and each gives a list:

- `.sort_by("field")` gives the pages sorted by a field.
  Put `-` before the name to reverse the order.
- `.filter(|p| test)` gives the pages for which the test is `true`.
  The test must return `true` or `false`.
- `.map(|p| value)` gives one value for each page, such as `p.title`.

Each page in `.pages` is a map of the page's fields:

| Field         | What it holds                                                                  |
| ------------- | ------------------------------------------------------------------------------ |
| `title`       | The title from the front matter.                                               |
| `description` | The description, or `()` when the page has none.                               |
| `summary`     | The description, or else the plain text of the first paragraph.                |
| `date`        | The date as text, or `()` when the page has none.                              |
| `weight`      | The weight, or `()` when the page has none.                                    |
| `layout`      | The layout name from the front matter, or `()`.                                |
| `draft`       | `true` for a draft page built with `--drafts`, and `false` otherwise.          |
| `url`         | The page's URL, such as `/posts/first/`.                                       |
| `path`        | The source path under `content/`, such as `posts/first.md`.                    |
| `slug`        | The last part of the URL.                                                      |
| `collection`  | The collection's name.                                                         |
| `toc`         | The page's headings.                                                           |

Any other front matter field, such as `tags`, is in the map too.
A collection holds the pages that are in the build, so a draft page isn't in any collection unless you build with `--drafts`.
Pages that aren't Markdown, such as `.html` templates, join a collection too, but other templates, such as an `.xml` feed, don't.

## Sort a collection

The `sort` setting names a page field.
Reuben orders the pages by that field, and by path when two pages tie.
These rules apply to `sort` and to `.sort_by()`:

- Numbers sort before text, and text sorts before missing values, whichever direction you sort in.
- A `date` is text, so `2024-03-01` sorts correctly because the year comes first.
- A page that doesn't have the field comes last.

A guide such as this one uses `weight` for its order.
Each page sets `weight: 1`, `weight: 2` and so on, and the collection sets `sort = "weight"`:

```toml
[collections.guide]
sort = "weight"
```

## Use the tree

`collections.blog.tree` is the folder structure, starting at the collection's own folder.
Each node is a map with a `title`, a `url`, a `path`, `is_dir` and a list of `children`.
The tree is sorted by the same `sort` setting as the collection.

A folder that has an `index.md` takes its title and URL from that page.
A folder without one has the folder's name as its `title` and an empty `url`.
The `archive` folder in the example has no `index.md`, so its node has the title `archive` and an empty `url`.

This include turns a node's children into nested lists:

```rhai
// Turns the `children` of a collection's tree into nested lists.
fn outline(children) {
    if children.len() == 0 {
        return "";
    }
    let html = "<ul>";
    for node in children {
        html += `<li>${escape(node.title)}${outline(node.children)}</li>`;
    }
    html + "</ul>"
}
```

The [include](@/guide/includes.md) calls itself for each folder.
A page outputs its result with `raw()`:

```markdown
{{ raw(outline(collections.blog.tree.children)) }}
```

```html
<ul><li>Second post</li><li>First post</li><li>archive<ul><li>Old post</li></ul></li></ul>
```

The sidebar on this page is built from a tree like this one.

## Errors

Two collections can't share a name.
If you rename a collection to a name that another one has, Reuben reports this error:

```text
error: reuben.toml: config: two collections are named "blog"; rename one under [collections.<folder>]
```

A `filter` test that doesn't return `true` or `false` is an error, and so is an index past the end of a collection:

```text
error: Runtime error: index 9 is out of range for a collection of 1
  --> content/posts/a.md:4:21
  |
4 | {{ collections.posts[9] }}
  |                     ^
error: Runtime error: filter: the function must return true or false, not i64
  --> content/posts/a.md:6:22
  |
6 | {{ collections.posts.filter(|p| 1) }}
  |                      ^
```

[`reuben explain`](@/guide/explain.md) shows each collection a page can read, with its page count:

```text
page.collection   "blog"                                                           computed
collections.blog  4 pages                                                          collection blog
```
