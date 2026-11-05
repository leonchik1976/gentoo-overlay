# Dash 4.5.0: restored compress and diskcache flags

All validation in this report was newly executed on 2026-11-05 for this
restoration. Earlier development-tool and Python-target logs are historical
and are not presented as reruns. New files/logs/helpers are under
`/tmp/codex/sci-visualization/dash-4.5.0/restore-use-flags` on leonids-pc;
native validation used the corresponding directory on gentoo, with logs
copied back to leonids-pc.

## Implementation and sources

The baseline was
`/var/db/repos/gentoo/sci-visualization/dash/dash-4.1.0.ebuild` and its
metadata.xml. Its `IUSE="compress diskcache"` gives both flags default-off
states. The local/global USE registries were checked: both descriptions are
local to Dash. The new metadata.xml descriptions explicitly describe
dependency installation.

The exact Dash 4.5.0 release artifact and source were inspected:

- [requirements/compress.txt](https://github.com/plotly/dash/blob/v4.5.0/requirements/compress.txt)
  requires flask-compress, with no version bound.
- [requirements/diskcache.txt](https://github.com/plotly/dash/blob/v4.5.0/requirements/diskcache.txt)
  requires diskcache >=5.2.1, multiprocess >=0.70.12, psutil >=5.8.0, and
  msgspec. Those exact constraints are reflected in the conditional group.
- [Flask backend](https://github.com/plotly/dash/blob/v4.5.0/dash/backends/_flask.py)
  imports flask_compress at runtime. Its version comparison with 1.6.0
  selects configuration behavior; it is not an unconditional minimum-version
  requirement, so no artificial lower bound was introduced.
- [DiskcacheManager](https://github.com/plotly/dash/blob/v4.5.0/dash/background_callback/managers/diskcache_manager.py)
  imports diskcache, psutil, and multiprocess, and starts a real worker process.
- [DiskcacheSharedStorage](https://github.com/plotly/dash/blob/v4.5.0/dash/_shared_storage/diskcache.py)
  calls require_msgspec; its codec stores serialized bytes. This is why the
  restored group includes msgspec in addition to the older ::gentoo group.

The user confirmed that the package is not installed and requested no revision
bump. The restoration is applied directly to `dash-4.5.0.ebuild`; the
experimental r1 file was withdrawn. Commands/logs below that name r1 record
the initial validation before that correction, not a retained package version.

### Final unrevisioned validation after the filename correction

Fresh non-merging builds of `dash-4.5.0.ebuild` were then run with both flags
enabled and disabled on both hosts, for Python 3.12–3.14. They used
`portage-final-enabled` and `portage-final-disabled` as temporary build roots.
The actual command was `ebuild sci-visualization/dash/dash-4.5.0.ebuild unpack prepare compile install`
(with the corresponding staged absolute path on gentoo). Each log contains
`>>> Completed installing sci-visualization/dash-4.5.0 into .../image`.

The four amd64 feature configurations and two native arm64 configurations
described below were rerun against those final images. They produced the
same gzip, distinct-worker callback, serialization, and disabled-provider
results. Final logs are `build-{amd64,arm64}-final-{enabled,disabled}.log`,
`runtime-amd64-final-{disabled,compress,diskcache,both}.log`, and
`runtime-arm64-final-{disabled,both}.log`; native logs were copied back.
The helper commands used the final image path ending in
`portage/sci-visualization/dash-4.5.0/image`, not the experimental r1 path.

A byte comparison printed:
`Final dash-4.5.0 ebuild body exactly matches the validated experimental body; no r1 ebuild remains.`
Portage metadata was evaluated again for the final CPV and printed:
`Final dash-4.5.0 evaluated metadata matches the four validated dependency selections and preserves all flag defaults.`
The expensive whole-source dependency plans were not repeated for this
filename-only correction; their optional dependency selections were compared
against the final evaluated metadata instead.

The new IUSE is `compress +development diskcache`. Python targets, the full
development dependency group, Node constraints, renderer patch declaration,
and build/install logic are unchanged. Only the new conditional dependencies
and post-install messages were added. Integration code is not pruned or
conditionally installed.

README.gentoo and post-install guidance now direct users to the flags for
automatic dependency selection, and explain that applications must still
configure Dash(compress=True), DiskcacheManager, or diskcache shared storage.
Disabling a flag omits its dependencies; it does not prevent use when the
providers are independently installed.

POLICY: these dependency-only flags intentionally retain the user's requested
::gentoo clean-install behavior despite the
[PG0001 concern](https://projects.gentoo.org/qa/policy-guide/dependencies.html#optional-runtime-dependencies).
This is a deliberate personal-overlay choice, not the policy-preferred design.
Statements endorsing their replacement by manual installation were removed
from README.gentoo and the earlier validation reports.

## Dependency selection and resolution

VERIFIED: Portage's evaluated metadata and use_reduce were used to check all
four modes, with development disabled only for this focused dependency check
and Python 3.14 selected. IUSE defaults were checked directly. Output:

```text
Portage metadata: compress/diskcache default off; development default on; conditional RDEPEND selection matches all four modes.
```

The selected atoms, including their Python USE dependencies, are recorded in
`selected-rdepend.json`:

| Flags | Direct providers selected by these two groups |
| --- | --- |
| neither | none |
| compress | flask-compress |
| diskcache | diskcache, multiprocess, psutil, msgspec |
| both | all five |

Four initial non-merging Portage plans named the experimental r1 and ran
against an empty temporary
ROOT and a temporary configuration using the default amd64/23.0 profile,
`ACCEPT_KEYWORDS="~amd64"`, `PYTHON_TARGETS="python3_14"`, and the checkout
as the local repository. No registered repository or user configuration was
edited. Exact invocation template, with mode-specific flags:

```sh
EMERGE_DEFAULT_OPTS='' USE='-development compress diskcache' emerge --ignore-default-opts --pretend --emptytree --onlydeps --with-bdeps=n --complete-graph=n --autounmask=n --backtrack=0 --root /tmp/codex/sci-visualization/dash-4.5.0/restore-use-flags/empty-root --config-root /tmp/codex/sci-visualization/dash-4.5.0/restore-use-flags/config =sci-visualization/dash-4.5.0-r1
```

For the other modes, compress/diskcache were explicitly negated as needed.
All four invocations exited 0, printing:

```text
disabled resolver exit: 0
compress resolver exit: 0
diskcache resolver exit: 0
both resolver exit: 0
```

The target-ROOT package lists selected exactly the providers in the table.
Their package counts were respectively 102, 104, 107, and 109. Results and
host-warning status are in `resolver-summary.json`; complete plans are
`resolve-disabled-final.log`, `resolve-compress-final.log`,
`resolve-diskcache-final.log`, and `resolve-both-final.log`.

LIMITATIONS: these source-build plans also evaluate host-side build tools.
They emitted unrelated installed-host slot-conflict diagnostics involving
ffmpeg, apache-arrow, flit-core, ocaml, and level-zero. They are not described
as clean full-system plans, despite the exit status. No unrelated package was
changed to resolve those diagnostics. Target selection was checked separately
from host-side lines, so a host psutil reinstall was not mistaken for an
enabled target diskcache dependency.

The first non-empty-ROOT attempt was sandbox-blocked when Portage tried to
update its live news cache. It is retained as `resolve-compress.log` and is
not a successful validation. An initial explicit-empty-ROOT compression plan
then correctly requested `app-arch/brotli[python]` through ::gentoo's
[Flask-Compress ebuild](/var/db/repos/gentoo/dev-python/flask-compress/flask-compress-1.26.ebuild).
Only the temporary validation package.use was given `app-arch/brotli python`
before the final plans. That transitive requirement may likewise require a
USE adjustment on a clean administrator configuration; no live/user USE
settings were changed.

## Initial non-merging builds and installed files

This section records the experimental r1 builds before the filename
correction. The subsequent final-version rebuilds are recorded above.

New builds on leonids-pc (amd64) and gentoo (native arm64) used:

```text
USE="compress diskcache"
USE="-compress -diskcache"
```

Development retained its default enabled state. Each used a distinct temporary
PORTAGE_TMPDIR (`portage-enabled` or `portage-disabled`) and the existing
package distdir, then ran:

```sh
ebuild sci-visualization/dash/dash-4.5.0-r1.ebuild unpack prepare compile install
```

The remote command used the staged temporary repository's absolute ebuild
path. All four builds completed staging; literal excerpts:

```text
>>> Completed installing sci-visualization/dash-4.5.0-r1 into .../image
 * Verifying compiled files for python3.12
 * Verifying compiled files for python3.13
 * Verifying compiled files for python3.14
```

The full paths appear in `build-amd64-enabled.log`, `build-amd64-disabled.log`,
`build-arm64-enabled.log`, and `build-arm64-disabled.log`. Here install means
staging a Portage image, not a live-system merge or installation.

The enabled/disabled amd64 images were compared, excluding bytecode:

```text
python3.12: 400 non-bytecode Dash files identical with flags enabled/disabled
python3.13: 400 non-bytecode Dash files identical with flags enabled/disabled
python3.14: 400 non-bytecode Dash files identical with flags enabled/disabled
```

A separate comparison of the old/new ebuild text printed:
`Development dependencies, Node constraints, Python targets and renderer patch declaration are unchanged.`

## Isolated functional checks

The first runs used experimental images. The same checks were subsequently
rerun against the final unrevisioned images, as recorded above.

The staged Dash package was tested using Python 3.14 in separate isolated
virtual environments, with no system site-packages. The environments were
asserted to contain exactly the enabled optional provider groups. All used
upstream's core requirements, with pydantic pinned to the current tree's
release for this test. The optional providers tested match these ::gentoo
ebuilds:

- [flask-compress-1.26](/var/db/repos/gentoo/dev-python/flask-compress/flask-compress-1.26.ebuild)
- [diskcache-5.6.3](/var/db/repos/gentoo/dev-python/diskcache/diskcache-5.6.3.ebuild)
- [multiprocess-0.70.19](/var/db/repos/gentoo/dev-python/multiprocess/multiprocess-0.70.19.ebuild)
- [psutil-7.2.2](/var/db/repos/gentoo/dev-python/psutil/psutil-7.2.2.ebuild)
- [msgspec-0.21.1](/var/db/repos/gentoo/dev-python/msgspec/msgspec-0.21.1.ebuild)

These dependency installations were confined to temporary venvs. Their exact
installed versions and transitive requirements appear in `deps-<mode>.log`.
They were not merges of those providers' ebuilds or tests of the minimum
allowed versions.

Exact invocation template:

```sh
TMPDIR=/tmp/codex/sci-visualization/dash-4.5.0/restore-use-flags/test-tmp /tmp/codex/sci-visualization/dash-4.5.0/restore-use-flags/venv-both/bin/python -u /tmp/codex/sci-visualization/dash-4.5.0/restore-use-flags/check-features.py both /tmp/codex/sci-visualization/dash-4.5.0/restore-use-flags/portage-enabled/portage/sci-visualization/dash-4.5.0-r1/image
```

The mode/venv were varied for the other cases; disabled used the disabled
build image. All four modes ran on amd64. Both-enabled and both-disabled
also ran natively on arm64 against that host's new images.

VERIFIED output on both architectures for the combined case:

```text
both: actual HTTP gzip 21073 -> 167 bytes, decompression matches
both: DiskcacheManager background callback HTTP submit/poll returned 42 in a distinct worker process
both: msgspec-backed DiskcacheSharedStorage round-trip OK
```

The gzip test sent Accept-Encoding: gzip to the WSGI test client, asserted
Content-Encoding: gzip, decompressed the response, and compared it with the
identity-encoded response. It did not merely check imports.

The callback test registered background=True, submitted an actual callback
request, and polled with the upstream signed job/cache handles and page endId.
The result included a worker PID different from the test process and the
expected computed value 42. Owned child processes were joined/cleaned up.
DiskcacheSharedStorage also encoded a value to bytes and decoded it back,
exercising the added msgspec dependency.

The disabled case printed on both hosts:

```text
disabled: uncompressed HTTP OK; missing compression provider gives expected ImportError
disabled: core app and installed diskcache code OK; absent providers give expected ImportError
```

The compression-only case exercised actual gzip and the expected absent
diskcache-provider error. The diskcache-only case exercised the background
callback/shared-storage round-trip and the expected absent compression-provider
error. All scripts asserted imports came from the staged Dash image and that
the integration source files existed even in disabled images.

Logs: `runtime-amd64-{disabled,compress,diskcache,both}.log` and
`runtime-arm64-{disabled,both}.log`. Native logs were copied back locally.

## QA, policy and remaining limits

`pkgdev manifest -d /tmp/codex/sci-visualization/dash-4.5.0/distfiles sci-visualization/dash`
reported `manifests are up to date`. No distfile or Manifest entry changed.
`bash -n sci-visualization/dash/dash-4.5.0.ebuild` and `git diff --check`
produced no output. metadata.xml parsed, and the changed package files/new
report had no trailing whitespace.

Final scan after withdrawing r1:

```sh
XDG_CACHE_HOME=/tmp/codex/sci-visualization/dash-4.5.0/restore-use-flags/qa-cache pkgcheck scan sci-visualization/dash
```

Literal findings, abbreviated only in their long dependency expressions:

```text
NonsolvableDepsInDev / NonsolvableDepsInStable: 4.5.0, ~arm64: coloredlogs, msgspec, python-fire
```

The full final output is in `pkgcheck-unrevisioned.log`. The earlier
`pkgcheck.log` and `pkgcheck-final.log` describe the withdrawn experimental
r1 configuration; no findings were suppressed.
Coloredlogs/python-fire arm64 metadata findings were already present before
this change. Msgspec's missing arm64 keyword is newly relevant to the restored
diskcache group. The isolated arm64 functional test does not substitute for
keywording/testing the provider ebuild. No keyword acceptance or provider
override was added. The experimental scan's RedundantVersion finding
disappeared when r1 was withdrawn; only dash-4.5.0.ebuild remains.

Upstream setuptools license/data-package warnings remain in both architectures'
build logs. They were not hidden. The PG0001 concern is an explicit requested
overlay departure. No unrelated package or
Python target coverage was changed to improve QA output.

NOT VERIFIED: real-browser behavior, the full browser integration suite,
minimum-version provider combinations, and full-system host dependency
resolution without the recorded unrelated slot diagnostics. Feature runtime
checks used Python 3.14; Python 3.12–3.14 package builds were performed on both
architectures. Historical renderer/component and 3.15/3.15t investigations
were not rerun or claimed as new results here.

Changed checkout files are dash-4.5.0.ebuild, metadata.xml, README.gentoo,
this report, and explanatory updates to the two earlier validation reports.
Pre-existing Janus/Python-target work was preserved. No registered overlay,
user configuration, or live-system package was modified. No commit, push,
or branch change was made.
