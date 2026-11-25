---
title: Sidecar scripts
weight: 2
description: Run a Rhai script before a page and give the page the variables it creates.
---

A sidecar script is a `.rhai` file that sits next to a page and has the same name.
Reuben runs it before it runs the page's blocks, and every top-level variable the script creates becomes available to the page and to its layout.

Use a sidecar when a page needs more than a one-line expression.
Sorting data, building a list, and picking a value all fit better in a script than in a block.

## Add a sidecar

Name the script after the page, with the extension `.rhai`.
`content/resume.md` gets the sidecar `content/resume.rhai`, and `content/guide/index.md` gets `content/guide/index.rhai`.
Reuben picks the script up when the file exists, so there is nothing to configure.

Suppose `data/jobs.json` holds this list:

```json
[
  { "name": "Line cook", "year": 2019 },
  { "name": "Pastry chef", "year": 2022 }
]
```

This sidecar, `content/resume.rhai`, sorts the jobs newest first, picks the latest one, and builds a Markdown list:

```rhai
let jobs = data.jobs.sort_by("-year");
let latest = jobs[0];

let list = "";
for job in jobs {
    list += `- ${job.name}, ${job.year}` + "\n";
}
let job_list = markdown(list);
```

The page, `content/resume.md`, uses the variables:

```markdown
---
title: Resume
---
I have held {{ jobs.len() }} jobs, most recently as {{ latest.name }}.

{{ job_list }}
```

Reuben builds `dist/resume/index.html`, and its `<main>` holds:

```html
<h1>Resume</h1>
<p>I have held 2 jobs, most recently as Pastry chef.</p>
<ul>
<li>Pastry chef, 2022</li>
<li>Line cook, 2019</li>
</ul>
```

The script reads `data.jobs` because every file in `data/` is available as `data`, as [Data](@/guide/data.md) explains.
It builds the list with a [template string](https://rhai.rs/book/), which is text between backticks that can hold `${ }` expressions.
Then it calls `markdown()`, which turns the Markdown list into HTML.
The page outputs that HTML as it is.

## What a sidecar can use

A sidecar sees the same names as a page's blocks:

- `page`, `site`, `data`, and `collections`, which are fixed for the script, so it can read them but not change them.
- Every function from [Includes](@/guide/includes.md), and the built-in helpers listed in [Rhai blocks](@/guide/rhai-blocks.md#what-a-block-can-use).

A sidecar has no output of its own.
It runs for its variables, and a value it computes but doesn't store in a variable goes nowhere.

## Where the variables go

Every variable a sidecar creates at the top level is visible to:

- Every block on the page, as `latest` and `job_list` are above.
- The page's layout, so a layout can print `{{ latest.name }}` too.

A variable inside a loop body or a function stays local to it.
Variables from setup blocks join the same set, so a variable from `{% let x = 1; %}` is visible to later blocks and to the layout.

## Which pages have a sidecar

Markdown pages and `.html` templates in `content/` can have a sidecar.
Reuben doesn't publish the `.rhai` file itself.
For the example above, `dist/` holds `resume/index.html` and no `resume.rhai`.

## Errors

A sidecar error names the script's own file, line, and column:

```text
error: Array index 5 out of bounds: only 2 elements in array
  --> content/broken.rhai:2:18
  |
2 | let third = jobs[5];
  |                  ^
Found 1 error in 1 file
```

A syntax error or a failing call is reported the same way.
[`reuben explain`](@/guide/explain.md) lists every variable a sidecar set, with the line that set it.
Here are the sidecar rows for the example above.
A value that is HTML, such as `job_list`, shows as its type, `reuben_core::script::Html`.

```text
jobs             [2 items]                                                        content/resume.rhai:1
latest           #{"name": "Pastry chef", "year": 2022}                           content/resume.rhai:2
list             "- Pastry chef, 2022\n- Line cook, 2019\n"                       content/resume.rhai:4
job_list         reuben_core::script::Html                                        content/resume.rhai:8
```
