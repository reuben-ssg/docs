---
title: Quickstart
description: Install Reuben, build a two-page site, preview it, and check it.
---

This page takes you from an empty folder to a built, previewed, and checked two-page site.
You need a terminal and a text editor.
You don't need to know Rust or Rhai.

## Install Reuben

Pick one of the routes below.
The npm route adds Reuben to a single site project.
The other routes install the `reuben` command for your whole machine.

### With npm

The npm route needs Node.js 14.18 or later.
In a new folder for your site, create a `package.json` and add Reuben as a dev dependency:

```sh
mkdir my-site
cd my-site
npm init -y
npm install --save-dev @reuben-ssg/reuben
```

The package installs the prebuilt `reuben` command, so you run it with `npx reuben`.
The rest of this page writes `npx reuben` in front of every command.

### With Cargo

`cargo install` compiles Reuben from source, so it needs Rust 1.85 or later:

```sh
cargo install reuben
```

With this route, and with the installers below, you run `reuben` directly.
Drop `npx` from the commands on this page.

### With the shell installer

On macOS and Linux, run the installer script from the latest GitHub release:

```sh
curl --proto '=https' --tlsv1.2 -LsSf https://github.com/reuben-ssg/reuben/releases/latest/download/reuben-installer.sh | sh
```

### With the PowerShell installer

On Windows, run the PowerShell installer from the same release:

```powershell
powershell -ExecutionPolicy Bypass -c "irm https://github.com/reuben-ssg/reuben/releases/latest/download/reuben-installer.ps1 | iex"
```

### Check the install

Print the version to confirm the command runs:

```sh
npx reuben --version
```

It prints `reuben` and the version number, such as `reuben 0.1.1`.

## Create the site

A Reuben site is a folder with a `reuben.toml` file and a `content/` folder of pages.
Make these three files in your site folder.

`reuben.toml`:

```toml
title = "My site"
```

`content/index.md`:

```markdown
---
title: Home
---

# Welcome to {{ site.title }}

This page was built by Reuben.
Read [about this site](@/about.md).
```

`content/about.md`:

```markdown
---
title: About
---

# About

This is the about page.
Go back to the [home page](@/index.md).
```

Each page starts with front matter between two `---` lines.
Every page needs a `title`.

The `{{ site.title }}` in the home page is a [Rhai block](@/guide/rhai-blocks.md).
Reuben runs the expression when it builds the page and puts the result in its place.
Here the result is the `title` from `reuben.toml`.

A link that starts with `@/` names a page by its source file under `content/`.
Reuben writes the page's real URL into the built site.
If you rename or move the page, Reuben reports every link that no longer resolves.
[Linking to pages](@/guide/linking.md) describes every form of source link.

With the npm route, your folder now looks like this, with `node_modules/` left out:

```text
my-site/
├── content/
│   ├── about.md
│   └── index.md
├── package.json
└── reuben.toml
```

## Build the site

Build the site into the `dist/` folder:

```sh
npx reuben build
```

Reuben prints a summary:

```text
Built 2 pages, copied 0 static files in 1ms
warning: sitemap.xml skipped: base_url must be absolute (http:// or https://)
```

The time differs on your machine.

The warning is about the sitemap.
Reuben writes `sitemap.xml` only when `base_url` is an absolute URL.
Add a line such as `base_url = "https://example.com/"` to `reuben.toml` once you know where the site will live, and the warning goes away.

`dist/` now holds the built pages:

```text
dist/index.html
dist/about/index.html
```

Reuben also writes a `.reuben-output` file into `dist/`.
It marks the folder as Reuben's own, so a later build knows it can replace it.

Open `dist/index.html`.
The heading and the link are filled in:

```html
<h1 id="welcome-to-my-site">Welcome to My site</h1>
<p>This page was built by Reuben.
Read <a href="/about/">about this site</a>.</p>
```

The site has no layouts, so Reuben wraps each page in a plain built-in page shell.
To change that, see [Theming](@/theming.md).

## Preview the site

Start the preview server:

```sh
npx reuben serve
```

Reuben prints the address:

```text
Serving at http://127.0.0.1:1111
```

Open that address in your browser.
The server builds the site in memory and listens on `127.0.0.1` only, so other machines can't reach it.

Edit `content/about.md` and save.
Reuben rebuilds the site, prints a line like the following, and reloads the page in your browser:

```text
Rebuilt 2 pages in 1 ms
```

The server adds a small live-reload script to the pages it serves.
`reuben build` never adds it.

If another program already uses port 1111, Reuben prints this error:

```text
error: cannot listen on 127.0.0.1:1111: Address already in use (os error 48)
```

Pick another port with `--port`, such as `npx reuben serve --port 4321`.
Press Ctrl+C to stop the server.

## Check the site

Check the site without writing anything:

```sh
npx reuben check
```

When the site is fine, Reuben prints:

```text
No problems found in 2 pages
```

Now break a link on purpose.
In `content/index.md`, change `@/about.md` to `@/abuot.md`, and run the check again:

```text
error: no page `abuot.md`; did you mean `about.md`?
  --> content/index.md:7:6
  |
7 | Read [about this site](@/abuot.md).
  |      ^
Found 1 error in 1 file
```

Reuben names the file, the line, and a likely fix.
When a site has several errors, Reuben reports all of them in one run.
Change the link back before you go on.

`reuben check` also reports [accessibility findings](@/guide/checks.md), such as a heading that skips a level.
It exits with status 0 only when it finds no errors and no findings, so you can use it in a CI job.

## Next steps

- The [Feature guide](@/guide/index.md) explains Rhai blocks, sidecar scripts, includes, data, collections, layouts, linking, and checks, each with an example.
- [Explaining a page](@/guide/explain.md) shows how `reuben explain` lists every name a page can use and where each value came from.
- [Configuration](@/configuration.md) lists every `reuben.toml` key, every front matter field, and every command with its flags.
- [Theming](@/theming.md) explains how to give the site its own layouts, includes, and static files.
