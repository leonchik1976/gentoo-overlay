#!/usr/bin/env python3
"""Cache explicitly listed upstream URLs for a packaging review."""
import concurrent.futures
import hashlib
import json
import pathlib
import sys
import urllib.request

root = pathlib.Path(__file__).resolve().parents[1]
directory = root / "tools/upgrade-audit-20261024"
jobs = json.loads(pathlib.Path(sys.argv[1]).read_text())


def collect(job):
    target = directory / job["path"]
    target.parent.mkdir(parents=True, exist_ok=True)
    try:
        request = urllib.request.Request(job["url"], headers={"User-Agent": "Gentoo-overlay-audit/1.0"})
        if not target.exists():
            with urllib.request.urlopen(request, timeout=60) as response, target.open("wb") as stream:
                while chunk := response.read(1024 * 1024):
                    stream.write(chunk)
        body = target.read_bytes()
        result = dict(job, size=len(body), sha256=hashlib.sha256(body).hexdigest())
    except Exception as error:
        if target.exists():
            target.unlink()
        result = dict(job, error=str(error))
    print(job["path"], result.get("error", result.get("size")), flush=True)
    return result


with concurrent.futures.ThreadPoolExecutor(max_workers=6) as pool:
    results = list(pool.map(collect, jobs))
(directory / (pathlib.Path(sys.argv[1]).stem + "-results.json")).write_text(json.dumps(results, indent=2) + "\n")
