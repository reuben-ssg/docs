---
title: Why?
description: A brief explanatory document of the motivations behind Reuben.
---

**TL;DR:** This is a craft project, written in a language that I love.
I'm not trying to prove anything to anyone.

One question, in its most distilled form, you might ask is this: why?

- Why build another static site generator (SSG) when [Jamstack lists hundreds of them available](https://jamstack.org/generators/), including arguably better SSGs?
- Why Rhai over something universal like JavaScript?
- Why call it Reuben?
- Why the cutesy theme?
- Why set the earth on fire in the process?

All of these are completely valid questions.
Reuben isn't trying to be the next [Next.js](https://nextjs.org/) or [Jekyll](https://jekyllrb.com/).
If it's not used beyond this website, then I'm fine with that.

## A love letter to Jekyll

My first entry into the world of Git/GitHub was in 2015, where I was working on a previous company's Jekyll documentation site.
I understood HTML in principle, but working with it in Jekyll on a regular basis overwhelmed me as a novice web developer.
After taking some time to really understand the product (even though I still had no Ruby experience), I fiddled around with Jekyll enough and read enough documentation to write my first index page, entirely in Liquid, built to loop over pages in a collection instead of a hardcoded Markdown list of pages.
No more merge conflicts with multiple editors on the same page.
It was pure bliss.

Since then, I've worked on a few bodies of documentation, each using different SSGs, each with their own quirks.
Jekyll will always have a soft spot in my heart, and it has rightfully earned its place in the Jamstack among the more popular SSGs.
For me personally, Ruby was never my favorite language in which to code.
Rust, however, was.

As complicated a relationship I, and probably many others, have with AI, it has admittedly unlocked so many ideas for me, both in a personal and a professional context.
That complicated relationship includes the earlier "earth on fire" question.
AI's energy use is real, and I don't take it lightly.

I treat Reuben as everything I wanted in Jekyll, rewritten and reimagined in Rust, created with AI assistance.
While the words on this page are my own, AI helped me turn an idea that was several years in the making that would have been several months of work into just a few weeks of prompting.
With Reuben, I feel I have achieved _my_ perfect static site generator, or at least the first phase of evolution toward such.

## Beyond a templating language

[Liquid](https://shopify.github.io/liquid/), like other templating languages, is critical for an SSG to do what it's supposed to do: generate static sites.
The need to pre-build content before it reaches the web cannot be overstated.
Many other templating languages—including [PHP](https://www.php.net/), [Jinja](https://jinja.palletsprojects.com/en/stable/), and [Tera](https://keats.github.io/tera/)—exist for similar purposes, although PHP usually runs on a server for every visit rather than once at build time.
So why "reinvent the wheel" here?

I wanted a real scripting language directly in the page.
Shopify built Liquid for the express purpose of giving untrusted store owners a safe way to generate website content.
As great as Liquid is, its design is limited, for good reason.
With [Rhai](https://rhai.rs) (pronounced like rye, the bread), Reuben gets an entire scripting language, and Rhai is what makes Reuben so delicious (I'm sorry).

## Reuben for static sites

Today, JavaScript is what primarily runs the web.
It also exists for good reason, and Reuben doesn't claim to be replacing it.
However, JavaScript comes with its own drawbacks for a static website:

- JavaScript invites dependency trees, supply-chain risks, version churn, and (eventually) a bundler.
  All of this is maintenance overhead for you as a web developer and is often more than what you may need.
- Page footprints with JavaScript are larger than static pages, often by dozens of kilobytes.
  [Starlight's doc on environmental impact](https://starlight.astro.build/environmental-impact/) does an excellent job of explaining the consequences of under-performing web pages.
- Search the web for `JavaScript vulnerabilities`, and you'll get a plethora of reasons why shipping third-party code you haven't vetted to your readers is risky.

Reuben avoids these concerns entirely by default, and adds some much needed (in my opinion) functionality to a static site:

- Reuben is written in Rust, and its own code uses no `unsafe` code.
  While Rust doesn't fix everything (and you can still do a lot of bad stuff with Rust), I chose Rust years ago as my language of choice because of the strictness of the compiler.
- Reuben is one binary (or one `npm` package that installs it).
  No Node runtime (unless you install through `npm`, which runs Reuben through a small Node wrapper), no bundler, no hydration on pages, and you save hundreds of MB of `node_modules`.
- Reuben has quality checks built in, and troubleshooting errors is much quicker.
  Often, I'll find SSGs will halt at the first error, so you go to fix that error only to get another error, and so on.
  One build in Reuben gives you the complete list of issues once, so you can spend less time troubleshooting and more time building.
- The Rhai scripts that Reuben runs can't:
  - **Use the network.**
    No network functions exist for scripts.
  - **Run arbitrary programs on your computer.**
    Scripts cannot start a process or a shell command.
  - **Load other script files.**
    Rhai's `import` functionality is explicitly blocked.
  - **Build and run code from text.**
    `eval` is turned off for security reasons.
  - **Touch the file system freely.**
    Rhai is only allowed to parse data files within your site and refuses any non-data files and any files outside of your site.
  - **Run forever and eat all your memory.**
    Rhai has hard limits on execution, which will be explained in an upcoming doc.

## Why the name and the theme

A Reuben is a deli sandwich on rye, and Rhai is pronounced "rye", so the base layer was named before anything else.
The deli theme follows from the name: Mustard yellow, Magenta, an awning, and a sandwich that opens when you hover over it.

## Honest tradeoffs

I believe Reuben is more than snake oil, but I must disclaim where Reuben falls short.

- Rhai is not well-known compared to JavaScript.
- No mixed rendering or server-side rendering is available today.
- The planned MDX add-on would bring interactive components, but it would also need Node and ship JavaScript, which works against Reuben's defaults.
- Reuben _itself_ isn't sandboxed.
  The sandbox is around the Rhai scripts it runs.
- Reuben protects the build machine, not necessarily your readers.
  Anyone can build a theme that puts harmful HTML and JavaScript into the pages it builds.
  This is true of almost any SSG, however.

A detailed comparison of Reuben, along with benchmarking of Reuben against other popular SSGs, is planned in an upcoming docs page.
