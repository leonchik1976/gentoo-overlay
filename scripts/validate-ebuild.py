#!/usr/bin/env python3
"""Run scoped QA and non-merging builds with package-local temporary state.

No merge, qmerge, package installation, or system configuration changes are
performed. The install phase, when requested, writes only the staged image.
Run from the overlay root; logs remain under /tmp/codex/category/package-version.
"""

import argparse
import json
import os
from pathlib import Path
import shlex
import subprocess


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("ebuild", type=Path)
    parser.add_argument("--manifest", action="store_true")
    parser.add_argument("--scan", action="store_true")
    parser.add_argument("--build", action="store_true")
    parser.add_argument("--tests", action="store_true")
    parser.add_argument("--unpack-only", action="store_true")
    parser.add_argument("--use", default="", help="USE selections for this isolated build")
    parser.add_argument("--accounts", default="", help="Validation-only name:uid:gid entries in a private mount namespace")
    parser.add_argument("--python", default="python3_13", choices=[f"python3_{v}" for v in range(11, 16)])
    parser.add_argument("--clean-after", action="store_true", help="Clean temporary build/image files after recording the staged inventory")
    args = parser.parse_args()
    ebuild = args.ebuild.resolve(strict=True)
    repo = ebuild.parents[2]
    cp = str(ebuild.parent.relative_to(repo))
    workspace = Path("/tmp/codex") / ebuild.parent.parent.name / ebuild.stem
    workspace.mkdir(parents=True, exist_ok=True)
    dist = workspace / "distfiles"
    dist.mkdir(exist_ok=True)
    manifest = ebuild.parent / "Manifest"
    if manifest.exists():
        for line in manifest.read_text().splitlines():
            fields = line.split()
            if fields and fields[0] == "DIST":
                cached = Path("/var/cache/distfiles") / fields[1]
                target = dist / fields[1]
                if cached.is_file() and not target.exists():
                    target.symlink_to(cached)

    result_file = workspace / "validation.json"
    results = json.loads(result_file.read_text()) if result_file.exists() else []

    def run(command, name, env=None):
        log = workspace / (name + ".log")
        with log.open("w") as output:
            result = subprocess.run(command, cwd=repo, env=env, stdout=output,
                                    stderr=subprocess.STDOUT)
        record = {"command": command, "exit": result.returncode, "log": str(log)}
        results.append(record)
        (workspace / "validation.json").write_text(json.dumps(results, indent=2) + "\n")
        print(json.dumps(record), flush=True)
        return result.returncode == 0

    if not run(["bash", "-n", str(ebuild)], "syntax"):
        return 1
    if args.manifest and not run(["pkgdev", "manifest", "-d", str(dist), cp], "manifest"):
        return 1
    if args.scan and not run(["pkgcheck", "scan", "--cache-dir",
                             str(workspace / "pkgcheck-cache"), "--cache=-git", cp], "pkgcheck"):
        return 1
    if args.build or args.unpack_only:
        etc = workspace / "config/etc/portage"
        etc.mkdir(parents=True, exist_ok=True)
        profile = etc / "make.profile"
        if not profile.exists():
            profile.symlink_to(Path("/etc/portage/make.profile").resolve())
        (etc / "repos.conf").write_text(
            "[DEFAULT]\nmain-repo = gentoo\n"
            "[gentoo]\nlocation = /var/db/repos/gentoo\n"
            "[guru]\nlocation = /var/db/repos/guru\n"
            f"[local]\nlocation = {repo}\n")
        (workspace / "build").mkdir(exist_ok=True)
        features = "test" if args.tests else "-test"
        (etc / "make.conf").write_text(
            "source /etc/portage/make.conf\n"
            f'PORTAGE_TMPDIR="{workspace}/build"\n'
            f'DISTDIR="{dist}"\n'
            f'PKGDIR="{workspace}/packages"\n'
            f'PORT_LOGDIR="{workspace}/logs"\n'
            'FEATURES="${FEATURES} -userpriv -usersandbox -ipc-sandbox '
            f'-pid-sandbox -cgroup -sccache -ccache network-sandbox {features}"\n'
            f'PYTHON_TARGETS="{args.python}"\nPYTHON_SINGLE_TARGET="{args.python}"\n'
            'MAKEOPTS="-j4"\nRUSTC_WRAPPER=""\nRUSTC_WORKSPACE_WRAPPER=""\n'
            f'USE="${{USE}} "{shlex.quote(args.use)}\n')
        env = os.environ.copy()
        env["TAR_OPTIONS"] = "--no-same-owner"
        env["PORTAGE_CONFIGROOT"] = str(workspace / "config")
        phases = ["clean", "unpack"]
        if not args.unpack_only:
            phases += ["prepare", "configure", "compile"]
            if args.tests:
                phases += ["test"]
            phases += ["install"]
        command = ["unshare", "--user", "--map-auto", "--map-root-user",
                   "ebuild", str(ebuild), *phases]
        if args.accounts:
            passwd = workspace / "validation-passwd"
            group = workspace / "validation-group"
            passwd_text = Path("/etc/passwd").read_text()
            group_text = Path("/etc/group").read_text()
            for entry in args.accounts.split(","):
                name, uid, gid = entry.split(":")
                int(uid), int(gid)
                if not name or not all(c.isalnum() or c in "_-" for c in name):
                    raise ValueError("Invalid account name")
                if not any(line.startswith(name + ":") for line in passwd_text.splitlines()):
                    passwd_text += f"{name}:x:{uid}:{gid}:Validation only:/nonexistent:/bin/false\n"
                if not any(line.startswith(name + ":") for line in group_text.splitlines()):
                    group_text += f"{name}:x:{gid}:\n"
            passwd.write_text(passwd_text)
            group.write_text(group_text)
            # Bindings affect only this child mount namespace. No host account
            # or live configuration file is modified.
            command = ["unshare", "--user", "--map-auto", "--map-root-user", "--mount",
                       "sh", "-ec", 'mount --make-rprivate /; mount --bind "$1" /etc/passwd; '
                       'mount --bind "$2" /etc/group; shift 2; exec "$@"',
                       "validate-ebuild", str(passwd), str(group), "ebuild", str(ebuild), *phases]
        if not run(command, "build", env):
            return 1
        image = workspace / "build/portage" / ebuild.parent.parent.name / ebuild.stem / "image"
        if not args.unpack_only:
            # Staged ownership can map to subordinate host UIDs. Inspect with
            # the same namespace mapping instead of silently missing files.
            inventory = (
                "from pathlib import Path; import sys; p=Path(sys.argv[1]); "
                "print(*(str(x.relative_to(p)) for x in sorted(p.rglob('*')) "
                "if not x.is_dir()), sep=chr(10))"
            )
            if not run(["unshare", "--user", "--map-auto", "--map-root-user",
                        "python", "-c", inventory, str(image)], "installed-files"):
                return 1
            if args.clean_after and not run(
                    ["unshare", "--user", "--map-auto", "--map-root-user",
                     "ebuild", str(ebuild), "clean"], "clean-after-build", env):
                return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
