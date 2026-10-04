#!/usr/bin/env python3
"""Preserve upstream notice bytes in a reproducible, deduplicated archive.

The input JSON is a list of components with name, version, source, and files.
Each file has a local path and its upstream name. No network access is used.
INDEX.json maps each upstream filename to a SHA256-addressed verbatim object.
"""

import argparse
import hashlib
import io
import json
from pathlib import Path
import tarfile


def generate(manifest, output):
    index = []
    objects = {}
    for component in json.loads(Path(manifest).read_text()):
        entry = {key: component[key] for key in ("name", "version", "source")}
        entry["files"] = []
        for notice in component["files"]:
            data = Path(notice["path"]).read_bytes()
            digest = hashlib.sha256(data).hexdigest()
            member = f"objects/{digest}.txt"
            objects[member] = data
            entry["files"].append({"name": notice["name"], "sha256": digest,
                                   "bytes": len(data), "object": member})
        index.append(entry)
    members = {"INDEX.json": (json.dumps(index, indent=2, ensure_ascii=False) + "\n").encode()}
    members.update(objects)
    with tarfile.open(output, "w:xz", preset=9) as archive:
        for name, data in sorted(members.items()):
            info = tarfile.TarInfo(name)
            info.size = len(data)
            info.mode = 0o644
            archive.addfile(info, io.BytesIO(data))
    # Check the actual archive, not just the in-memory input.
    with tarfile.open(output) as archive:
        for component in index:
            for notice in component["files"]:
                data = archive.extractfile(notice["object"]).read()
                assert len(data) == notice["bytes"]
                assert hashlib.sha256(data).hexdigest() == notice["sha256"]
    print(f"{len(index)} components, {len(objects)} distinct verbatim notices; "
          f"archive SHA256 round-trip verified; {Path(output).stat().st_size} bytes")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("manifest")
    parser.add_argument("output")
    args = parser.parse_args()
    generate(args.manifest, args.output)
