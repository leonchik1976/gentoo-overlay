#!/usr/bin/env python3
# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
"""Isolate the desktop workspace and use only Portage-fetched npm archives."""
import json
from pathlib import Path
import posixpath
import sys

import yaml

source, distdir = map(Path, sys.argv[1:])
lock = source / 'pnpm-lock.yaml'
documents = list(yaml.safe_load_all(lock.read_text()))
data = documents[-1]


def dependency_key(name, version):
    for key in (name + '@' + version, version):
        if key in data['snapshots']:
            return key
    raise ValueError((name, version))


workspaces = set()
snapshots = set()
pending = ['applications/inbox-desktop']
while pending:
    workspace = pending.pop()
    if workspace in workspaces:
        continue
    workspaces.add(workspace)
    for field in ('dependencies', 'devDependencies', 'optionalDependencies'):
        for name, info in data['importers'][workspace].get(field, {}).items():
            version = info['version']
            if version.startswith('link:'):
                pending.append(posixpath.normpath(posixpath.join(workspace, version[5:])))
            else:
                snapshots.add(dependency_key(name, version))
pending = list(snapshots)
while pending:
    snapshot = pending.pop()
    for field in ('dependencies', 'optionalDependencies'):
        for name, version in data['snapshots'][snapshot].get(field, {}).items():
            key = dependency_key(name, version)
            if key not in snapshots:
                snapshots.add(key)
                pending.append(key)

packages = {key.split('(')[0] for key in snapshots}
data['importers'] = {key: data['importers'][key] for key in sorted(workspaces)}
data['importers']['.'] = {}
data['snapshots'] = {key: data['snapshots'][key] for key in sorted(snapshots)}
data['packages'] = {key: data['packages'][key] for key in sorted(packages)}
count = 0
for key, info in data['packages'].items():
    if key.startswith('@electron/node-gyp@https:'):
        filename = 'proton-mail-node-gyp-06b29aafb7708acef8b3669835c8a7857ebc92d2.tar.gz'
    else:
        name, version = key.rsplit('@', 1)
        filename = f'proton-mail-npm-{name.replace("@", "").replace("/", "-")}-{version}.tgz'
    archive = distdir / filename
    if archive.is_file():
        # Keep the upstream integrity: only the location changes, never the
        # locked version or content. Other-platform optional packages are left
        # untouched and skipped by pnpm on Linux arm64.
        info['resolution'] = {'integrity': info['resolution']['integrity'], 'tarball': archive.as_uri()}
        count += 1
lock.write_text(yaml.safe_dump_all(documents, sort_keys=False, explicit_start=True))
print(f'Using {count} Portage-fetched npm archives in {len(workspaces)} workspaces')

manifest = source / 'package.json'
package = json.loads(manifest.read_text())
for field in ('dependencies', 'devDependencies', 'optionalDependencies', 'scripts'):
    package.pop(field, None)
manifest.write_text(json.dumps(package, indent=2) + '\n')
workspace_file = source / 'pnpm-workspace.yaml'
workspace_config = yaml.safe_load(workspace_file.read_text())
workspace_config['packages'] = sorted(workspaces)
workspace_file.write_text(yaml.safe_dump(workspace_config, sort_keys=False))

config = source / 'applications/inbox-desktop/forge.config.ts'
text = config.read_text()
needle = '    packagerConfig: {\n'
if text.count(needle) != 1:
    raise SystemExit('Unexpected Electron Forge configuration')
config.write_text(text.replace(needle, needle + '        electronZipDir: process.env.PROTON_ELECTRON_ZIP_DIR,\n'))
