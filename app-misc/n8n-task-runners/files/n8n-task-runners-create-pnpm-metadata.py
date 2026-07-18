#!/usr/bin/env python3
"""Create both pnpm 10.32.1 offline registry metadata layouts."""
import json
import sys
from pathlib import Path
import yaml

def registry_uri(name, version):
    return f"https://registry.npmjs.org/{name}/-/{name.rsplit('/', 1)[-1]}-{version}.tgz"

def resolved_dependency(dependency, value):
    value = value.split("(", 1)[0]
    if "@" not in value:
        return value
    actual_name, possible_version = value.rsplit("@", 1)
    if actual_name and possible_version and actual_name != dependency:
        return f"npm:{value}"
    return value

lockfile, cache_root = map(Path, sys.argv[1:])
lock = yaml.safe_load(lockfile.read_text(encoding="utf-8"))
metadata = {}
for key, package in lock["packages"].items():
    name, version = key.rsplit("@", 1)
    resolution = package.get("resolution", {})
    if "tarball" in resolution:
        continue
    manifest = {"name": name, "version": version}
    for field in ("dependencies", "optionalDependencies", "peerDependencies", "peerDependenciesMeta", "engines", "cpu", "os", "libc"):
        if field in package:
            manifest[field] = package[field]
    manifest["dist"] = {"tarball": registry_uri(name, version), "integrity": resolution["integrity"]}
    metadata.setdefault(name, {"name": name, "versions": {}})["versions"][version] = manifest
for key, snapshot in lock.get("snapshots", {}).items():
    locator = key.split("(", 1)[0]
    name, version = locator.rsplit("@", 1)
    manifest = metadata.get(name, {}).get("versions", {}).get(version)
    if manifest is None:
        continue
    peers = set(manifest.get("peerDependencies", {}))
    for field in ("dependencies", "optionalDependencies"):
        resolved = {dep: resolved_dependency(dep, value) for dep, value in snapshot.get(field, {}).items() if dep not in peers}
        if resolved:
            manifest.setdefault(field, {}).update(resolved)
for name, record in sorted(metadata.items()):
    versions = sorted(record["versions"])
    record["dist-tags"] = {"latest": versions[-1]}
    record["cachedAt"] = 4102444800000
    record["modified"] = "2100-01-01T00:00:00.000Z"
    record["time"] = {"created": "1970-01-01T00:00:00.000Z", "modified": "2100-01-01T00:00:00.000Z", **{v: "1970-01-01T00:00:00.000Z" for v in versions}}
    for layout in ("metadata-v1.3", "metadata-ff-v1.3"):
        output = cache_root / layout / "registry.npmjs.org" / f"{name}.json"
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(json.dumps(record, sort_keys=True, separators=(",", ":")) + "\n", encoding="utf-8")
for layout in ("metadata-v1.3", "metadata-ff-v1.3"):
    cliui = json.loads((cache_root / layout / "registry.npmjs.org/@isaacs/cliui.json").read_text())
    if cliui["versions"]["8.0.2"]["dependencies"].get("string-width-cjs") != "npm:string-width@4.2.3":
        raise RuntimeError("incomplete alias metadata")
