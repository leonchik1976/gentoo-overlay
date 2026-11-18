"""Materialize the locked npm tree from Portage distfiles without lifecycle scripts."""

import base64
import hashlib
import json
import os
import platform
import stat
import sys
import tarfile
from pathlib import Path


def matches(values, target):
    return not values or "any" in values or (
        f"!{target}" not in values
        and (target in values or all(value.startswith("!") for value in values))
    )


def npm_member(member, destination):
    # npm archives and GitHub snapshots each have one wrapper directory.
    _, separator, name = member.name.partition("/")
    if not separator or not name:
        return None
    if member.islnk():
        member = member.replace(linkname=member.linkname.partition("/")[2])
    member = tarfile.data_filter(member.replace(name=name), destination)
    if member.isdir():
        return member.replace(mode=0o755)
    return member


def unpack_dependency(path, entry, distdir):
    resolved = entry.get("resolved")
    if not resolved:
        # Some npm lock entries specify only the package name and version.
        # Their exact registry tarballs are pinned by the Portage Manifest.
        name = entry.get("name", str(path).rsplit("node_modules/", 1)[-1])
        resolved = f"https://registry.npmjs.org/{name}/-/{name.rsplit('/', 1)[-1]}-{entry['version']}.tgz"
    suffix = ".tar.gz" if resolved.startswith("git+ssh://") else ".tgz"
    digest = hashlib.sha256(resolved.encode()).hexdigest()[:16]
    archive = distdir / f"nct-{digest}{suffix}"
    with archive.open("rb") as stream:
        if integrity := entry.get("integrity"):
            algorithm, expected = integrity.split("-", 1)
            actual = base64.b64encode(hashlib.file_digest(stream, algorithm).digest()).decode()
            if actual != expected:
                raise ValueError(f"Integrity mismatch for {path}")
            stream.seek(0)
        path.mkdir(parents=True, exist_ok=True)
        with tarfile.open(fileobj=stream, mode="r:gz") as package:
            package.extractall(path, filter=npm_member)

    manifest = json.loads((path / "package.json").read_text())
    bins = manifest.get("bin", {})
    if isinstance(bins, str):
        bins = {manifest["name"].rsplit("/", 1)[-1]: bins}
    modules = next(parent for parent in path.parents if parent.name == "node_modules")
    for command, target in bins.items():
        executable = path / target
        if not executable.is_file():
            continue
        executable.chmod(executable.stat().st_mode | stat.S_IXUSR)
        link = modules / ".bin" / command
        link.parent.mkdir(exist_ok=True)
        if not link.is_symlink():
            link.symlink_to(os.path.relpath(executable, link.parent))


def main():
    distdir = Path(sys.argv[1])
    lock = json.loads(Path("package-lock.json").read_text())
    cpu = {"aarch64": "arm64", "x86_64": "x64"}[platform.machine()]
    for name, entry in lock["packages"].items():
        if (name and matches(entry.get("os"), "linux")
                and matches(entry.get("cpu"), cpu)
                and matches(entry.get("libc"), "glibc")):
            unpack_dependency(Path(name), entry, distdir)

    # Electron Packager can open the vendor ZIP directly from DISTDIR.
    config = Path("forge.config.js")
    source = config.read_text()
    marker = "packagerConfig: {"
    if source.count(marker) != 1:
        raise ValueError("Unexpected Electron Forge config")
    config.write_text(source.replace(marker, f"{marker}\n\t\telectronZipDir: {json.dumps(str(distdir))},"))


if __name__ == "__main__":
    main()
