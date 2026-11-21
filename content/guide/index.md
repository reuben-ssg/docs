---
title: Feature guide
nav_title: Guide
description: How Reuben's features work, with a short example you can build for each one.
---

This guide explains what Reuben does beyond turning Markdown into HTML.
Each page covers one feature, with an example you can build yourself.
The examples use Rhai, a small scripting language, which the [Rhai book](https://rhai.rs/book/) documents in full.
Every example on these pages was built with Reuben 0.2.0, and the output shown is what Reuben printed.

If you haven't built a site yet, start with the [Quickstart](@/quickstart.md).
For the full list of settings and commands, see [Configuration](@/configuration.md).

## The pages

The pages build on each other, so read them in this order the first time:

1. [Rhai blocks](@/guide/rhai-blocks.md) put computed values into a page with `{{ }}` and `{% %}`.
2. [Sidecar scripts](@/guide/sidecars.md) run a script before a page and hand it variables.
3. [Includes](@/guide/includes.md) define functions that every page and layout can call.
4. [Data](@/guide/data.md) loads JSON, TOML, YAML, and Rhai files into the `data` value.
5. [Collections](@/guide/collections.md) turn a folder of pages into a sorted list and a tree.
6. [Layouts](@/guide/layouts.md) wrap each page in HTML and decide which layout a page gets.
7. [Linking to pages](@/guide/linking.md) names a page by its source file, so links survive a move.
8. [Accessibility checks](@/guide/checks.md) warn about common accessibility problems on every build.
9. [Explaining a page](@/guide/explain.md) shows every name a page can use and the file that set it.
