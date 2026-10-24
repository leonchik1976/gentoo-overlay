#!/usr/bin/env python3
"""Inspect release sources and CI; never infer support from pure-Python status."""
import concurrent.futures
import hashlib
import io
import json
import pathlib
import re
import tarfile
import urllib.request

ROOT = pathlib.Path(__file__).resolve().parents[1]
OUT = ROOT / "tools/upgrade-audit-20261024"
INVENTORY = json.loads((OUT / "inventory.json").read_text())
TARGET = OUT / "python-ci.json"
results = json.loads(TARGET.read_text()) if TARGET.exists() else {}


def inspect(cp, item):
    xml = ROOT / cp / "metadata.xml"
    repos = re.findall(r'<remote-id type="github">([^<]+)', xml.read_text()) if xml.exists() else []
    pv = re.sub(r"-r\d+$", "", item["version"])
    urls = []
    for url in re.findall(r"https://\S+", item["resolved_metadata"]["SRC_URI"]):
        if "github.com" in url and "/archive/" in url:
            urls.append(url)
    for repo in repos[:1]:
        tags = ["v" + pv, pv]
        if cp == "dev-python/posthog":
            tags = ["posthog-v" + pv]
        for tag in tags:
            urls.append(f"https://codeload.github.com/{repo}/tar.gz/refs/tags/{tag}")
    errors = []
    for url in dict.fromkeys(urls):
        try:
            request = urllib.request.Request(url, headers={"User-Agent": "Gentoo-overlay-python-audit/1.0"})
            with urllib.request.urlopen(request, timeout=45) as response:
                body = response.read(32 * 1024 * 1024 + 1)
            if len(body) > 32 * 1024 * 1024:
                raise ValueError("source archive exceeds 32 MiB inspection limit")
            signals = []
            inspected = []
            text_files = {}
            with tarfile.open(fileobj=io.BytesIO(body), mode="r:*") as archive:
                for member in archive:
                    if not member.isfile() or member.size > 800000:
                        continue
                    path = member.name
                    base = pathlib.PurePosixPath(path).name
                    if not (path.endswith((".py", ".toml", ".cfg", ".ini", ".yaml", ".yml", ".md", ".rst", ".rs", ".c", ".pyx", ".txt")) or "LICENSE" in base or base == "COPYING"):
                        continue
                    text = archive.extractfile(member).read().decode("utf8", "replace")
                    inspected.append(path)
                    if "/.github/workflows/" in path or base in ("pyproject.toml", "setup.cfg", "tox.ini", "noxfile.py", "meson.build"):
                        text_files[path] = text
                    for number, line in enumerate(text.splitlines(), 1):
                        if re.search(r"3[._]15|314t|315t|3\.14t|3\.15t|freethread|free.thread|Py_MOD_GIL_NOT_USED|gil_used", line, re.I):
                            signals.append({"file": path, "line": number, "text": line[:1000]})
            return cp, {"url": url, "sha256": hashlib.sha256(body).hexdigest(), "inspected": inspected,
                        "metadata_and_ci": text_files, "signals": signals}
        except Exception as error:
            errors.append({"url": url, "error": str(error)})
    return cp, {"errors": errors, "status": "no matching source archive found; sdist metadata remains separate evidence"}


with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:
    futures = [pool.submit(inspect, cp, item) for cp, item in INVENTORY.items()
               if "PYTHON_COMPAT" in (ROOT / item["ebuild"]).read_text() and cp not in results]
    for future in concurrent.futures.as_completed(futures):
        cp, result = future.result()
        results[cp] = result
        TARGET.write_text(json.dumps(dict(sorted(results.items())), indent=2) + "\n")
        print(cp, result.get("status", f"{len(result.get('signals', []))} support search matches"), flush=True)
