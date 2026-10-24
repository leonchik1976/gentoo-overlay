#!/usr/bin/env python3
"""Run only a non-merging ebuild phase, with writable state confined to this repo."""
import json
import os
import pathlib
import subprocess
import sys
import shlex
import hashlib
import socket
import portage

root = pathlib.Path(__file__).resolve().parents[1]
out = root / "tools/upgrade-audit-20261024"
cp, version, target, phase = sys.argv[1:]
if phase not in {"unpack", "prepare", "configure", "compile", "test"}:
    raise SystemExit("Only non-merging source phases are permitted")
ebuild = root / cp / (cp.split("/")[1] + "-" + version + ".ebuild")
if not ebuild.exists():
    ebuild = pathlib.Path("/var/db/repos/gentoo") / cp / ebuild.name
source_hash = hashlib.sha256(ebuild.read_bytes())
for resource in sorted((ebuild.parent / "files").rglob("*")):
    if resource.is_file():
        source_hash.update(str(resource.relative_to(ebuild.parent)).encode())
        source_hash.update(resource.read_bytes())
source_id = source_hash.hexdigest()[:8]
workspace = pathlib.Path(os.environ.get("AUDIT_WORK_ROOT", "/tmp/codex")) / (cp + "-" + version) / (target + "-" + source_id)
workspace.mkdir(parents=True, exist_ok=True)
distdir = workspace / "distfiles"
distdir.mkdir(exist_ok=True)
# Existing tool-managed cache files are read through symlinks; never fetch
# into or update the system cache during this audit.
for path in (out / "distfiles").glob("*"):
    link = distdir / path.name
    if not link.exists():
        link.symlink_to(path)
inventory_file = out / "final-inventory.json"
if not inventory_file.exists():
    inventory_file = out / "inventory.json"
inventory = json.loads(inventory_file.read_text())
item = inventory.get(cp, {})
metadata = item.get("metadata", item.get("resolved_metadata", {}))
if not metadata:
    db = portage.db[portage.root]["porttree"].dbapi
    metadata = {"SRC_URI": db.aux_get(cp + "-" + version, ["SRC_URI"])[0]}
tokens = metadata.get("SRC_URI", "").split()
for i, token in enumerate(tokens):
    if not token.startswith(("https://", "http://", "mirror://")):
        continue
    name = tokens[i + 2] if i + 2 < len(tokens) and tokens[i + 1] == "->" else token.rsplit("/", 1)[-1]
    source = pathlib.Path("/var/cache/distfiles") / name
    link = distdir / name
    if source.is_file() and not link.exists():
        link.symlink_to(source)
config = portage.settings.repositories.config_string()
try:
    local_location = portage.settings.repositories.get_location_for_name("local")
except KeyError:
    local_location = None
if local_location is not None:
    config = config.replace("location = " + local_location, "location = " + str(root))
else:
    config += "\n[local]\nlocation = " + str(root) + "\nmasters = gentoo guru\n"
configroot = workspace / "config"
(configroot / "etc/portage").mkdir(parents=True, exist_ok=True)
(configroot / "etc/portage/repos.conf").write_text(config)
profile = configroot / "etc/portage/make.profile"
if not profile.exists():
    profile.symlink_to("/etc/portage/make.profile")
(configroot / "etc/portage/make.conf").write_text(
    'source /etc/portage/make.conf\nRUSTC_WRAPPER=""\n'
    'FEATURES="${FEATURES} -ccache -sccache"\n'
    'GIT_CONFIG_SYSTEM=' + shlex.quote(str(workspace / "git-system.config")) + '\n')
env = dict(os.environ, PORTAGE_REPOSITORIES=config, PORTAGE_TMPDIR=str(workspace),
           PORTAGE_CONFIGROOT=str(configroot),
           DISTDIR=str(distdir), PKGDIR=str(workspace / "packages"),
           PORT_LOGDIR=str(workspace / "logs"), PORTAGE_LOGDIR=str(workspace / "logs"),
           PORTAGE_ELOG_SYSTEM="", PYTHON_TARGETS=target, PYTHON_SINGLE_TARGET=target,
           USE="test", MAKEOPTS="-j8", RUSTC_WRAPPER="", SCCACHE_DISABLE="1",
           SCCACHE_DIR=str(workspace / "sccache"),
           GIT_CONFIG_SYSTEM=str(workspace / "git-system.config"))
env.pop("PYTHON_GIL", None)
command = ["ebuild", str(ebuild), phase]
print("Command:", " ".join(command), flush=True)
print("Host:", socket.gethostname(), "; target:", target, "; workspace:", workspace, flush=True)
if phase == "test" and os.environ.get("AUDIT_TEST_SITE"):
    extra_site = pathlib.Path(os.environ["AUDIT_TEST_SITE"]).resolve()
    if not (extra_site.is_relative_to(root) or extra_site.is_relative_to(pathlib.Path("/tmp/codex"))):
        raise SystemExit("Test dependency staging must remain inside the repository or /tmp/codex")
    result = subprocess.run(["ebuild", str(ebuild), "compile"], env=env)
    if result.returncode:
        raise SystemExit(result.returncode)
    sites = list(workspace.glob("portage/*/*/work/**/install/usr/lib/python*/site-packages"))
    if len(sites) != 1:
        raise SystemExit(f"Expected one staged site directory, found {sites}")
    (sites[0] / "audit-test-dependency.pth").write_text("\n".join([str(extra_site)] + [line for file in sorted(extra_site.glob("audit-*.pth")) for line in file.read_text().splitlines() if line and not line.startswith(("#", "import "))]) + "\n")
# A successful previous test phase must not turn a requested rerun into a no-op.
# Remove only Portage's test marker inside this isolated package workspace.
if phase == "test":
    for marker in workspace.glob("portage/*/*/.tested"):
        marker.unlink()
result = subprocess.run(command, env=env)
print("Exit:", result.returncode, flush=True)
raise SystemExit(result.returncode)
