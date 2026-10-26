#!/usr/bin/env python3
"""Stage the built application and the runtime closure of upstream dependencies."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil


def resolve(name, origin):
    for parent in [origin, *origin.parents]:
        candidate = parent / 'node_modules' / name
        if (candidate / 'package.json').is_file():
            return candidate
    raise FileNotFoundError(f'{name} from {origin}')


def stage(source, target):
    app = source / 'packages/compass'
    if target.parent != source.parent or target.name != 'app':
        raise ValueError('Runtime staging must be WORKDIR/app beside the source')
    if target.exists():
        shutil.rmtree(target)
    target.mkdir(parents=True)
    shutil.copytree(app / 'build', target / 'build', symlinks=False)
    pkg = json.loads((app / 'package.json').read_text())
    pkg.update(channel='stable', distribution='compass')
    pkg.pop('devDependencies', None)
    pkg.pop('scripts', None)
    (target / 'package.json').write_text(json.dumps(pkg, indent=2) + '\n')
    seen = set()

    def visit(name, origin, optional=False):
        try:
            module = resolve(name, origin)
        except FileNotFoundError:
            if optional:
                return
            raise
        if module in seen:
            return
        seen.add(module)
        relative = module.relative_to(source)
        if relative.parts[0] != 'node_modules':
            raise ValueError(f'Unexpected workspace runtime dependency: {relative}')
        dest = target / relative
        dest.parent.mkdir(parents=True, exist_ok=True)
        def ignored(directory, names):
            skip = set(shutil.ignore_patterns('node_modules', '.cache', 'obj.target', '*.o', '*.a')(directory, names))
            if name == 'mongodb-client-encryption' and Path(directory) == module:
                skip.add('deps')  # libmongocrypt was statically linked into mongocrypt.node
            return skip

        shutil.copytree(module, dest, symlinks=False, ignore=ignored)
        info = json.loads((module / 'package.json').read_text())
        for dep in info.get('dependencies', {}):
            visit(dep, module, dep in info.get('optionalDependencies', {}))
        for dep in info.get('optionalDependencies', {}):
            visit(dep, module, True)
        # Published modules may use their installed peer providers at runtime.
        for dep in info.get('peerDependencies', {}):
            visit(dep, module, True)

    for name in pkg.get('dependencies', {}):
        visit(name, app)
    # Explicit webpack externals also include this native module, even though
    # it is provided through the embedded shell rather than Compass directly.
    visit('interruptor', app)
    print(f'Staged {len(seen)} runtime npm packages')


def prepare(source, distdir):
    lockpath = source / 'package-lock.json'
    lock = json.loads(lockpath.read_text())
    count = 0
    for info in lock['packages'].values():
        url = info.get('resolved', '')
        if not url.startswith('https://registry.npmjs.org/'):
            continue
        filename = 'mc-' + hashlib.sha256(url.encode()).hexdigest()[:16] + '.tgz'
        archive = distdir / filename
        if not archive.is_file():
            raise FileNotFoundError(archive)
        # Only redirect the frozen download location. npm still verifies the
        # upstream lockfile's original integrity, including old SHA1 entries.
        info['resolved'] = archive.as_uri()
        count += 1
    lockpath.write_text(json.dumps(lock, indent=2) + '\n')
    print(f'Redirected {count} locked npm inputs to Portage distfiles')


def configure(source):
    ssh = source / 'node_modules/ssh2'
    replacements = {
        'lib/protocol/constants.js': (
            "let cpuInfo;\ntry {\n  cpuInfo = require('cpu-features')();\n} catch {}",
            "// Use upstream's baseline cipher ordering.\nconst cpuInfo = undefined;"
        ),
        'lib/protocol/crypto.js': (
            "try {\n  binding = require('./crypto/build/Release/sshcrypto.node');\n"
            "  ({ AESGCMCipher, ChaChaPolyCipher, GenericCipher,\n"
            "     AESGCMDecipher, ChaChaPolyDecipher, GenericDecipher } = binding);\n} catch {}",
            "// Use the upstream JavaScript implementations below."
        ),
    }
    for name, (old, new) in replacements.items():
        path = ssh / name
        text = path.read_text()
        if new in text:  # Allow a failed compile to be retried.
            continue
        if text.count(old) != 1:
            raise ValueError(f'Unexpected upstream SSH2 source: {name}')
        path.write_text(text.replace(old, new))
    path = ssh / 'package.json'
    pkg = json.loads(path.read_text())
    for name in ('cpu-features', 'nan'):
        pkg.get('optionalDependencies', {}).pop(name, None)
    path.write_text(json.dumps(pkg, indent=2) + '\n')
    print('Selected upstream SSH2 JavaScript fallbacks for optional NAN accelerators')


parser = argparse.ArgumentParser(description=__doc__)
subparsers = parser.add_subparsers(dest='command', required=True)
for command in ('prepare', 'configure', 'stage'):
    sub = subparsers.add_parser(command)
    sub.add_argument('source', type=Path)
    if command != 'configure':
        sub.add_argument('target', type=Path)
args = parser.parse_args()
if args.command == 'configure':
    configure(args.source)
else:
    {'prepare': prepare, 'stage': stage}[args.command](args.source, args.target)
