#!/usr/bin/env python3
"""Print the Snipe-IT SRC_URI dependency block from an upstream composer.lock.

Usage: scripts/generate-snipe-it-composer-deps.py /path/to/composer.lock
The filename algorithm must match www-apps/snipe-it/files/local-dist.php.
"""

import hashlib
import json
from pathlib import Path
import re
import sys


def main():
    lock = json.loads(Path(sys.argv[1]).read_text())
    for package in lock["packages"]:
        dist = package["dist"]
        url = dist["url"]
        if dist["type"] != "zip" or not re.fullmatch(
            r"https://api.github.com/repos/[\w.-]+/[\w.-]+/zipball/[0-9a-f]{40}", url
        ):
            raise ValueError(f"Review unsupported dist: {package['name']}: {dist}")
        name = package["name"].replace("/", "-")
        digest = hashlib.sha256(url.encode()).hexdigest()[:16]
        # codeload avoids the GitHub REST API's unauthenticated rate limit.
        repo, commit = url.removeprefix("https://api.github.com/repos/").split("/zipball/")
        print(f"\thttps://codeload.github.com/{repo}/legacy.zip/{commit}"
              f"\n\t\t-> snipe-it-dep-{name}-{digest}.zip")


if __name__ == "__main__":
    main()
