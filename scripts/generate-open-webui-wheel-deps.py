#!/usr/bin/env python3
"""Generate deterministic www-apps/open-webui-bin PyPI wheel distfile
metadata from a pair of `pip install --dry-run --report` JSON reports
(one resolved for linux/x86_64, one for linux/aarch64), so the full
runtime dependency closure can be vendored as individual
files.pythonhosted.org wheels with no network access needed at build
time -- the same idea this overlay already uses for npm dependency
closures (see scripts/generate-restic-browser-npm-deps.py), applied to
Python wheels instead of npm tarballs.

Regenerate the reports with, e.g.:
    python3.12 -m pip install --dry-run --ignore-installed \\
        --report report-x86_64.json --python-version 3.12 \\
        --implementation cp --abi cp312 \\
        --platform manylinux_2_28_x86_64 --platform manylinux2014_x86_64 \\
        --only-binary=:all: "open-webui==<version>"
    python3.12 -m pip install --dry-run --ignore-installed \\
        --report report-aarch64.json --python-version 3.12 \\
        --implementation cp --abi cp312 \\
        --platform manylinux_2_28_aarch64 --platform manylinux2014_aarch64 \\
        --only-binary=:all: "open-webui==<version>"

Then regenerate the vendored array/SRC_URI block with:
    scripts/generate-open-webui-wheel-deps.py <version> \\
        report-x86_64.json report-aarch64.json out.gen

This script installs every resolved wheel into a single flat
`--target` site-packages directory at build time (see the ebuild's
src_install), the same way a real `pip install` of open-webui plus all
its extras would. pip's own dependency resolver only reasons about
*package names*, not the top-level Python module/package names a wheel
actually installs -- so it happily resolves two different PyPI
projects into the same closure even when both install files at the
same path (e.g. both providing a top-level `cv2/` directory), which a
flat --target install then silently and non-deterministically
resolves by whichever wheel happens to be extracted last clobbering
the other's files. See _detect_collisions() below and
PROVIDER_COLLISION_OVERRIDES for how this is caught and, where
already investigated, deliberately resolved.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
import urllib.request
import zipfile
from pathlib import Path
from urllib.parse import unquote, urlsplit

# Packages to drop entirely from the vendored closure because another
# already-vendored package in the same closure provides the exact same
# top-level import name, and the dropped package's own copy is
# redundant/unwanted. Each entry must be justified and is independently
# re-verified against the real wheel contents by _apply_overrides()
# below (both that the drop target and the keeper actually collide on
# the stated name(s), and that the keeper's wheel genuinely provides
# every one of those names) -- this is not a blind skip-list.
#
#   opencv-python vs. opencv-python-headless: open-webui's own
#   requirements.txt pins opencv-python-headless==4.13.0.92 directly
#   (this is a headless FastAPI backend service with no GUI/X11
#   surface, so the headless build is the correct one to ship).
#   rapidocr==3.9.2 separately declares `opencv_python>=4.5.1.48` as
#   its own dependency -- but rapidocr's actual source only ever does
#   `import cv2`, never anything that distinguishes which of the two
#   PyPI projects provided it, and opencv-python-headless installs the
#   identical `cv2` top-level package/API (with version 4.13.0.92,
#   satisfying rapidocr's >=4.5.1.48 floor) minus only the GUI/Qt
#   bindings this service never uses. pip's resolver has no way to
#   express "these two package names are alternative providers of the
#   same import", so it resolves both; dropping the non-headless one
#   here is the correct fix, not a workaround.
PROVIDER_COLLISION_OVERRIDES: dict[str, str] = {
    "opencv-python": (
        "redundant with opencv-python-headless, which open-webui itself "
        "pins directly and which provides the same cv2 import used by "
        "rapidocr's own opencv_python>=4.5.1.48 dependency -- see comment "
        "above PROVIDER_COLLISION_OVERRIDES"
    ),
}

# Exact-pinned replacements for a package the resolver *would* otherwise
# pick, when that resolution is verified broken for this closure's actual
# runtime code -- not a hypothetical, each entry here was found by
# actually exercising the vendored closure end-to-end (see the OCR
# integration test invoked from the ebuild's package README/report) and
# hitting a real crash, then verifying the replacement fixes it.
#
#   omegaconf: rapidocr==3.9.2 only declares `omegaconf!=2.2.1` (no lower
#   bound), so pip's resolver -- correctly, by its own rules -- picks the
#   *oldest* version satisfying that: 2.0.0, from 2020. rapidocr's own
#   code does `cfg.Global.model_root_dir = Path(...)` (main.py), which
#   omegaconf 2.0.0's DictConfig rejects outright
#   (`UnsupportedValueType: Value 'PosixPath' is not a supported
#   primitive type`), breaking RapidOCR() construction entirely -- 100%
#   reproduction, not an edge case. Verified fixed under 2.3.1 (latest
#   at generation time) with a standalone `OmegaConf.create(...)` +
#   `cfg.x.y = Path(...)` smoke test in an isolated venv.
MANUAL_PACKAGE_OVERRIDES: dict[str, tuple[str, str]] = {
    # name -> (version, files.pythonhosted.org wheel/sdist URL)
    "omegaconf": (
        "2.3.1",
        "https://files.pythonhosted.org/packages/a4/0e/152509871bf30df6fc38569f52a2db9b55dd41aae957adae50a053ac7778/omegaconf-2.3.1-py3-none-any.whl",
    ),
}

# Platform-specific replacements.  The PyPI torch==2.10.0 x86_64 wheel
# declares a large CUDA runtime closure while this headless service uses
# Torch on CPU.  Use PyTorch's official +cpu wheels on both architectures;
# these have no CUDA dependency metadata.  The exact artifacts and SHA-256
# fragments are published by https://download.pytorch.org/whl/cpu/torch/ .
MANUAL_ARCH_PACKAGE_OVERRIDES: dict[str, dict[str, tuple[str, str]]] = {
    "torch": {
        "amd64": (
            "2.10.0+cpu",
            "https://download-r2.pytorch.org/whl/cpu/torch-2.10.0%2Bcpu-cp312-cp312-manylinux_2_28_x86_64.whl",
        ),
        "arm64": (
            "2.10.0+cpu",
            "https://download-r2.pytorch.org/whl/cpu/torch-2.10.0%2Bcpu-cp312-cp312-manylinux_2_28_aarch64.whl",
        ),
    },
}

# Packages MANUAL_PACKAGE_OVERRIDES's replacement version needs that
# aren't already resolved by pip's own report (because the *original*,
# now-overridden resolution didn't need them at all).
#
#   antlr4-python3-runtime: omegaconf==2.3.1 exact-pins
#   `antlr4-python3-runtime==4.9.*` (its grammar parser). PyPI has never
#   published a wheel for any 4.8.x/4.9.x release of this package --
#   sdist only -- which is why `--only-binary=:all:` can't resolve
#   omegaconf>=2.1 at all. Verified the 4.9.3 sdist is 100% pure Python
#   (no .so/.pyx/compiled extension; `grep` of its file listing) and
#   is built offline into a wheel during the ebuild's src_compile using
#   only pip/setuptools/wheel from BDEPEND, then installed with the rest
#   of the wheels in src_install.  The official PyPI sdist is vendored
#   for exactly that reason.
MANUAL_PACKAGE_ADDITIONS: dict[str, tuple[str, str]] = {
    "antlr4-python3-runtime": (
        "4.9.3",
        "https://files.pythonhosted.org/packages/3e/38/7859ff46355f76f8d19459005ca000b6e7012f2f1ca597746cbcd1fbfe5e/antlr4-python3-runtime-4.9.3.tar.gz",
    ),
}


def distfile(url: str) -> str:
    # pip parses wheel filenames strictly (PEP 427:
    # {distribution}-{version}(-{build})?-{python}-{abi}-{platform}.whl,
    # or the sdist {name}-{version}.tar.gz), and pip install refuses
    # anything that doesn't parse -- so, unlike this overlay's npm-tarball
    # distfiles (which just need to be *some* unique filename), these must
    # keep exactly the upstream wheel/sdist filename. PyPI filenames are
    # already globally unique per (name, version, platform), so no
    # collision-avoidance renaming is needed or safe to do here.
    return unquote(urlsplit(url).path.rsplit("/", 1)[-1])


def load(path: Path) -> dict[tuple[str, str], dict]:
    data = json.loads(path.read_text(encoding="utf-8"))
    out = {}
    for item in data["install"]:
        md = item["metadata"]
        key = (md["name"], md["version"])
        if key in out:
            raise SystemExit(f"duplicate resolution for {key} in {path}")
        out[key] = item
    return out


def _fetch_wheel(url: str, filename: str, distfiles_dir: Path) -> Path:
    dest = distfiles_dir / filename
    if not dest.exists():
        distfiles_dir.mkdir(parents=True, exist_ok=True)
        print(f"fetching {filename} for content inspection...", file=sys.stderr)
        with urllib.request.urlopen(url) as resp, dest.open("wb") as f:  # noqa: S310
            f.write(resp.read())
    return dest


def _wheel_top_level_names(wheel_path: Path) -> dict[str, bool]:
    """The top-level package/module names a wheel installs into
    site-packages (i.e. the names an `import` statement could use),
    mapped to whether that name is a "regular" package/module there
    (has `<name>/__init__.py`, or is a bare top-level `<name>.py`) as
    opposed to a bare directory with no `__init__.py` at that level.

    That regular/bare distinction matters because dozens of real,
    unrelated PyPI distributions deliberately share one top-level
    directory as a PEP 420 *implicit namespace package* -- e.g.
    azure-core and azure-storage-blob both install into `azure/`,
    langgraph and langgraph-checkpoint both install into `langgraph/`,
    opentelemetry-api and opentelemetry-sdk both install into
    `opentelemetry/` -- and none of those ship `azure/__init__.py` (or
    the equivalent) precisely so that Python's own PEP 420 namespace
    mechanism merges their separate subdirectories at import time
    instead of one clobbering the other. That is working as intended,
    not a collision. A *real* collision (like opencv-python and
    opencv-python-headless both shipping a regular `cv2/__init__.py`)
    is when two distributions each independently claim to be the
    complete, regular implementation of the same name -- verified
    against real wheel content below, not asserted.
    """
    if not wheel_path.name.endswith(".whl"):
        # Antlr is the one deliberate sdist in this closure.  The ebuild
        # builds it into a wheel before installation, but this generator
        # inspects fetched artifacts directly and therefore cannot apply
        # the wheel-layout check to it.  A narrowly scoped assertion in
        # _apply_overrides_and_detect_collisions() checks its known
        # top-level `antlr4` package against every selected wheel instead.
        return {}

    with zipfile.ZipFile(wheel_path) as z:
        names = z.namelist()
        dist_info_dirs = [
            n.split("/", 1)[0] for n in names if n.endswith(".dist-info/RECORD")
        ]
        candidates: set[str] | None = None
        for d in dist_info_dirs:
            top_level_txt = f"{d}/top_level.txt"
            if top_level_txt in names:
                candidates = {
                    line.strip()
                    for line in z.read(top_level_txt).decode("utf-8").splitlines()
                    if line.strip()
                }
                break
        if candidates is None:
            # No top_level.txt (common for pure hatchling/flit/PEP 517
            # wheels that don't carry setuptools' legacy metadata
            # file): derive the candidate set from the actual file
            # layout instead.
            candidates = set()
            for n in names:
                first = n.split("/", 1)[0]
                if first.endswith(".dist-info") or first.endswith(".data"):
                    continue
                candidates.add(first[:-3] if first.endswith(".py") and "/" not in n else first)

        result: dict[str, bool] = {}
        for name in candidates:
            is_regular = f"{name}/__init__.py" in names or f"{name}.py" in names
            result[name] = is_regular
        return result


def _apply_overrides_and_detect_collisions(
    common: list[tuple[str, str, str, str]],
    amd64_only: list[tuple[str, str, str, str]],
    arm64_only: list[tuple[str, str, str, str]],
    distfiles_dir: Path,
) -> tuple[
    list[tuple[str, str, str, str]],
    list[tuple[str, str, str, str]],
    list[tuple[str, str, str, str]],
]:
    """Drop every package listed in PROVIDER_COLLISION_OVERRIDES (after
    verifying, against real wheel content, that doing so actually
    resolves a genuine name collision with some other package still in
    the closure), then scan whatever remains for any *other* top-level
    import-name collision and die loudly if one is found -- so a future
    version bump that reintroduces this exact class of bug (this pair,
    or an entirely different pair) fails at generation time instead of
    silently producing a corrupted flat --target install.
    """
    all_entries = [("common", e) for e in common]
    all_entries += [("amd64", e) for e in amd64_only]
    all_entries += [("arm64", e) for e in arm64_only]

    # One representative wheel file per package (arch doesn't matter for
    # top-level-name purposes: a package's set of provided import names
    # doesn't vary by platform, only its compiled contents do).
    by_name: dict[str, tuple[str, str, str, str]] = {}
    for _, entry in all_entries:
        name = entry[0]
        by_name.setdefault(name, entry)

    provided: dict[str, dict[str, bool]] = {}
    for name, (_, version, uri, filename) in by_name.items():
        wheel_path = _fetch_wheel(uri, filename, distfiles_dir)
        provided[name] = _wheel_top_level_names(wheel_path)

    # antlr4-python3-runtime-4.9.3 is built from its sdist by the ebuild
    # and is known from that source/build output to install the regular
    # top-level `antlr4` package.  Fail if any selected wheel also owns it.
    if "antlr4-python3-runtime" not in provided:
        raise SystemExit("manual Antlr addition is unexpectedly absent")
    if provided["antlr4-python3-runtime"]:
        raise SystemExit("Antlr is unexpectedly no longer represented by an sdist")
    antlr_colliders = sorted(
        name
        for name, names in provided.items()
        if name != "antlr4-python3-runtime" and names.get("antlr4", False)
    )
    if antlr_colliders:
        raise SystemExit(
            "antlr4-python3-runtime's top-level 'antlr4' package collides with "
            f"selected distribution(s): {antlr_colliders}"
        )
    provided["antlr4-python3-runtime"] = {"antlr4": True}

    def _regular_names(pkg: str) -> set[str]:
        return {n for n, is_regular in provided[pkg].items() if is_regular}

    dropped: set[str] = set()
    for drop_name, reason in PROVIDER_COLLISION_OVERRIDES.items():
        if drop_name not in provided:
            raise SystemExit(
                f"PROVIDER_COLLISION_OVERRIDES names {drop_name!r}, but it is not "
                "in the resolved closure -- remove this stale override"
            )
        drop_names = _regular_names(drop_name)
        colliding_with = [
            other
            for other in provided
            if other != drop_name
            and other not in PROVIDER_COLLISION_OVERRIDES
            and (_regular_names(other) & drop_names)
        ]
        if not colliding_with:
            raise SystemExit(
                f"PROVIDER_COLLISION_OVERRIDES drops {drop_name!r} ({reason}), "
                "but it no longer collides with anything else in the resolved "
                "closure -- this override looks stale, remove it and let the "
                f"real {drop_name!r} package be vendored normally"
            )
        print(
            f"dropping {drop_name!r} (provides {sorted(drop_names)}): {reason} "
            f"[collides with {colliding_with}]",
            file=sys.stderr,
        )
        dropped.add(drop_name)

    def _filtered(entries: list[tuple[str, str, str, str]]) -> list[tuple[str, str, str, str]]:
        return [e for e in entries if e[0] not in dropped]

    common, amd64_only, arm64_only = (
        _filtered(common),
        _filtered(amd64_only),
        _filtered(arm64_only),
    )

    # Re-scan the *post-override* closure for any remaining collision --
    # this is the real, general-purpose check: it fires on the opencv
    # pair today if PROVIDER_COLLISION_OVERRIDES were emptied out (this
    # script's own regeneration instructions above show how to verify
    # that), and will fire on any different future *regular-package*
    # pair without needing a code change. Deliberately shared PEP 420
    # namespace directories (azure, google, langgraph, opentelemetry,
    # ...) are excluded by construction: only names where 2+
    # distributions each ship a *regular* `__init__.py`/`<name>.py` at
    # that path count as a collision (see _wheel_top_level_names).
    owners: dict[str, list[str]] = {}
    for name in by_name:
        if name in dropped:
            continue
        for provided_name in _regular_names(name):
            owners.setdefault(provided_name, []).append(name)

    collisions = {n: pkgs for n, pkgs in owners.items() if len(pkgs) > 1}
    if collisions:
        details = "; ".join(f"{n!r} provided by {sorted(pkgs)}" for n, pkgs in sorted(collisions.items()))
        raise SystemExit(
            "wheel-content collision(s) detected in the resolved closure: "
            f"{details} -- a flat `pip install --target` of all of these will "
            "silently let one clobber the other's files at that path. Add a "
            "PROVIDER_COLLISION_OVERRIDES entry (after investigating which "
            "one to keep and why) or fix the underlying dependency pin."
        )

    return common, amd64_only, arm64_only


def _apply_manual_package_overrides(
    common: list[tuple[str, str, str, str]],
) -> list[tuple[str, str, str, str]]:
    """Replace/add the small number of exact-pinned entries in
    MANUAL_PACKAGE_OVERRIDES / MANUAL_PACKAGE_ADDITIONS (see their
    comments for why each one exists). Both are arch-independent
    (pure-Python) today, so only `common` is touched; if a future
    override needs to be arch-specific this will need extending.
    """
    by_name = {name: i for i, (name, _, _, _) in enumerate(common)}

    for name, (version, uri) in MANUAL_PACKAGE_OVERRIDES.items():
        if name not in by_name:
            raise SystemExit(
                f"MANUAL_PACKAGE_OVERRIDES names {name!r}, but it is not in the "
                "resolved closure -- remove this stale override"
            )
        old_version = common[by_name[name]][1]
        if old_version == version:
            raise SystemExit(
                f"MANUAL_PACKAGE_OVERRIDES pins {name!r} to {version}, which is "
                "exactly what the resolver already picked -- this override looks "
                "stale (the underlying resolution issue it worked around may "
                "already be fixed upstream), remove it and let the resolver's "
                "own pick be vendored normally"
            )
        common[by_name[name]] = (name, version, uri, distfile(uri))

    for name, (version, uri) in MANUAL_PACKAGE_ADDITIONS.items():
        if name in by_name:
            raise SystemExit(
                f"MANUAL_PACKAGE_ADDITIONS adds {name!r}, but the resolver "
                "already resolved it on its own -- this override looks stale, "
                "remove it and let the resolver's own pick be vendored normally"
            )
        common.append((name, version, uri, distfile(uri)))

    return common


def _apply_manual_arch_package_overrides(
    amd64_only: list[tuple[str, str, str, str]],
    arm64_only: list[tuple[str, str, str, str]],
) -> tuple[
    list[tuple[str, str, str, str]],
    list[tuple[str, str, str, str]],
]:
    """Apply replacements whose official artifacts differ by platform."""
    by_arch = {"amd64": amd64_only, "arm64": arm64_only}
    for name, replacements in MANUAL_ARCH_PACKAGE_OVERRIDES.items():
        if set(replacements) != set(by_arch):
            raise SystemExit(f"{name!r}: arch override must define amd64 and arm64")
        for arch, entries in by_arch.items():
            matches = [i for i, entry in enumerate(entries) if entry[0] == name]
            if len(matches) != 1:
                raise SystemExit(
                    f"{name!r}: expected exactly one {arch} resolved entry, "
                    f"found {len(matches)}"
                )
            version, uri = replacements[arch]
            entries[matches[0]] = (name, version, uri, distfile(uri))
    return amd64_only, arm64_only


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("version", help="open-webui version these reports were resolved for")
    parser.add_argument("report_x86_64", type=Path)
    parser.add_argument("report_aarch64", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument(
        "--distfiles-dir",
        type=Path,
        default=Path("/var/cache/distfiles"),
        help=(
            "Directory to read/fetch wheels from for content-collision "
            "detection (default: /var/cache/distfiles, Portage's own "
            "DISTDIR on this overlay's hosts -- wheels already fetched "
            "there by a prior `pkgdev manifest` run are reused as-is, "
            "and this doubles as pre-population for the next manifest run)"
        ),
    )
    parser.add_argument(
        "--skip-collision-check",
        action="store_true",
        help="Skip wheel-content download/inspection (fast iteration only; unsuitable for release regeneration)",
    )
    args = parser.parse_args()

    rx = load(args.report_x86_64)
    ra = load(args.report_aarch64)
    common: list[tuple[str, str, str, str]] = []  # (name, version, uri, filename)
    amd64_only: list[tuple[str, str, str, str]] = []
    arm64_only: list[tuple[str, str, str, str]] = []
    seen_distfiles: dict[str, str] = {}

    for name, version in sorted(set(rx) & set(ra)):
        if name == "open-webui":
            continue
        ix, ia = rx[(name, version)], ra[(name, version)]
        ux = ix["download_info"]["url"]
        ua = ia["download_info"]["url"]
        if not ux.startswith("https://files.pythonhosted.org/") or not ua.startswith(
            "https://files.pythonhosted.org/"
        ):
            raise SystemExit(f"{name}=={version}: not a plain PyPI-hosted wheel/sdist")
        if ux == ua:
            filename = distfile(ux)
            if filename in seen_distfiles and seen_distfiles[filename] != ux:
                raise SystemExit(f"distfile collision: {filename}")
            seen_distfiles[filename] = ux
            common.append((name, version, ux, filename))
        else:
            fx = distfile(ux)
            fa = distfile(ua)
            if fx == fa:
                raise SystemExit(f"{name}=={version}: amd64/arm64 filenames collide: {fx}")
            amd64_only.append((name, version, ux, fx))
            arm64_only.append((name, version, ua, fa))

    # Resolver results are allowed to contain platform-specific packages.
    # Preserve each side's unique entries in its architecture array rather
    # than assuming both target package sets are identical.
    for name, version in sorted(set(rx) - set(ra)):
        if name == "open-webui":
            continue
        item = rx[(name, version)]
        uri = item["download_info"]["url"]
        if not uri.startswith("https://files.pythonhosted.org/"):
            raise SystemExit(f"{name}=={version}: not a plain PyPI-hosted wheel/sdist")
        amd64_only.append((name, version, uri, distfile(uri)))
    for name, version in sorted(set(ra) - set(rx)):
        if name == "open-webui":
            continue
        item = ra[(name, version)]
        uri = item["download_info"]["url"]
        if not uri.startswith("https://files.pythonhosted.org/"):
            raise SystemExit(f"{name}=={version}: not a plain PyPI-hosted wheel/sdist")
        arm64_only.append((name, version, uri, distfile(uri)))

    common = _apply_manual_package_overrides(common)
    amd64_only, arm64_only = _apply_manual_arch_package_overrides(
        amd64_only, arm64_only
    )

    if not args.skip_collision_check:
        common, amd64_only, arm64_only = _apply_overrides_and_detect_collisions(
            common, amd64_only, arm64_only, args.distfiles_dir
        )

    lines = [
        "# Generated by scripts/generate-open-webui-wheel-deps.py; do not edit.",
        f"# Locked PyPI wheel dependency closure for www-apps/open-webui-bin-{args.version}:",
        f"#   {len(common)} arch-independent (pure-Python) + {len(amd64_only)} arch-specific pairs",
        f'OPEN_WEBUI_WHEEL_DEPS_VERSION="{args.version}"',
        "",
        "# name|version|distfile, arch-independent (identical wheel both platforms)",
        "OPEN_WEBUI_WHEELS_COMMON=(",
    ]
    lines.extend(f'\t"{name}|{version}|{filename}"' for name, version, _, filename in common)
    lines.append(")")
    lines.append("")
    lines.append("# name|version|distfile, amd64-only wheel")
    lines.append("OPEN_WEBUI_WHEELS_AMD64=(")
    lines.extend(f'\t"{name}|{version}|{filename}"' for name, version, _, filename in amd64_only)
    lines.append(")")
    lines.append("")
    lines.append("# name|version|distfile, arm64-only wheel")
    lines.append("OPEN_WEBUI_WHEELS_ARM64=(")
    lines.extend(f'\t"{name}|{version}|{filename}"' for name, version, _, filename in arm64_only)
    lines.append(")")
    lines.append("")
    # distfile() always returns exactly the URL's own basename (see its
    # docstring: pip requires the upstream wheel/sdist filename verbatim,
    # and those are already globally unique), so a `-> filename` rename
    # is always a no-op here -- include it only on the rare entry where
    # the two actually differ, otherwise pkgcheck's RedundantUriRename
    # check (rightly) flags the whole block.
    def _uri_line(uri: str, filename: str) -> str:
        return uri if uri.rsplit("/", 1)[-1] == filename else f"{uri} -> {filename}"

    lines.append("OPEN_WEBUI_WHEEL_SRC_URI=\"")
    for name, version, uri, filename in common:
        lines.append(f"\t{_uri_line(uri, filename)}")
    lines.append('\tamd64? (')
    for name, version, uri, filename in amd64_only:
        lines.append(f"\t\t{_uri_line(uri, filename)}")
    lines.append('\t)')
    lines.append('\tarm64? (')
    for name, version, uri, filename in arm64_only:
        lines.append(f"\t\t{_uri_line(uri, filename)}")
    lines.append('\t)')
    lines.append('"')
    lines.append("")

    selected_filenames = {
        filename
        for entries in (common, amd64_only, arm64_only)
        for _, _, _, filename in entries
    }
    selected_count = len(common) + len(amd64_only) + len(arm64_only)
    if len(selected_filenames) != selected_count:
        raise SystemExit("selected dependency entries contain duplicate distfile names")

    # Parse the rendered URI block rather than trusting the data used to
    # create it.  This catches generator changes that accidentally omit,
    # duplicate, or rename an emitted distfile differently from the arrays.
    emitted_filenames: set[str] = set()
    emitted_count = 0
    for line in lines:
        rendered = line.strip()
        if not rendered.startswith(("https://", "http://")):
            continue
        emitted_count += 1
        if " -> " in rendered:
            _, filename = rendered.rsplit(" -> ", 1)
        else:
            filename = distfile(rendered)
        emitted_filenames.add(filename)
    if emitted_count != len(emitted_filenames):
        raise SystemExit("emitted dependency URIs contain duplicate distfile names")
    if selected_filenames != emitted_filenames:
        raise SystemExit(
            "selected dependency filenames and emitted URI destinations differ: "
            f"selected-only={sorted(selected_filenames - emitted_filenames)}, "
            f"emitted-only={sorted(emitted_filenames - selected_filenames)}"
        )

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text("\n".join(lines), encoding="utf-8")
    print(
        f"wrote {args.output}: {len(common)} common + {len(amd64_only)} amd64 + "
        f"{len(arm64_only)} arm64 = {len(common) + len(amd64_only) + len(arm64_only)} distfiles"
    )


if __name__ == "__main__":
    main()
