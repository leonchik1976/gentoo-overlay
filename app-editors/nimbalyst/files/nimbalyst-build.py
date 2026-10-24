#!/usr/bin/env python3
"""Offline build resources for the pinned Nimbalyst/pnpm release.

pnpm's CLI imports local tarballs into its own content-addressed store. Its
registry cache keys additionally contain the package identity; register aliases
for those exact, integrity-checked bytes without resolving registry metadata.
The pinned implementation defines this format at:
https://github.com/pnpm/pnpm/blob/v12.9.1/pnpm/crates/store-dir/src/store_index.rs
No msgpack records or package contents are fabricated by this helper.
"""

import argparse
import base64
import hashlib
import json
from pathlib import Path
import re
import shutil
import sqlite3
import subprocess


def seed(args):
    entries = [line.split("|") for line in args.table.read_text().splitlines()]
    for identifier, integrity, filename in entries:
        with (args.distdir / filename).open("rb") as stream:
            digest = base64.b64encode(hashlib.file_digest(stream, "sha512").digest()).decode()
        if integrity != "sha512-" + digest:
            raise ValueError(f"Upstream lockfile integrity mismatch: {identifier}")
    # store add imports only the given archives, runs no lifecycle scripts,
    # and does not resolve their transitive dependencies.
    for start in range(0, len(entries), 100):
        subprocess.run([args.pnpm, "store", "add", "--ignore-workspace",
                        "--store-dir", str(args.store), "--state-dir", str(args.state),
                        *[str(args.distdir / entry[2]) for entry in entries[start:start + 100]]],
                       check=True, cwd=args.state)
    database = args.store / "v11/index.db"
    with sqlite3.connect(database) as connection:
        columns = [row[1] for row in connection.execute("PRAGMA table_info(package_index)")]
        if columns != ["key", "data"]:
            raise ValueError("Unexpected pinned pnpm store schema")
        for identifier, integrity, _ in entries:
            record = connection.execute("SELECT data FROM package_index WHERE key LIKE ? LIMIT 1",
                                        (integrity + "\t%",)).fetchone()
            if record is None:
                raise ValueError(f"pnpm did not import {identifier}")
            connection.execute("INSERT OR REPLACE INTO package_index(key,data) VALUES (?,?)",
                               (integrity + "\t" + identifier, record[0]))
    print(f"Registered {len(entries)} integrity-checked offline npm archives")


def prepare(args):
    root = args.source
    workspace = root / "pnpm-workspace.yaml"
    # No versions are resolved in the build. Portage's Manifest and the pinned
    # upstream lockfile verify all inputs; a live registry-age query would make
    # an otherwise offline, frozen install time/network-dependent.
    text, count = re.subn(r"(?m)^minimumReleaseAge: 4320$", "minimumReleaseAge: 0", workspace.read_text())
    if count != 1:
        raise ValueError("Unexpected upstream release-age setting")
    workspace.write_text(text)
    package = root / "packages/electron/package.json"
    data = json.loads(package.read_text())
    data["build"]["npmRebuild"] = False  # native modules are explicitly built with local headers
    package.write_text(json.dumps(data, indent=2) + "\n")
    electron = root / "node_modules/electron"
    (electron / "path.txt").write_text("electron")
    # Eliminate co-shipped prebuilds before compiling these two addons. Their
    # loaders already fall back to build/Release, and the packager keeps it.
    for name in ("better-sqlite3", "node-pty"):
        for subdir in ("prebuilds", "build", "bin"):
            directory = root / "node_modules" / name / subdir
            if directory.exists():
                shutil.rmtree(directory)


def tidy(args):
    directory = "linux-unpacked" if args.arch == "x64" else "linux-arm64-unpacked"
    resources = args.source / "packages/electron/release" / directory / "resources"
    # node-pty is copied wholesale by upstream. Keep its runtime JS and the
    # compiled addon, not source, build objects, or foreign platform prebuilds.
    pty = resources / "node-pty"
    for entry in list(pty.iterdir()):
        if entry.name not in ("lib", "package.json", "LICENSE", "build"):
            if entry.is_dir():
                shutil.rmtree(entry)
            else:
                entry.unlink()
    for module in (pty, resources / "node_modules/better-sqlite3"):
        build = module / "build"
        for entry in list(build.iterdir()):
            if entry.name != "Release":
                if entry.is_dir():
                    shutil.rmtree(entry)
                else:
                    entry.unlink()
        for entry in list((build / "Release").iterdir()):
            if not entry.is_file() or entry.suffix != ".node":
                if entry.is_dir():
                    shutil.rmtree(entry)
                else:
                    entry.unlink()
        (build / "Release/test_extension.node").unlink(missing_ok=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)
    p = sub.add_parser("seed")
    for field in ("table", "distdir", "store", "state"):
        p.add_argument(field, type=Path)
    p.add_argument("pnpm")
    p = sub.add_parser("prepare")
    p.add_argument("source", type=Path)
    p = sub.add_parser("tidy")
    p.add_argument("source", type=Path)
    p.add_argument("arch", choices=("x64", "arm64"))
    args = parser.parse_args()
    {"seed": seed, "prepare": prepare, "tidy": tidy}[args.command](args)
