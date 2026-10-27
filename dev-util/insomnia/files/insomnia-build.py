#!/usr/bin/env python3
"""Prepare locked offline inputs and stage Insomnia's unbundled runtime modules."""
import argparse
import base64
import hashlib
import json
from pathlib import Path
import re
import shutil

PLUGINS = {'@kong/insomnia-plugin-ai', '@kong/insomnia-plugin-external-vault'}
GRPC_COMMIT = 'f806b5a0dc2092b7a6fb54dfb66c38fb58231774'


def read_json(path):
    return json.loads(path.read_text())


def write_json(path, value):
    path.write_text(json.dumps(value, indent=2) + '\n')


def filtered_lock(lock):
    """Retain the dependency closure of all workspaces, excluding private plugins."""
    packages = lock['packages']
    for info in packages.values():
        for name in PLUGINS:
            info.get('optionalDependencies', {}).pop(name, None)
    seen = set()

    def visit(key):
        if key in seen:
            return
        seen.add(key)
        info = packages[key]
        if ((info.get('os') and 'linux' not in info['os']) or
                (info.get('cpu') and not {'x64', 'arm64'}.intersection(info['cpu']))):
            return
        if info.get('link'):
            visit(info['resolved'])
            return
        for group in ('dependencies', 'devDependencies', 'optionalDependencies', 'peerDependencies'):
            for name in info.get(group, {}):
                for parent in (Path(key), *Path(key).parents):
                    candidate = (parent / 'node_modules' / name).as_posix()
                    if candidate in packages:
                        visit(candidate)
                        break
                else:
                    if group not in ('optionalDependencies', 'peerDependencies'):
                        raise ValueError(f'Unresolved {group}: {name} from {key}')

    visit('')
    for key in packages:
        if key.startswith('packages/') and '/node_modules/' not in key:
            visit(key)
    lock['packages'] = {key: value for key, value in packages.items()
                        if key in seen or (value.get('link') and value['resolved'] in seen)}
    return lock


def archive_name(url):
    return 'in-' + hashlib.sha256(url.encode()).hexdigest()[:16] + '.tgz'


def registry_url(url):
    return url.replace('https://registry.npmmirror.com/', 'https://registry.npmjs.org/')


def prepare(source, distdir):
    lock = filtered_lock(read_json(source / 'package-lock.json'))
    grpc = distdir / f'grpc-reflection-js-{GRPC_COMMIT}.tar.gz'
    grpc_uri = 'file:' + str(grpc)
    for key, info in lock['packages'].items():
        url = info.get('resolved', '')
        if url.startswith('https://registry.'):
            url = registry_url(url)
            archive = distdir / archive_name(url)
            if not archive.is_file():
                raise FileNotFoundError(archive)
            info['resolved'] = 'file:' + str(archive)
        elif url.startswith('git+'):
            if not url.endswith('#' + GRPC_COMMIT):
                raise ValueError(f'Unexpected Git dependency: {url}')
            info['resolved'] = grpc_uri
            info['integrity'] = 'sha512-' + base64.b64encode(hashlib.sha512(grpc.read_bytes()).digest()).decode()
        elif url and not info.get('link'):
            raise ValueError(f'Unexpected dependency URL: {url}')
        if 'grpc-reflection-js' in info.get('dependencies', {}):
            info['dependencies']['grpc-reflection-js'] = grpc_uri
    for path in (source / 'package.json', *source.glob('packages/*/package.json')):
        pkg = read_json(path)
        for name in PLUGINS:
            pkg.get('optionalDependencies', {}).pop(name, None)
        if 'grpc-reflection-js' in pkg.get('dependencies', {}):
            pkg['dependencies']['grpc-reflection-js'] = grpc_uri
        write_json(path, pkg)
    write_json(source / 'package-lock.json', lock)
    config = source / 'packages/insomnia/config/config.json'
    data = read_json(config)
    data['bundlePlugins'] = [p for p in data['bundlePlugins'] if p['name'] not in PLUGINS]
    write_json(config, data)
    print(f'Prepared {len(lock["packages"])} locked packages without private plugins')


def stage(source, target):
    app = source / 'packages/insomnia'
    if target != source.parent / 'app' or target.is_symlink():
        raise ValueError('Runtime staging must be WORKDIR/app beside the source')
    if target.exists():
        shutil.rmtree(target)
    shutil.copytree(app / 'build', target, ignore=shutil.ignore_patterns('*.map'))
    pkg = read_json(app / 'package.json')
    pkg['main'] = 'entry.main.min.js'
    pkg.pop('devDependencies', None)
    pkg.pop('scripts', None)
    write_json(target / 'package.json', pkg)
    seen = set()

    def visit(name, origin, optional=False):
        for parent in (origin, *origin.parents):
            module = parent / 'node_modules' / name
            if (module / 'package.json').is_file():
                break
        else:
            if optional:
                return
            raise FileNotFoundError(f'{name} from {origin}')
        if module in seen:
            return
        seen.add(module)
        dest = target / module.relative_to(source)
        dest.parent.mkdir(parents=True, exist_ok=True)

        def ignore(directory, names):
            skipped = set(shutil.ignore_patterns('node_modules', '.cache', '*.o', '*.a', 'obj.target', '.deps')(directory, names))
            if name == '@getinsomnia/node-libcurl' and Path(directory) == module:
                skipped.add('build')  # The installed addon lives in lib/binding.
            return skipped

        shutil.copytree(module, dest, symlinks=False,
                        ignore=ignore)
        info = read_json(module / 'package.json')
        for group in ('dependencies', 'optionalDependencies', 'peerDependencies'):
            for dep in info.get(group, {}):
                visit(dep, module, group != 'dependencies' or dep in info.get('optionalDependencies', {}))

    # esbuild externals and bare imports in the copied, unbundled lint worker.
    # Copy complete packages so Spectral retains its schemas and ruleset assets.
    for name in (
        '@getinsomnia/node-libcurl', 'quickjs-emscripten', 'apiconnect-wsdl',
        '@stoplight/spectral-core', '@stoplight/spectral-ref-resolver',
        '@stoplight/spectral-ruleset-bundler', '@stoplight/spectral-rulesets',
        '@stoplight/spectral-runtime',
    ):
        visit(name, app)
    print(f'Staged {len(seen)} external runtime packages')
    # Bundled JavaScript may not carry its separate license files in the output.
    # Preserve the input notices, including those for the build tools, for audit.
    notices = target / 'third-party-notices'
    inventory = {}
    for key, info in read_json(source / 'package-lock.json')['packages'].items():
        module = source / key
        if not key or info.get('link') or not module.is_dir():
            continue
        inventory[key] = {k: info[k] for k in ('version', 'license', 'integrity') if k in info}
        for path in module.iterdir():
            if path.is_file() and re.match(r'(?i)(licen[cs]e|copying|notice|readme)', path.name):
                dest = notices / key / path.name
                dest.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(path, dest)
    notices.mkdir(exist_ok=True)
    write_json(notices / 'npm-inputs.json', inventory)


def configure(source):
    # npm ci needed local tarball references, but these must not be embedded in
    # the application when upstream bundles its own package.json into main.
    for path in (source / 'package.json', *source.glob('packages/*/package.json')):
        pkg = read_json(path)
        if 'grpc-reflection-js' in pkg.get('dependencies', {}):
            pkg['dependencies']['grpc-reflection-js'] = f'github:Kong/grpc-reflection-js#{GRPC_COMMIT}'
            write_json(path, pkg)
    path = source / 'packages/insomnia/esbuild.entrypoints.ts'
    text = path.read_text()
    old_date = 'JSON.stringify(new Date())'
    if text.count(old_date) != 2:
        raise ValueError('Unexpected upstream build date expressions')
    text = text.replace(old_date, 'JSON.stringify(new Date(Number(process.env.SOURCE_DATE_EPOCH ?? 0) * 1000))')
    error = "console.error('[Build] Build failed:', err);"
    if text.count(error) != 1:
        raise ValueError('Unexpected upstream esbuild error handler')
    path.write_text(text.replace(error, error + '\n    throw err;'))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('command', choices=('prepare', 'configure', 'stage'))
    parser.add_argument('source', type=Path)
    parser.add_argument('target', type=Path, nargs='?')
    args = parser.parse_args()
    if args.command == 'configure':
        configure(args.source)
    else:
        if args.target is None:
            parser.error('prepare and stage require a target')
        {'prepare': prepare, 'stage': stage}[args.command](args.source, args.target)
