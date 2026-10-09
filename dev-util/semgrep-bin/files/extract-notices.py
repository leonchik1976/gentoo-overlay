#!/usr/bin/env python3
"""Extract selected documentation, never RPM binaries or source build inputs."""

import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile


def rpm_member(archive, member):
    return subprocess.run(
        ["bsdtar", "-xOf", str(archive), member],
        check=True, stdout=subprocess.PIPE,
    ).stdout


def extract(distdir, index, output):
    count = 0
    for entry in json.loads(index.read_text()):
        archive = distdir / entry["archive"]
        output.parent.mkdir(parents=True, exist_ok=True)
        with tempfile.TemporaryDirectory(dir=output.parent) as temporary:
            temporary = Path(temporary)
            if "inner" in entry:
                source = temporary / "source-archive"
                source.write_bytes(rpm_member(archive, entry["inner"]))
            else:
                source = archive
            extracted = temporary / "documents"
            extracted.mkdir()
            subprocess.run(
                ["bsdtar", "--no-same-owner", "-xf", str(source),
                 "-C", str(extracted), "--", *entry["files"]],
                check=True,
            )
            for member, name in entry["files"].items():
                relative = Path(name)
                if relative.is_absolute() or ".." in relative.parts:
                    raise ValueError(f"Unsafe documentation destination: {name}")
                document = extracted / member
                if not document.is_file() or document.is_symlink():
                    raise ValueError(f"Not a regular document: {member}")
                if not document.stat().st_size:
                    raise ValueError(f"Empty document: {member}")
                target = output / relative
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(document, target)
                count += 1
    print(f"Extracted {count} selected notice/source-metadata documents")


if __name__ == "__main__":
    extract(*(Path(argument) for argument in sys.argv[1:]))
