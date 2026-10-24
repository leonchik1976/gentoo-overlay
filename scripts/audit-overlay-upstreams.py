#!/usr/bin/env python3
"""Read-only release discovery; results are candidates, never automatic bumps."""
import concurrent.futures
import json
import pathlib
import re
import urllib.request
import xml.etree.ElementTree as ET

ROOT = pathlib.Path(__file__).resolve().parents[1]
OUT = ROOT / "tools/upgrade-audit-20261024"
SKIP = set("dev-debug/sysdig dev-util/intel-ocl-sdk net-misc/rabbitmq-server sci-geosciences/qgis sci-ml/XNNPACK sys-block/libfabric sys-cluster/ceph".split())


def fetch(url):
    request = urllib.request.Request(url, headers={"User-Agent": "Gentoo-overlay-release-audit/1.0"})
    with urllib.request.urlopen(request, timeout=45) as response:
        return response.read()


def pypi(name, version=None):
    url = f"https://pypi.org/pypi/{name}/" + (f"{version}/" if version else "") + "json"
    data = json.loads(fetch(url))
    info = data["info"]
    return {"url": url, "info": {k: info.get(k) for k in (
        "name", "version", "requires_python", "requires_dist", "classifiers",
        "license", "license_expression", "license_files", "project_urls")},
        "files": data.get("urls", []), "versions": list(data.get("releases", {}))}


def inspect(cp, item):
    if cp in SKIP or cp.startswith("acct-"):
        return cp, {"status": "excluded" if cp in SKIP else "account package"}
    result = {"current": item["version"]}
    xml = ROOT / cp / "metadata.xml"
    ids = re.findall(r'<remote-id type="([^"]+)">([^<]+)', xml.read_text()) if xml.exists() else []
    source = (ROOT / item["ebuild"]).read_text()
    pyname = next((v for k, v in ids if k == "pypi"), None)
    if cp == "dev-python/pydub":
        pyname = "pydub"
    if pyname:
        try:
            result["pypi"] = pypi(pyname)
            pv = re.sub(r"-r\d+$", "", item["version"])
            pv = pv.replace("_beta", "b").replace("_alpha", "a").replace("_rc", "rc")
            result["pypi_current"] = pypi(pyname, pv)
        except Exception as error:
            result["pypi_error"] = str(error)
    else:
        gh = next((v for k, v in ids if k == "github"), None)
        if gh:
            url = f"https://github.com/{gh}/releases.atom"
            try:
                tree = ET.fromstring(fetch(url))
                ns = {"a": "http://www.w3.org/2005/Atom"}
                result["github"] = {"url": url, "entries": [
                    {"title": e.findtext("a:title", namespaces=ns),
                     "url": e.find("a:link", ns).get("href"),
                     "updated": e.findtext("a:updated", namespaces=ns),
                     "notes": e.findtext("a:content", namespaces=ns)}
                    for e in tree.findall("a:entry", ns)]}
            except Exception as error:
                result["github_error"] = str(error)
    npm = {"dev-util/aws-cdk-local": "aws-cdk-local", "dev-util/aws-cdk": "aws-cdk",
           "dev-libs/node-diff": "diff", "dev-libs/node-semver": "semver"}.get(cp)
    if npm:
        try:
            url = f"https://registry.npmjs.org/{npm}"
            data = json.loads(fetch(url))
            result["npm"] = {"url": url, "tags": data["dist-tags"],
                             "versions": {v: {k: d.get(k) for k in
                                 ("version", "dependencies", "peerDependencies", "engines", "license", "dist")}
                                 for v, d in data["versions"].items()}}
        except Exception as error:
            result["npm_error"] = str(error)
    if not any(k in result for k in ("pypi", "github", "npm")):
        result["status"] = "needs manual release source"
    return cp, result


def main():
    inventory = json.loads((OUT / "inventory.json").read_text())
    results = {}
    priority = ["app-admin/aws-sam-cli", "dev-util/aws-cdk-local", "sci-ml/ollmcp"]
    for cp in priority:
        key, value = inspect(cp, inventory[cp])
        results[key] = value
        print(key, json.dumps(value.get("pypi", {}).get("info", value.get("npm", {}).get("tags", {}))), flush=True)
    (OUT / "upstream-priority.json").write_text(json.dumps(results, indent=2) + "\n")
    with concurrent.futures.ThreadPoolExecutor(max_workers=8) as pool:
        futures = [pool.submit(inspect, cp, item) for cp, item in inventory.items() if cp not in priority]
        for future in concurrent.futures.as_completed(futures):
            cp, value = future.result()
            results[cp] = value
            print(cp, value.get("pypi", {}).get("info", {}).get("version", ""), value.get("status", "queried"), flush=True)
    (OUT / "upstream.json").write_text(json.dumps(dict(sorted(results.items())), indent=2) + "\n")


if __name__ == "__main__":
    main()
