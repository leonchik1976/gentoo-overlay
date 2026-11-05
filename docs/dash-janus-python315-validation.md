# Janus and Dash: Python 3.15 / 3.15t investigation

Date: 2026-11-05. All results in this report were newly executed for this
investigation. Previous Python 3.12–3.14 validation is separate.

## Findings

| Package | Python 3.15 | Python 3.15t |
| --- | --- | --- |
| Janus 2.0.0 | Native builds, upstream tests, and threaded stress checks completed on amd64 and arm64 | Same checks completed; the GIL remained disabled |
| Dash 4.5.0 | Native builds and selected staged runtime/development CLI checks completed on both architectures using isolated upstream dependencies | Same selected checks completed; imports and checks did not re-enable the GIL |

INFERRED: the evidence supports enabling both targets for Janus. No Janus
source patch was required. Dash's selected runtime checks found no failure,
but its current Gentoo dependency graph does not provide these targets
throughout. These results do not establish complete Dash compatibility or
general thread safety under free-threaded execution.

The initial investigation left the checkout compatibility lists unchanged.
Following the user's request to enable the validated targets, Janus now
declares `PYTHON_COMPAT=( python3_{12..15} python3_15t )`. Its ebuild matches
the temporary Janus ebuild validated below. Dash remains unchanged because
its dependency targets are incomplete. No removed provider override was
recreated in the checkout.

After enabling Janus, a byte comparison confirmed that the checkout ebuild
is identical to the temporary ebuild built and tested on both hosts.
`bash -n dev-python/janus/janus-2.0.0.ebuild` and `git diff --check` produced
no output. The checkout's scoped
`XDG_CACHE_HOME=/tmp/codex/dev-python/janus-2.0.0/python315-investigation/qa-cache pkgcheck scan dev-python/janus`
exited 0 with no output. Builds were not repeated for this exact validated
ebuild copy.

## Sources and interpreter identity

The exact releases were inspected, not inferred from package classifiers:

- [Janus 2.0.0 PyPI JSON](https://pypi.org/pypi/janus/2.0.0/json),
  its source distribution's setup.cfg, and
  [tagged CI workflow](https://github.com/aio-libs/janus/blob/v2.0.0/.github/workflows/ci.yml).
  Requires-Python is `>=3.9`. Tagged CI lists Python 3.9–3.13 and does not
  demonstrate 3.15 or free-threaded coverage.
- [Dash 4.5.0 PyPI JSON](https://pypi.org/pypi/dash/4.5.0/json),
  [tagged setup.py](https://github.com/plotly/dash/blob/v4.5.0/setup.py),
  and [tagged testing workflow](https://github.com/plotly/dash/blob/v4.5.0/.github/workflows/testing.yml).
  Requires-Python is `>=3.9`. The inspected lint/unit matrix uses 3.9 and
  3.12 and does not demonstrate 3.15 or free-threaded coverage.
- `/var/db/repos/gentoo/eclass/python-utils-r1.eclass` lists
  `python3_{14..15}{t,}` among its supported implementations.
  distutils-r1 and pypi still require EAPI 8 for these ebuilds.
- [CPython free-threading documentation](https://docs.python.org/3.15/howto/free-threading-python.html)
  explains that incompatible extension imports can re-enable the GIL.
  Therefore testing with a t-suffixed executable alone was not sufficient.

VERIFIED on leonids-pc (amd64) and gentoo (native arm64): both executable
variants reported Python 3.15.2. The ordinary build returned
`Py_GIL_DISABLED: 0`, with `sys._is_gil_enabled()` True; the free-threaded
build returned `Py_GIL_DISABLED: 1`, with `sys._is_gil_enabled()` False.
The scripts checked the GIL state after imports and after testing too.
No `-X gil=0` override was used to bypass an extension's GIL declaration.

## Temporary ebuild builds

Workspaces on both hosts:

```text
/tmp/codex/dev-python/janus-2.0.0/python315-investigation
/tmp/codex/sci-visualization/dash-4.5.0/python315-investigation
```

Each temporary repo copied the current checkout package and changed only
its compatibility declaration to:

```bash
PYTHON_COMPAT=( python3_{12..15} python3_15t )
```

Exact amd64 build command for Janus (the Dash command substitutes its category,
package, and version throughout):

```sh
PYTHON_TARGETS="python3_15 python3_15t" PORTAGE_TMPDIR=/tmp/codex/dev-python/janus-2.0.0/python315-investigation/portage DISTDIR=/tmp/codex/dev-python/janus-2.0.0/distfiles ebuild /tmp/codex/dev-python/janus-2.0.0/python315-investigation/repo/dev-python/janus/janus-2.0.0.ebuild unpack prepare compile install
```

The same commands ran via SSH on gentoo. All build images remained under
the package-specific temporary workspace. Literal excerpts in each build log:

```text
>>> Completed installing dev-python/janus-2.0.0 into .../image
>>> Completed installing sci-visualization/dash-4.5.0 into .../image
 * Verifying compiled files for python3.15
 * Verifying compiled files for python3.15t
```

The ellipses above abbreviate package-specific temporary paths; the complete
paths are present in `build-amd64.log` and `build-arm64.log` under each workspace.
The ebuild install phase staged an image; no package was merged or installed
on a live system. Existing setuptools metadata warnings remained visible.

## Janus tests and free-threaded stress

Separate virtual environments for each interpreter supplied pytest and
pytest-asyncio. Tests imported Janus from the new Portage image and asserted
its __file__ was inside that image. Plugin autoload was disabled, the asyncio
plugin was explicitly loaded, pytest's extra coverage options were cleared,
and benchmarks were excluded as in the local ebuild.

Commands on both hosts, for each interpreter:

```sh
/tmp/codex/dev-python/janus-2.0.0/python315-investigation/venv-python3.15/bin/python -u /tmp/codex/dev-python/janus-2.0.0/python315-investigation/check.py
/tmp/codex/dev-python/janus-2.0.0/python315-investigation/venv-python3.15t/bin/python -u /tmp/codex/dev-python/janus-2.0.0/python315-investigation/check.py
```

The helper calls pytest on the exact release's tests with:
`-p pytest_asyncio.plugin -o addopts= --import-mode=importlib -p no:cacheprovider`
and an explicit ignore path for test_benchmarks.py. It then exercises Queue,
LifoQueue, and PriorityQueue with four producer threads, bounded queues,
async consumers, uniqueness/completeness assertions, task completion, and
queue closure: 60,000 items in each interpreter run.

VERIFIED literal upstream test summaries:

| Host / architecture | Interpreter | Output |
| --- | --- | --- |
| leonids-pc / amd64 | 3.15 | `99 passed, 1 skipped in 4.06s` |
| leonids-pc / amd64 | 3.15t | `99 passed, 1 skipped in 4.09s` |
| gentoo / arm64 | 3.15 | `99 passed, 1 skipped in 4.02s` |
| gentoo / arm64 | 3.15t | `99 passed, 1 skipped in 3.98s` |

Every run also printed:

```text
python3.15: staged upstream tests and 60000-item multithreaded queue stress OK; GIL after: True
python3.15t: staged upstream tests and 60000-item multithreaded queue stress OK; GIL after: False
```

The single skip is the existing upstream Python-version condition. An initial
test launcher prematurely imported pytest_asyncio and triggered an assertion-
rewrite warning under upstream's warnings-as-errors setting. The launcher was
corrected without suppressing warnings or changing Janus or its tests.

Logs are `tests-amd64-python3.15-final.log`,
`tests-amd64-python3.15t-final.log`, `tests-arm64-python3.15.log`, and
`tests-arm64-python3.15t.log`. Native logs were copied back to leonids-pc.

## Dash selected runtime checks

Dash's interpreter-specific virtual environments installed the exact release's
requirements/install.txt and requirements/dev.txt plus Black from PyPI.
This deliberately tests upstream runtime behavior separately from Gentoo's
currently incomplete target metadata. These are isolated dependency sets,
not a successful Portage dependency resolution, nor builds of all dependency
ebuilds. Provisioning logs record their exact installed versions.

Commands on both hosts:

```sh
/tmp/codex/sci-visualization/dash-4.5.0/python315-investigation/venv-python3.15/bin/python -u /tmp/codex/sci-visualization/dash-4.5.0/python315-investigation/check.py
/tmp/codex/sci-visualization/dash-4.5.0/python315-investigation/venv-python3.15t/bin/python -u /tmp/codex/sci-visualization/dash-4.5.0/python315-investigation/check.py
```

The helper forces Dash imports to the new staged image and checks:

- core import and explicit nest_asyncio.apply();
- WSGI test-client HTTP responses for index, layout, callback dependencies,
  and all ten JavaScript assets;
- a POST callback producing the expected output;
- imports and help execution for component_generator, update_components,
  and renderer, including staged archive-path remapping for the renderer
  workspace;
- GIL state before and after imports and checks.

VERIFIED on both hosts:

```text
python3.15: core HTTP layout/dependencies, 10 JS assets, callback and nest_asyncio.apply OK; GIL: True
python3.15t: core HTTP layout/dependencies, 10 JS assets, callback and nest_asyncio.apply OK; GIL: False
component_generator CLI help OK; GIL: False
update_components CLI help OK; GIL: False
build_process CLI help OK; GIL: False
RESULT: {'free_threaded_interpreter': True, 'core_import_gil': False, 'final_gil': False, 'development_failures': []}
```

Logs are `runtime-amd64-python3.15.log`, `runtime-amd64-python3.15t.log`,
`runtime-arm64-python3.15.log`, and `runtime-arm64-python3.15t.log`.
Native logs were copied back locally.

NOT VERIFIED: full Dash/browser suites, concurrent application-wide behavior,
the complete renderer/component build workflow under these two interpreters,
and optional server/storage integrations. The earlier Python 3.14 full
component workflow does not establish those results for 3.15 or 3.15t.

## Gentoo target availability

VERIFIED from the current provider ebuilds and their generated IUSE metadata:

- Neither target: [nest-asyncio](/var/db/repos/gentoo/dev-python/nest-asyncio/nest-asyncio-1.6.0-r1.ebuild),
  [Plotly](/var/db/repos/gentoo/dev-python/plotly/plotly-7.1.0.ebuild),
  [coloredlogs](/var/db/repos/gentoo/dev-python/coloredlogs/coloredlogs-15.0.1-r2.ebuild),
  [humanfriendly](/var/db/repos/gentoo/dev-python/humanfriendly/humanfriendly-10.0-r2.ebuild),
  and [python-fire](/var/db/repos/guru/dev-python/python-fire/python-fire-0.7.1-r3.ebuild).
- Ordinary 3.15 but no 3.15t: importlib-metadata, retrying, pydantic, comm,
  and Black. Exact inspected metadata paths are in
  `python315-investigation/provider-targets.log` in Dash's workspace.
- Flask, Werkzeug, requests, typing-extensions, setuptools, and PyYAML already
  expose both targets in the inspected provider metadata.

Thus keyword acceptance alone does not enable these missing Python targets.
The core Dash dependencies already prevent resolution; disabling development
does not eliminate the whole problem.

The temporary Janus expanded-target repository's command
`pkgcheck scan dev-python/janus` produced no output. For Dash, a corrected
temporary repo included the expanded-target Janus package too, avoiding a
false missing-package finding. `pkgcheck scan sci-visualization/dash`
reported `NonsolvableDepsInDev` and `NonsolvableDepsInStable`, listing the
missing-target providers above. Output is in `pkgcheck-with-janus.log`.
The scan's full combined target expressions are retained there; it was not
described as clean or suppressed.

INFERRED packaging conclusion: Janus is ready for a compatibility-list update
for these two targets based on this validation. Dash needs dependency-target
work in its provider repositories or explicitly requested local overrides
before a corresponding target update can provide a usable Portage solution.

## Compression and diskcache USE flags

VERIFIED: neither upstream feature was removed in Dash 4.5.0.
[setup.py](https://github.com/plotly/dash/blob/v4.5.0/setup.py) still declares
the compress and diskcache extras. Exact upstream requirements:

- [requirements/compress.txt](https://github.com/plotly/dash/blob/v4.5.0/requirements/compress.txt):
  flask-compress.
- [requirements/diskcache.txt](https://github.com/plotly/dash/blob/v4.5.0/requirements/diskcache.txt):
  diskcache >=5.2.1, multiprocess >=0.70.12, psutil >=5.8.0, and msgspec.

The Flask backend still imports flask_compress in enable_compression();
DiskcacheManager still imports diskcache, psutil, and multiprocess at runtime.
The existing ::gentoo ebuild's compress/diskcache flags only select runtime
dependencies; they do not switch files or code during the build/install.

Dash 4.5.0 now restores the dependency-only compress and diskcache flags,
both disabled by default, as explicitly requested. Enabling them pulls in
their required providers while the integration modules remain installed
regardless of flag state. This retains the requested ::gentoo behavior
despite the [PG0001 concern](https://projects.gentoo.org/qa/policy-guide/dependencies.html#optional-runtime-dependencies);
it is not presented as the policy-preferred design. Application configuration
is still required, such as Dash(compress=True) or a DiskcacheManager.
The [new restoration report](dash-4.5.0-use-validation.md) records its
separate validation; this Python-target investigation did not test or
implement the restored flags.

## Changes and boundaries

This report, its link in the existing Dash validation report, and Janus's
compatibility list changed in the checkout. No dependencies, USE flags,
source patches, or Manifests were changed. No live-system package merge/install/removal,
provider override recreation, user keyword edit, registered overlay edit,
commit, push, or branch change was performed.
