// The document head, page title, section sidebar, breadcrumb, "on this page" list and footer.

fn head(page, site) {
    let title = escape(site.title);
    if page.title != "" && page.title != site.title {
        title = escape(page.title) + " · " + title;
    }
    let description = "";
    if type_of(page.description) == "string" && page.description != "" {
        description = `<meta name="description" content="${escape(page.description)}">
`;
    }
    raw(`<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${title}</title>
${description}<link rel="icon" href="/img/favicon.svg" type="image/svg+xml">
<link rel="stylesheet" href="/css/tokens.css">
<link rel="stylesheet" href="/css/components.css">
<link rel="stylesheet" href="/css/syntax.css">`)
}

// The page title as the one h1, unless the body already has its own.
fn title_heading(page, content) {
    if content.to_string().contains("<h1") {
        return ();
    }
    raw(`<h1>${escape(page.title)}</h1>`)
}

fn tree_list(children, current) {
    if children.len() == 0 {
        return "";
    }
    let html = "<ul>";
    for node in children {
        let label = escape(node.title);
        let item = label;
        if node.url != "" {
            let attr = "";
            if node.url == current {
                attr = ` aria-current="page"`;
            }
            item = `<a href="${escape(node.url)}"${attr}>${label}</a>`;
        } else {
            item = `<span>${label}</span>`;
        }
        html += `<li>${item}${tree_list(node.children, current)}</li>`;
    }
    html + "</ul>"
}

// Every page in a collection folder gets that collection's tree as its sidebar.
fn sidebar(page, collections) {
    let name = page.collection;
    if name == "" || !(name in collections) {
        return ();
    }
    let tree = collections[name].tree;
    let title = escape(tree.title);
    let heading = title;
    if tree.url != "" {
        let attr = "";
        if tree.url == page.url {
            attr = ` aria-current="page"`;
        }
        heading = `<a href="${escape(tree.url)}"${attr}>${title}</a>`;
    }
    raw(`<nav class="sidebar" aria-label="${title}">
<p class="sidebar-title">${heading}</p>
${tree_list(tree.children, page.url)}
</nav>`)
}

// Home, then each folder above the page that has an index page, then the page. Only pages inside a collection get
// one: a root-level page's trail would be just "Home".
fn breadcrumb(page, collections) {
    let name = page.collection;
    if name == "" || !(name in collections) {
        return ();
    }
    let crumbs = [#{ title: "Home", url: "/" }];
    let node = collections[name].tree;
    loop {
        if node.url != "" && node.url != page.url {
            crumbs.push(#{ title: node.title, url: node.url });
        }
        let next = ();
        for child in node.children {
            if child.is_dir && page.path.starts_with(tree_dir(child) + "/") {
                next = child;
                break;
            }
        }
        if type_of(next) != "map" {
            break;
        }
        node = next;
    }
    let html = `<nav class="breadcrumb" aria-label="Breadcrumb"><ol>`;
    for c in crumbs {
        html += `<li><a href="${escape(c.url)}">${escape(c.title)}</a></li>`;
    }
    html += `<li><span aria-current="page">${escape(page.title)}</span></li>`;
    raw(html + `</ol></nav>`)
}

// Left out when the page has fewer than three h2s.
fn on_this_page(page) {
    let entries = page.toc.filter(|e| e.level == 2 || e.level == 3);
    let h2s = entries.filter(|e| e.level == 2);
    if h2s.len() < 3 {
        return ();
    }
    let html = `<nav class="toc" aria-label="On this page">
<p class="toc-title">On this page</p>
<ul>`;
    for e in entries {
        html += `<li class="toc-l${e.level}"><a href="#${escape(e.id)}">${escape(e.text)}</a></li>`;
    }
    raw(html + `</ul>
</nav>`)
}

fn footer(site) {
    let parts = [];
    if "repo_url" in site.params {
        parts.push(`<a href="${escape(site.params.repo_url)}">Source code</a>`);
    }
    if "license" in site.params {
        parts.push(`<span>Licensed under ${escape(site.params.license)}.</span>`);
    }
    parts.push(`<span>Built with Reuben.</span>`);
    let html = `<footer class="site-footer"><p>`;
    let first = true;
    for part in parts {
        if !first {
            html += ` <span aria-hidden="true">·</span> `;
        }
        html += part;
        first = false;
    }
    raw(html + `</p></footer>`)
}
