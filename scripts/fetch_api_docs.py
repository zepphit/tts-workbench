#!/usr/bin/env python3
"""Vendor the Tabletop Simulator scripting API docs as local markdown.

<https://api.tabletopsimulator.com/> is a MkDocs Material site. This walks its
navigation, converts each page's content to markdown and writes one file per
page under reference/api/, plus an INDEX.md listing the functions each page
documents. An agent then greps the index and reads exactly one page instead of
fetching the web.

Stdlib only, deliberately: this machine has no pandoc, bs4, html2text,
markdownify or requests, so the converter is a small html.parser subclass
targeting the MkDocs content div.

Re-runnable: a page whose markdown is unchanged is left alone, so a re-run that
finds nothing new touches only INDEX.md's fetch date.

Usage:
    fetch_api_docs.py [-o reference/api]
    fetch_api_docs.py --list                 enumerate pages, download nothing
    fetch_api_docs.py --only wait --only ui  just these pages
    fetch_api_docs.py --source-dir DIR       convert saved HTML, fetch nothing
"""

import argparse
import datetime as dt
import html.parser
import os
import posixpath
import re
import sys
import time
import urllib.parse
import urllib.request

BASE = "https://api.tabletopsimulator.com/"
UA = "Mozilla/5.0 (compatible; tts-docs-vendor/1.0; local documentation mirror)"
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# The docs express parameter and return types as empty <span class="tag str">
# elements that CSS renders as a label. Drop them and every signature loses its
# types, so they are restored here. Mapping taken from the site's own
# css/type_icons.css, not guessed.
TYPE_TAGS = {
    "str": "string", "tab": "table", "int": "int", "flo": "float",
    "nil": "nil", "boo": "bool", "obj": "object", "sel": "self",
    "var": "var", "vec": "vector", "col": "color", "pla": "player",
    "fun": "func", "deprecated": "deprecated",
    "xmlco": "color", "xmlcb": "colorblock",
}

SKIP_ELEMENTS = {"svg", "path", "script", "style"}
HEADINGS = {"h1": 1, "h2": 2, "h3": 3, "h4": 4, "h5": 5, "h6": 6}
TYPE_ONLY = re.compile(r"^\*(returns )?[a-z][a-z/]*\*$")


def die(msg):
    sys.exit("error: %s" % msg)


def show(path):
    full = os.path.abspath(path)
    if full == ROOT or full.startswith(ROOT + os.sep):
        return os.path.relpath(full, ROOT)
    return full


def fetch(url):
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    with urllib.request.urlopen(req, timeout=30) as fh:
        return fh.read().decode("utf-8", "replace")


def page_file(slug):
    """URL path -> flat filename: behavior/container/ -> behavior__container.md"""
    return (slug.strip("/").replace("/", "__") or "index") + ".md"


# --------------------------------------------------------------------------
# navigation


class NavParser(html.parser.HTMLParser):
    """Collect the hrefs of MkDocs' primary navigation."""

    def __init__(self):
        html.parser.HTMLParser.__init__(self)
        self.hrefs = []

    def handle_starttag(self, tag, attrs):
        if tag != "a":
            return
        attr = dict(attrs)
        if "md-nav__link" not in (attr.get("class") or ""):
            return
        href = (attr.get("href") or "").split("#")[0]
        if href and not href.startswith(("http://", "https://", "//", "..")):
            self.hrefs.append(href)


def discover(base):
    """Every page in the nav, in nav order. The site's sitemap.xml is empty."""
    parser = NavParser()
    parser.feed(fetch(base))
    seen, slugs = set(), []
    for href in parser.hrefs:
        slug = href.strip("/")
        if slug in ("", ".") or slug in seen:
            continue
        seen.add(slug)
        slugs.append(slug)
    return slugs


# --------------------------------------------------------------------------
# html -> markdown
#
# Only what these pages actually use is handled: headings, paragraphs, lists,
# tables, Pygments-highlighted code blocks, admonitions, and the type-tag spans
# above. Anything else degrades to its text.


class ArticleParser(html.parser.HTMLParser):
    """Convert one MkDocs page's <article> into markdown."""

    def __init__(self, slug):
        html.parser.HTMLParser.__init__(self)
        self.slug = slug
        self.on = False          # inside the content <article>
        self.depth = 0           # element depth within it
        self.skip = 0            # inside an element whose content is dropped
        self.blocks = []         # finished markdown blocks
        self.buf = []            # inline text of the block being built
        self.prefix = ""         # markdown prefix for the current block
        self.headings = []       # (level, id, text) for the index
        self.pre = False
        self.lists = []          # nesting of "ul"/"ol", with an item counter
        self.table = None        # {"head": [...], "rows": [[...]]}
        self.cell = None
        self.row = None
        self.in_head = False
        self.quote = 0           # admonition nesting
        self.link = None

    # -- helpers ----------------------------------------------------------

    def text(self):
        out = "".join(self.buf)
        return out if self.pre else re.sub(r"[ \t]*\n[ \t]*", " ", out).strip()

    def flush(self):
        body = self.text()
        self.buf = []
        prefix, self.prefix = self.prefix, ""
        if not body and not prefix.strip():
            return
        block = (prefix + body).rstrip()
        if self.quote and not block.startswith(">"):
            block = "\n".join("> " + ln if ln else ">" for ln in block.split("\n"))
            # Keep one admonition as one blockquote rather than a run of them.
            if self.blocks and self.blocks[-1].startswith(">"):
                self.blocks[-1] += "\n>\n" + block
                return
        self.blocks.append(block)

    def target(self):
        """The buffer currently receiving inline text."""
        return self.cell if self.cell is not None else self.buf

    def emit(self, text):
        if self.skip:
            return
        self.target().append(text)

    def image_src(self, src):
        """Make an image source absolute against the page it was found on.

        Images are not vendored — only the markdown is — so a relative src like
        ../img/atom/logo.png would point at a file that was never fetched. The
        site is the only place the image exists, so link there.
        """
        if not src or src.startswith(("http://", "https://", "//", "data:")):
            return src
        return urllib.parse.urljoin(BASE + self.slug + "/", src)

    def local_link(self, href):
        """Rewrite a link between doc pages to the vendored file beside it."""
        if not href or href.startswith(("http://", "https://", "//", "mailto:")):
            return href
        url, _, frag = href.partition("#")
        if not url:
            return "#" + frag if frag else ""
        target = posixpath.normpath(posixpath.join(self.slug + "/", url)).strip("/")
        if target in (".", ""):
            return "INDEX.md" + (("#" + frag) if frag else "")
        return page_file(target) + (("#" + frag) if frag else "")

    # -- tags -------------------------------------------------------------

    def handle_starttag(self, tag, attrs):
        attr = dict(attrs)
        klass = attr.get("class") or ""

        if not self.on:
            if tag == "article" and "md-content__inner" in klass:
                self.on, self.depth = True, 1
            return

        self.depth += 1
        if self.skip:
            return
        if tag in SKIP_ELEMENTS or "headerlink" in klass or "md-content__button" in klass:
            self.skip = self.depth
            return

        if tag in HEADINGS:
            self.flush()
            self.prefix = "#" * HEADINGS[tag] + " "
            self._heading = (HEADINGS[tag], attr.get("id") or "")
        elif tag == "p":
            self.flush()
            if "admonition-title" in klass:
                self.prefix = "**"
                self._admonition_title = True
        elif tag in ("ul", "ol"):
            self.flush()
            self.lists.append([tag, 0])
        elif tag == "li":
            self.flush()
            if self.lists:
                self.lists[-1][1] += 1
                kind, n = self.lists[-1]
                bullet = "%d. " % n if kind == "ol" else "- "
            else:
                bullet = "- "
            self.prefix = "  " * max(0, len(self.lists) - 1) + bullet
        elif tag == "pre":
            self.flush()
            self.pre = True
        elif tag == "code":
            if not self.pre:
                self.emit("`")
        elif tag in ("strong", "b"):
            self.emit("**")
        elif tag in ("em", "i"):
            self.emit("*")
        elif tag == "kbd":
            self.emit("`")
        elif tag == "br":
            self.emit("\n" if self.pre else " ")
        elif tag == "hr":
            self.flush()
            self.blocks.append("---")
        elif tag == "img":
            self.emit("![%s](%s)" % (attr.get("alt", ""), self.image_src(attr.get("src", ""))))
        elif tag == "a":
            self.link = self.local_link(attr.get("href", ""))
            self.link_at = len(self.target())
            self.emit("[")
        elif tag == "table":
            self.flush()
            self.table = {"head": [], "rows": []}
        elif tag == "tr":
            self.row = []
        elif tag in ("td", "th"):
            self.cell = []
            self.in_head = tag == "th"
        elif tag == "div" and "admonition" in klass:
            self.flush()
            self.quote += 1
        elif tag == "span":
            parts = klass.split()
            if "tag" in parts or "ret" in parts:
                names = [TYPE_TAGS.get(p, p) for p in parts if p not in ("tag", "ret")]
                if names:
                    label = "/".join(names)
                    self.emit("*returns %s* " % label if "ret" in parts
                              else "*%s* " % label)

    def handle_endtag(self, tag):
        if not self.on:
            return
        if self.skip:
            if self.depth == self.skip:
                self.skip = 0
            self.depth -= 1
            return

        if tag == "article" and self.depth == 1:
            self.flush()
            self.on = False
            self.depth = 0
            return

        if tag in HEADINGS:
            text = self.text()
            level, ident = getattr(self, "_heading", (1, ""))
            self.headings.append((level, ident, text))
            self.flush()
        elif tag == "p":
            if getattr(self, "_admonition_title", False):
                self.emit("**")
                self._admonition_title = False
            self.flush()
        elif tag in ("ul", "ol"):
            self.flush()
            if self.lists:
                self.lists.pop()
        elif tag == "li":
            self.flush()
        elif tag == "pre":
            body = "".join(self.buf).strip("\n")
            self.buf, self.pre = [], False
            lang = "lua" if re.search(r"\b(function|local|end)\b", body) else ""
            self.blocks.append("```%s\n%s\n```" % (lang, body))
        elif tag == "code":
            if not self.pre:
                self.emit("`")
        elif tag in ("strong", "b"):
            self.emit("**")
        elif tag in ("em", "i"):
            self.emit("*")
        elif tag == "kbd":
            self.emit("`")
        elif tag == "a":
            # Most links here wrap either a type-tag span or the ¶ anchor icon.
            # Linking "*table*" to the glossary on every parameter of every
            # signature is pure noise, and the anchor links come out empty.
            buf = self.target()
            at = getattr(self, "link_at", None)
            inner = "".join(buf[at + 1:]).strip() if at is not None else None
            if at is not None and (not inner or TYPE_ONLY.match(inner)):
                del buf[at:]
                if inner:
                    buf.append(inner + " ")
            else:
                self.emit("](%s)" % self.link if self.link else "]")
            self.link, self.link_at = None, None
        elif tag in ("td", "th"):
            cell = re.sub(r"\s+", " ", "".join(self.cell or [])).strip()
            self.cell = None
            if self.row is not None:
                self.row.append(cell.replace("|", "\\|"))
        elif tag == "tr":
            if self.table is not None and self.row:
                key = "head" if self.in_head else "rows"
                (self.table["head"].extend if key == "head"
                 else self.table["rows"].append)(self.row)
            self.row, self.in_head = None, False
        elif tag == "table":
            self.blocks.append(self.render_table())
            self.table = None
        elif tag == "div" and self.quote:
            self.flush()
            self.quote -= 1

        self.depth -= 1

    def handle_data(self, data):
        if not self.on or self.skip:
            return
        if self.pre:
            self.buf.append(data)
        elif data.strip() or (self.buf and not self.buf[-1].endswith(" ")):
            self.emit(data if self.pre else re.sub(r"\s+", " ", data))

    # -- output -----------------------------------------------------------

    def render_table(self):
        head = self.table["head"]
        rows = self.table["rows"]
        if not head and rows:
            head, rows = rows[0], rows[1:]
        width = max([len(head)] + [len(r) for r in rows] or [0])
        head = (head + [""] * width)[:width]
        rows = [(r + [""] * width)[:width] for r in rows]
        # The rightmost column is often just the ¶ anchor, which renders empty.
        while width > 1 and not head[width - 1].strip() \
                and not any(r[width - 1].strip() for r in rows):
            width -= 1
            head = head[:width]
            rows = [r[:width] for r in rows]
        lines = ["| " + " | ".join(head) + " |",
                 "| " + " | ".join(["---"] * width) + " |"]
        for row in rows:
            lines.append("| " + " | ".join((row + [""] * width)[:width]) + " |")
        return "\n".join(lines)

    def markdown(self):
        out = []
        for block in self.blocks:
            if block.strip():
                out.append(block)
        text = "\n\n".join(out)
        return re.sub(r"\n{3,}", "\n\n", text).strip() + "\n"


def convert(html_text, slug):
    parser = ArticleParser(slug)
    parser.feed(html_text)
    parser.close()
    return parser.markdown(), parser.headings


# --------------------------------------------------------------------------
# index


def functions_of(headings):
    """Function names a page documents, from its heading ids."""
    names = []
    for level, ident, text in headings:
        if level < 2 or not text:
            continue
        name = text.split("(")[0].strip()
        if "(" in text and name and name not in names:
            names.append(name)
    return names


def sections_of(headings):
    return [t for lvl, _, t in headings if lvl == 2 and t][:6]


def write_index(out, pages, when):
    total = sum(p[3] for p in pages)
    lines = [
        "# Tabletop Simulator API — vendored reference",
        "",
        "One markdown file per page of <%s>, fetched %s by "
        "`scripts/fetch_api_docs.py`. %d pages, %d KB."
        % (BASE, when, len(pages), round(total / 1024)),
        "",
        "**Grep [the function list](#every-documented-function) for a name, then "
        "read that one page.** The pages are large — `object.md` is the whole "
        "Object class — so opening the right one matters.",
        "",
        "## Pages",
        "",
        "| Page | File | Covers |",
        "| --- | --- | --- |",
    ]
    for slug, fname, headings, nbytes in pages:
        names = functions_of(headings)
        what = ", ".join(sections_of(headings))
        if names:
            what = "%d functions%s" % (len(names), (" — " + what) if what else "")
        title = headings[0][2] if headings else slug
        lines.append("| %s | [`%s`](%s) | %s |" % (
            title.replace("|", "\\|"), fname, fname,
            (what or "—").replace("\n", " ")))

    # The greppable half: every function on its own line, so that a grep for a
    # name lands on exactly one row naming the page to open. Truncating this
    # would defeat the point of having an index at all.
    index = {}
    for slug, fname, headings, _ in pages:
        for name in functions_of(headings):
            index.setdefault(name, []).append(fname)
    lines += [
        "",
        "## Every documented function",
        "",
        "%d names. A name documented on more than one page lists them all."
        % len(index),
        "",
        "| Function | Page |",
        "| --- | --- |",
    ]
    for name in sorted(index, key=str.lower):
        lines.append("| `%s` | %s |" % (
            name, ", ".join("[`%s`](%s)" % (f, f) for f in index[name])))
    lines += [
        "",
        "Re-run `python3 scripts/fetch_api_docs.py` to refresh; pages whose "
        "content has not changed are left untouched.",
        "",
    ]
    path = os.path.join(out, "INDEX.md")
    with open(path, "w", encoding="utf-8") as fh:
        fh.write("\n".join(lines))
    return path


# --------------------------------------------------------------------------


def main():
    ap = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("-o", "--out", default=os.path.join(ROOT, "reference", "api"),
                    help="output directory (default reference/api)")
    ap.add_argument("--only", action="append", metavar="SLUG",
                    help="fetch just this page; repeatable")
    ap.add_argument("--list", action="store_true",
                    help="print the pages in the nav and exit")
    ap.add_argument("--source-dir", metavar="DIR",
                    help="convert saved HTML from DIR instead of fetching")
    ap.add_argument("--delay", type=float, default=0.25,
                    help="seconds between requests (default 0.25)")
    args = ap.parse_args()

    if args.source_dir:
        slugs = sorted(
            f[:-5].replace("__", "/") for f in os.listdir(args.source_dir)
            if f.endswith(".html"))
    else:
        slugs = discover(BASE)
    if args.only:
        wanted = {s.strip("/") for s in args.only}
        slugs = [s for s in slugs if s in wanted]
        if not slugs:
            die("none of %s are in the nav" % ", ".join(sorted(wanted)))

    if args.list:
        for slug in slugs:
            print("  %-28s -> %s" % (slug + "/", page_file(slug)))
        print("\n%d pages" % len(slugs))
        return

    os.makedirs(args.out, exist_ok=True)
    pages, written, unchanged, failed = [], 0, 0, []
    for i, slug in enumerate(slugs, 1):
        if args.source_dir:
            src = os.path.join(args.source_dir, slug.replace("/", "__") + ".html")
            try:
                with open(src, encoding="utf-8") as fh:
                    raw = fh.read()
            except OSError as exc:
                failed.append((slug, exc))
                continue
        else:
            try:
                raw = fetch(BASE + slug + "/")
            except Exception as exc:  # network, HTTP, decoding
                failed.append((slug, exc))
                continue
            time.sleep(args.delay)

        text, headings = convert(raw, slug)
        if not text.strip():
            failed.append((slug, "no content found"))
            continue
        fname = page_file(slug)
        body = "<!-- vendored from %s%s/ — do not edit, regenerate with " \
               "scripts/fetch_api_docs.py -->\n\n%s" % (BASE, slug, text)
        path = os.path.join(args.out, fname)
        old = None
        if os.path.exists(path):
            with open(path, encoding="utf-8") as fh:
                old = fh.read()
        if old == body:
            unchanged += 1
        else:
            with open(path, "w", encoding="utf-8") as fh:
                fh.write(body)
            written += 1
        pages.append((slug, fname, headings, len(body)))
        print("  [%2d/%d] %-28s %6d bytes  %s" % (
            i, len(slugs), slug, len(body),
            "unchanged" if old == body else "written"))

    index = write_index(args.out, pages, dt.date.today().isoformat())
    print("\n%d page(s): %d written, %d unchanged, %d failed"
          % (len(pages), written, unchanged, len(failed)))
    for slug, exc in failed:
        print("  FAILED %s: %s" % (slug, exc))
    print("index: %s" % show(index))
    if failed:
        sys.exit(1)


if __name__ == "__main__":
    main()
