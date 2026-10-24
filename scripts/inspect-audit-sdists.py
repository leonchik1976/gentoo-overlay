#!/usr/bin/env python3
"""Inspect upstream sdists without running their build systems or code."""
import concurrent.futures
import hashlib
import io
import json
import pathlib
import re
import sys
import tarfile
import zipfile

sys.path.insert(0, str(pathlib.Path(__file__).parent))
from importlib import import_module
fetch = import_module("audit-overlay-upstreams").fetch

ROOT = pathlib.Path(__file__).resolve().parents[1]
OUT = ROOT / "tools/upgrade-audit-20261024"


def inspect(cp, key, data):
    files = [x for x in data["files"] if x["packagetype"] == "sdist"]
    if not files:
        return cp, key, {"error": "no sdist"}
    f = files[0]
    try:
        body = fetch(f["url"])
        digest = hashlib.sha256(body).hexdigest()
        assert digest == f["digests"]["sha256"], "upstream sha256 mismatch"
        texts = {}
        names = []
        with tarfile.open(fileobj=io.BytesIO(body), mode="r:*") as archive:
            for member in archive:
                name = member.name
                names.append(name)
                if member.isfile() and member.size <= 600000 and (
                    pathlib.PurePosixPath(name).name in (
                        "pyproject.toml", "setup.py", "setup.cfg", "tox.ini", "noxfile.py",
                        "LICENSE", "LICENSE.txt", "LICENSE.md", "COPYING", "PKG-INFO",
                        "MANIFEST.in", "requirements.txt", "requirements-dev.txt")
                    or "/.github/workflows/" in name
                ):
                    texts[name] = archive.extractfile(member).read().decode("utf8", "replace")
        signals = []
        for name, text in texts.items():
            for number, line in enumerate(text.splitlines(), 1):
                if re.search(r"3[._]15|314t|315t|3\.14t|3\.15t|freethread|free.thread|Py_MOD_GIL_NOT_USED|gil_used", line, re.I):
                    signals.append({"file": name, "line": number, "text": line})
        return cp, key, {"url": f["url"], "sha256": digest, "size": len(body),
                         "files": names, "metadata_and_licenses": texts, "python_signals": signals}
    except Exception as error:
        return cp, key, {"error": str(error), "url": f["url"]}


def main():
    upstream = json.loads((OUT / "upstream.json").read_text())
    target = OUT / "sdists.json"
    result = json.loads(target.read_text()) if target.exists() else {}
    jobs = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=6) as pool:
        for cp, data in upstream.items():
            if "pypi_current" not in data:
                continue
            if "current" not in result.get(cp, {}):
                jobs.append(pool.submit(inspect, cp, "current", data["pypi_current"]))
            if data["pypi"]["info"]["version"] != data["pypi_current"]["info"]["version"]:
                if "latest" not in result.get(cp, {}):
                    jobs.append(pool.submit(inspect, cp, "latest", data["pypi"]))
        for future in concurrent.futures.as_completed(jobs):
            cp, key, item = future.result()
            result.setdefault(cp, {})[key] = item
            print(cp, key, item.get("error") or f"{len(item['files'])} files inspected", flush=True)
            target.write_text(json.dumps(result, indent=2) + "\n")


if __name__ == "__main__":
    main()
