#!/usr/bin/env python3
"""Read the leading control archive of rolling vendor debs without installing."""
import concurrent.futures
import io
import json
import pathlib
import tarfile
import urllib.request

ROOT = pathlib.Path(__file__).resolve().parents[1]
OUT = ROOT / "tools/upgrade-audit-20261024"
urls = {
    "net-im/viber": "https://download.cdn.viber.com/cdn/desktop/Linux/viber.deb",
    "net-im/webex-bin": "https://binaries.webex.com/WebexDesktop-Ubuntu-Official-Package/Webex.deb",
    "net-misc/amazon-workspaces-bin": "https://d3nt0h4h6pmmc4.cloudfront.net/new_workspacesclient_noble_amd64.deb",
    "net-misc/expandrive": "https://www.expandrive.com/api/download/expandrive?platform=linux&ext=deb",
    "media-sound/muse-sounds-manager": "https://muse-cdn.com/Muse_Sounds_Manager_x64.deb",
}


def inspect(item):
    cp, url = item
    try:
        request = urllib.request.Request(url, headers={"Range": "bytes=0-1048575", "User-Agent": "Gentoo-overlay-audit/1.0"})
        with urllib.request.urlopen(request, timeout=45) as response:
            prefix = response.read(1048576)
            final_url = response.url
        if not prefix.startswith(b"!<arch>\n"):
            raise ValueError("response is not a deb ar archive")
        offset = 8
        while offset + 60 < len(prefix):
            header = prefix[offset:offset + 60]
            name = header[:16].decode().strip().rstrip("/")
            size = int(header[48:58].decode().strip())
            body = prefix[offset + 60:offset + 60 + size]
            if name.startswith("control.tar"):
                with tarfile.open(fileobj=io.BytesIO(body), mode="r:*") as archive:
                    control = next(m for m in archive if pathlib.PurePosixPath(m.name).name == "control")
                    return cp, {"url": url, "final_url": final_url, "control": archive.extractfile(control).read().decode()}
            offset += 60 + size + (size % 2)
        raise ValueError("control archive not found in first MiB")
    except Exception as error:
        return cp, {"url": url, "error": str(error)}


with concurrent.futures.ThreadPoolExecutor(max_workers=5) as pool:
    results = dict(pool.map(inspect, urls.items()))
(OUT / "rolling-deb-versions.json").write_text(json.dumps(results, indent=2) + "\n")
for cp, data in results.items():
    print(cp, data.get("error") or data["control"].split("Version:")[-1].splitlines()[0], flush=True)
