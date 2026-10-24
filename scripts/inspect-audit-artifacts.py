#!/usr/bin/env python3
"""Inspect archive layouts, notices, wheel metadata and ELF linkage without execution."""
import hashlib
import io
import json
import pathlib
import re
import subprocess
import tarfile
import zipfile

ROOT = pathlib.Path(__file__).resolve().parents[1]
OUT = ROOT / "tools/upgrade-audit-20261024"
TARGET = OUT / "artifact-inspection.json"
results = json.loads(TARGET.read_text()) if TARGET.exists() else {}
OBJECTS = OUT / "inspection-objects"
OBJECTS.mkdir(exist_ok=True)


def analyze(name, body, result):
    if body.startswith(b"\x7fELF"):
        digest = hashlib.sha256(body).hexdigest()
        target = OBJECTS / digest
        target.write_bytes(body)
        dynamic = subprocess.run(["readelf", "-d", str(target)], capture_output=True, text=True)
        header = subprocess.run(["readelf", "-h", str(target)], capture_output=True, text=True)
        result.setdefault("elf", {})[name] = {
            "header": header.stdout, "dynamic": dynamic.stdout,
            "needed": re.findall(r"\(NEEDED\).*?\[(.*?)\]", dynamic.stdout),
            "readelf_exit": [header.returncode, dynamic.returncode],
        }
        target.unlink()
    base = pathlib.PurePosixPath(name).name
    if re.search(r"licen[cs]e|copying|third.?party|notice", base, re.I) and len(body) < 40000000:
        digest = hashlib.sha256(body).hexdigest()
        target = OBJECTS / (digest + ".txt")
        target.write_bytes(body)
        result.setdefault("notices", {})[name] = {"sha256": digest, "path": str(target.relative_to(ROOT)), "size": len(body)}
    if base in ("METADATA", "package.json", "pom.xml", "META.yml", "META.json", "Makefile.PL", "go.mod", "Cargo.toml") and len(body) < 500000:
        result.setdefault("metadata", {})[name] = body.decode("utf8", "replace")


def analyze_tar(archive, result):
    names = []
    for member in archive:
        names.append(member.name)
        if not member.isfile():
            continue
        stream = archive.extractfile(member)
        prefix = stream.read(4)
        base = pathlib.PurePosixPath(member.name).name
        wanted = prefix == b"\x7fELF" or re.search(r"licen[cs]e|copying|third.?party|notice", base, re.I) or base in (
            "package.json", "pom.xml", "META.yml", "META.json", "Makefile.PL", "go.mod", "Cargo.toml", "control")
        if wanted:
            body = prefix + stream.read()
            if base == "control":
                result["control"] = body.decode("utf8", "replace")
            analyze(member.name, body, result)
    result["files"] = names


jobs = json.loads((OUT / "assets-results.json").read_text())
for job in jobs:
    if "error" in job or not job["path"].startswith("distfiles/"):
        continue
    path = OUT / job["path"]
    if path.name in results:
        continue
    result = {"url": job["url"], "package": job.get("package"), "sha256": job["sha256"]}
    try:
        if path.suffix == ".deb":
            control = subprocess.check_output(["dpkg-deb", "--ctrl-tarfile", str(path)])
            with tarfile.open(fileobj=io.BytesIO(control)) as archive:
                analyze_tar(archive, result)
            process = subprocess.Popen(["dpkg-deb", "--fsys-tarfile", str(path)], stdout=subprocess.PIPE)
            with tarfile.open(fileobj=process.stdout, mode="r|") as archive:
                analyze_tar(archive, result)
            result["dpkg_exit"] = process.wait()
        elif path.suffix == ".whl":
            with zipfile.ZipFile(path) as archive:
                result["files"] = archive.namelist()
                for name in archive.namelist():
                    if not name.endswith("/"):
                        analyze(name, archive.read(name), result)
        elif tarfile.is_tarfile(path):
            with tarfile.open(path) as archive:
                analyze_tar(archive, result)
        else:
            analyze(path.name, path.read_bytes(), result)
            result["go_buildinfo"] = subprocess.run(["go", "version", "-m", str(path)], capture_output=True, text=True).stdout
    except Exception as error:
        result["error"] = str(error)
    results[path.name] = result
    TARGET.write_text(json.dumps(results, indent=2) + "\n")
    print(path.name, "ELF", len(result.get("elf", {})), "notices", len(result.get("notices", {})), result.get("error", ""), flush=True)
