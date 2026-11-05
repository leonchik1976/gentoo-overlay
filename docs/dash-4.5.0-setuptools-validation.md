# Dash 4.5.0 setuptools metadata and asset validation

New validation executed on 2026-11-05. This report does not reuse saved build
results from the earlier Dash reports. Existing distfiles, test helpers and
isolated dependency environments were reused, but every build and test result
quoted below was newly executed. No live-system installation or merge occurred.

## Changes and source review

Updated `sci-visualization/dash/dash-4.5.0.ebuild` and added
`files/dash-4.5.0-setuptools-metadata.patch`. The renderer patch remains
unchanged. At the user's correction that the package is not installed, the
fix was moved from the temporary `-r1` ebuild into `4.5.0`; no revision ebuild
remains. The final ebuild body exactly matches the previously tested revision.

The builds, image comparisons, runtime results and first pkgcheck output below
were executed before this filename correction. Their `-r1` paths are historical
and intentionally retained. No build or runtime test was repeated for the
filename-only correction. The revision-specific README relocation described
below does not apply to the final unrevisioned ebuild.

VERIFIED: the exact [PyPI 4.5.0 release JSON](https://pypi.org/pypi/dash/4.5.0/json)
was fetched again and its sdist checksum compared with the build input:

```text
PyPI release 4.5.0 sdist SHA256 matches: 950964e22c21485edc50c36d5c139d95316d94b11348ea3e77f99acc2456b43d
```

Inspected `setup.py`, `MANIFEST.in`, `LICENSE`, the asset directories, and the
baseline wheel from that sdist. Upstream references:
[setup.py](https://github.com/plotly/dash/blob/v4.5.0/setup.py),
[MANIFEST.in](https://github.com/plotly/dash/blob/v4.5.0/MANIFEST.in),
[LICENSE](https://github.com/plotly/dash/blob/v4.5.0/LICENSE).
The shipped license text is MIT, matching the retained `LICENSE="MIT"`.

The metadata patch uses `license_expression="MIT"` and
`license_files=["LICENSE"]`, and removes the deprecated MIT Trove classifier.
Appended `>=dev-python/setuptools-77[${PYTHON_USEDEP}]` to BDEPEND, preserving
eclass dependencies. Setuptools documents PEP 639 support starting with 77.0.0:
[license migration](https://setuptools.pypa.io/en/latest/userguide/license_migration.html).
These builds used the installed setuptools 84.2.1; the minimum backend itself
was not separately built/tested in this task.

INFERRED from the exact source and runtime references: `dash/deps`,
`dash/labextension`, and `dash/labextension/dist` are asset directories belonging
to Dash, not additional intended Python namespace packages. They contain no
Python modules. Their ability to be interpreted as namespace packages is why
manifest-driven inclusion warned. The patch replaces `include_package_data=True`
with explicit `package_data` under the existing packages, including their
subdirectory paths. No namespace-package discovery was added, no warning filter
was used, and no asset was deleted. Existing component data, hidden `.gitkeep`
files and nbextension data are also declared explicitly, because replacing the
manifest-based mechanism must preserve its entire previous wheel payload.
`MANIFEST.in` and Jupyter `data_files` remain unchanged. This follows the
[setuptools package-data interface](https://setuptools.pypa.io/en/latest/userguide/datafiles.html).

Reviewed the current baseline at
`/var/db/repos/gentoo/sci-visualization/dash/dash-4.1.0.ebuild`, and the local
`/var/db/repos/gentoo/eclass/distutils-r1.eclass`, particularly installation
cleanup and supported EAPI 8. The [current eclass reference](https://devmanual.gentoo.org/eclass-reference/distutils-r1.eclass/index.html)
was also consulted. There was no need to change EAPI or integration behavior.
The r1 diff consists only of BDEPEND and the additional PATCHES entry.
Runtime dependencies, Node constraints, USE defaults, post-install guidance,
renderer source handling, architecture keywords and Python 3.12–3.14 targets
are unchanged. README.gentoo and metadata.xml need no semantic changes.

The current REST response for [Gentoo bug 985652](https://bugs.gentoo.org/985652)
was fetched: `RESOLVED / WORKSFORME`, summary
`sci-visualization/dash-4.1.0 - No module named 'coloredlogs'`.
That development-dependency history does not prescribe this metadata fix;
the existing development dependency group remains intact.

## Fresh non-merging builds

Workspace on each host:
`/tmp/codex/sci-visualization/dash-4.5.0/setuptools-qa` (`W` below).
All remote repository files were staged under `$W/repo`; no remote Git checkout
or registered overlay was edited. Native arm64 validation ran only on `gentoo`.

`$W/build.sh` executed the following, with a separate PORTAGE_TMPDIR per label:

```sh
export PORTAGE_TMPDIR="$W/$label"
export DISTDIR=/tmp/codex/sci-visualization/dash-4.5.0/distfiles
export TMPDIR="$W/tmp"
export PYTHON_TARGETS="$target" ACCEPT_KEYWORDS='~amd64 ~arm64'
export USE="$mode -compress -diskcache"
ebuild "$repo/sci-visualization/dash/dash-$version.ebuild" unpack prepare compile install
```

The exact successful argument matrix on **both** hosts was:

```text
before-enabled       4.5.0     python3_14 development
before-disabled      4.5.0     python3_14 -development
after-fixed-312      4.5.0-r1  python3_12 development
after-fixed-313      4.5.0-r1  python3_13 development
after-fixed-314      4.5.0-r1  python3_14 development
after-fixed-disabled 4.5.0-r1  python3_14 -development
```

Invocation: `bash "$W/build.sh" label version target mode [repo]`.
The local default repo was the requested Git checkout; arm64 explicitly used
`$W/repo`. All logs are `$W/<label>.log`. Native logs were copied back under
`$W/arm64/` on leonids-pc.

VERIFIED: each host printed the following completion markers:

```text
before-enabled exit=0
before-disabled exit=0
after-fixed-312 exit=0
after-fixed-313 exit=0
after-fixed-314 exit=0
after-fixed-disabled exit=0
```

Each final log includes `Completed installing` into its temporary `image` and
`Verifying compiled files for python3.12`, `.13`, or `.14` as appropriate.
These are actual compile/install-to-image builds, not dependency simulations
or live installations. Thus amd64 was build-tested on leonids-pc and arm64 was
build-tested natively on gentoo for every declared target. Runtime tests below
used Python 3.14; they were not repeated under 3.12/3.13.

VERIFIED by `$W/inspect_artifacts.py`, newly run on each host:

```text
before-enabled build staged; specific warnings=4
before-disabled build staged; specific warnings=4
after-fixed-312 build staged; specific warnings=0
after-fixed-313 build staged; specific warnings=0
after-fixed-314 build staged; specific warnings=0
after-fixed-disabled build staged; specific warnings=0
```

The helper asserts presence/absence of the exact license-classifier warning
and all three `Package 'dash.…' is absent` warnings, and requires successful
staging. No warning filters or QA overrides were set.

An initial sandbox build could not set Portage directory ownership; it was
rerun outside that sandbox, still as the ordinary user. Initial patch attempts
(`after-312`, `after-313`, `after-314`, `after-disabled`) failed during prepare
because the existing benchmark exclusion changed a patch context line.
The patch context was corrected; all successful final builds used fresh
`after-fixed-*` directories. Failed logs are retained, not counted as validation.

## Wheel metadata, full payload comparison and Jupyter structure

Exact commands on each host:

```sh
python3 "$W/inspect_artifacts.py" > "$W/inspect-ARCH.log"
python3.14 "$W/compare_bytecode.py" > "$W/bytecode-ARCH.log"
```

VERIFIED: Python 3.12, 3.13 and 3.14 wheels, plus the development-disabled wheel,
have `Metadata-Version: 2.4`, `License-Expression: MIT`, `License-File: LICENSE`,
no legacy `License` field and no license classifier. Their
`dash-4.5.0.dist-info/licenses/LICENSE` is byte-identical to the original sdist.
Installed metadata was also checked in every staged target.

The eclass removes `RECORD` and `.dist-info/licenses/*` during normal staged
installation (`distutils-r1.eclass`, lines 958–973 at inspection time).
Both baseline and revised images therefore omit that duplicate license copy;
this patch does not remove it. The license remains in source and wheel
metadata/files, with the standard Gentoo `LICENSE="MIT"` declaration retained.

VERIFIED on both architectures, separately for development enabled/disabled:

```text
wheel before-enabled after-fixed-314 entries 409 409 removed 0 added 0 changed 2
wheel before-disabled after-fixed-disabled entries 409 409 removed 0 added 0 changed 2
```

Only `dash-4.5.0.dist-info/METADATA` and `RECORD` differ. METADATA changes are:
`License: MIT` becomes `License-Expression: MIT`, the MIT classifier disappears,
and `Dynamic: license` becomes `Dynamic: license-expression`. RECORD updates
its METADATA checksum and size. All other wheel bytes and paths are identical.
All 109 non-Python package assets match the original sdist, including JavaScript,
workers, source maps, component metadata, third-party notices and hidden files.

Staged-image comparison output on each host:

```text
image before-enabled after-fixed-314 entries 1287 1287 removed 2 added 2 changed 874
image before-disabled after-fixed-disabled entries 1283 1283 removed 2 added 2 changed 874
before-enabled after-fixed-314 873 changed pycs: normalized code identical; 873 differ only in header
before-disabled after-fixed-disabled 873 changed pycs: normalized code identical; 873 differ only in header
```

Every relocated file is accounted for: `README.gentoo.bz2` and `README.md.bz2`
move from `/usr/share/doc/dash-4.5.0/` to `/usr/share/doc/dash-4.5.0-r1/`, with
identical bytes. Nothing else is removed or added. The changed files are
METADATA and 873 `.pyc` files; their marshalled payloads are identical and only
regenerated headers differ. Full path lists are saved as
`$W/before-*-after-fixed-*-{wheel,image}-diff.json` on each host and copied back
with arm64 evidence.

VERIFIED structurally in every revised wheel and staged image:

- `dash/labextension/dist/dash-jupyterlab.tgz` matches the sdist and the wheel's
  separate `share/jupyter/lab/extensions` copy byte for byte.
- `/usr/share/jupyter/lab/extensions/dash-jupyterlab.tgz` is identical in stage.
- Its package metadata identifies `@plotly/dash-jupyterlab`, version `0.4.3`.
  This is the archive shipped by Dash 4.5.0, not a version inferred from the
  older Gentoo baseline. The seven tar entries are `package`, `package/lib`,
  `package/package.json`, `package/style`, `package/lib/index.d.ts`,
  `package/lib/index.js`, and `package/style/index.css`.
- `/usr/share/jupyter/nbextensions/dash/main.js` and
  `/etc/jupyter/nbconfig/notebook.d/dash.json` match upstream bytes. There is
  no staged `/usr/etc`; the existing Gentoo relocation remains effective.
- Development-enabled staging contains the three development console commands
  and `/usr/share/dash/dash-4.5.0.gh.tar.gz`; disabled staging omits those
  commands/archive. The other wheel payload is preserved in both cases.

NOT VERIFIED: an actual JupyterLab/notebook session, extension activation or
compatibility with a particular installed Jupyter version. These are archive,
metadata and installation-path checks.

## Newly executed runtime and development checks

For each host, `stage` was the image under `after-fixed-314` or
`after-fixed-disabled`. Existing isolated `restore-use-flags/venv-disabled`
and `venv-both` environments supplied dependencies, without changing any live
package or treating installed imports as dependency-resolution validation.

```sh
R=/tmp/codex/sci-visualization/dash-4.5.0/restore-use-flags
"$R/venv-disabled/bin/python" "$W/runtime.py" "$stage"
"$R/venv-disabled/bin/python" "$W/check-features.py" disabled "$disabled_stage"
"$R/venv-both/bin/python" "$W/check-features.py" both "$enabled_stage"
```

VERIFIED on both hosts and development modes, importing Dash from the stage:

```text
staged Dash HTTP layout/dependencies, 10 JavaScript assets and callback HELLO OK
registered assets: 38 HTTP responses match staged bytes; upstream absent: ['dash/dash-renderer/build/dash_renderer.min.js.map', 'dash/dcc/async-mathjax.js.map']
```

The registered-asset check covers workers, dynamically loaded bundles and
available maps in addition to index scripts; Plotly's separately installed
bundle is resolved from the isolated environment. The two named maps are also
absent from the original 4.5.0 sdist; they were not removed by this patch.
No replacement files were fabricated. Existing maps remain byte-identical.
These tests use Flask's HTTP test client, not a browser executing JavaScript.

Also VERIFIED on both hosts:

```text
both: actual HTTP gzip 21073 -> 167 bytes, decompression matches
both: DiskcacheManager background callback HTTP submit/poll returned 42 in a distinct worker process
both: msgspec-backed DiskcacheSharedStorage round-trip OK
disabled: uncompressed HTTP OK; missing compression provider gives expected ImportError
disabled: core app and installed diskcache code OK; absent providers give expected ImportError
```

This exercises installed feature code with and without isolated providers. Builds
used `-compress -diskcache`; the r1 feature dependency groups are textually
unchanged. Fresh dependency-resolution plans were not repeated for this metadata
fix; prior dependency-plan evidence remains historical in the flag report.

Renderer workspace and CLI checks were newly rerun with the existing smoke
helper on each host:

```sh
python3.14 /tmp/codex/sci-visualization/dash-4.5.0/smoke.py \
  "$enabled_stage" /tmp/codex/dev-python/janus-2.0.0/janus-2.0.0 "$W/renderer-cache"
```

```text
python3.14: Dash 4.5.0 staged imports, HTTP layout/dependencies, 10 JS assets, renderer workspace and 3 CLI help checks OK
```

This checks extraction of the staged source archive to a writable cache and an
explicit renderer path. It does not substitute for the real component-update
workflow recorded previously in `dash-4.5.0-validation.md`; that npm workflow
was not rerun for this metadata-only change.

## QA and remaining findings

Commands newly run in the requested checkout:

```sh
bash -n sci-visualization/dash/dash-4.5.0-r1.ebuild
XDG_CACHE_HOME="$W/qa-cache" \
 /tmp/codex/sci-visualization/dash-4.5.0/qa-venv/bin/pkgdev manifest \
 -d /tmp/codex/sci-visualization/dash-4.5.0/distfiles sci-visualization/dash
XDG_CACHE_HOME="$W/qa-cache" pkgcheck scan sci-visualization/dash
git diff --check
# The three new files are untracked; check their complete diffs too.
git diff --no-index --check /dev/null sci-visualization/dash/dash-4.5.0-r1.ebuild
git diff --no-index --check /dev/null sci-visualization/dash/files/dash-4.5.0-setuptools-metadata.patch
git diff --no-index --check /dev/null docs/dash-4.5.0-r1-setuptools-validation.md
```

VERIFIED: `bash -n` and `git diff --check` returned 0 without output.
The complete-file `--no-index --check` comparisons emitted no whitespace
diagnostics; they returned 1 because each new file differs from `/dev/null`.
An additional line-by-line assertion found no trailing whitespace in the three
new files. Manifest output:
`manifests are up to date`. No Manifest entries changed (thin manifests retain
the same upstream distfiles).

Pkgcheck is **not clean**. Literal finding categories were:

```text
NonsolvableDepsInDev: version 4.5.0
NonsolvableDepsInStable: version 4.5.0
RedundantVersion: version 4.5.0: slot(0) keywords are overshadowed by version: 4.5.0-r1
NonsolvableDepsInDev: version 4.5.0-r1
NonsolvableDepsInStable: version 4.5.0-r1
```

The dependency findings concern `~arm64` providers `coloredlogs`, `msgspec` and
`python-fire`, already reported for r0. The same unchanged dependencies produce
them for r1. The user's prior keyword acceptance is not repository keywording;
no provider ebuilds or user configuration were changed. `RedundantVersion` is
new because the original ebuild is retained under the standing repository rule
against removing old versions without need. Full literal output:
`$W/pkgcheck.log`.

Other build-log messages remain on both baselines and revisions:

```text
error: could not lock config file /etc/gitconfig: Permission denied
warning: build_py: byte-compiling is disabled, skipping.
warning: install_lib: byte-compiling is disabled, skipping.
warning: no files found matching 'dash/deps/*.map'
warning: no files found matching 'dash/dash-renderer/build/*.map'
```

The first is an existing environment/hook attempt that could not change the
system config and did not stop staging. Backend byte-compilation is deferred to
Portage; each build's final compiled-file verification ran. The empty manifest
globs refer to files absent from the original release. None of these messages
was filtered or suppressed. This revision addresses the four requested
setuptools QA warnings, not unrelated upstream/environment messages.

## Validation after removing the revision

Newly executed after moving the tested body to `dash-4.5.0.ebuild`:

```sh
bash -n sci-visualization/dash/dash-4.5.0.ebuild
git diff --check
XDG_CACHE_HOME=/tmp/codex/sci-visualization/dash-4.5.0/setuptools-qa/qa-cache pkgcheck scan sci-visualization/dash
```

Syntax and diff checks returned 0 without output. The scoped scan output is
saved in `setuptools-qa/pkgcheck-unrevisioned.log` under the package's temporary
workspace. VERIFIED: the scan reports only `NonsolvableDepsInDev` and
`NonsolvableDepsInStable` for version 4.5.0 and the same arm64 providers
(coloredlogs, msgspec, python-fire). `RedundantVersion` is no longer reported.
No live installation or merge was performed.
