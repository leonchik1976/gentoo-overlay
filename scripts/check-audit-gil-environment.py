#!/usr/bin/env python3
"""Run current python_test() with a targeted pytest subset in an existing stage.
This supplements earlier full ebuild runs; it does not rebuild the extension.
"""
import hashlib
import json
import os
import pathlib
import platform
import shlex
import socket
import subprocess
import sys

root = pathlib.Path(__file__).resolve().parents[1]
cp, version, target = sys.argv[1:4]
package = cp.split('/')[1]
ebuild = root / cp / f'{package}-{version}.ebuild'
digest = hashlib.sha256(ebuild.read_bytes())
for resource in sorted((ebuild.parent / 'files').rglob('*')):
    if resource.is_file():
        digest.update(str(resource.relative_to(ebuild.parent)).encode())
        digest.update(resource.read_bytes())
default_workspace = pathlib.Path('/tmp/codex') / (cp + '-' + version) / (target + '-' + digest.hexdigest()[:8])
workspace = pathlib.Path(sys.argv[4] if len(sys.argv) == 5 else default_workspace).resolve()
assert workspace.is_relative_to(pathlib.Path('/tmp/codex') / (cp + '-' + version))
source = ebuild.read_text()
function = source[source.index('python_test() {'):]
assert function.rstrip().endswith('}')
sites = list(workspace.glob('portage/*/*/work/**/install/usr/lib/python*/site-packages'))
assert len(sites) == 1, sites
site = sites[0]
build_dir = site.parents[3].parent
executable = site.parents[2] / 'bin' / target.replace('python3_', 'python3.')
source_dir = next(workspace.glob(f'portage/*/*/work/{package}-{version}'))
test_file = {'jh2': 'tests/test_events.py', 'qh3': 'tests/test_buffer.py'}[package]
# Exercise the exact package function with epytest supplying a targeted subset.
script = workspace / 'audit-current-python-test.sh'
script.write_text('set -e\n'
    + 'die() { echo "die: $*" >&2; exit 1; }\n'
    + 'epytest() { "${EPYTHON}" -m pytest "$@" ' + shlex.quote(test_file) + '; }\n'
    + function + '\npython_test\n')
records = []
for mode in (None, '0', '1'):
    env = dict(os.environ, EPYTHON=str(executable), BUILD_DIR=str(build_dir),
               PYTEST_DISABLE_PLUGIN_AUTOLOAD='1')
    env.pop('PYTHON_GIL', None)
    if mode is not None:
        env['PYTHON_GIL'] = mode
    preflight_command = [str(executable), '-c',
        'import os,sys; print(sys.version); print("PYTHON_GIL",os.getenv("PYTHON_GIL")); '
        'print("xoptions",sys._xoptions); print("GIL",sys._is_gil_enabled())']
    preflight = subprocess.run(preflight_command, env=env, cwd=source_dir,
                               text=True, capture_output=True)
    record = {'mode': 'unset' if mode is None else mode,
              'preflight_command': preflight_command, 'preflight_exit': preflight.returncode,
              'preflight_stdout': preflight.stdout, 'preflight_stderr': preflight.stderr}
    if preflight.returncode:
        record['result'] = 'interpreter rejected mode before package testing'
    else:
        command = ['bash', str(script)]
        result = subprocess.run(command, env=env, cwd=source_dir,
                                text=True, capture_output=True)
        record.update(command=command, exit=result.returncode,
                      stdout=result.stdout, stderr=result.stderr)
        record['result'] = 'targeted package function executed'
    records.append(record)
output = dict(package=cp, version=version, target=target, workspace=str(workspace),
              source_dir=str(source_dir), staged_site=str(site),
              current_ebuild_sha256=hashlib.sha256(ebuild.read_bytes()).hexdigest(),
              function=function, shell_script=script.read_text(), test_file=test_file,
              architecture=platform.machine(), host=socket.gethostname(), results=records,
              limitation='Uses previously compiled same-version staged package; targeted python_test checks, not fresh compilation or full ebuild phase')
path = root / 'tools/upgrade-audit-20261024' / f'final-environment-{package}-{target}.json'
path.write_text(json.dumps(output, indent=2) + '\n')
for record in records:
    print(cp, target, record['mode'], record['result'], record.get('exit',record['preflight_exit']))
    if record.get('stdout'):
        print('\n'.join(record['stdout'].splitlines()[-4:]))
assert all(record.get('exit',0) == 0 for record in records)
