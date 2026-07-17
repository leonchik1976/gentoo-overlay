#!/usr/bin/env python3
"""Create pnpm's offline registry metadata cache from declared distfiles."""

import json
import re
import sys
from pathlib import Path

import yaml


def registry_uri(name, version):
    basename = name.rsplit("/", 1)[-1]
    return f"https://registry.npmjs.org/{name}/-/{basename}-{version}.tgz"


def distfile(name, version):
    safe_name = re.sub(r"[^A-Za-z0-9+_.-]", "-", name.lstrip("@"))
    safe_version = re.sub(r"[^A-Za-z0-9+_.-]", "-", version)
    return f"n8n-pnpm-{safe_name}-{safe_version}.tgz"


lockfile, distdir, cache_root = map(Path, sys.argv[1:])
lock = yaml.safe_load(lockfile.read_text(encoding="utf-8"))
metadata = {}

for key, package in lock["packages"].items():
    name, version = key.rsplit("@", 1)
    resolution = package.get("resolution", {})
    # Direct URL and Git tarballs are exact lockfile resolutions, not registry
    # versions, and therefore do not belong in the registry metadata cache.
    if "tarball" in resolution:
        continue
    manifest = {"name": name, "version": version}
    for field in (
        "dependencies",
        "optionalDependencies",
        "peerDependencies",
        "peerDependenciesMeta",
        "engines",
        "cpu",
        "os",
        "libc",
    ):
        if field in package:
            manifest[field] = package[field]
    manifest["dist"] = {
        "tarball": registry_uri(name, version),
        "integrity": resolution["integrity"],
    }
    record = metadata.setdefault(name, {"name": name, "versions": {}})
    record["versions"][version] = manifest

# pnpm lockfiles split registry manifests between `packages` (constraints and
# integrity) and `snapshots` (the dependency map selected for a peer variant).
# Legacy deploy needs both.  Peer suffixes such as `(zod@3.25.67)` are pnpm
# locators, not part of the registry version, and peer dependencies must remain
# peers rather than being copied into the normal dependency map.
for key, snapshot in lock.get("snapshots", {}).items():
    locator = key.split("(", 1)[0]
    name, version = locator.rsplit("@", 1)
    manifest = metadata.get(name, {}).get("versions", {}).get(version)
    if manifest is None:
        continue
    peers = set(manifest.get("peerDependencies", {}))
    for field in ("dependencies", "optionalDependencies"):
        resolved = {
            dependency: value.split("(", 1)[0]
            for dependency, value in snapshot.get(field, {}).items()
            if dependency not in peers
        }
        if resolved:
            manifest.setdefault(field, {}).update(resolved)

for name, record in sorted(metadata.items()):
    versions = sorted(record["versions"])
    record["dist-tags"] = {"latest": versions[-1]}
    # Keep the generated cache valid without embedding build time. pnpm treats
    # an epoch timestamp as expired and refuses it in strict offline mode.
    record["cachedAt"] = 4102444800000
    record["modified"] = "2100-01-01T00:00:00.000Z"
    record["time"] = {
        "created": "1970-01-01T00:00:00.000Z",
        "modified": "2100-01-01T00:00:00.000Z",
        **{version: "1970-01-01T00:00:00.000Z" for version in versions},
    }
    for cache_format in ("metadata-v1.3", "metadata-ff-v1.3"):
        output = cache_root / cache_format / "registry.npmjs.org" / f"{name}.json"
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(
            json.dumps(record, sort_keys=True, separators=(",", ":")) + "\n",
            encoding="utf-8",
        )

# pnpm's legacy deploy resolves this workspace dependency as a range.  Keep a
# regression check for the exact metadata entry that exposed the missing-cache
# bug, in both cache layouts consumed by pnpm 10.32.1.
for cache_format in ("metadata-v1.3", "metadata-ff-v1.3"):
    output = (
        cache_root
        / cache_format
        / "registry.npmjs.org"
        / "@ai-sdk"
        / "cohere.json"
    )
    cohere = json.loads(output.read_text(encoding="utf-8"))
    if "3.0.36" not in cohere["versions"]:
        raise RuntimeError(f"incomplete pnpm metadata cache: {output}")
