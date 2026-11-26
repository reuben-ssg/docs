---
title: Quickstart
description: Install Reuben, preview and build a two-page site, and check it.
---

This page takes you from an empty folder to a previewed, built, and checked two-page site.
You need a terminal and a text editor.
You don't need to know Rust or Rhai.

## Install Reuben

Pick one of the routes below.
The npm route adds Reuben to a single site project.
The other routes install the `reuben` command for your whole machine.

### With npm

The npm route needs Node.js 14.18 or later.
It adds Reuben to your site's folder, so you run its two commands in [Create the site](#create-the-site), after you make the folder.

The package installs the prebuilt `reuben` command.
This page, and the rest of the docs, write each command as plain `reuben`.
If you installed Reuben with npm, put `npx` in front of each command, such as `npx reuben serve`.
`npm run` scripts work too.

### With Cargo

`cargo install` compiles Reuben from source, so it needs Rust 1.100 or later:

```sh
cargo install reuben
```

If `cargo install` says your Rust is too old, run `rustup update` and try again.

With this route, and with the installers below, you run `reuben` directly.

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

If you chose npm, run this in your site folder after the next section's npm commands, as `npx reuben --version`.
Otherwise, print the version to confirm the command runs:

```sh
reuben --version
```

It prints `reuben` and the version number, which for this release is {{ data.release.version }}.

## Create the site

A Reuben site is a folder with a `reuben.toml` file and a `content/` folder of pages.
Make the site folder, whichever route you chose, and move into it:

```sh
mkdir my-site
cd my-site
```

If you installed with npm, create a `package.json` and add Reuben as a dev dependency inside the folder:

```sh
npm init -y
npm install --save-dev @reuben-ssg/reuben
```

Then make these three files in your site folder.

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
[Page links](@/guide/linking.md) describes every form of source link.

With the npm route, your folder now looks like this, with `node_modules/` left out:

```text
my-site/
├── content/
│   ├── about.md
│   └── index.md
├── package.json
└── reuben.toml
```

## Preview the site

Start the preview server:

```sh
reuben serve
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

Pick another port with `--port`, such as `reuben serve --port 4321`.
Press Ctrl+C to stop the server.

The preview writes nothing to disk, so the next section builds the site into files.

## Build the site

With the preview stopped, build the site into the `dist/` folder:

```sh
reuben build
```

Reuben prints a summary:

```text
Built 2 pages, copied 0 static files in 23ms
```

The time differs on your machine.

Reuben writes no `sitemap.xml` unless you ask for one.
When you know where the site will live, add `base_url = "https://example.com/"` and `sitemap = true` to `reuben.toml`.
The [sitemap](@/configuration.md#sitemap) section of the configuration reference has the details.

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
To change that, check out [Theming](@/theming.md).

## Check the site

Check the site without writing anything:

```sh
reuben check
```

When the site is fine, Reuben prints:

```text
No problems found in 2 pages
```

Now break a link on purpose.
In `content/index.md`, change `@/about.md` to `@/abuot.md`, and run the check again:

```text
error: no page `abuot.md`; did you mean `about.md`?
  --> content/index.md:8:6
  |
8 | Read [about this site](@/abuot.md).
  |      ^
Found 1 error in 1 file
```

Reuben names the file, the line, and a likely fix.
When a site has several errors, Reuben reports all of them in one run.
Change the link back before you go on.

`reuben check` also reports [accessibility findings](@/guide/checks.md), such as a heading that skips a level.
It exits with status 0 only when it finds no errors and no findings, so you can use it in a CI job.

## Learn more

- The [Feature guide](@/guide/index.md) explains Rhai blocks, sidecar scripts, includes, data, collections, layouts, linking, and checks, each with an example.
- [Explain a page](@/guide/explain.md) shows how `reuben explain` lists every name a page can use and where each value came from.
- [Configuration](@/configuration.md) lists every `reuben.toml` key, every front matter field, and every command with its flags.
- [Theming](@/theming.md) explains how to give the site its own layouts, includes, and static files.
