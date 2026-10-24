#!/usr/bin/env python3
"""Audit changed bundled Go/Rust dependencies against their exact source archives."""
import concurrent.futures
import hashlib
import io
import json
import pathlib
import re
import tarfile
import tomllib
import urllib.request
import zipfile

ROOT = pathlib.Path(__file__).resolve().parents[1]
OUT = ROOT / "tools/upgrade-audit-20261024"
review = json.loads((OUT / "source-review.json").read_text())
TARGET = OUT / "dependency-licenses.json"
result = json.loads(TARGET.read_text()) if TARGET.exists() else {}


def fetch(url):
    request = urllib.request.Request(url, headers={"User-Agent": "Gentoo-overlay-license-audit/1.0"})
    with urllib.request.urlopen(request, timeout=60) as response:
        return response.read()


def audit(job):
    ecosystem, name, version = job
    key = "/".join(job)
    try:
        notices = {}
        if ecosystem == "go":
            escaped = re.sub(r"[A-Z]", lambda m: "!" + m[0].lower(), name)
            url = f"https://proxy.golang.org/{escaped}/@v/{version}.zip"
            body = fetch(url)
            with zipfile.ZipFile(io.BytesIO(body)) as archive:
                for path in archive.namelist():
                    if re.search(r"(?:^|/)(?:LICENSE|COPYING|NOTICE)(?:[.-][^/]*)?$", path, re.I):
                        notices[path] = archive.read(path).decode("utf8", "replace")
            value = {"url": url, "notices": notices}
        else:
            url = f"https://static.crates.io/crates/{name}/{name}-{version}.crate"
            cache = pathlib.Path("/var/cache/distfiles") / f"{name}-{version}.crate"
            body = cache.read_bytes() if cache.is_file() else fetch(url)
            license_expression = None
            with tarfile.open(fileobj=io.BytesIO(body)) as archive:
                for member in archive:
                    if not member.isfile():
                        continue
                    if member.name == f"{name}-{version}/Cargo.toml":
                        manifest = tomllib.loads(archive.extractfile(member).read().decode())
                        license_expression = manifest["package"].get("license")
                    if re.search(r"(?:^|/)(?:LICENSE|COPYING|NOTICE)(?:[.-][^/]*)?$", member.name, re.I):
                        notices[member.name] = archive.extractfile(member).read().decode("utf8", "replace")
            value = {"url": url, "license": license_expression, "notices": notices}
        value["sha256"] = hashlib.sha256(body).hexdigest()
        if not notices:
            value["limitation"] = "No conventional license filename found in exact archive; manual follow-up required"
        return key, value
    except Exception as error:
        return key, {"error": str(error)}


jobs = set()
for name in ["ByteNess-aws-vault", "gruntwork-io-terragrunt"]:
    data = review[name]
    old_modules = dict(re.findall(r"^\s*([a-zA-Z0-9][\w./-]*)\s+(v[\w.+-]+)", data["build_metadata"]["go.mod"]["old"], re.M))
    for module, version in data.get("changed_go_modules", {}).items():
        jobs.add(("go", module, version))
        if module in old_modules:
            jobs.add(("go", module, old_modules[module]))
for name, version in review["jdx-mise"]["changed_crates"]:
    if not name.startswith("mise"):
        jobs.add(("crate", name, version))
with concurrent.futures.ThreadPoolExecutor(max_workers=6) as pool:
    futures = [pool.submit(audit, job) for job in sorted(jobs) if "/".join(job) not in result]
    for future in concurrent.futures.as_completed(futures):
        key, value = future.result()
        result[key] = value
        TARGET.write_text(json.dumps(dict(sorted(result.items())), indent=2) + "\n")
        print(key, value.get("error") or value.get("license") or f"{len(value.get('notices', {}))} notices", flush=True)
