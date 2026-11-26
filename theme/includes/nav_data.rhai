// Navigation data the header, sidebar and breadcrumb share. Nothing here names a page: the order comes from
// `site.params.nav_order` and the titles and URLs from collections.

// `url_for` joins the full base_url; layouts compare and emit page URLs the way `page.url` spells them.
fn site_path(site, url) {
    let base = site.base_url;
    if base.ends_with("/") {
        base = base.sub_string(0, base.len() - 1);
    }
    if base != "" && url.starts_with(base) {
        url.sub_string(base.len())
    } else {
        url
    }
}

// A label for a root-level page, which belongs to no collection, so its title isn't visible to layouts.
// `nav_labels` in [params] names one outright (`cli = "CLI"`); otherwise the slug's hyphens become spaces and its
// first letter a capital (`site-structure` reads "Site structure").
fn label_from_slug(site, slug) {
    if "nav_labels" in site.params && slug in site.params.nav_labels {
        return site.params.nav_labels[slug];
    }
    if slug.len() == 0 {
        return slug;
    }
    let words = slug;
    words.replace("-", " ");
    words.sub_string(0, 1).to_upper() + words.sub_string(1)
}

// The page a folder's tree node was built from, for front matter the tree doesn't carry.
fn index_page(collection, url) {
    for p in collection.pages {
        if p.url == url {
            return p;
        }
    }
    ()
}

// One entry per `nav_order` slug that is built: a collection (its index page, else its first page) or a
// root-level `<slug>.md`. A draft or missing page is skipped, because `url_for` refuses it and the error is caught.
fn nav_items(site, collections) {
    let items = [];
    if !("nav_order" in site.params) {
        return items;
    }
    for slug in site.params.nav_order {
        if slug in collections {
            let c = collections[slug];
            if c.len() == 0 {
                continue;
            }
            let tree = c.tree;
            let url = tree.url;
            let title = tree.title;
            if url == "" {
                url = c.pages[0].url;
                title = label_from_slug(site, slug);
            } else {
                let index = index_page(c, url);
                if type_of(index) == "map" && "nav_title" in index && type_of(index.nav_title) == "string" {
                    title = index.nav_title;
                }
            }
            items.push(#{ slug: slug, url: url, title: title, section: true });
        } else {
            let url = ();
            try {
                url = site_path(site, url_for("@/" + slug + ".md"));
            } catch {
            }
            if type_of(url) == "string" {
                items.push(#{ slug: slug, url: url, title: label_from_slug(site, slug), section: false });
            }
        }
    }
    items
}

// The folder a tree node stands for: a node built from `x/index.md` has that page's path.
fn tree_dir(node) {
    let path = node.path;
    if path.ends_with("/index.md") {
        path.sub_string(0, path.len() - 9)
    } else {
        path
    }
}
