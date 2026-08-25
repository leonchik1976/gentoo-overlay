#!/usr/bin/env python3
"""Generate deterministic app-misc/openclaw-bin npm distfile metadata from
npm-shrinkwrap.json, restricted to the linux/amd64+arm64 dependency closure
needed to assemble node_modules without network access at build time.

Unlike app-backup/restic-browser's generator (which builds and therefore
must select a single arch's native npm packages), openclaw-bin is a -bin
package: it vendors upstream's own prebuilt npm-published tarball as-is and
only needs a *runtime* node_modules tree. The overwhelming majority of
openclaw's locked dependencies are plain JS with no os/cpu constraint at
all, so most entries apply to both KEYWORDS. Only a couple of optional
native-binary packages (@lydell/node-pty, sqlite-vec) publish per-platform
variant packages; for those this script keeps just the linux-x64 and
linux-arm64 variants (both -- picked at install time by ARCH, see the
ebuild) and drops darwin/win32 variants entirely.
"""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

# npm packages that publish OS/CPU-specific variant packages (not the base
# package itself, which has no os/cpu constraint and is always vendored).
# Maps npm-shrinkwrap.json node_modules path -> Gentoo ARCH this variant
# should be vendored for ("amd64" or "arm64"), or None to drop it.
_LINUX_VARIANT_ARCH = {
    "node_modules/@lydell/node-pty-linux-x64": "amd64",
    "node_modules/@lydell/node-pty-linux-arm64": "arm64",
    "node_modules/sqlite-vec-linux-x64": "amd64",
    "node_modules/sqlite-vec-linux-arm64": "arm64",
}

# Non-Linux variant packages of the same two native-addon families: safe
# to drop, since this overlay only ever builds for linux/amd64+arm64.
_KNOWN_SKIP_PREFIXES = (
    "node_modules/@lydell/node-pty-darwin-",
    "node_modules/@lydell/node-pty-win32-",
    "node_modules/sqlite-vec-darwin-",
    "node_modules/sqlite-vec-windows-",
)


def distfile(name: str, version: str) -> str:
    safe_name = re.sub(r"[^A-Za-z0-9+_.-]", "-", name.lstrip("@"))
    safe_version = re.sub(r"[^A-Za-z0-9+_.-]", "-", version)
    return f"openclaw-bin-npm-{safe_name}-{safe_version}.tgz"


# SPDX-like syntax (not validation against the SPDX license list): one or
# more tokens (letters,
# digits, '.', '-', '+') optionally joined by "AND"/"OR"/"WITH" (proper SPDX
# operators) and optionally wrapped in a single pair of parens -- matches
# every license string actually seen in openclaw's dependency closure, e.g.
# "MIT", "0BSD", "BlueOak-1.0.0", "(MIT AND Zlib)",
# "(MIT OR GPL-3.0-or-later)", and npm's own slightly-off-SPDX "MIT OR
# Apache". A bare alnum-token regex alone would also accept npm's known
# non-answer placeholder strings ("UNKNOWN", "UNLICENSED" -- npm's literal
# marker for "no license declared", not to be confused with the real SPDX
# id "Unlicense"), so those are rejected by name below before the regex
# even runs.
_LICENSE_TOKEN = r"[A-Za-z0-9][A-Za-z0-9.+-]*"
_LICENSE_EXPR_RE = re.compile(
    rf"^\(?{_LICENSE_TOKEN}(?:\s+(?:AND|OR|WITH)\s+{_LICENSE_TOKEN})*\)?$"
)
_LICENSE_DENYLIST = {"UNKNOWN", "UNLICENSED", "PROPRIETARY", "NONE", "NOASSERTION"}


def validate_license(path: str, version: str, text: str) -> None:
    if text.strip().upper() in _LICENSE_DENYLIST:
        raise SystemExit(
            f"{path}@{version}: license is a known non-answer placeholder "
            f"({text!r}) -- this package has no real declared license, do "
            "not vendor it without manually confirming its actual terms"
        )
    if "://" in text:
        raise SystemExit(
            f"{path}@{version}: non-SPDX-like license ({text!r}) -- looks like a "
            "URL pointer (the pattern proprietary packages use instead of "
            "a plain SPDX identifier) -- do not vendor without updating "
            "the license accounting"
        )
    if not _LICENSE_EXPR_RE.match(text):
        raise SystemExit(
            f"{path}@{version}: license ({text!r}) does not look like a "
            "plain SPDX identifier/expression -- do not vendor without "
            "manually confirming its actual terms and, if genuinely valid, "
            "extending _LICENSE_EXPR_RE to accept it"
        )


def wanted(path: str, info: dict) -> str | None:
    """Return None to skip, "" for arch-independent, or "amd64"/"arm64"."""
    os_ = info.get("os")
    cpu_ = info.get("cpu")
    if not os_ and not cpu_:
        return ""
    if path in _LINUX_VARIANT_ARCH:
        return _LINUX_VARIANT_ARCH[path]
    if path.startswith(_KNOWN_SKIP_PREFIXES):
        return None
    # Any other platform-locked package we don't know about: refuse to
    # silently drop or silently include a possibly-wrong variant.
    raise SystemExit(
        f"{path}: unrecognized os/cpu-constrained package (os={os_!r} "
        f"cpu={cpu_!r}); add it to _LINUX_VARIANT_ARCH or confirm it's "
        "safe to skip"
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("version")
    parser.add_argument("lockfile", type=Path, help="npm-shrinkwrap.json")
    parser.add_argument("output", type=Path)
    parser.add_argument(
        "license_summary_output",
        type=Path,
        help="deterministic name@version -> license text file, for dodoc",
    )
    args = parser.parse_args()

    lock = json.loads(args.lockfile.read_text(encoding="utf-8"))
    # entries: (node_modules path, uri, filename, arch or "" for both)
    entries: list[tuple[str, str, str, str]] = []
    seen_distfiles: dict[str, str] = {}
    # (name, version) -> license text, deduplicated across every path that
    # resolves to the same name@version, for the verifiable license summary.
    licenses_by_name_version: dict[tuple[str, str], str] = {}

    root = lock["packages"].get("", {})
    root_name = lock.get("name", "openclaw")
    root_version = root.get("version", args.version)
    root_license = root.get("license")
    if isinstance(root_license, str):
        validate_license("<root>", root_version, root_license)
        licenses_by_name_version[(root_name, root_version)] = root_license

    for path, info in lock["packages"].items():
        if path == "":
            continue
        if not path.startswith("node_modules/"):
            raise SystemExit(f"unexpected non-flat lockfile entry: {path}")
        arch = wanted(path, info)
        if arch is None:
            continue
        license_ = info.get("license")
        if license_ is None:
            raise SystemExit(f"{path}@{info.get('version')}: no license field")
        text = license_ if isinstance(license_, str) else json.dumps(license_)
        validate_license(path, info.get("version"), text)
        uri = info.get("resolved")
        if not uri or not uri.startswith("https://registry.npmjs.org/"):
            raise SystemExit(f"{path}: not a plain npm-registry tarball dependency")
        name = path.rsplit("node_modules/", 1)[-1]
        filename = distfile(name, info["version"])
        if filename in seen_distfiles and seen_distfiles[filename] != uri:
            raise SystemExit(f"distfile collision: {filename}")
        seen_distfiles[filename] = uri
        entries.append((path, uri, filename, arch))

        key = (name, info["version"])
        prior = licenses_by_name_version.get(key)
        if prior is not None and prior != text:
            raise SystemExit(
                f"{name}@{info['version']}: conflicting license text seen "
                f"at different node_modules paths ({prior!r} vs {text!r})"
            )
        licenses_by_name_version[key] = text

    entries.sort(key=lambda item: item[0])

    # Multiple node_modules paths can resolve to the same name@version (npm
    # nests a second copy under a dependent package when versions diverge
    # elsewhere in the tree, but this closure happens to want the same
    # version at both spots) -- dedupe by filename for the SRC_URI arrays
    # (each distfile only needs to be fetched once), while OPENCLAW_NPM_PATHS
    # below still lists every path so each gets its own node_modules copy.
    by_filename: dict[str, tuple[str, str, str]] = {}
    for _, uri, filename, arch in entries:
        if filename not in by_filename:
            by_filename[filename] = (uri, filename, arch)
    unique = sorted(by_filename.values(), key=lambda item: item[1])

    both = [e for e in unique if e[2] == ""]
    amd64_only = [e for e in unique if e[2] == "amd64"]
    arm64_only = [e for e in unique if e[2] == "arm64"]

    lines = [
        "# Generated by scripts/generate-openclaw-npm-deps.py; do not edit.",
        f"# Locked closure: {len(entries)} node_modules paths, "
        f"{len(unique)} distfiles ({len(both)} both, {len(amd64_only)}"
        f" amd64, {len(arm64_only)} arm64)",
        f'OPENCLAW_NPM_DEPS_VERSION="{args.version}"',
        "",
        "OPENCLAW_NPM_SRC_URI=(",
    ]
    lines.extend(f'\t"{uri} -> {filename}"' for uri, filename, arch in unique if arch == "")
    lines.append(")")
    lines.append("")
    lines.append("OPENCLAW_NPM_SRC_URI_AMD64=(")
    lines.extend(f'\t"{uri} -> {filename}"' for uri, filename, arch in unique if arch == "amd64")
    lines.append(")")
    lines.append("")
    lines.append("OPENCLAW_NPM_SRC_URI_ARM64=(")
    lines.extend(f'\t"{uri} -> {filename}"' for uri, filename, arch in unique if arch == "arm64")
    lines.append(")")
    lines.append("")
    lines.append("# node_modules/<path> -> distfile, one per line")
    lines.append("OPENCLAW_NPM_PATHS=(")
    lines.extend(f'\t"{path}|{filename}"' for path, _, filename, arch in entries if arch == "")
    lines.append(")")
    lines.append("")
    lines.append("OPENCLAW_NPM_PATHS_AMD64=(")
    lines.extend(f'\t"{path}|{filename}"' for path, _, filename, arch in entries if arch == "amd64")
    lines.append(")")
    lines.append("")
    lines.append("OPENCLAW_NPM_PATHS_ARM64=(")
    lines.extend(f'\t"{path}|{filename}"' for path, _, filename, arch in entries if arch == "arm64")
    lines.append(")")
    lines.append("")

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text("\n".join(lines), encoding="utf-8")
    print(f"wrote {len(entries)} entries to {args.output}")

    # Deterministic, sorted, human- and machine-readable license summary:
    # one "name@version: license" line per distinct package actually
    # vendored (plus openclaw itself), so a user/auditor can verify exactly
    # which license applies to which vendored file without re-deriving it
    # from npm-shrinkwrap.json. No timestamps or other non-reproducible
    # content, so rerunning this generator against the same lockfile always
    # reproduces byte-identical output.
    summary_lines = [
        f"{name}@{version}: {text}"
        for (name, version), text in sorted(licenses_by_name_version.items())
    ]
    args.license_summary_output.parent.mkdir(parents=True, exist_ok=True)
    args.license_summary_output.write_text(
        "\n".join(summary_lines) + "\n", encoding="utf-8"
    )
    print(
        f"wrote {len(summary_lines)} package license entries to "
        f"{args.license_summary_output}"
    )


if __name__ == "__main__":
    main()
