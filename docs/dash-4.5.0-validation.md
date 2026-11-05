# Dash packaging investigation and validation — 2026-11-05

The [4.5.0 flag-restoration report](dash-4.5.0-use-validation.md)
records the current compress/diskcache behavior and new validation. Both
flags are restored, disabled by default, and automatically select providers.
This retains the requested ::gentoo behavior despite the PG0001 concern.

The subsequent [Python 3.15 and 3.15t investigation](dash-janus-python315-validation.md)
records new native builds/tests on both architectures, dependency-target
limitations, and the reason for the local compression/diskcache flag change.
Its results supersede earlier statements here that these targets were untested.

## Current provider selection

At the user's request, the local coloredlogs and python-fire overrides were
removed, including their ebuilds, metadata, Manifests, and patches. The user
reports having accepted the needed keywords for the existing ::gentoo and
::guru providers. No user keyword configuration was changed by the assistant.
At the user's subsequent request, the local humanfriendly, capturer, and
verboselogs overrides were also removed, including their ebuilds, metadata,
Manifests, and patches. These packages will use the existing ::gentoo
providers. Dash's dependency atoms are unchanged. Only Dash and its missing
Janus dependency remain as local additions from this work.

The build and scan results below describe the earlier local-provider
configuration and remain historical evidence, not validation of this revised
provider selection. No builds were repeated for this removal-only change.

For the three subsequent removals, file-absence checks and `git diff --check`
were run; builds and pkgcheck were not repeated.

Validation of the earlier coloredlogs/python-fire removal:
`git diff --check` produced no output. The command
`XDG_CACHE_HOME=/tmp/codex/sci-visualization/dash-4.5.0/fix-development-20261105/cache pkgcheck scan sci-visualization/dash`
was rerun. It reports `NonsolvableDepsInDev` and `NonsolvableDepsInStable`
for the upstream providers' missing arm64 keywords, as expected for repository
profile scanning without the user's personal keyword acceptance. The literal
output is saved in
`/tmp/codex/sci-visualization/dash-4.5.0/fix-development-20261105/pkgcheck-after-provider-removal.log`.
Those findings were not suppressed.

## Follow-up correction: validation before provider removal

This section records **new commands executed for the follow-up request**.
Earlier results are retained below under **Initial investigation (historical)**
and are not presented as reruns. New Dash logs and helpers are in
`/tmp/codex/sci-visualization/dash-4.5.0/fix-development-20261105/` on
leonids-pc. New provider logs use `*-new.log`, `*-guarded.log`,
`*-unbuffered.log`, or `*-final.log` in their package-specific workspaces.

### Source review and changes

VERIFIED against the original tagged release, before editing Dash's dependency
list: each built-in component project invokes `black` in its backend build:

- [dash-core-components/package.json](https://github.com/plotly/dash/blob/v4.5.0/components/dash-core-components/package.json), `build:backends`.
- [dash-html-components/package.json](https://github.com/plotly/dash/blob/v4.5.0/components/dash-html-components/package.json), `build:backends`.
- [dash-table/package.json](https://github.com/plotly/dash/blob/v4.5.0/components/dash-table/package.json), `private::build:backends`.

Added `dev-python/black[${PYTHON_USEDEP}]` under `development?` in RDEPEND:
it is a runtime tool for the installed development commands, not a tool used
by the ebuild's normal compile phase. No old CI formatter pin was imposed.
The actual workflow below used Black 26.10.1.

VERIFIED: all five lockfiles were examined: the
[root lockfile](https://github.com/plotly/dash/blob/v4.5.0/package-lock.json),
[renderer lockfile](https://github.com/plotly/dash/blob/v4.5.0/dash/dash-renderer/package-lock.json),
and the lockfiles in each of the three component directories above.
Root Lerna's Node predicate is `^22.13.0 || ^24.0.0 || ^26.0.0`.
Root lint-staged requires `>=22.22.1`; dash-table's http-proxy-middleware
requires `^22.15.0 || ^24.0.0 || >=26.0.0`, and webpack-dev-server requires
`>=22.15.0`. These constraints are stricter than Lerna alone.

INFERRED from their combined contracts: the development dependency must allow
`>=22.22.1,<23`, `>=24,<25`, or `>=26,<27`. The ebuild now expresses those
as an any-of group of bounded, slot-0 Node dependencies with npm enabled.
The check used npm's semver implementation on 2,989 engine declarations:

```text
node /tmp/codex/sci-visualization/dash-4.5.0/fix-development-20261105/check-node-engines.js
Node 22.13.0: checked 2989 engine declarations; failures=3
Node 22.15.0: checked 2989 engine declarations; failures=1
Node 22.22.0: checked 2989 engine declarations; failures=1
Node 22.22.1: checked 2989 engine declarations; failures=0
Node 23.0.0: checked 2989 engine declarations; failures=40
Node 24.0.0: checked 2989 engine declarations; failures=0
Node 25.0.0: checked 2989 engine declarations; failures=2
Node 26.0.0: checked 2989 engine declarations; failures=0
Node 26.12.1: checked 2989 engine declarations; failures=0
Node 27.0.0: checked 2989 engine declarations; failures=1
```

All five lockfiles in the built workspace were byte-compared to the original
release afterward: `all five development lockfiles unchanged by initialization/build`.
No lockfile was regenerated or dependency audit fix applied.

Local provider packages were added to resolve both runtime and test dependency
keyword closure. The ::gentoo versions and patches were retained for
coloredlogs, humanfriendly, capturer, and verboselogs. Only local maintainer
metadata, unstable architecture keywords, and appending dependency assignments
differ from their ::gentoo ebuilds. The extra capturer/verboselogs packages
resolve the baseline's test?-BDEPEND findings; tests were not disabled.

| Local package | Baseline | Native arm64 Python 3.14 upstream tests |
| --- | --- | --- |
| coloredlogs-15.0.1-r2 | `::gentoo/dev-python/coloredlogs/coloredlogs-15.0.1-r2.ebuild` | `Ran 34 tests in 0.445s` / `OK (skipped=3)` |
| humanfriendly-10.0-r2 | `::gentoo/dev-python/humanfriendly/humanfriendly-10.0-r2.ebuild` | `Ran 69 tests in 10.424s` / `OK` |
| capturer-3.0-r1 | `::gentoo/dev-python/capturer/capturer-3.0-r1.ebuild` | `Ran 14 tests in 0.709s` / `OK` |
| verboselogs-1.7-r1 | `::gentoo/dev-python/verboselogs/verboselogs-1.7-r1.ebuild` | `Ran 5 tests in 0.001s` / `OK` |
| python-fire-0.7.1-r3 | `::guru/dev-python/python-fire/python-fire-0.7.1-r3.ebuild` | selected upstream suites: `Ran 237 tests in 0.234s` / `OK` |

For Fire, its exact sdist `pyproject.toml` declares termcolor as the sole
runtime dependency. The local ebuild therefore omits ::guru's unused six
dependency and duplicate test dependencies; Hypothesis is in test?-BDEPEND,
and the verified upstream asyncio/inspect patches are retained. The local
ebuild retains upstream's license metadata, rather than deleting its license
field. Fire's naming matches the existing ::guru package and Dash consumers.

Provider versions/checksums were verified using
[coloredlogs JSON](https://pypi.org/pypi/coloredlogs/15.0.1/json),
[humanfriendly JSON](https://pypi.org/pypi/humanfriendly/10.0/json),
[Fire JSON](https://pypi.org/pypi/fire/0.7.1/json),
[capturer JSON](https://pypi.org/pypi/capturer/3.0/json), and
[verboselogs JSON](https://pypi.org/pypi/verboselogs/1.7/json).
All five local sdist SHA256 values matched the respective JSON responses.
The shipped license texts were read: MIT for the four xolox projects;
Apache-2.0 for Fire. Dependencies were checked against shipped setup.py,
requirements.txt, or pyproject.toml, including humanfriendly's absence of
runtime requirements on Gentoo/Python 3.

### New non-merging builds and native validation

VERIFIED: new `unpack prepare compile install` builds were executed for Dash
and all five provider ebuilds on **leonids-pc (amd64)** and **gentoo (arm64)**.
These are actual native builds, not import-only checks of installed packages.
All used package-specific /tmp/codex PORTAGE_TMPDIR and DISTDIR locations.
Representative exact amd64 invocation:

```sh
PORTAGE_TMPDIR=/tmp/codex/sci-visualization/dash-4.5.0/fix-development-20261105/portage DISTDIR=/tmp/codex/sci-visualization/dash-4.5.0/distfiles ebuild sci-visualization/dash/dash-4.5.0.ebuild unpack prepare compile install
```

For each provider `<pn>-<pv>`, PORTAGE_TMPDIR was
`/tmp/codex/dev-python/<pn>-<pv>/validation/portage`, DISTDIR was
`/tmp/codex/dev-python/<pn>-<pv>/distfiles`, and the ebuild path was the
local ebuild listed in the table. For the remote builds the same commands
used the staged ebuild below that package's `validation/repo/dev-python/`.
The paths are fully recorded in each `build-amd64-new.log` and
`build-arm64-new.log`. New Dash builds are `build-amd64.log` and
`build-arm64.log` within this round's fix-development directory.

All logs contain `>>> Completed installing ... into .../image` and the
Python 3.12, 3.13, 3.14 compiled-file verification messages. Verboselogs also
built for Python 3.15 on both hosts, preserving its ::gentoo compatibility
list. Here `install` only populates the temporary Portage image. No merge
or installation on a live system occurred.

Native behavioral checks first built sys.path from the new provider images
and asserted each module's __file__ was under those image directories.
For all three Python versions on both hosts they printed:

```text
python3.14: staged humanfriendly parsing, coloredlogs ANSI formatting, Fire synchronous and async CLI execution OK
```

The prefix was python3.12/python3.13 in those runs. The command was
`python3.14 /tmp/codex/sci-visualization/dash-4.5.0/fix-development-20261105/provider-smoke.py`
(repeated with python3.12/python3.13); log names are
`provider-smoke-amd64.log` and `provider-smoke-arm64.log`.

The native upstream suites used the staged package files through
`provider-unittests.py`, including staged PYTHONPATH and PATH for subprocesses.
Exact final Fire invocation on gentoo:

```sh
cd /tmp/codex/dev-python/python-fire-0.7.1
TMPDIR=/tmp/codex/dev-python/python-fire-0.7.1/test-tmp XDG_CACHE_HOME=/tmp/codex/dev-python/python-fire-0.7.1/cache HYPOTHESIS_STORAGE_DIRECTORY=/tmp/codex/dev-python/python-fire-0.7.1/hypothesis timeout -s TERM -k 5s 60s /tmp/codex/sci-visualization/dash-4.5.0/fix-development-20261105/test-venv/bin/python -u /tmp/codex/sci-visualization/dash-4.5.0/fix-development-20261105/provider-unittests.py fire
```

The other module arguments were `humanfriendly`, `coloredlogs`, `capturer`,
and `verboselogs`, using their own corresponding temporary/cache paths.
Humanfriendly and coloredlogs final logs are `unittests-arm64-guarded.log`;
capturer and verboselogs use `unittests-arm64-unbuffered.log`; Fire uses
`unittests-arm64-final.log`. These logs were copied back to leonids-pc.
The test tools mock/Hypothesis were provisioned in an isolated temporary
virtual environment; no user package.accept_keywords or live packages changed.

Initial runner failures remain separate: mock was initially unavailable;
the first launcher lacked the __main__ guard needed by Python 3.14's
forkserver; redirected buffered output then failed capturer's print-capture
tests; an initial Fire module list named nonexistent value_types_test.
Those were corrected in the temporary launcher, not hidden with package
patches or new test exclusions. Coloredlogs retained ::gentoo's existing
test_auto_install exclusion, and verboselogs retained ::gentoo's existing
pylint-test patch. Fire's tested selection covers core, inspectutils,
parser, fire, completion, decorators, docstrings, formatting, helptext,
and trace; it is not represented as the entire Fire test suite.

`~arm64` was added to each local provider only after its native build and
behavioral/upstream checks. No installed-provider imports were used as a
substitute. All new packages also carry the required local `~amd64` keyword.

### Actual component-update workflow and generated runtime

VERIFIED: this round used a fresh extraction of the upstream GitHub release
under `fix-development-20261105/workspace/dash-4.5.0`, initialized with
upstream [CONTRIBUTING.md](https://github.com/plotly/dash/blob/v4.5.0/CONTRIBUTING.md)'s
root `npm ci`. The installed Python tools came from the new staged Dash
image through PATH/PYTHONPATH; all three development providers came from
their new staged images. Black was supplied by a temporary virtual environment.
The standalone `python -c` diagnostic in run-development.sh resolves the source
checkout from its current directory; the installed CLI script entry points
resolve Dash through the explicit staged PYTHONPATH.

Exact commands executed:

```sh
cd /tmp/codex/sci-visualization/dash-4.5.0/fix-development-20261105/workspace/dash-4.5.0
npm_config_cache=/tmp/codex/sci-visualization/dash-4.5.0/npm-cache XDG_CACHE_HOME=/tmp/codex/sci-visualization/dash-4.5.0/fix-development-20261105/cache npm ci
bash /tmp/codex/sci-visualization/dash-4.5.0/fix-development-20261105/run-development.sh
```

The script contains the exact PATH/PYTHONPATH environment and invokes
`dash-update-components all --ci True --concurrency 1`. It exited 0.
Output included:

```text
v26.12.1
11.20.0
black, 26.10.1 (compiled: yes)
lerna success exec Executed command in 3 packages: "npm ci"
lerna success exec Executed command in 3 packages: "npm run build"
🟢 Finished moving build artifacts from components/dash-core-components/dash_core_components to Dash 🟢
🟢 Finished moving build artifacts from components/dash-html-components/dash_html_components to Dash 🟢
🟢 Finished moving build artifacts from components/dash-table/dash_table to Dash 🟢
```

The new renderer build also completed in this same workspace, invoked via
the staged Renderer class with an explicit path. Its new output/log is
`renderer-build-new.log`; this is not the earlier saved renderer build.

`python3.14 /tmp/codex/sci-visualization/dash-4.5.0/fix-development-20261105/generated-runtime.py`
then byte-compared the freshly generated Input.py, Div.py, and DataTable.py
to their copied files, asserted imports came from that checkout, and served
an app using Input, Slider, Div, and DataTable. Literal final output:

```text
Input generated/copied SHA256 ef362b96286277eb7e27267ac281ef3545db6e7a92f0d395aeb8dad37ccbd92d
Div generated/copied SHA256 4dd60bf63df2d6a25f9dbe543e80fdfdae2fe62dd8980619f3c58baef242d9fc
DataTable generated/copied SHA256 2134e3803a7f71d99344bf68727af7b85549eb1c0cee6748419092a386f74af6
python3.14: freshly generated dcc/html/dash_table imported; layout, dependencies, 10 JS assets and callback HTTP responses OK
```

These checks used Flask's WSGI test client and checked HTTP 200 responses,
nonempty script resources from all three component namespaces, and a POST
callback response. They did not depend on an installed Dash component package.

Fresh staged-runtime checks also ran on both hosts for Python 3.12–3.14,
using this round's Dash image and the staged providers. The script
`staged-runtime.py` accepts the image path, matching staged Janus site-packages
path, and a new cache directory. Logs are `staged-runtime-amd64.log` and
`staged-runtime-arm64.log`; each version printed:

```text
python3.14: Dash 4.5.0 staged imports, HTTP layout/dependencies, 10 JS assets, renderer workspace and 3 CLI help checks OK
```

### Current QA and limits

Manifests for Dash and all five new provider packages were generated/checked
with pkgdev manifest using their package-specific distdirs. Final reruns
reported `manifests are up to date`. The five provider Manifests and their
package directories are new checkout changes. Janus was not modified.

Exact scoped scan:

```sh
XDG_CACHE_HOME=/tmp/codex/sci-visualization/dash-4.5.0/fix-development-20261105/cache pkgcheck scan sci-visualization/dash dev-python/coloredlogs dev-python/humanfriendly dev-python/python-fire dev-python/capturer dev-python/verboselogs dev-python/janus
```

Final literal output:

```text
dev-python/janus
  PythonCompatUpdate: version 2.0.0: PYTHON_COMPAT update available: python3_15

dev-python/python-fire
  PythonMismatchedPackageName: package name does not match remote-id, recommended name: 'fire'
  PythonCompatUpdate: version 0.7.1-r3: PYTHON_COMPAT update available: python3_15
```

There are no NonsolvableDeps findings in this output. No checks were suppressed.
`bash -n` was rerun for Dash and the five new provider ebuilds. All six
metadata.xml files parsed, the non-patch package files had no trailing
whitespace, and all copied provider patches byte-matched their baseline
repositories. `git diff --check` was rerun; untracked files were also checked
directly because git diff does not include them.
The Fire naming finding is retained to preserve the existing ::guru atom;
the Python 3.15 suggestions were not adopted for these packages without
validation. Janus's suggestion was already present in the initial report.
Upstream setuptools deprecation warnings remain and are recorded in the
build logs; no ebuild QA-warning suppression was introduced.

Root npm ci reported `58 vulnerabilities (34 moderate, 21 high, 3 critical)`
for upstream's locked development tree, plus upstream deprecation/install-script
notices. These are development dependency audit results, not a claim about the
Python package's runtime exposure. Component build logs retain their upstream
warnings; no audit-fix or source-lockfile changes were made.

NOT VERIFIED: visual behavior in a real browser; component/renderer JavaScript
builds on arm64; actual builds under Node 22 or 24; the complete Fire suite;
all optional servers, services, and external integrations. Actual development
builds used Node 26.12.1 on leonids-pc. Both architectures received new native
Python builds and staged runtime tests. No live-system merge/install occurred,
no registered /var/db/repos/gentoo-overlay checkout was modified, and no
commit, push, or branch change was made.

## Initial investigation (historical)

Everything below records the initial packaging turn. Its unresolved-keyword
and untested-component-workflow statements are superseded by the follow-up
results above; they are retained as historical evidence, not current limits.

## Sources and scope

VERIFIED: Both [PyPI's Dash JSON API](https://pypi.org/pypi/dash/json)
and [GitHub's latest-release API](https://api.github.com/repos/plotly/dash/releases/latest)
identified 4.5.0 as the latest stable release. GitHub returned
`v4.5.0 2026-10-29T20:23:20Z`.

The base is `/var/db/repos/gentoo/sci-visualization/dash/dash-4.1.0.ebuild`,
also published in [the official repository](https://gitweb.gentoo.org/repo/gentoo.git/tree/sci-visualization/dash/dash-4.1.0.ebuild).
No previous local Dash package or local package history existed. The initial
`git status --short` output was empty. No Dash package was found in ::guru.

[Bug 985652](https://bugs.gentoo.org/985652) was read through its REST API,
including all comments. It is RESOLVED/WORKSFORME. The maintainer's last
comment explains that the official ebuild targets Python usage and invites
patches to expand component-development support.

Exact upstream artifacts inspected:

- [Dash PyPI source distribution](https://files.pythonhosted.org/packages/c9/93/f4f8cbc5fb7f6fd16ce08d27bf9005b450a7b4b6c94357ae34708bdc7807/dash-4.5.0.tar.gz):
  SHA256 `950964e22c21485edc50c36d5c139d95316d94b11348ea3e77f99acc2456b43d`.
  This contains the built frontend assets and JupyterLab extension.
- [Dash complete tagged source](https://github.com/plotly/dash/archive/refs/tags/v4.5.0.tar.gz):
  development source, including renderer configuration, lockfile, component
  projects, and the websocket worker referenced by renderer's webpack config.
- Dash's shipped `LICENSE` is the MIT text; see the
  [tagged license](https://github.com/plotly/dash/blob/v4.5.0/LICENSE).
  Mandatory dependency constraints come from the shipped
  [requirements/install.txt](https://github.com/plotly/dash/blob/v4.5.0/requirements/install.txt),
  development dependencies from
  [requirements/dev.txt](https://github.com/plotly/dash/blob/v4.5.0/requirements/dev.txt),
  and integration guidance from the other shipped `requirements/*.txt` files.
- [Janus JSON API](https://pypi.org/pypi/janus/2.0.0/json) and
  [Janus source distribution](https://files.pythonhosted.org/packages/d8/7f/69884b6618be4baf6ebcacc716ee8680a842428a19f403db6d1c0bb990aa/janus-2.0.0.tar.gz):
  SHA256 `0970f38e0e725400496c834a368a67ee551dc3b5ad0a257e132f5b46f2e77770`.
  `LICENSE` contains Apache License 2.0; `setup.cfg` declares no runtime
  dependencies; `pyproject.toml` uses setuptools. This mandatory Dash
  dependency was absent from both ::gentoo and ::guru, so it was added locally.

The current local `distutils-r1.eclass`, `python-r1.eclass`, `pypi.eclass`,
and `optfeature.eclass` documentation and relevant implementation were read.
EAPI 9 is the latest supported by the installed Portage (`eapi_is_supported`
returned True for 9 and False for 10), but distutils-r1 supports only EAPI 8.
Both new ebuilds therefore use EAPI 8. The
[EAPI 9 PMS](https://projects.gentoo.org/pms/9/pms.html),
[PG0001](https://projects.gentoo.org/qa/policy-guide/dependencies.html#optional-runtime-dependencies),
and the [Python QA guide](https://projects.gentoo.org/python/guide/qawarn.html#stray-top-level-files-in-site-packages)
are the relevant official specifications/guidance.

## Implementation and rationale

INFERRED from upstream implementation: adding coloredlogs and fire cannot fix
renderer alone. The installed entry point assumes a writable complete source
tree beside its Python module. The Python distribution only installs runtime
bundles. It would also try to overwrite system files when rebuilding assets.

The local patch selects a renderer directory in the current source checkout,
accepts `--path`, or extracts the complete version-matched upstream archive
into `${XDG_CACHE_HOME:-$HOME/.cache}/dash/4.5.0/dash-4.5.0`. Extraction uses
Python's `data` filter and a temporary staging directory. Builds affect that
workspace, not the installed package. This is an intentional overlay design.

`USE=development` is enabled by default and controls installation of the
three development entry points and source archive, with their actual runtime
tools. It is a local flag with a metadata.xml description. Global and local
USE registries were searched; no existing global development flag applied.
It makes an installation choice and is not merely an optional-dependency flag.

The compress/diskcache integration modules remain installed. In 4.5.0,
the restored flags automatically select their runtime dependencies, retaining
the requested ::gentoo behavior despite the PG0001 concern. README.gentoo
documents application configuration and the other optional integrations.
Separate Cloud/AG Grid projects are documented, not bundled. The original
validation below predates the restored flags; see the new restoration report
for newly executed compression and background-callback tests.

The sdist includes its Jupyter extension, so the official ebuild's separate
maintainer-provided Jupyter archive is unnecessary. Its Jupyter configuration
relocation is retained. Upstream inadvertently includes a top-level benchmarks
package; it is excluded from setuptools package discovery.

## Commands and VERIFIED results

Manifests were generated with an isolated temporary pkgdev virtual environment:

```text
pkgdev manifest -d /tmp/codex/sci-visualization/dash-4.5.0/distfiles sci-visualization/dash
 * generating manifest: sci-visualization/dash::local
pkgdev manifest -d /tmp/codex/dev-python/janus-2.0.0/distfiles dev-python/janus
 * generating manifest: dev-python/janus::local
```

Both package Manifests are new repository files. SHA256 values above were
checked against PyPI metadata; pkgdev produced the Manifest BLAKE2B/SHA512
entries from the downloaded artifacts.

Non-merging builds used `PORTAGE_TMPDIR` and `DISTDIR` beneath each package's
`/tmp/codex/<category>/<package>-<version>` workspace and:

```text
ebuild sci-visualization/dash/dash-4.5.0.ebuild unpack prepare compile install
ebuild dev-python/janus/janus-2.0.0.ebuild unpack prepare compile install
```

On amd64 (`leonids-pc`) and arm64 (`gentoo`) the literal output included:

```text
>>> Completed installing sci-visualization/dash-4.5.0 into .../image
>>> Completed installing dev-python/janus-2.0.0 into .../image
 * Verifying compiled files for python3.12
 * Verifying compiled files for python3.13
 * Verifying compiled files for python3.14
```

Here `install` means staging into Portage's temporary image, not installation
or merging on the live system. An additional amd64 `USE=-development` build
completed; its entry_points.txt contained only `plotly` under console_scripts,
and the development archive was absent. All remote work was confined to the
two package-specific /tmp/codex workspaces; no remote overlay checkout changed.
Remote build/runtime logs were copied back locally.

The temporary smoke.py imported the staged package, checked Flask test-client
responses and all script assets referenced by the index, created the renderer
workspace, checked the websocket-worker source, tested explicit path selection,
and invoked help for all three development CLIs. It remapped the installed
archive path to the staged image for this non-merging check.

On amd64 with Python 3.12, 3.13, 3.14 and arm64 with Python 3.14 it printed:

```text
python3.14: Dash 4.5.0 staged imports, HTTP layout/dependencies, 10 JS assets, renderer workspace and 3 CLI help checks OK
```

The version prefix was respectively python3.12/python3.13 in those runs.
No TCP listener or live service was needed.

The actual amd64 renderer build used the staged Python package and:

```python
Renderer(path=".../runtime-cache/dash/4.5.0/dash-4.5.0/dash/dash-renderer").build()
```

It ran npm ci and webpack in that user workspace. Literal excerpts:

```text
added 917 packages, and audited 918 packages in 7s
webpack 5.111.1 compiled successfully in 7807 ms
webpack 5.111.1 compiled with 3 warnings in 8459 ms
webpack 5.111.1 compiled successfully in 3387 ms
webpack 5.111.1 compiled successfully in 3777 ms
webpack 5.111.1 compiled successfully in 280 ms
```

The three warnings concern webpack bundle/entrypoint size. Renderer generated
development and production bundles, websocket and stream workers, React shim,
React dependency assets, `_dash_renderer.py`, and digest.json in its workspace.
No npm command ran during any ebuild phase.

The upstream TypeScript generator fixture was built with `npm ci` and
`npm run build --prefix .../@plotly/dash-generator-test-component-typescript`,
with PATH pointing at the staged Python 3.14 CLI scripts and PYTHONPATH at
the staged Dash package. It exited 0 and printed `Generated StandardComponent.py`
and created its source distribution. Its setup step logged
`ERROR listing git files failed - pretending there aren't any` because the
workspace was extracted from a release archive, with no .git directory.
The fixture also reported missing component descriptions. These were not
suppressed. npm reported `7 vulnerabilities (6 low, 1 moderate)` for the
fixture's upstream locked development dependencies; no audit-fix was applied.

Janus upstream tests were run with Python 3.14 in a temporary virtual
environment containing pytest-asyncio, with plugin autoload disabled and
the asyncio plugin loaded explicitly; benchmark tests were excluded:

```text
PYTEST_DISABLE_PLUGIN_AUTOLOAD=1 PYTHONPATH=<janus-source> timeout -s INT -k 5s 45s <test-venv>/bin/python -m pytest -p pytest_asyncio.plugin -o addopts= -p no:cacheprovider --ignore=<source>/tests/test_benchmarks.py <source>/tests
======================== 99 passed, 1 skipped in 4.08s =========================
```

An earlier ebuild test phase could not find pytest-asyncio on the live system;
it was not installed there. An initial sandboxed thread test stalled and was
stopped; the time-limited run outside the sandbox produced the result above.
The one skip is upstream's Python-version condition, not a packaging exclusion.

`bash -n` was run for both ebuilds. `git diff --check` was also run.
The working tree's new files were reviewed directly because untracked files
are not included in ordinary git diff output.

## QA findings and NOT VERIFIED coverage

`XDG_CACHE_HOME=<workspace>/cache pkgcheck scan sci-visualization/dash dev-python/janus`
reported the following remaining findings; the scan is not described as clean:

```text
dev-python/janus
  PythonCompatUpdate: version 2.0.0: PYTHON_COMPAT update available: python3_15
sci-visualization/dash
  NonsolvableDepsInDev: ... keyword(~arm64) ... coloredlogs ... python-fire ...
  NonsolvableDepsInStable: ... keyword(~arm64) ... coloredlogs ... python-fire ...
```

These are findings for the newly added packages. coloredlogs in ::gentoo and
python-fire in ::guru lack arm64 keywords. The native arm64 host already had
both importable; this does not resolve their repository keyword status.
The requested `~amd64 ~arm64` keywords are retained. A default development
installation on arm64 needs deliberate administrator keyword acceptance for
those providers, or their separate keywording; runtime-only installations can
use `USE=-development`. No unrelated dependency ebuild or user configuration
was changed to hide the findings. Python 3.15 was not added or validated.

Both builds still report upstream setuptools metadata warnings:
`License classifiers are deprecated`; Dash also reports data directories
`dash.deps`, `dash.labextension`, and `dash.labextension.dist` absent from its
explicit packages configuration. Required assets were present and served in
the staged runtime tests. No QA-warning suppression was added.

NOT VERIFIED: browser integration suite, a live Jupyter session, running
Celery/Redis services, all optional server backends, Cloud/AG Grid add-ons,
and the full dash-update-components workflow. The latter's CLI help was
checked; renderer and a custom component generation build were exercised.
The renderer JavaScript build and Janus upstream tests ran on amd64 only.
Both packages' Python builds ran natively on both architectures.

Logs and helper scripts are under `/tmp/codex/sci-visualization/dash-4.5.0`
and `/tmp/codex/dev-python/janus-2.0.0` on leonids-pc. No live-system package
merge/installation/removal was performed. No commit, push, branch change,
or pull request was made.
