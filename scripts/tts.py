#!/usr/bin/env python3
"""Read-mostly tools for the Tabletop Simulator data folder.

Saves run to ~4 MB and 100,000 lines of pretty-printed JSON, so opening one in an
editor (or feeding it to an agent verbatim) is rarely what you want. Every
subcommand here answers a specific question about a save without printing the
whole thing.

Nothing in this file modifies an existing save. The subcommands that write JSON
(`lua inject`, `xml inject`, `new`, `deck build`, `object add`) require an
explicit -o and refuse to point it at their input; `corpus` refuses to write
anywhere under Mods/ or Saves/.

Usage:
    tts.py summary     <save>
    tts.py tree        <save> [--depth N] [--filter TYPE] [--nickname TEXT]
    tts.py get         <save> <path> [--no-children]
    tts.py urls        <save> [--missing-only]
    tts.py find-asset  <url|filename|cache-path>
    tts.py refs        <save> <guid-or-text>
    tts.py validate    <save>
    tts.py diff        <save-a> <save-b> [--full] [--all]
    tts.py lua extract <save> [--object GUID|--list] [-o DIR]
    tts.py lua inject  <save> <file-or-dir> -o NEW_SAVE [--object GUID]
    tts.py xml extract <save> [--object GUID|--list] [-o DIR]
    tts.py xml inject  <save> <file-or-dir> -o NEW_SAVE [--object GUID]
    tts.py corpus      <save> -o DIR
    tts.py new         -o NEW_SAVE [--name NAME]
    tts.py deck build  --face URL --back URL --cols N --rows N -o FILE
    tts.py object add  <save> <object-json> -o NEW_SAVE [--at X,Y,Z] [--count N]
    tts.py selftest
    tts.py inventory   [-o docs/inventory.md]
"""

import argparse
import copy
import datetime as dt
import decimal
import glob
import hashlib
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Every field in a save that can hold an asset URL, mapped to the Mods/
# subfolder TTS caches it into. See docs/asset-cache.md.
URL_FIELDS = {
    "ImageURL": "Images",
    "ImageSecondaryURL": "Images",
    "FaceURL": "Images",
    "BackURL": "Images",
    "DiffuseURL": "Images",
    "NormalURL": "Images",
    "TableURL": "Images",
    "SkyURL": "Images",
    "MeshURL": "Models",
    "ColliderURL": "Models",
    "PDFUrl": "PDF",
    "AssetbundleURL": "Assetbundles",
    "AssetbundleSecondaryURL": "Assetbundles",
    "CurrentAudioURL": "Audio",
    "URL": None,  # appears on a few object types; folder unknown, search all
}

ASSET_DIRS = ["Images", "Models", "PDF", "Assetbundles", "Audio", "Text"]

BUNDLE_MARKER = "-- Bundled by luabundle"
BUNDLE_RE = re.compile(
    r'__bundle_register\("((?:[^"\\]|\\.)*)", '
    r"function\(require, _LOADED, __bundle_register, __bundle_modules\)\n"
)
MODULE_END = "\nend)\n"

# What TTS puts in XmlUI when nobody has written any UI. Present in most saves,
# and pure noise in a grep corpus.
XML_STUB = "<!-- Xml UI. See documentation: https://api.tabletopsimulator.com/ui/introUI/ -->"


# --------------------------------------------------------------------------
# loading


def resolve(path):
    """Accept a path relative to cwd or to the TTS root."""
    if os.path.exists(path):
        return path
    alt = os.path.join(ROOT, path)
    if os.path.exists(alt):
        return alt
    sys.exit("no such file: %s" % path)


def load(path):
    full = resolve(path)
    try:
        with open(full, encoding="utf-8") as fh:
            return json.load(fh)
    except ValueError as exc:
        die("%s is not valid JSON (%s)" % (show(full), exc))
    except UnicodeDecodeError as exc:
        die("%s is not UTF-8 text (%s)" % (show(full), exc))


def die(msg):
    sys.exit("error: %s" % msg)


def show(path):
    """Display a path relative to the TTS root, or absolute if it lives outside."""
    full = os.path.abspath(path)
    if full == ROOT or full.startswith(ROOT + os.sep):
        return os.path.relpath(full, ROOT)
    return full


# --------------------------------------------------------------------------
# object tree walking
#
# ObjectStates is a recursive tree: containers (Bag, Deck, ...) nest their
# contents under "ContainedObjects", and objects with flip/rotate variants nest
# them under "States" (a dict keyed by state number). Paths emitted here are
# valid Python-ish accessors, e.g. ObjectStates[38].ContainedObjects[2].


def walk(objs, path="ObjectStates", depth=0):
    """Yield (object, path, depth) for every object in the tree, depth-first."""
    for i, obj in enumerate(objs):
        here = "%s[%d]" % (path, i)
        yield obj, here, depth
        if obj.get("ContainedObjects"):
            yield from walk(obj["ContainedObjects"], here + ".ContainedObjects", depth + 1)
        for key, state in (obj.get("States") or {}).items():
            sp = "%s.States[%s]" % (here, key)
            yield state, sp, depth + 1
            if state.get("ContainedObjects"):
                yield from walk(
                    state["ContainedObjects"], sp + ".ContainedObjects", depth + 1
                )


PATH_TOKEN = re.compile(r"([A-Za-z_]+)|\[([^\]]+)\]")


def get_by_path(save, path):
    """Resolve a path string emitted by `tree` back to the live object."""
    node = save
    for name, index in PATH_TOKEN.findall(path):
        if name:
            if not isinstance(node, dict) or name not in node:
                die("path does not exist: %s (stuck at %r)" % (path, name))
            node = node[name]
        else:
            if isinstance(node, list):
                node = node[int(index)]
            elif isinstance(node, dict):
                node = node.get(index) or node.get(str(index))
                if node is None:
                    die("path does not exist: %s (no key %r)" % (path, index))
            else:
                die("path does not exist: %s" % path)
    return node


def label(obj):
    nick = (obj.get("Nickname") or "").strip().replace("\n", " ")
    return nick[:48] if nick else ""


# --------------------------------------------------------------------------
# asset URLs


def iter_urls(node, path=""):
    """Yield (field, url, json-path) for every asset URL anywhere in a save."""
    if isinstance(node, dict):
        for key, val in node.items():
            sub = "%s.%s" % (path, key) if path else key
            if isinstance(val, str) and val.strip() and key in URL_FIELDS:
                yield key, val.strip(), sub
            else:
                yield from iter_urls(val, sub)
    elif isinstance(node, list):
        for i, val in enumerate(node):
            yield from iter_urls(val, "%s[%d]" % (path, i))


def mangle(url):
    """TTS cache filename: the URL with every non-alphanumeric char removed."""
    return re.sub(r"[^A-Za-z0-9]", "", url)


def cache_path(url, field=None):
    """Find the cached file for a URL, or None. Extensions vary, so glob."""
    stem = mangle(url)
    dirs = ASSET_DIRS
    hint = URL_FIELDS.get(field)
    if hint:
        dirs = [hint] + [d for d in ASSET_DIRS if d != hint]
    for folder in dirs:
        hits = sorted(glob.glob(os.path.join(ROOT, "Mods", folder, stem + ".*")))
        if hits:
            return os.path.relpath(hits[0], ROOT)
        exact = os.path.join(ROOT, "Mods", folder, stem)
        if os.path.exists(exact):
            return os.path.relpath(exact, ROOT)
    return None


# --------------------------------------------------------------------------
# luabundle
#
# Global scripts pulled from scripted Workshop mods are luabundle 1.6.0 output:
# a runtime preamble, then one __bundle_register(...) call per source module,
# then a final require. Rather than re-bundling from scratch on inject (which
# would rewrite the preamble and lose formatting), extract records each module
# body's byte range and inject splices the edited bodies back in. An unmodified
# round-trip is therefore byte-identical.


def split_bundle(lua):
    """Return [(module_name, body, start, end)] or None if not a bundle."""
    if BUNDLE_MARKER not in lua:
        return None
    modules = []
    matches = list(BUNDLE_RE.finditer(lua))
    if not matches:
        return None
    for i, match in enumerate(matches):
        start = match.end()
        limit = matches[i + 1].start() if i + 1 < len(matches) else len(lua)
        chunk = lua[start:limit]
        cut = chunk.rfind(MODULE_END)
        if cut == -1:
            return None
        modules.append((match.group(1), chunk[:cut], start, start + cut))
    return modules


def module_filename(name):
    safe = name.replace("/", "__").replace("\\", "__")
    return safe if safe.endswith(".lua") else safe + ".lua"


def lua_targets(save, guid=None, field="LuaScript"):
    """Yield (description, container-dict) for each thing holding a script.

    `field` is "LuaScript" or "XmlUI" — the save itself and every object carry
    both, so the same traversal serves `lua extract` and `xml extract`.
    """
    if guid is None:
        yield "Global", save
    for obj, path, _ in walk(save.get("ObjectStates", [])):
        if guid is not None and obj.get("GUID") != guid:
            continue
        if (obj.get(field) or "").strip() or guid is not None:
            name = obj.get("GUID") or "noguid"
            nick = label(obj)
            desc = "%s%s [%s]" % (name, (" " + nick) if nick else "", path)
            yield desc, obj


def is_stub_xml(xml):
    """True if this XmlUI holds nothing but TTS's default comment."""
    return (xml or "").strip() in ("", XML_STUB)


def sha(text):
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def bundle_modules(save, guid=None):
    """Yield (slot, module_name, body) for every bundled module in a save."""
    for _, holder in lua_targets(save, guid):
        bundle = split_bundle(holder.get("LuaScript") or "")
        if not bundle:
            continue
        slot = "global" if holder is save else (holder.get("GUID") or "noguid")
        for name, body, _, _ in bundle:
            yield slot, name, body


def shared_modules(save):
    """Modules compiled into more than one bundle slot.

    Returns [(name, {sha: [slots]})]. luabundle inlines every dependency into
    every bundle, so a module used by both Global and an object script exists
    twice. More than one distinct sha means the copies have drifted: editing one
    leaves the others resolving the old value, with no error (critique C5).
    """
    seen = {}
    for slot, name, body in bundle_modules(save):
        seen.setdefault(name, {}).setdefault(sha(body), []).append(slot)
    return [(name, by_sha) for name, by_sha in sorted(seen.items())
            if sum(len(slots) for slots in by_sha.values()) > 1]


# --------------------------------------------------------------------------
# writing
#
# Every command that writes JSON goes through here: an explicit -o that is never
# the input, and output formatted byte-for-byte the way TTS formats it.


def check_new_out(path, force):
    """Validate the -o of a command that writes something new."""
    out = os.path.abspath(path)
    if os.path.exists(out) and not force:
        die("%s already exists (pass --force only if you meant to replace it)" % path)
    return out


def check_out(args):
    """Validate a writing command's -o and return it as an absolute path."""
    out = os.path.abspath(args.out)
    if os.path.abspath(resolve(args.save)) == out:
        die("-o must differ from the input save; this tool never edits in place")
    return check_new_out(args.out, args.force)


def refuse_managed(path):
    """Guard output trees against the folders TTS owns (CLAUDE.md rules 1, 3)."""
    full = os.path.abspath(path)
    for name in ("Mods", "Saves"):
        owned = os.path.join(ROOT, name)
        if full == owned or full.startswith(owned + os.sep):
            die("refusing to write inside %s/ — TTS owns it (see CLAUDE.md)" % name)


JSON_STRING = re.compile(r'"(?:[^"\\]|\\.)*"', re.S)
JSON_NUMBER = re.compile(r"-?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?")


def cs_number(tok):
    """Re-render one JSON number the way C# does. Most need no change.

    TTS is a C# program using .NET's default float formatting ("G7"): scientific
    notation when the decimal exponent is <= -5 or >= 7, uppercase E, a signed
    two-digit exponent. Python agrees on the low end but only switches at 1e16,
    so it writes 10000000.0 where TTS writes 1E+07.
    """
    if "." not in tok and "e" not in tok and "E" not in tok:
        return tok  # a JSON integer: C# writes it as written, never in E notation
    if "e" not in tok and "E" not in tok:
        head = tok.lstrip("-").split(".")[0]
        if head == "0" or len(head) <= 7:
            return tok  # exponent is in [-4, 6]: C# writes it just as Python does
    sign, digits, exp = decimal.Decimal(tok).normalize().as_tuple()
    n = len(digits) + exp - 1
    if -5 < n < 7:
        return tok
    mantissa = str(digits[0])
    rest = "".join(str(d) for d in digits[1:])
    if rest:
        mantissa += "." + rest
    return "%s%sE%s%02d" % (
        "-" if sign else "", mantissa, "+" if n >= 0 else "-", abs(n))


def cs_numbers(text):
    """Apply cs_number to every JSON number, leaving string contents alone."""
    def convert(chunk):
        return JSON_NUMBER.sub(lambda m: cs_number(m.group()), chunk)

    out, pos = [], 0
    for m in JSON_STRING.finditer(text):
        out.append(convert(text[pos:m.start()]))
        out.append(m.group())
        pos = m.end()
    out.append(convert(text[pos:]))
    return "".join(out)


def dump_save(save):
    """Serialize exactly as TTS does: 2-space indent, literal UTF-8, C#-style
    floats, no trailing newline. Verified byte-identical against every save and
    mod in this folder — see `tts.py selftest`."""
    return cs_numbers(json.dumps(save, indent=2, ensure_ascii=False))


def write_save(save, out):
    os.makedirs(os.path.dirname(out) or ".", exist_ok=True)
    with open(out, "w", encoding="utf-8", newline="\n") as fh:
        fh.write(dump_save(save))


def set_field(save, guid, field, text, savepath):
    """Write text into the save's field or one object's; return a label for it."""
    if not guid:
        save[field] = text
        return "Global"
    for obj, _, _ in walk(save.get("ObjectStates", [])):
        if obj.get("GUID") == guid:
            obj[field] = text
            return "object %s" % guid
    die("no object with GUID %s in %s" % (guid, savepath))


def read_text(path):
    """Read a script file. newline='' keeps CRLF intact — see docs/save-format.md."""
    with open(path, encoding="utf-8", newline="") as fh:
        return fh.read()


def write_text(path, text):
    os.makedirs(os.path.dirname(path) or ".", exist_ok=True)
    with open(path, "w", encoding="utf-8", newline="") as fh:
        fh.write(text)


# --------------------------------------------------------------------------
# commands


def cmd_summary(args):
    save = load(args.save)
    objs = list(walk(save.get("ObjectStates", [])))
    types = {}
    for obj, _, _ in objs:
        types[obj.get("Name", "?")] = types.get(obj.get("Name", "?"), 0) + 1
    scripted = [(o, p) for o, p, _ in objs if (o.get("LuaScript") or "").strip()]
    top = len(save.get("ObjectStates", []))

    print("file        %s" % show(resolve(args.save)))
    print("SaveName    %s" % save.get("SaveName"))
    print("GameMode    %s" % save.get("GameMode"))
    print("Date        %s   (TTS %s)" % (save.get("Date"), save.get("VersionNumber")))
    if save.get("Tags"):
        print("Tags        %s" % ", ".join(save["Tags"]))
    print("objects     %d top-level, %d including nested" % (top, len(objs)))
    print("max depth   %d" % (max((d for _, _, d in objs), default=0)))
    print("Global Lua  %d chars%s" % (
        len(save.get("LuaScript") or ""),
        " (luabundle)" if BUNDLE_MARKER in (save.get("LuaScript") or "") else "",
    ))
    print("LuaState    %d chars" % len(save.get("LuaScriptState") or ""))
    print("XmlUI       %d chars" % len(save.get("XmlUI") or ""))
    print("obj scripts %d objects carry Lua" % len(scripted))
    print("asset URLs  %d references" % len(list(iter_urls(save))))

    print("\nobject types")
    for name, count in sorted(types.items(), key=lambda kv: -kv[1]):
        print("  %5d  %s" % (count, name))

    note = (save.get("Note") or "").strip()
    if note:
        flat = re.sub(r"\s+", " ", note)
        print("\nNote        %s%s" % (flat[:400], "..." if len(flat) > 400 else ""))

    if scripted:
        print("\nscripted objects")
        for obj, path in scripted[:20]:
            print("  %-7s %-30s %6d chars  %s" % (
                obj.get("GUID"), label(obj) or obj.get("Name"),
                len(obj["LuaScript"]), path))
        if len(scripted) > 20:
            print("  ... %d more" % (len(scripted) - 20))


def cmd_tree(args):
    save = load(args.save)
    shown = 0
    for obj, path, depth in walk(save.get("ObjectStates", [])):
        if args.depth is not None and depth > args.depth:
            continue
        if args.filter and args.filter.lower() not in obj.get("Name", "").lower():
            continue
        if args.nickname and args.nickname.lower() not in label(obj).lower():
            continue
        nick = label(obj)
        bits = []
        if obj.get("ContainedObjects"):
            bits.append("%d inside" % len(obj["ContainedObjects"]))
        if (obj.get("LuaScript") or "").strip():
            bits.append("lua")
        if obj.get("States"):
            bits.append("%d states" % len(obj["States"]))
        print("%s%-22s %-34s %-7s %s%s" % (
            "  " * depth,
            obj.get("Name", "?"),
            nick,
            obj.get("GUID", ""),
            path,
            ("  (" + ", ".join(bits) + ")") if bits else "",
        ))
        shown += 1
    if shown == 0:
        print("(no objects matched)")


def cmd_get(args):
    save = load(args.save)
    node = get_by_path(save, args.path)
    if args.no_children and isinstance(node, dict):
        node = {k: v for k, v in node.items() if k not in ("ContainedObjects", "States")}
    print(json.dumps(node, indent=2, ensure_ascii=False))


def cmd_urls(args):
    save = load(args.save)
    seen = {}
    for field, url, path in iter_urls(save):
        seen.setdefault((field, url), path)
    missing = 0
    for (field, url), path in sorted(seen.items(), key=lambda kv: kv[0][0]):
        local = cache_path(url, field)
        if local is None:
            missing += 1
        elif args.missing_only:
            continue
        print("%-22s %-11s %s" % (field, local or "MISSING", url))
        if args.paths:
            print("%-22s %s" % ("", path))
    print("\n%d distinct assets, %d MISSING from the cache" % (len(seen), missing))


def cmd_find_asset(args):
    target = args.target
    if "://" in target:
        local = cache_path(target)
        print(local or "MISSING")
        return
    # Given a cache filename, find which saves and mods reference it.
    stem = os.path.splitext(os.path.basename(target))[0]
    files = sorted(glob.glob(os.path.join(ROOT, "Saves", "**", "*.json"), recursive=True))
    files += sorted(glob.glob(os.path.join(ROOT, "Mods", "Workshop", "*.json")))
    hits = 0
    for path in files:
        if os.path.basename(path) in ("SaveFileInfos.json", "WorkshopFileInfos.json"):
            continue
        try:
            with open(path, encoding="utf-8", errors="replace") as fh:
                save = json.load(fh)
        except (ValueError, OSError):
            continue
        for field, url, jpath in iter_urls(save):
            if mangle(url) == stem:
                print("%-42s %-16s %s" % (
                    os.path.relpath(path, ROOT), field, save.get("SaveName")))
                print("%-42s %s" % ("", url))
                hits += 1
                break
    if not hits:
        print("no save or mod references %s" % stem)


def cmd_lua_extract(args):
    save = load(args.save)
    targets = list(lua_targets(save, args.object))
    if args.object and not targets:
        die("no object with GUID %s" % args.object)

    if args.list:
        for desc, holder in targets:
            lua = holder.get("LuaScript") or ""
            bundle = split_bundle(lua)
            print("%-44s %7d chars%s" % (
                desc, len(lua),
                "  (%d bundled modules)" % len(bundle) if bundle else ""))
        return

    outdir = args.out or os.path.join(ROOT, "scripts", "lua-out")
    written = []
    for desc, holder in targets:
        lua = holder.get("LuaScript") or ""
        if not lua.strip():
            continue
        slot = "global" if holder is save else holder.get("GUID", "object")
        base = os.path.join(outdir, slot)
        os.makedirs(base, exist_ok=True)
        bundle = split_bundle(lua)
        index = {
            "save": show(resolve(args.save)),
            "slot": slot,
            "guid": None if holder is save else holder.get("GUID"),
            "bundled": bool(bundle),
        }
        if bundle:
            index["modules"] = []
            for name, body, start, end in bundle:
                fname = module_filename(name)
                write_text(os.path.join(base, fname), body)
                index["modules"].append(
                    {"name": name, "file": fname, "start": start, "end": end})
                written.append(os.path.join(slot, fname))
            write_text(os.path.join(base, "_bundle.lua"), lua)
        else:
            write_text(os.path.join(base, "script.lua"), lua)
            written.append(os.path.join(slot, "script.lua"))
        with open(os.path.join(base, "_index.json"), "w", encoding="utf-8") as fh:
            json.dump(index, fh, indent=2)

    if not written:
        print("no Lua found")
        return
    print("wrote %d file(s) under %s" % (len(written), show(outdir)))
    for name in written[:40]:
        print("  %s" % name)
    if len(written) > 40:
        print("  ... %d more" % (len(written) - 40))

    report_shared(save, args.object)
    print("\nEdit the module files, then:")
    print("  tts.py lua inject %s %s -o Saves/TS_Save_<new>.json"
          % (args.save, show(outdir)))


def report_shared(save, guid=None):
    """Warn that a module exists in several slots, so one edit is not enough."""
    if guid is not None:
        return
    shared = shared_modules(save)
    if not shared:
        return
    drifted = [s for s in shared if len(s[1]) > 1]
    print("\nwarning: %d module(s) are compiled into more than one slot%s."
          % (len(shared), ", %d DRIFTED" % len(drifted) if drifted else ""))
    print("An edit to one copy does not reach the others.")
    for name, by_sha in shared[:20]:
        slots = [s for group in by_sha.values() for s in group]
        mark = "DRIFTED" if len(by_sha) > 1 else "identical"
        print("  %-9s %-34s %d copies: %s" % (
            mark, name, len(slots), ", ".join(sorted(set(slots)))))
    if len(shared) > 20:
        print("  ... %d more" % (len(shared) - 20))


def rebuild_bundle(base, index):
    """Splice edited module bodies back into the original bundle text."""
    original = read_text(os.path.join(base, "_bundle.lua"))
    out, cursor = [], 0
    for mod in sorted(index["modules"], key=lambda m: m["start"]):
        out.append(original[cursor:mod["start"]])
        out.append(read_text(os.path.join(base, mod["file"])))
        cursor = mod["end"]
    out.append(original[cursor:])
    return "".join(out)


def cmd_lua_inject(args):
    out = check_out(args)

    source = args.source
    if os.path.isdir(source):
        base = source
        index_path = os.path.join(base, "_index.json")
        if not os.path.exists(index_path):
            die("%s has no _index.json; point at a slot directory from `lua extract`"
                % source)
        with open(index_path, encoding="utf-8") as fh:
            index = json.load(fh)
        lua = (rebuild_bundle(base, index) if index["bundled"]
               else read_text(os.path.join(base, "script.lua")))
        guid = args.object or index.get("guid")
    else:
        lua = read_text(resolve(source))
        guid = args.object

    save = load(args.save)
    where = set_field(save, guid, "LuaScript", lua, args.save)
    write_save(save, out)
    print("wrote %s (%s, %d chars of Lua)" % (args.out, where, len(lua)))
    print("Load it from TTS: Games > Save & Load. The original is untouched.")


# --------------------------------------------------------------------------
# XML UI
#
# The same round-trip `lua` has, for XmlUI. There is no bundling here, so a slot
# is one file; the newline="" rule still applies, since object XML written on
# Windows carries CRLF and losing it shifts every line in the markup.


def cmd_xml_extract(args):
    save = load(args.save)
    targets = [(desc, holder) for desc, holder in lua_targets(save, args.object, "XmlUI")
               if not is_stub_xml(holder.get("XmlUI"))]
    if args.object and not targets:
        die("object %s has no XmlUI (or does not exist)" % args.object)

    if args.list:
        for desc, holder in targets:
            print("%-44s %7d chars" % (desc, len(holder.get("XmlUI") or "")))
        if not targets:
            print("no XML UI beyond TTS's default stub")
        return

    outdir = args.out or os.path.join(ROOT, "scripts", "xml-out")
    written = []
    for _, holder in targets:
        slot = "global" if holder is save else (holder.get("GUID") or "object")
        base = os.path.join(outdir, slot)
        write_text(os.path.join(base, "ui.xml"), holder["XmlUI"])
        with open(os.path.join(base, "_index.json"), "w", encoding="utf-8") as fh:
            json.dump({
                "save": show(resolve(args.save)),
                "slot": slot,
                "guid": None if holder is save else holder.get("GUID"),
                "field": "XmlUI",
                "file": "ui.xml",
            }, fh, indent=2)
        written.append(os.path.join(slot, "ui.xml"))

    if not written:
        print("no XML UI beyond TTS's default stub")
        return
    print("wrote %d file(s) under %s" % (len(written), show(outdir)))
    for name in written[:40]:
        print("  %s" % name)
    if len(written) > 40:
        print("  ... %d more" % (len(written) - 40))
    print("\nEdit the markup, then:")
    print("  tts.py xml inject %s %s -o Saves/TS_Save_<new>.json"
          % (args.save, show(outdir)))


def cmd_xml_inject(args):
    out = check_out(args)

    source = args.source
    if os.path.isdir(source):
        index_path = os.path.join(source, "_index.json")
        if not os.path.exists(index_path):
            die("%s has no _index.json; point at a slot directory from `xml extract`"
                % source)
        with open(index_path, encoding="utf-8") as fh:
            index = json.load(fh)
        xml = read_text(os.path.join(source, index.get("file", "ui.xml")))
        guid = args.object or index.get("guid")
    else:
        xml = read_text(resolve(source))
        guid = args.object

    save = load(args.save)
    where = set_field(save, guid, "XmlUI", xml, args.save)
    write_save(save, out)
    print("wrote %s (%s, %d chars of XML)" % (args.out, where, len(xml)))
    print("Load it from TTS: Games > Save & Load. The original is untouched.")


# --------------------------------------------------------------------------
# corpus
#
# Everything a save holds in Lua and XML, written out as real files so the next
# question can be answered with grep instead of by re-parsing megabytes of JSON.
# Object scripts are bundles too (Arcs' Setup packs 13 modules into 257 KB), so
# every slot is split, not just Global.


def cmd_corpus(args):
    src = resolve(args.save)
    outdir = os.path.abspath(args.out)
    refuse_managed(outdir)
    save = load(args.save)

    with open(src, "rb") as fh:
        raw = fh.read()
    manifest = {
        "source": show(src),
        "sha256": hashlib.sha256(raw).hexdigest(),
        "bytes": len(raw),
        "save_name": save.get("SaveName"),
        "game_mode": save.get("GameMode"),
        "date": save.get("Date"),
        "tts_version": save.get("VersionNumber"),
        "extracted": dt.date.today().isoformat(),
        "slots": [],
    }

    nfiles, verified, bundles = 0, 0, 0
    for _, holder in lua_targets(save):
        is_global = holder is save
        lua = holder.get("LuaScript") or ""
        xml = holder.get("XmlUI") or ""
        if not lua.strip() and is_stub_xml(xml):
            continue
        slot = "global" if is_global else (holder.get("GUID") or "noguid")
        rel = "global" if is_global else os.path.join("objects", slot)
        base = os.path.join(outdir, rel)
        entry = {
            "slot": slot,
            "guid": None if is_global else holder.get("GUID"),
            "nickname": None if is_global else (label(holder) or None),
            "type": None if is_global else holder.get("Name"),
            "dir": rel,
        }

        if lua.strip():
            bundle = split_bundle(lua)
            info = {"chars": len(lua), "sha256": sha(lua), "bundled": bool(bundle)}
            if bundle:
                bundles += 1
                index = {"bundled": True, "modules": []}
                for name, body, start, end in bundle:
                    fname = module_filename(name)
                    write_text(os.path.join(base, fname), body)
                    index["modules"].append(
                        {"name": name, "file": fname, "start": start, "end": end})
                    nfiles += 1
                write_text(os.path.join(base, "_bundle.lua"), lua)
                nfiles += 1
                info["file"] = os.path.join(rel, "_bundle.lua")
                info["modules"] = [
                    {"name": m["name"], "file": os.path.join(rel, m["file"]),
                     "chars": len(b), "sha256": sha(b)}
                    for m, (_, b, _, _) in zip(index["modules"], bundle)]
                # Faithfulness check: splice the files we just wrote back into
                # the bundle and compare with what the save actually holds.
                if rebuild_bundle(base, index) == lua:
                    verified += 1
                else:
                    print("WARNING: %s does not round-trip" % rel)
                with open(os.path.join(base, "_index.json"), "w", encoding="utf-8") as fh:
                    json.dump(dict(index, slot=slot, guid=entry["guid"],
                                   save=show(src)), fh, indent=2)
            else:
                write_text(os.path.join(base, "script.lua"), lua)
                nfiles += 1
                info["file"] = os.path.join(rel, "script.lua")
                verified += 1
            entry["lua"] = info

        if not is_stub_xml(xml):
            write_text(os.path.join(base, "ui.xml"), xml)
            nfiles += 1
            entry["xml"] = {"file": os.path.join(rel, "ui.xml"),
                            "chars": len(xml), "sha256": sha(xml)}
        elif xml.strip():
            entry["xml"] = {"stub": True, "chars": len(xml)}

        manifest["slots"].append(entry)

    manifest["shared_modules"] = [
        {
            "name": name,
            "copies": sum(len(slots) for slots in by_sha.values()),
            "identical": len(by_sha) == 1,
            "slots": sorted({s for slots in by_sha.values() for s in slots}),
            "sha256": sorted(by_sha),
        }
        for name, by_sha in shared_modules(save)
    ]

    os.makedirs(outdir, exist_ok=True)
    with open(os.path.join(outdir, "manifest.json"), "w", encoding="utf-8") as fh:
        json.dump(manifest, fh, indent=2, ensure_ascii=False)

    print("%s -> %s" % (show(src), show(outdir)))
    print("  %d slot(s), %d file(s), %d bundle(s)" % (
        len(manifest["slots"]), nfiles, bundles))
    print("  round-trip verified: %d/%d slot(s) with Lua" % (
        verified, sum(1 for s in manifest["slots"] if "lua" in s)))
    dup = manifest["shared_modules"]
    if dup:
        drifted = [d for d in dup if not d["identical"]]
        print("  shared modules: %d across slots%s" % (
            len(dup), ", %d DRIFTED" % len(drifted) if drifted else " (all identical)"))
    print("  manifest.json records source sha256 %s" % manifest["sha256"][:16])


# --------------------------------------------------------------------------
# validate
#
# Run this on any save before loading it, and on any save you generated. It only
# reports: nothing here rewrites a file. Findings on an untouched mod are real
# mod bugs, not tool noise.

GUID_LITERAL = re.compile(r"""getObjectFromGUID\s*\(\s*['"]([0-9a-fA-F]{6})['"]""")
XML_IMAGE = re.compile(r'\bimage\s*=\s*"([^"]+)"')
NESTED_TAIL = re.compile(r"\.(ContainedObjects|States)\[[^\]]+\]$")


def all_scripts(save):
    """Yield (slot, field, text) for every Lua and XML body in a save."""
    for _, holder in lua_targets(save):
        slot = "Global" if holder is save else (holder.get("GUID") or "noguid")
        for field in ("LuaScript", "XmlUI"):
            text = holder.get(field) or ""
            if text.strip():
                yield slot, field, text


def cmd_validate(args):
    path = resolve(args.save)
    save = load(args.save)
    findings = []

    def flag(level, code, msg):
        findings.append((level, code, msg))

    # 1. byte format — a file TTS did not write itself reformats on its next save
    with open(path, "rb") as fh:
        raw = fh.read()
    if dump_save(save).encode("utf-8") != raw:
        flag("WARN", "format-differs",
             "bytes differ from what TTS itself would write (2-space indent, "
             "literal UTF-8, C# float exponents, no trailing newline); it loads, "
             "but TTS reformats it on its next save")

    # 2. GUID collisions, by scope.
    #
    # A GUID only has to be unique among objects that can be on the table at
    # once. Objects sitting in different containers routinely share one (169
    # pairs in Arcs, 40 in the owner's own TS_Save_125) because TTS reassigns on
    # spawn, and an object's States share GUIDs by nature. Two objects on the
    # table, or two in one container, are the cases that actually bite.
    guids = {}
    for obj, jpath, _ in walk(save.get("ObjectStates", [])):
        g = obj.get("GUID")
        if g:
            guids.setdefault(g, []).append(jpath)
    for g, paths in sorted(guids.items()):
        if len(paths) < 2:
            continue
        table = [p for p in paths if not NESTED_TAIL.search(p)]
        holders = [NESTED_TAIL.sub("", p) for p in paths]
        if len(table) > 1:
            flag("ERROR", "duplicate-guid",
                 "%s is on the table %d times (%s); getObjectFromGUID cannot "
                 "tell them apart" % (g, len(table), ", ".join(table[:4])))
        elif len(set(holders)) < len(holders):
            flag("WARN", "duplicate-guid-in-container",
                 "%s appears twice in one container (%s); both can be out at "
                 "once, and TTS will renumber one" % (g, paths[0]))

    # 3. deck invariants (docs/save-format.md: CardID = sheet * 100 + index).
    #
    # Only a deck's own CustomDeck is authoritative. A card inside a deck keeps
    # whatever sheet key it had before it was shuffled in — Arcs' 'SILVER
    # TONGUES' is CardID 97007 in a deck keyed 970, but still carries its own
    # CustomDeck keyed 364 — so checking a contained card against its own sheet
    # map reports hundreds of non-problems.
    in_deck = set()
    for obj, _, _ in walk(save.get("ObjectStates", [])):
        if "Deck" in (obj.get("Name") or ""):
            for kid in obj.get("ContainedObjects") or []:
                in_deck.add(id(kid))

    for obj, jpath, _ in walk(save.get("ObjectStates", [])):
        ids = obj.get("DeckIDs")
        if ids is not None:
            kids = obj.get("ContainedObjects") or []
            child = [k.get("CardID") for k in kids]
            if child != ids:
                flag("ERROR", "deckids-mismatch",
                     "%s %s: DeckIDs (%d) does not match ContainedObjects (%d) "
                     "in order/length" % (jpath, label(obj) or obj.get("Name"),
                                          len(ids), len(child)))
            sheets = set((obj.get("CustomDeck") or {}))
            missing = sorted({str(i // 100) for i in ids if str(i // 100) not in sheets})
            if missing:
                flag("ERROR", "deck-sheet-missing",
                     "%s: CardIDs reference sheet(s) %s absent from CustomDeck"
                     % (jpath, ", ".join(missing)))
        cid, own = obj.get("CardID"), obj.get("CustomDeck")
        if cid is not None and own and id(obj) not in in_deck \
                and str(cid // 100) not in own:
            flag("ERROR", "card-sheet-missing",
                 "%s: CardID %d wants sheet %s, but this loose card's CustomDeck "
                 "has %s" % (jpath, cid, cid // 100, ", ".join(sorted(own))))

    # 4. getObjectFromGUID literals that cannot resolve
    contained = {g for g, ps in guids.items()
                 if all(".ContainedObjects" in p for p in ps)}
    wanted = {}
    for slot, field, text in all_scripts(save):
        if field != "LuaScript":
            continue
        for g in GUID_LITERAL.findall(text):
            wanted.setdefault(g, set()).add(slot)
    for g, slots in sorted(wanted.items()):
        where = "referenced from %s" % ", ".join(sorted(slots)[:3])
        if g not in guids:
            flag("ERROR", "dead-guid",
                 "getObjectFromGUID(\"%s\") matches no object; %s" % (g, where))
        elif g in contained:
            flag("WARN", "guid-in-container",
                 "getObjectFromGUID(\"%s\") only matches an object inside a "
                 "container, where it does not resolve until taken out; %s"
                 % (g, where))

    # 5. XML image= names that no CustomUIAssets entry provides (TTS renders a
    #    blank box and logs nothing)
    assets = {a.get("Name") for a in (save.get("CustomUIAssets") or [])}
    for obj, _, _ in walk(save.get("ObjectStates", [])):
        assets |= {a.get("Name") for a in (obj.get("CustomUIAssets") or [])}
    for slot, field, text in all_scripts(save):
        if field != "XmlUI":
            continue
        for name in sorted(set(XML_IMAGE.findall(text))):
            if name not in assets:
                flag("ERROR", "missing-ui-asset",
                     "%s XmlUI uses image=\"%s\", which is not in CustomUIAssets"
                     % (slot, name))

    # 6. shared modules that have drifted apart (critique C5)
    for name, by_sha in shared_modules(save):
        slots = sorted({s for group in by_sha.values() for s in group})
        if len(by_sha) > 1:
            flag("ERROR", "drifted-module",
                 "%s exists in %d slots (%s) in %d DIFFERENT versions"
                 % (name, len(slots), ", ".join(slots), len(by_sha)))
        else:
            flag("WARN", "duplicated-module",
                 "%s is compiled into %d slots (%s); an edit must be applied to "
                 "all of them" % (name, len(slots), ", ".join(slots)))

    print("validate %s" % show(path))
    if not findings:
        print("  clean — no findings")
        return
    order = {"ERROR": 0, "WARN": 1}
    findings.sort(key=lambda f: (order.get(f[0], 2), f[1]))
    for level, code, msg in findings:
        print("  %-5s %-20s %s" % (level, code, msg))
    errors = sum(1 for f in findings if f[0] == "ERROR")
    print("\n%d finding(s): %d ERROR, %d WARN" % (
        len(findings), errors, len(findings) - errors))
    # 2 for an error, 0 for warnings only. A warning is something to read, not a
    # failed run: every one of these mods ships with warnings, and a build
    # script under `set -e` (reference/framework/demo/build.sh) would otherwise
    # report a perfectly good save as a failure.
    sys.exit(2 if errors else 0)


# --------------------------------------------------------------------------
# refs
#
# "What breaks if I delete this?", asked before rather than after. Scripts
# address objects by GUID, but mods also key off Nickname, Description and
# GMNotes (see the save-format.md caveat), so all of them are searched.

REF_FIELDS = ("LuaScript", "XmlUI", "GMNotes", "Description", "Nickname")


def cmd_refs(args):
    save = load(args.save)
    needle = args.needle.lower()
    hits, shown = 0, 0

    def scan(slot, field, text):
        nonlocal hits, shown
        for n, line in enumerate(text.splitlines(), 1):
            if needle not in line.lower():
                continue
            hits += 1
            if shown >= args.limit:
                continue
            shown += 1
            flat = line.strip()
            col = flat.lower().find(needle)
            if len(flat) > 110:
                start = max(0, col - 40)
                flat = ("..." if start else "") + flat[start:start + 110] + "..."
            print("  %-9s %-12s %5d  %s" % (slot, field, n, flat))

    for field in ("LuaScript", "XmlUI", "Note"):
        text = save.get(field) or ""
        if text.strip():
            scan("Global", field, text)
    for obj, jpath, _ in walk(save.get("ObjectStates", [])):
        slot = obj.get("GUID") or "noguid"
        for field in REF_FIELDS:
            text = obj.get(field) or ""
            if text.strip():
                scan(slot, field, text)
        if (obj.get("GUID") or "").lower() == needle:
            print("  %-9s %-12s %5s  %s  <- the object itself (%s, %s)" % (
                slot, "GUID", "", jpath, obj.get("Name"), label(obj) or "no nickname"))
            hits += 1
            shown += 1

    if not hits:
        print("no mention of %r in %s" % (args.needle, show(resolve(args.save))))
        return
    print("\n%d mention(s)%s" % (
        hits, ", %d shown (raise --limit)" % shown if hits > shown else ""))


# --------------------------------------------------------------------------
# authoring
#
# Everything above answers a question about a save. The four commands below make
# one: an empty table, a deck from an art sheet, a Saved Object inserted with
# fresh GUIDs, and a structural diff so that "change it by hand in TTS, then read
# the delta" becomes a workflow rather than a guess.
#
# The same two rules hold as for `lua inject`: an explicit -o that is never the
# input, and every byte written through dump_save(), so TTS does not silently
# reformat the whole file on its next save.

# TTS's key order at save level. Only used when creating a key that is missing;
# an existing save keeps whatever order it came with.
TOP_LEVEL_ORDER = [
    "SaveName", "EpochTime", "Date", "VersionNumber", "GameMode", "GameType",
    "GameComplexity", "PlayingTime", "PlayerCounts", "Tags", "Gravity",
    "PlayArea", "Table", "TableURL", "Sky", "SkyURL", "Note", "TabStates",
    "MusicPlayer", "Grid", "Lighting", "Hands", "ComponentTags", "Turns",
    "DecalPallet", "LuaScript", "LuaScriptState", "XmlUI", "CustomUIAssets",
    "SnapPoints", "VectorLines", "CameraStates", "ObjectStates",
]

# The same, per object. Type-specific blocks (Bag, CustomDeck, Text, ...) sit
# between Hands and LuaScript; AttachedSnapPoints comes after XmlUI.
OBJECT_ORDER = [
    "GUID", "Name", "Transform", "Nickname", "Description", "GMNotes",
    "AltLookAngle", "ColorDiffuse", "Tags", "LayoutGroupSortIndex", "Value",
    "Locked", "Grid", "Snap", "IgnoreFoW", "MeasureMovement", "DragSelectable",
    "Autoraise", "Sticky", "Tooltip", "GridProjection", "HideWhenFaceDown",
    "Hands",
]

# What TTS puts in LuaScript for a table nobody has scripted. Both of the
# owner's finished prototypes still carry exactly this.
LUA_STUB = (
    "--[[ Lua code. See documentation: https://api.tabletopsimulator.com/ --]]\n"
    "\n"
    "--[[ The onLoad event is called after the game save finishes loading. --]]\n"
    "function onLoad()\n"
    "    --[[ print('onLoad!') --]]\n"
    "end\n"
    "\n"
    "--[[ The onUpdate event is called once per frame. --]]\n"
    "function onUpdate()\n"
    "    --[[ print('onUpdate loop!') --]]\n"
    "end"
)

# The notebook tabs TTS creates for a new table: one per player colour, plus
# Rules. Written out rather than abbreviated, because TTS writes them all.
TAB_COLOURS = [
    ("Rules", "Grey", 0.5, 0.5, 0.5),
    ("White", "White", 1.0, 1.0, 1.0),
    ("Brown", "Brown", 0.443, 0.231, 0.09),
    ("Red", "Red", 0.856, 0.1, 0.094),
    ("Orange", "Orange", 0.956, 0.392, 0.113),
    ("Yellow", "Yellow", 0.905, 0.898, 0.172),
    ("Green", "Green", 0.192, 0.701, 0.168),
    ("Blue", "Blue", 0.118, 0.53, 1.0),
    ("Teal", "Teal", 0.129, 0.694, 0.607),
    ("Purple", "Purple", 0.627, 0.125, 0.941),
    ("Pink", "Pink", 0.96, 0.439, 0.807),
    ("Black", "Black", 0.25, 0.25, 0.25),
]


def tts_date(when):
    """TTS's Date string: US order, no zero padding, 12-hour clock."""
    hour = when.hour % 12 or 12
    return "%d/%d/%d %d:%02d:%02d %s" % (
        when.month, when.day, when.year, hour, when.minute, when.second,
        "AM" if when.hour < 12 else "PM")


def transform(pos=(0.0, 1.0, 0.0), rot=(0.0, 0.0, 0.0), scale=(1.0, 1.0, 1.0)):
    """A Transform block. Every value is a float: TTS rejects some int fields."""
    names = ("posX", "posY", "posZ", "rotX", "rotY", "rotZ",
             "scaleX", "scaleY", "scaleZ")
    return dict(zip(names, [float(v) for v in tuple(pos) + tuple(rot) + tuple(scale)]))


def parse_vector(text, flag):
    """Parse "x,y,z" (commas or spaces) into three floats."""
    parts = [p for p in re.split(r"[,\s]+", text.strip()) if p]
    if len(parts) != 3:
        die("%s wants three numbers, e.g. %s 0,1.2,-3" % (flag, flag))
    try:
        return [float(p) for p in parts]
    except ValueError:
        die("%s is not three numbers: %r" % (flag, text))


def ensure_key(holder, key, default, order):
    """Insert a missing key in TTS's own field order, rather than at the end.

    `order` is one of the lists above; the key lands before the first key that
    follows it there. Purely cosmetic — TTS loads any order — but a generated
    save that reads like one TTS wrote is far easier to diff against one that
    TTS did write.
    """
    if key in holder:
        return holder[key]
    later = set(order[order.index(key) + 1:]) if key in order else set()
    rebuilt = {}
    for name, value in holder.items():
        if name in later and key not in rebuilt:
            rebuilt[key] = default
        rebuilt[name] = value
    if key not in rebuilt:
        rebuilt[key] = default
    holder.clear()
    holder.update(rebuilt)
    return holder[key]


def all_guids(save):
    return {obj.get("GUID") for obj, _, _ in walk(save.get("ObjectStates", []))
            if obj.get("GUID")}


def mint_guid(taken, seed):
    """A free 6-hex GUID, derived from `seed` rather than drawn at random.

    Deriving it means the same build run twice produces the same save, so a
    generated save can be diffed against its predecessor and the only changes
    are the ones you made.
    """
    for salt in range(1 << 16):
        guid = hashlib.sha256(("%s|%d" % (seed, salt)).encode("utf-8")).hexdigest()[:6]
        if guid not in taken:
            taken.add(guid)
            return guid
    die("could not mint a free GUID after 65536 tries")


def regen_guids(objs, taken, seed):
    """Give every object in a subtree a fresh GUID. Returns {old: new}.

    A GUID is minted per instance, so two copies of one Saved Object must not
    share one: getObjectFromGUID cannot tell them apart, and TTS renumbers one
    of them on load anyway (critique C1).
    """
    mapping = {}
    for obj, path, _ in walk(objs):
        old = obj.get("GUID")
        obj["GUID"] = mint_guid(taken, "%s|%s|%s" % (seed, path, old))
        if old:
            mapping.setdefault(old, obj["GUID"])
    return mapping


REWRITE_FIELDS = ("LuaScript", "XmlUI", "GMNotes", "Description")


def rewrite_guid_refs(objs, mapping):
    """Point a subtree's own GUID references at its new GUIDs.

    A Saved Object that scripts its own children carries their GUIDs in its Lua
    and its GMNotes back-pointers (RotLA stores a supply item's home bag that
    way). Regenerating without this leaves it addressing objects that no longer
    exist. Only GUIDs belonging to this subtree are touched.
    """
    if not mapping:
        return 0
    # Bounded by "not a hex digit" rather than \b, so a GUID that happens to sit
    # inside a longer hex literal — a colour, a hash — is left alone.
    pattern = re.compile(
        "(?<![0-9a-fA-F])(?:%s)(?![0-9a-fA-F])"
        % "|".join(re.escape(g) for g in sorted(mapping)))
    hits = 0
    for obj, _, _ in walk(objs):
        for field in REWRITE_FIELDS:
            text = obj.get(field)
            if not isinstance(text, str) or not text:
                continue
            replaced, count = pattern.subn(lambda m: mapping[m.group()], text)
            if count:
                obj[field] = replaced
                hits += count
    return hits


def merge_component_tags(save, objs):
    """Declare the inserted objects' tags at save level.

    A component tag lives in two places: the Tags array on the object, and the
    save's ComponentTags.labels, which is the list TTS's own tag UI offers. An
    object may carry an undeclared tag — Rurik declares 147 and uses 61 — but
    then the tag is invisible in the UI and impossible to apply to anything else.
    """
    tags = ensure_key(save, "ComponentTags", {"labels": []}, TOP_LEVEL_ORDER)
    labels = tags.setdefault("labels", [])
    known = {entry.get("normalized") for entry in labels}
    added = []
    for obj, _, _ in walk(objs):
        for tag in obj.get("Tags") or []:
            if tag.lower() in known:
                continue
            known.add(tag.lower())
            labels.append({"displayed": tag, "normalized": tag.lower()})
            added.append(tag)
    return added


def cmd_new(args):
    """An empty table, in TTS's own key order and with TTS's own defaults."""
    out = check_new_out(args.out, args.force)
    now = dt.datetime.now()
    tabs = {}
    for i, (title, colour, r, g, b) in enumerate(TAB_COLOURS):
        tabs[str(i)] = {
            "title": title, "body": "", "color": colour,
            "visibleColor": {"r": r, "g": g, "b": b}, "id": i,
        }

    save = {
        "SaveName": args.name,
        "EpochTime": int(now.timestamp()),
        "Date": tts_date(now),
        "VersionNumber": args.version,
        "GameMode": args.name if args.mode is None else args.mode,
        "GameType": "",
        "GameComplexity": "",
        "Tags": [],
        "Gravity": 0.5,
        "PlayArea": 0.5,
        "Table": args.table,
        "Sky": args.sky,
        "Note": "",
        "TabStates": tabs,
        "Grid": {
            "Type": 0, "Lines": False,
            "Color": {"r": 0.0, "g": 0.0, "b": 0.0},
            "Opacity": 0.75, "ThickLines": False, "Snapping": False,
            "Offset": False, "BothSnapping": False, "xSize": 2.0, "ySize": 2.0,
            "PosOffset": {"x": 0.0, "y": 1.0, "z": 0.0},
        },
        "Lighting": {
            "LightIntensity": 0.54,
            "LightColor": {"r": 1.0, "g": 0.9804, "b": 0.8902},
            "AmbientIntensity": 1.3, "AmbientType": 0,
            "AmbientSkyColor": {"r": 0.5, "g": 0.5, "b": 0.5},
            "AmbientEquatorColor": {"r": 0.5, "g": 0.5, "b": 0.5},
            "AmbientGroundColor": {"r": 0.5, "g": 0.5, "b": 0.5},
            "ReflectionIntensity": 1.0, "LutIndex": 0, "LutContribution": 1.0,
        },
        "Hands": {"Enable": True, "DisableUnused": False, "Hiding": 0},
        "ComponentTags": {"labels": []},
        "Turns": {
            "Enable": False, "Type": 0, "TurnOrder": [], "Reverse": False,
            "SkipEmpty": False, "DisableInteractions": False,
            "PassTurns": True, "TurnColor": "",
        },
        "DecalPallet": [],
        "LuaScript": "" if args.no_stub else LUA_STUB,
        "LuaScriptState": "",
        "XmlUI": "" if args.no_stub else XML_STUB,
        "ObjectStates": [],
    }
    write_save(save, out)
    print("wrote %s — an empty %s table named %r" % (args.out, args.table, args.name))
    print("Add components with `tts.py object add`, a script with `tts.py lua inject`.")


def saved_object(objs):
    """Wrap objects as a Saved Object file.

    A Saved Object is a save with the same schema holding one component, which is
    the whole trick to a reusable part (docs/save-format.md). TTS writes every
    metadata field empty in one, so this does too.
    """
    return {
        "SaveName": "", "Date": "", "VersionNumber": "", "GameMode": "",
        "GameType": "", "GameComplexity": "", "Tags": [],
        "Gravity": 0.5, "PlayArea": 0.5, "Table": "", "Sky": "", "Note": "",
        "TabStates": {}, "LuaScript": "", "LuaScriptState": "", "XmlUI": "",
        "ObjectStates": objs,
    }


def cmd_deck_build(args):
    """A DeckCustom from one art sheet, honouring CardID = sheet * 100 + index."""
    out = check_new_out(args.out, args.force)
    if args.cols < 1 or args.rows < 1:
        die("--cols and --rows must be at least 1")
    slots = args.cols * args.rows
    if slots > 100:
        die("a %dx%d sheet has %d slots, but CardID is sheet * 100 + a "
            "zero-based index, so slot 100 and up would decode as sheet %d; "
            "split the art across several sheets"
            % (args.cols, args.rows, slots, args.sheet + 1))
    count = args.count if args.count is not None else slots
    if count > slots:
        die("--count %d exceeds the %dx%d sheet's %d slots"
            % (count, args.cols, args.rows, slots))
    if count < 2:
        die("a deck needs at least 2 cards; TTS collapses a one-card deck to a Card")
    if args.sheet < 1:
        die("--sheet must be a positive whole number: CardID is sheet * 100 + index")

    names = []
    if args.names:
        names = read_text(resolve(args.names)).splitlines()
        if len(names) > count:
            die("%s holds %d names for %d cards" % (args.names, len(names), count))

    sheet = str(args.sheet)
    art = {
        "FaceURL": args.face,
        "BackURL": args.back,
        "NumWidth": args.cols,
        "NumHeight": args.rows,
        "BackIsHidden": bool(args.back_is_hidden),
        "UniqueBack": bool(args.unique_back),
        "Type": 0,
    }
    card_ids = [args.sheet * 100 + i for i in range(count)]

    at = parse_vector(args.at, "--at") if args.at else [0.0, 1.5, 0.0]
    spin = 180.0 if args.face_down else 0.0
    taken = set()
    tags = list(args.tag or [])

    def component(name, guid, extra, nickname=""):
        """One card or the deck itself, in TTS's own field order.

        A contained card gets the deck's transform: TTS recomputes the transform
        of everything inside a container when it instantiates it, and what real
        decks store there is arbitrary — one in TS_Save_100 has its cards
        scattered over 0.45 of world Y for no reason anybody can reconstruct.
        """
        obj = {
            "GUID": guid,
            "Name": name,
            "Transform": transform(pos=at, rot=(0.0, 180.0, spin)),
            "Nickname": nickname,
            "Description": "",
            "GMNotes": "",
            "AltLookAngle": {"x": 0.0, "y": 0.0, "z": 0.0},
            "ColorDiffuse": {"r": 0.713235259, "g": 0.713235259, "b": 0.713235259},
        }
        if tags:
            obj["Tags"] = list(tags)
        obj.update({
            "LayoutGroupSortIndex": 0, "Value": 0, "Locked": False,
            "Grid": True, "Snap": True, "IgnoreFoW": False,
            "MeasureMovement": False, "DragSelectable": True, "Autoraise": True,
            "Sticky": True, "Tooltip": name != "CardCustom",
            "GridProjection": False,
            "HideWhenFaceDown": bool(args.back_is_hidden),
            "Hands": name == "CardCustom",
        })
        obj.update(extra)
        obj.update({"LuaScript": "", "LuaScriptState": "", "XmlUI": ""})
        return obj

    cards = []
    for i, card_id in enumerate(card_ids):
        nickname = names[i].strip() if i < len(names) else ""
        cards.append(component(
            "CardCustom",
            mint_guid(taken, "card|%s|%s|%d" % (args.face, sheet, card_id)),
            {"CardID": card_id, "SidewaysCard": bool(args.sideways),
             "CustomDeck": {sheet: dict(art)}},
            nickname=nickname))

    deck = component(
        "DeckCustom",
        mint_guid(taken, "deck|%s|%s" % (args.face, sheet)),
        {"SidewaysCard": bool(args.sideways), "DeckIDs": list(card_ids),
         "CustomDeck": {sheet: dict(art)}},
        nickname=args.name or "")
    deck["ContainedObjects"] = cards

    write_save(saved_object([deck]), out)
    print("wrote %s" % args.out)
    print("  %d card(s) from a %dx%d sheet, CardID %d..%d on CustomDeck key %s"
          % (count, args.cols, args.rows, card_ids[0], card_ids[-1], sheet))
    if names:
        print("  %d card(s) named from %s" % (len(names), args.names))
    if count < slots:
        print("  %d sheet slot(s) left unused" % (slots - count))
    local = cache_path(args.face, "FaceURL")
    print("  face art %s" % (local if local else "NOT in the Mods/ cache yet — "
                             "TTS downloads it on first load"))
    print("\nThis is a Saved Object. Put it on a table with:")
    print("  tts.py object add <save> %s -o Saves/TS_Save_<new>.json" % args.out)


def load_objects(path):
    """Read a Saved Object, a whole save, or a single bare object."""
    data = load(path)
    if not isinstance(data, dict):
        die("%s is not a TTS object file" % path)
    if "ObjectStates" in data:
        objs = data.get("ObjectStates") or []
        if not objs:
            die("%s has an empty ObjectStates" % path)
        return objs
    if data.get("Name"):
        return [data]
    die("%s is neither a Saved Object (no ObjectStates) nor one object (no Name)"
        % path)


def cmd_object_add(args):
    """Insert a Saved Object into a save, with GUIDs minted fresh."""
    out = check_out(args)
    save = load(args.save)
    source = resolve(args.source)
    objs = load_objects(args.source)

    taken = all_guids(save)
    at = parse_vector(args.at, "--at") if args.at else None
    spacing = parse_vector(args.spacing, "--spacing") if args.spacing else None
    if args.count < 1:
        die("--count must be at least 1")

    added, rewrites = [], 0
    for copy_index in range(args.count):
        batch = copy.deepcopy(objs)
        mapping = regen_guids(batch, taken, "%s#%d" % (show(source), copy_index))
        if not args.keep_refs:
            rewrites += rewrite_guid_refs(batch, mapping)

        for obj in batch:
            if at is not None or spacing is not None:
                tr = obj.get("Transform")
                if not isinstance(tr, dict):
                    tr = transform()
                    obj["Transform"] = tr
                base = at if at is not None else (
                    tr.get("posX", 0.0), tr.get("posY", 1.0), tr.get("posZ", 0.0))
                step = [(spacing[i] * copy_index) if spacing else 0.0 for i in range(3)]
                tr["posX"] = float(base[0]) + step[0]
                tr["posY"] = float(base[1]) + step[1]
                tr["posZ"] = float(base[2]) + step[2]
            if args.nickname is not None:
                obj["Nickname"] = args.nickname
            if args.tag:
                current = ensure_key(obj, "Tags", [], OBJECT_ORDER)
                for tag in args.tag:
                    if tag not in current:
                        current.append(tag)
            if args.lock:
                obj["Locked"] = True

        save.setdefault("ObjectStates", []).extend(batch)
        added.extend(batch)

    declared = merge_component_tags(save, added)
    write_save(save, out)

    print("wrote %s" % args.out)
    print("  added %d object(s) from %s" % (len(added), show(source)))
    for obj in added[:10]:
        nested = len(list(walk([obj]))) - 1
        print("    %-7s %-22s %-24s%s" % (
            obj.get("GUID"), obj.get("Name", "?"), label(obj),
            "  (%d inside)" % nested if nested else ""))
    if len(added) > 10:
        print("    ... %d more" % (len(added) - 10))
    if rewrites:
        print("  rewrote %d GUID reference(s) inside the inserted scripts and notes"
              % rewrites)
    if declared:
        print("  declared component tag(s): %s" % ", ".join(sorted(set(declared))))
    print("\nRun `tts.py validate %s` before loading it." % args.out)


# --------------------------------------------------------------------------
# diff
#
# TTS is the only editor that knows every field's meaning, so the fastest way to
# learn what a field does is to change it in TTS, save to a new slot, and read
# the delta. That is only practical if the delta is a page rather than a 100,000
# line JSON diff — which is what this prints.

VOLATILE_KEYS = ("EpochTime", "Date", "VersionNumber")


def brief(value, width=64):
    """Render a value short enough for one line of a diff."""
    if isinstance(value, str):
        return json.dumps(value, ensure_ascii=False) if len(value) <= width \
            else "<%d chars>" % len(value)
    text = json.dumps(value, ensure_ascii=False)
    if len(text) <= width:
        return text
    if isinstance(value, list):
        return "<%d items>" % len(value)
    if isinstance(value, dict):
        return "<%d keys>" % len(value)
    return text[:width] + "..."


def transform_delta(old, new, epsilon):
    """How far an object moved, ignoring physics jitter below epsilon.

    Every save re-records positions a few thousandths off, so an unfiltered
    comparison reports every object in the save as changed.
    """
    parts = []
    for prefix in ("pos", "rot", "scale"):
        deltas = []
        for axis in "XYZ":
            key = prefix + axis
            delta = float(new.get(key, 0.0)) - float(old.get(key, 0.0))
            if prefix == "rot":
                # 359.99 -> 0.01 is a hundredth of a degree, not 359.98.
                delta = (delta + 180.0) % 360.0 - 180.0
            deltas.append(delta)
        if max(abs(d) for d in deltas) > epsilon:
            parts.append("%s %+.3f %+.3f %+.3f" % tuple([prefix] + deltas))
    return "; ".join(parts)


MAX_DELTA_ROWS = 200


def value_delta(before, after, prefix="", depth=0, out=None):
    """Rows describing how two values differ, descending into dicts and lists.

    Every settings block TTS writes is a nested dict, and "Turns changed" is no
    answer to "what did that checkbox do" — `Turns.Enable false -> true` is.
    Three levels reaches the deepest thing TTS writes (Grid.Color.r).
    """
    if out is None:
        out = []
    if len(out) >= MAX_DELTA_ROWS:
        return out

    same_kind = isinstance(before, dict) == isinstance(after, dict) \
        and isinstance(before, list) == isinstance(after, list)
    if depth >= 3 or not same_kind or not isinstance(before, (dict, list)):
        if isinstance(before, str) and isinstance(after, str) \
                and max(len(before), len(after)) > 64:
            out.append((prefix, "%d -> %d chars" % (len(before), len(after))))
        else:
            out.append((prefix, "%s -> %s" % (brief(before), brief(after))))
        return out

    if isinstance(before, dict):
        for key in list(before) + [k for k in after if k not in before]:
            name = "%s.%s" % (prefix, key) if prefix else key
            if key not in before:
                out.append((name, "added %s" % brief(after[key])))
            elif key not in after:
                out.append((name, "removed %s" % brief(before[key])))
            elif before[key] != after[key]:
                value_delta(before[key], after[key], name, depth + 1, out)
        return out

    if len(before) != len(after):
        out.append((prefix, "%d -> %d items" % (len(before), len(after))))
        return out
    for i, (left, right) in enumerate(zip(before, after)):
        if left != right:
            value_delta(left, right, "%s[%d]" % (prefix, i), depth + 1, out)
    return out


def object_delta(old, new, epsilon):
    """[(field, how it changed)] for one matched pair of objects."""
    out = []
    for key in list(old) + [k for k in new if k not in old]:
        if key == "States":
            continue
        before, after = old.get(key), new.get(key)
        if key == "ContainedObjects":
            counts = (len(before or []), len(after or []))
            if counts[0] != counts[1]:
                out.append((key, "%d -> %d items" % counts))
            continue
        if before == after:
            continue
        if key == "Transform":
            moved = transform_delta(before or {}, after or {}, epsilon)
            if moved:
                out.append((key, moved))
            continue
        value_delta(before, after, key, 0, out)
    return out


def cmd_diff(args):
    a, b = load(args.a), load(args.b)
    print("diff %s" % show(resolve(args.a)))
    print("  -> %s" % show(resolve(args.b)))

    # 1. table settings
    keys = list(a) + [k for k in b if k not in a]
    rows = []
    for key in keys:
        if key == "ObjectStates" or (key in VOLATILE_KEYS and not args.all):
            continue
        if key not in a:
            rows.append(("+", key, brief(b[key])))
        elif key not in b:
            rows.append(("-", key, brief(a[key])))
        elif a[key] != b[key]:
            for name, how in value_delta(a[key], b[key], key):
                rows.append(("~", name, how))
    print("\nsettings")
    if not rows:
        print("  (identical%s)" % ("" if args.all else ", ignoring the date and "
                                   "version; --all shows them"))
    for mark, key, text in rows[:args.limit]:
        print("  %s %-28s %s" % (mark, key, text))
    if len(rows) > args.limit:
        print("  ... %d more (raise --limit)" % (len(rows) - args.limit))

    # 2. objects, matched by GUID. A GUID is unique per scope rather than per
    #    file, so several objects can share one; match those up in tree order.
    def index(save):
        found = {}
        for obj, path, _ in walk(save.get("ObjectStates", [])):
            found.setdefault(obj.get("GUID"), []).append((path, obj))
        return found

    index_a, index_b = index(a), index(b)
    total_a = sum(len(v) for v in index_a.values())
    total_b = sum(len(v) for v in index_b.values())

    added, removed, changed = [], [], []
    for guid in sorted(set(index_a) | set(index_b), key=lambda g: (g is None, g)):
        left, right = index_a.get(guid, []), index_b.get(guid, [])
        for i in range(max(len(left), len(right))):
            if i >= len(right):
                removed.append((guid, left[i][0], left[i][1]))
            elif i >= len(left):
                added.append((guid, right[i][0], right[i][1]))
            else:
                fields = object_delta(left[i][1], right[i][1], args.epsilon)
                if fields:
                    changed.append((guid, right[i][0], right[i][1], fields))

    print("\nobjects   %d -> %d including nested   (+%d, -%d, %d changed)"
          % (total_a, total_b, len(added), len(removed), len(changed)))

    def listing(title, entries):
        if not entries:
            return
        print("\n%s (%d)" % (title, len(entries)))
        for guid, path, obj in entries[:args.limit]:
            print("  %-7s %-22s %-24s %s" % (
                guid, obj.get("Name", "?"), label(obj), path))
        if len(entries) > args.limit:
            print("  ... %d more (raise --limit)" % (len(entries) - args.limit))

    listing("added", added)
    listing("removed", removed)

    if changed:
        print("\nchanged (%d)" % len(changed))
        for guid, path, obj, fields in changed[:args.limit]:
            print("  %-7s %-22s %-24s %s" % (
                guid, obj.get("Name", "?"), label(obj), path))
            if args.full:
                for name, how in fields:
                    print("      %-18s %s" % (name, how))
            else:
                print("      %s" % ", ".join(name for name, _ in fields))
        if len(changed) > args.limit:
            print("  ... %d more (raise --limit)" % (len(changed) - args.limit))


def cmd_selftest(args):
    """Prove the writer still matches TTS, over every save and mod on disk.

    The one thing that could silently invalidate every file this tool writes is
    TTS changing its serializer in an update. Re-run this after a TTS upgrade.
    """
    files = sorted(glob.glob(os.path.join(ROOT, "Saves", "**", "*.json"), recursive=True))
    files += sorted(glob.glob(os.path.join(ROOT, "Mods", "Workshop", "*.json")))
    ok, bad, skipped = 0, [], 0
    for path in files:
        if os.path.basename(path) in ("SaveFileInfos.json", "WorkshopFileInfos.json"):
            continue
        try:
            with open(path, "rb") as fh:
                raw = fh.read()
            save = json.loads(raw.decode("utf-8"))
        except (ValueError, OSError):
            skipped += 1
            continue
        if dump_save(save).encode("utf-8") == raw:
            ok += 1
        else:
            bad.append(show(path))
    print("round-trip load -> dump_save over %d file(s)" % (ok + len(bad)))
    print("  byte-identical %d, differs %d, unreadable %d" % (ok, len(bad), skipped))
    for name in bad[:20]:
        print("  DIFFERS %s" % name)
    if bad:
        print("\nThe writer no longer matches TTS. Saves this tool writes will be "
              "reformatted by TTS on its next save; check cs_number().")
        sys.exit(1)
    print("  the writer matches TTS byte for byte")


def cmd_inventory(args):
    out = args.out or os.path.join(ROOT, "docs", "inventory.md")

    names = {}
    infos = os.path.join(ROOT, "Saves", "SaveFileInfos.json")
    if os.path.exists(infos):
        with open(infos, encoding="utf-8") as fh:
            for entry in json.load(fh):
                key = os.path.basename(entry["Directory"].replace("//", "/"))
                names[key] = (entry["Name"], entry["UpdateTime"])

    rows = []
    pattern = os.path.join(ROOT, "Saves", "**", "TS_*.json")
    for path in sorted(glob.glob(pattern, recursive=True)):
        rel = os.path.relpath(path, ROOT)
        try:
            with open(path, encoding="utf-8") as fh:
                save = json.load(fh)
        except (ValueError, OSError) as exc:
            rows.append((0, rel, "UNREADABLE (%s)" % exc, "", 0, 0, ""))
            continue
        base = os.path.basename(path)
        folder = os.path.basename(os.path.dirname(path))
        display, stamp = names.get(base, (save.get("SaveName") or "", 0))
        if not stamp:
            stamp = save.get("EpochTime") or int(os.path.getmtime(path))
        rows.append((
            stamp, rel, save.get("SaveName") or "", display,
            len(save.get("ObjectStates") or []),
            len(save.get("LuaScript") or ""),
            "" if folder == "Saves" else folder,
        ))
    rows.sort(reverse=True)

    mods = []
    winfo = os.path.join(ROOT, "Mods", "Workshop", "WorkshopFileInfos.json")
    if os.path.exists(winfo):
        with open(winfo, encoding="utf-8") as fh:
            for entry in json.load(fh):
                mods.append((
                    entry["Name"],
                    os.path.basename(entry["Directory"].replace("//", "/")),
                ))
    mods.sort(key=lambda m: m[0].lower())

    lines = [
        "# Inventory",
        "",
        "Generated by `scripts/tts.py inventory` on %s. Regenerate after saving "
        "from TTS." % dt.date.today().isoformat(),
        "",
        "## Saves (%d)" % len(rows),
        "",
        "Newest first. `Lua` is the size of the global script in characters — a "
        "large number means the save came from a scripted mod.",
        "",
        "| File | Save name | Date | Objects | Lua | Folder |",
        "| --- | --- | --- | --- | --- | --- |",
    ]
    for stamp, rel, name, display, nobj, nlua, folder in rows:
        when = dt.datetime.fromtimestamp(stamp).strftime("%Y-%m-%d") if stamp else ""
        lines.append("| `%s` | %s | %s | %d | %s | %s |" % (
            rel, name or "—", when, nobj,
            "{:,}".format(nlua) if nlua else "—", folder or "—"))

    lines += [
        "",
        "## Workshop mods (%d)" % len(mods),
        "",
        "Each lives at `Mods/Workshop/<id>.json` with a `.png` thumbnail beside it. "
        "The id is the Steam Workshop item id, so "
        "`steamcommunity.com/sharedfiles/filedetails/?id=<id>` is the mod page.",
        "",
        "| Mod | File |",
        "| --- | --- |",
    ]
    for name, fname in mods:
        lines.append("| %s | `Mods/Workshop/%s` |" % (name.replace("|", "\\|"), fname))
    lines.append("")

    os.makedirs(os.path.dirname(out), exist_ok=True)
    with open(out, "w", encoding="utf-8") as fh:
        fh.write("\n".join(lines))
    print("wrote %s — %d saves, %d mods" % (show(out), len(rows), len(mods)))


# --------------------------------------------------------------------------


def main():
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = parser.add_subparsers(dest="cmd", required=True)

    p = sub.add_parser("summary", help="overview of a save without dumping it")
    p.add_argument("save")
    p.set_defaults(func=cmd_summary)

    p = sub.add_parser("tree", help="the ObjectStates hierarchy, with paths")
    p.add_argument("save")
    p.add_argument("--depth", type=int, help="max nesting depth to show (0 = top level)")
    p.add_argument("--filter", help="only objects whose type matches, e.g. Deck")
    p.add_argument("--nickname", help="only objects whose nickname matches")
    p.set_defaults(func=cmd_tree)

    p = sub.add_parser("get", help="print one object by the path `tree` printed")
    p.add_argument("save")
    p.add_argument("path")
    p.add_argument("--no-children", action="store_true",
                   help="omit ContainedObjects and States")
    p.set_defaults(func=cmd_get)

    p = sub.add_parser("urls", help="asset URLs in a save and where they cache to")
    p.add_argument("save")
    p.add_argument("--missing-only", action="store_true")
    p.add_argument("--paths", action="store_true", help="also show the JSON path")
    p.set_defaults(func=cmd_urls)

    p = sub.add_parser("find-asset", help="URL -> cache file, or cache file -> savers")
    p.add_argument("target")
    p.set_defaults(func=cmd_find_asset)

    p = sub.add_parser("refs", help="every mention of a GUID or nickname in a save")
    p.add_argument("save")
    p.add_argument("needle", help="a GUID, nickname or any text (case-insensitive)")
    p.add_argument("--limit", type=int, default=100, help="max lines to print")
    p.set_defaults(func=cmd_refs)

    p = sub.add_parser("validate", help="check a save's invariants; reports, never writes")
    p.add_argument("save")
    p.set_defaults(func=cmd_validate)

    p = sub.add_parser("corpus", help="write a save's Lua and XML out as a grep corpus")
    p.add_argument("save")
    p.add_argument("-o", "--out", required=True, help="output directory, e.g. reference/mods/arcs")
    p.set_defaults(func=cmd_corpus)

    p = sub.add_parser("lua", help="extract or inject Lua")
    lsub = p.add_subparsers(dest="luacmd", required=True)

    q = lsub.add_parser("extract", help="write Lua out as real .lua files")
    q.add_argument("save")
    q.add_argument("--object", help="GUID of one object instead of the global script")
    q.add_argument("--list", action="store_true", help="list Lua holders, write nothing")
    q.add_argument("-o", "--out", help="output directory (default scripts/lua-out)")
    q.set_defaults(func=cmd_lua_extract)

    q = lsub.add_parser("inject", help="re-embed Lua into a NEW save file")
    q.add_argument("save")
    q.add_argument("source", help="a .lua file, or a slot dir from `lua extract`")
    q.add_argument("-o", "--out", required=True, help="new save path (must not be the input)")
    q.add_argument("--object", help="GUID to write into instead of the global script")
    q.add_argument("--force", action="store_true", help="allow overwriting -o")
    q.set_defaults(func=cmd_lua_inject)

    p = sub.add_parser("xml", help="extract or inject XML UI")
    xsub = p.add_subparsers(dest="xmlcmd", required=True)

    q = xsub.add_parser("extract", help="write XmlUI out as real .xml files")
    q.add_argument("save")
    q.add_argument("--object", help="GUID of one object instead of the global UI")
    q.add_argument("--list", action="store_true", help="list XML holders, write nothing")
    q.add_argument("-o", "--out", help="output directory (default scripts/xml-out)")
    q.set_defaults(func=cmd_xml_extract)

    q = xsub.add_parser("inject", help="re-embed XML UI into a NEW save file")
    q.add_argument("save")
    q.add_argument("source", help="a .xml file, or a slot dir from `xml extract`")
    q.add_argument("-o", "--out", required=True, help="new save path (must not be the input)")
    q.add_argument("--object", help="GUID to write into instead of the global UI")
    q.add_argument("--force", action="store_true", help="allow overwriting -o")
    q.set_defaults(func=cmd_xml_inject)

    p = sub.add_parser("diff", help="structural diff of two saves")
    p.add_argument("a", help="the older save")
    p.add_argument("b", help="the newer save")
    p.add_argument("--full", action="store_true",
                   help="show how each field changed, not just which")
    p.add_argument("--all", action="store_true",
                   help="include the date and version, which always differ")
    p.add_argument("--epsilon", type=float, default=0.001,
                   help="ignore movement below this (default 0.001: physics jitter)")
    p.add_argument("--limit", type=int, default=40, help="max objects per section")
    p.set_defaults(func=cmd_diff)

    p = sub.add_parser("new", help="create an empty save to build a prototype in")
    p.add_argument("-o", "--out", required=True, help="new save path")
    p.add_argument("--name", default="Untitled", help="SaveName (default Untitled)")
    p.add_argument("--mode", help="GameMode (defaults to --name)")
    p.add_argument("--table", default="Table_RPG", help="e.g. Table_None, Table_Custom")
    p.add_argument("--sky", default="Sky_Museum")
    p.add_argument("--version", default="v14.2.2", help="VersionNumber to record")
    p.add_argument("--no-stub", action="store_true",
                   help="leave LuaScript and XmlUI empty instead of TTS's stubs")
    p.add_argument("--force", action="store_true", help="allow overwriting -o")
    p.set_defaults(func=cmd_new)

    p = sub.add_parser("deck", help="build a deck from an art sheet")
    dsub = p.add_subparsers(dest="deckcmd", required=True)

    q = dsub.add_parser("build", help="a Saved Object holding one DeckCustom")
    q.add_argument("--face", required=True, help="URL of the card-face sheet")
    q.add_argument("--back", required=True, help="URL of the card back")
    q.add_argument("--cols", type=int, required=True, help="sheet columns (NumWidth)")
    q.add_argument("--rows", type=int, required=True, help="sheet rows (NumHeight)")
    q.add_argument("--count", type=int,
                   help="cards to use, in reading order (default the whole sheet)")
    q.add_argument("--sheet", type=int, default=1,
                   help="CustomDeck key; CardID is sheet * 100 + index (default 1)")
    q.add_argument("--name", help="Nickname for the deck")
    q.add_argument("--names", help="file of card nicknames, one per line, in order")
    q.add_argument("--tag", action="append", help="component tag (repeatable)")
    q.add_argument("--at", help="position as X,Y,Z (default 0,1.5,0)")
    q.add_argument("--unique-back", action="store_true",
                   help="the back URL is a sheet of per-card backs, not one image")
    q.add_argument("--back-is-hidden", action="store_true",
                   help="show the back, not the face, to players who cannot see it")
    q.add_argument("--sideways", action="store_true", help="landscape cards")
    q.add_argument("--face-down", action="store_true", help="start face down")
    q.add_argument("-o", "--out", required=True, help="Saved Object path to write")
    q.add_argument("--force", action="store_true", help="allow overwriting -o")
    q.set_defaults(func=cmd_deck_build)

    p = sub.add_parser("object", help="add a Saved Object to a save")
    osub = p.add_subparsers(dest="objcmd", required=True)

    q = osub.add_parser("add", help="insert a Saved Object with fresh GUIDs")
    q.add_argument("save")
    q.add_argument("source", help="a Saved Object, a save, or one object as JSON")
    q.add_argument("-o", "--out", required=True, help="new save path (not the input)")
    q.add_argument("--at", help="position as X,Y,Z; default is where it was saved")
    q.add_argument("--count", type=int, default=1, help="how many copies to insert")
    q.add_argument("--spacing", help="offset per copy as X,Y,Z, e.g. 1.5,0,0")
    q.add_argument("--tag", action="append", help="component tag to add (repeatable)")
    q.add_argument("--nickname", help="override the Nickname")
    q.add_argument("--lock", action="store_true", help="insert locked")
    q.add_argument("--keep-refs", action="store_true",
                   help="do not repoint the object's own GUID references")
    q.add_argument("--force", action="store_true", help="allow overwriting -o")
    q.set_defaults(func=cmd_object_add)

    p = sub.add_parser("selftest", help="check this tool still writes what TTS writes")
    p.set_defaults(func=cmd_selftest)

    p = sub.add_parser("inventory", help="regenerate docs/inventory.md")
    p.add_argument("-o", "--out")
    p.set_defaults(func=cmd_inventory)

    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
