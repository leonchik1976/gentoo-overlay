#!/usr/bin/env python3
"""Collect exact compiled Go-module notices, checking recorded module sums.

Use BINARY WORKSPACE. Downloads remain in WORKSPACE; no target code is run.
The resulting notice-input.json can feed generate-binary-notices.py. Missing
module versions, local replacements, and missing notices require human review.
"""

import argparse
from concurrent.futures import ThreadPoolExecutor
import json
import os
from pathlib import Path
import re
import subprocess
import zipfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("binary", type=Path)
    parser.add_argument("workspace", type=Path)
    args = parser.parse_args()
    workspace = args.workspace.resolve()
    workspace.mkdir(parents=True, exist_ok=True)
    result = subprocess.run(["go", "version", "-m", "-json", str(args.binary)],
                            capture_output=True, text=True, check=True)
    (workspace / "binary-buildinfo.json").write_text(result.stdout)
    info = json.loads(result.stdout)
    env = os.environ.copy()
    env.update(GOPATH=str(workspace / "go"),
               GOMODCACHE=str(workspace / "go/pkg/mod"),
               GOCACHE=str(workspace / "go-cache"),
               GOTOOLCHAIN="local", GOWORK="off", GO111MODULE="on")

    def collect(dep):
        module = dep.get("Replace") or dep
        path, version = module["Path"], module.get("Version")
        record = {"name": path, "version": version, "source": "https://proxy.golang.org/", "files": []}
        if not version or version == "(devel)":
            record["review"] = "Local replacement or unavailable exact version"
            return record
        result = subprocess.run(["go", "mod", "download", "-json", f"{path}@{version}"],
                                capture_output=True, text=True, env=env)
        try:
            downloaded = json.loads(result.stdout)
        except ValueError:
            record["review"] = result.stderr
            return record
        record["download"] = downloaded
        if result.returncode or "Zip" not in downloaded:
            record["review"] = downloaded.get("Error", result.stderr)
            return record
        expected = module.get("Sum")
        if expected and expected != downloaded.get("Sum"):
            raise ValueError(f"Compiled module checksum mismatch: {path}@{version}")
        record["compiled_sum_matches"] = bool(expected)
        target = workspace / "module-notices" / re.sub(r"[^A-Za-z0-9_.-]", "_", path + "@" + version)
        target.mkdir(parents=True, exist_ok=True)
        with zipfile.ZipFile(downloaded["Zip"]) as archive:
            for member in archive.namelist():
                relative = member.split("/", 1)[-1]
                # Go proxy roots can contain slashes: remove the full module
                # path@version prefix before selecting notice files.
                prefix = path + "@" + version + "/"
                if member.startswith(prefix):
                    relative = member[len(prefix):]
                if relative.count("/") <= 1 and re.match(
                        r"(?i)^(?:(?:un)?licen[cs]e|copying|copyright|notice)(?:[._-]|$)", Path(relative).name):
                    data = archive.read(member)
                    if len(data) > 2_000_000:
                        raise ValueError(f"Unexpected notice size: {member}")
                    destination = target / relative.replace("/", "__")
                    destination.write_bytes(data)
                    record["files"].append({"name": relative, "path": str(destination)})
        if not record["files"]:
            record["review"] = "No root or immediate-subdirectory notice found"
        return record

    with ThreadPoolExecutor(max_workers=6) as executor:
        records = list(executor.map(collect, info.get("Deps", [])))
    (workspace / "go-module-audit.json").write_text(json.dumps(records, indent=2) + "\n")
    (workspace / "notice-input.json").write_text(json.dumps(records, indent=2) + "\n")
    review = [r["name"] for r in records if r.get("review")]
    # Notice bytes and checksum records are retained; the package-local Go
    # download cache can be very large and is no longer needed by this audit.
    subprocess.run(["go", "clean", "-modcache"], env=env, check=True)
    print(json.dumps({"modules": len(records), "review": review,
                      "notice_files": sum(len(r["files"]) for r in records)}))
    return bool(review) or not records


if __name__ == "__main__":
    raise SystemExit(main())
