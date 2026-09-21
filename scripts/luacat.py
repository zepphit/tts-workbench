#!/usr/bin/env python3
"""Concatenate a ttslib build, and lint the one thing concatenation breaks.

TTS has no `require`, so a build is `cat` in load order.  That is documented
everywhere in this folder and it is fine — except for one hazard that does not
exist while the files are separate, and which therefore survives every test that
loads them separately:

    ttslib/01-async.lua      local A = {}          -- the async module table
    ttslib/01-async.lua      ttslib.async = A
    ...
    src/50-api.lua           A = {}                -- a *global*, or so it looks

In separate chunks those are two different variables.  Concatenated into one
chunk they are the same variable, because `local A` at the top level of a file
stays in scope for every line that follows it in the concatenation.  The second
assignment silently guts the library: `ttslib.async` still points at the real
table, so `async.keyed` is callable, but the `A.cancel(key)` on its first line
now resolves to the empty table and TTS says

    Global:(178,10-15): attempt to call a nil value  at A.keyed

which names neither file involved.  This happened on 2026-09-21; the lint
exists so it cannot happen twice.

    python3 scripts/luacat.py                    # the build, to stdout
    python3 scripts/luacat.py -o /tmp/global.lua
    python3 scripts/luacat.py --lint             # lint only; exit 1 on a finding
    python3 scripts/luacat.py --src DIR --extra F

`build.sh` and `ttsd.py push` both go through here, so the save on disk and the
script pushed to the running game are the same bytes by construction rather than
by coincidence.
"""

import argparse
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
LIB = os.path.join(ROOT, "reference", "framework", "ttslib")
PROTO = os.path.join(ROOT, "proto", "amazonia")

# Lua's own ceiling on local variables per function; the main chunk is a
# function, and a big concatenation is the one place it is reachable.
MAX_LOCALS = 200

LOCAL = re.compile(r"^local\s+([A-Za-z_]\w*)")
ASSIGN = re.compile(r"^([A-Za-z_]\w*)\s*=(?!=)")
METHOD = re.compile(r"^function\s+([A-Za-z_]\w*)[.:]")


def sources(lib=LIB, extra=None, src=None):
    """Every file of the build, in the order `cat` would take them."""
    files = [os.path.join(lib, n) for n in sorted(os.listdir(lib))
             if n.endswith(".lua")]
    for path in extra or []:
        files.append(path)
    if src:
        files += [os.path.join(src, n) for n in sorted(os.listdir(src))
                  if n.endswith(".lua")]
    return files


def concat(files):
    out = []
    for path in files:
        if not os.path.exists(path):
            sys.stderr.write("luacat: missing %s\n" % path)
            raise SystemExit(2)
        with open(path, encoding="utf-8", newline="") as handle:
            out.append(handle.read())
    return "".join(out)


def lint(files):
    """Findings, worst first.  Only top-level declarations matter: a local
    inside a function goes out of scope at its `end` and cannot reach the next
    file, which is why both patterns below are anchored to column zero."""
    findings = []
    in_scope = {}          # top-level local name -> the file that declared it
    order = {path: i for i, path in enumerate(files)}

    for path in files:
        for number, line in enumerate(open(path, encoding="utf-8"), 1):
            hit = ASSIGN.match(line) or METHOD.match(line)
            if hit:
                name = hit.group(1)
                owner = in_scope.get(name)
                if owner is not None and order[owner] < order[path]:
                    findings.append((
                        "shadowed-global", path, number, name,
                        "`%s` is a top-level local in %s, so this assigns to "
                        "that local, not to a global"
                        % (name, os.path.relpath(owner, ROOT))))
            hit = LOCAL.match(line)
            if hit:
                in_scope.setdefault(hit.group(1), path)

    if len(in_scope) > MAX_LOCALS:
        findings.append((
            "too-many-locals", files[-1], 0, "",
            "%d top-level locals in the concatenated chunk; Lua allows %d"
            % (len(in_scope), MAX_LOCALS)))
    return findings, in_scope


def main():
    parser = argparse.ArgumentParser(
        description="Concatenate and lint a ttslib build.")
    parser.add_argument("--lib", default=LIB)
    parser.add_argument("--src", default=os.path.join(PROTO, "src"))
    parser.add_argument("--extra", action="append",
                        default=[os.path.join(PROTO, "art", "index.lua")],
                        help="files inserted between --lib and --src")
    parser.add_argument("-o", "--out")
    parser.add_argument("--lint", action="store_true",
                        help="lint only; write nothing")
    parser.add_argument("--quiet", action="store_true")
    args = parser.parse_args()

    files = sources(args.lib, args.extra, args.src)
    findings, in_scope = lint(files)

    for kind, path, number, name, message in findings:
        sys.stderr.write("luacat: %s:%s: %s: %s\n"
                         % (os.path.relpath(path, ROOT), number or "-",
                            kind, message))
    if findings:
        sys.stderr.write("luacat: %d finding(s) — the build was NOT written.\n"
                         % len(findings))
        return 1

    if args.lint:
        if not args.quiet:
            print("luacat: %d files, %d top-level locals, no findings"
                  % (len(files), len(in_scope)))
        return 0

    text = concat(files)
    if args.out:
        with open(args.out, "w", encoding="utf-8", newline="") as handle:
            handle.write(text)
        if not args.quiet:
            print("luacat: %d files -> %s (%d chars)"
                  % (len(files), args.out, len(text)))
    else:
        sys.stdout.write(text)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
