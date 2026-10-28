# arm64 desktop packages

Current Compass update (2026-10-28): `dev-db/mongodb-compass-1.53.2` replaces
1.53.1 and retains arm64-only keywords. See
[the release audit](../docs/upstream-bumps-20261028.md) for the new build evidence.
The older validation records below retain their original versions and paths.


These personal-overlay packages deliberately have only `KEYWORDS="~arm64"`.
The applications need glibc because they bundle upstream arm64 Electron.
The source packages compile their application code; Electron itself remains an
upstream binary. No maintainer-hosted npm dependency tarball is needed.

| Package | Packaging |
| --- | --- |
| `net-im/signal-desktop-bin-8.33.0_beta1` | Official arm64 beta Debian package; executable `signal-desktop-beta` |
| `dev-db/mongodb-compass-1.53.1` | Application and required native addons built from source; upstream Electron runtime |
| `sci-misc/jupyterlab-desktop-4.6.3_p1` | TypeScript application built from source; upstream Electron runtime; Gentoo Python environment |

The three package directories contain the ebuilds, maintainer metadata and
Manifests. The two generated dependency eclasses and their generators under
`scripts/` describe exact upstream registry archives. Compass's `${FILESDIR}`
helper redirects locked npm inputs to distfiles, selects SSH2 fallbacks, and
stages the runtime dependency closure.

## Upstream evidence

* Signal's [official arm64 announcement](https://community.signalusers.org/t/beta-test-signal-desktop-for-linux-arm64/76184)
  documents beta Debian packages and AppImages. The
  [arm64 package index](https://updates.signal.org/desktop/apt-arm64/dists/stable/main/binary-arm64/Packages.xz)
  contained `Version: 8.33.0~beta.1`, `Architecture: arm64`, and the filename
  used by the ebuild. It also contained a stable arm64 package; arm64 is no
  longer exclusively beta. The selected beta remains intentional.
  [Release source and license](https://github.com/signalapp/Signal-Desktop/tree/v8.33.0-beta.1).
* Compass's [release](https://github.com/mongodb-js/compass/releases/tag/v1.53.1)
  has Linux x64 binaries and macOS arm64 binaries, but no Linux arm64 application
  binary. Its [build instructions](https://github.com/mongodb-js/compass/blob/v1.53.1/CONTRIBUTING.md)
  and [source license](https://github.com/mongodb-js/compass/blob/v1.53.1/LICENSE)
  accompany the source. The application license is SSPL version 1.
  All npm versions and integrity values come from its
  [package-lock.json](https://github.com/mongodb-js/compass/blob/v1.53.1/package-lock.json),
  including Electron 45.0.0 and mongodb-client-encryption 7.2.1.
* The encryption addon's [release metadata](https://registry.npmjs.org/mongodb-client-encryption/7.2.1)
  pins libmongocrypt 1.20.1. Its
  [upstream source build script](https://github.com/mongodb-js/mongodb-client-encryption/blob/v7.2.1/.github/scripts/libmongocrypt.mjs)
  supplies the crypto-hook configuration used here. libmongocrypt's
  [C-driver pin](https://github.com/mongodb/libmongocrypt/blob/1.20.1/cmake/FetchMongoC.cmake)
  specifies mongo-c-driver 2.3.3; `MONGOCRYPT_MONGOC_DIR` avoids fetching it
  during configuration. The source archives ship Apache-2.0 and additional
  component notices, including Intel DFP's BSD license.
* JupyterLab Desktop's [release](https://github.com/jupyterlab/jupyterlab-desktop/releases/tag/v4.6.3-1)
  has Linux x64 installers, not Linux arm64 installers. Its
  [package.json](https://github.com/jupyterlab/jupyterlab-desktop/blob/v4.6.3-1/package.json)
  includes a Linux arm64 distribution target, and its
  [yarn.lock](https://github.com/jupyterlab/jupyterlab-desktop/blob/v4.6.3-1/yarn.lock)
  locks Electron to 42.5.0. The
  [source license](https://github.com/jupyterlab/jupyterlab-desktop/blob/v4.6.3-1/LICENSE)
  is BSD-3-Clause, represented by Gentoo's `BSD` identifier.
  [env.ts](https://github.com/jupyterlab/jupyterlab-desktop/blob/v4.6.3-1/src/main/env.ts)
  sets `MIN_JLAB_VERSION_REQUIRED = '3.0.0'`; the runtime dependency follows
  that requirement rather than the version of upstream's conda bundle.
  The locked [which 7.0.0 metadata](https://registry.npmjs.org/which/7.0.0)
  requires `^22.22.2 || ^24.15.0 || >=26.0.0`; the build dependency uses the
  24.15.0 lower bound. [Upstream issue 1073](https://github.com/jupyterlab/jupyterlab-desktop/issues/1073)
  tracks publishing Linux arm64 installers and was open during investigation.

The Electron archives' `LICENSE` and `LICENSES.chromium.html`, npm package
metadata and shipped notices were inspected for the additional license terms.
The installed applications retain Electron and npm notices. Compass also
installs notices from its statically linked C components.

## Packaging choices

EAPI 9 is the latest supported EAPI checked against
[PMS 9](https://projects.gentoo.org/pms/9/pms.html), the
[Devmanual](https://devmanual.gentoo.org/ebuild-writing/eapi/), and local Portage
(`8: True, 9: True, 10: False`). EAPI 8 is necessary here: local
`unpacker.eclass`, `xdg.eclass`, `xdg-utils.eclass` and `python-any-r1.eclass`
do not support EAPI 9. The eclasses are selected according to each package's
actual needs, and inherited dependency variables are preserved.

Signal's arm64 beta includes an x86-64 `fs-xattr` addon. Its sole caller in
[the exact beta source](https://github.com/signalapp/Signal-Desktop/blob/v8.33.0-beta.1/ts/windows/main/attachments.preload.ts)
is inside `process.platform === 'darwin'`. The ebuild removes this unused
foreign-architecture addon. No ABI or SONAME is rewritten.

Compass uses system sans-serif fallbacks instead of downloading proprietary
Euclid fonts during installation. It does not bundle enterprise `crypt_shared`;
[upstream's setup code](https://github.com/mongodb-js/compass/blob/v1.53.1/packages/compass/src/main/setup-csfle-library.ts)
handles absence and permits `COMPASS_CRYPT_LIBRARY_PATH`. This is distinct from
libmongocrypt, which is compiled and statically linked into the native addon.

Compass's optional SSH2 NAN acceleration addons failed to compile against the
selected Electron/V8 headers. SSH2's upstream JavaScript implementations remain
in use; CPU-based cipher ordering and native crypto acceleration are omitted.
The exact locked SSH2 package is 1.17.0, from Compass's lockfile. Its
[README](https://github.com/mscdex/ssh2/blob/v1.17.0/README.md),
[CPU-detection fallback](https://github.com/mscdex/ssh2/blob/v1.17.0/lib/protocol/constants.js),
and [crypto fallback](https://github.com/mscdex/ssh2/blob/v1.17.0/lib/protocol/crypto.js)
explain this behavior. No USE flag is added for these always-installed runtime
imports. Searches of indexed Gentoo bugs did not surface a relevant arm64 or
NAN compatibility bug; that does not prove that none exists.

JupyterLab uses the user's selected Python environment containing JupyterLab.
No conda environment is installed by the ebuild. Source-built application
updates are handled through Portage; Compass's upstream updater is disabled.

## Dependency regeneration

Unpack the exact release in its package workspace, then run:

```sh
python3 scripts/generate-mongodb-compass-npm-deps.py \
  /tmp/codex/dev-db/mongodb-compass-1.53.1/compass-1.53.1/package-lock.json \
  eclass/mongodb-compass-npm-deps-1.53.1.eclass
python3 scripts/generate-jupyterlab-desktop-yarn-deps.py \
  /tmp/codex/sci-misc/jupyterlab-desktop-4.6.3_p1/jupyterlab-desktop-4.6.3-1/yarn.lock \
  eclass/jupyterlab-desktop-yarn-deps-4.6.3_p1.eclass
```

There are 3225 distinct Compass registry archives and 665 distinct JupyterLab
Yarn archives in these releases. Short Compass distfile names keep Portage's
exported `A` below Linux's per-string limit and Portage's environment warning
threshold. Digest-prefix collisions are rejected by the generator.

Compass changes only registry download locations in a temporary copy of the
lockfile; original integrity fields and versions remain intact.
[npm ci](https://docs.npmjs.com/cli/v11/commands/npm-ci/) uses those local inputs
with `--offline --ignore-scripts`; native addons are built explicitly with
matching Electron headers. JupyterLab uses
[Yarn Classic's offline, frozen-lockfile installation](https://classic.yarnpkg.com/lang/en/docs/cli/install/).
No normal ebuild phase needs network access.

## Validation recorded on 2026-10-26

**VERIFIED — arm64, host `gentoo`.** Each final ebuild ran from a fresh
Portage work directory through `clean unpack prepare configure compile install`,
using a staged repository and distfiles under its own
`/tmp/codex/<category>/<package>-<version>` workspace. `PORTAGE_TMPDIR` was
inside that workspace and `FEATURES="-userpriv"` retained network sandboxing.
No overlay Git checkout was edited remotely. No live-system merge or package
installation was performed on any host.

For Compass the actual command, from its workspace, was:

```sh
PORTDIR_OVERLAY="$PWD/repo" DISTDIR="$PWD/distfiles" \
  PORTAGE_TMPDIR="$PWD/build" FEATURES="-userpriv" MAKEOPTS="-j4" \
  ebuild repo/dev-db/mongodb-compass/mongodb-compass-1.53.1.ebuild \
  clean unpack prepare configure compile install
```

The corresponding commands used
`repo/net-im/signal-desktop-bin/signal-desktop-bin-8.33.0_beta1.ebuild` and
`repo/sci-misc/jupyterlab-desktop/jupyterlab-desktop-4.6.3_p1.ebuild`, with the
same phase list and their own workspace paths. Signal used its workspace itself
as `DISTDIR`; JupyterLab used its workspace's `distfiles/` directory.

The final logs contain:

```text
>>> Source compiled.
>>> Completed installing dev-db/mongodb-compass-1.53.1 into /tmp/codex/dev-db/mongodb-compass-1.53.1/build/portage/dev-db/mongodb-compass-1.53.1/image
>>> Completed installing net-im/signal-desktop-bin-8.33.0_beta1 into /tmp/codex/net-im/signal-desktop-bin-8.33.0_beta1/build/portage/net-im/signal-desktop-bin-8.33.0_beta1/image
>>> Completed installing sci-misc/jupyterlab-desktop-4.6.3_p1 into /tmp/codex/sci-misc/jupyterlab-desktop-4.6.3_p1/build/portage/sci-misc/jupyterlab-desktop-4.6.3_p1/image
```

The compilation statement represents actual application compilation for Compass
and JupyterLab. Signal is a binary repackaging test; its default compile phase
performs no source compilation. No upstream test suite was run.

A separate isolated Xvfb startup check used fresh temporary XDG directories,
`--no-sandbox --disable-gpu --disable-dev-shm-usage`, and a 15-second observation
period. Compass additionally needed its documented
`--ignore-additional-command-line-flags` option to accept the harness's Chromium
flags. Output:

```text
mongodb-compass SURVIVED_STARTUP_15_SECONDS
jupyterlab-desktop SURVIVED_STARTUP_15_SECONDS
signal-desktop-bin SURVIVED_STARTUP_15_SECONDS
```

Compass's native modules were loaded with its staged executable and
`ELECTRON_RUN_AS_NODE=1`:

```text
ARCH arm64 ELECTRON 45.0.0
LOADED interruptor
LOADED kerberos
LOADED os-dns-native
LOADED @mongodb-js/native-machine-id
LOADED mongodb-client-encryption
```

Inspection of every installed ELF header on `gentoo`, with `readelf -d` used to
record needed libraries, produced:

```text
mongodb-compass ELF files: 11 non-aarch64: []
signal-desktop-bin ELF files: 9 non-aarch64: []
jupyterlab-desktop ELF files: 8 non-aarch64: []
```

**VERIFIED — metadata and static checks, host `leonids-pc`.** Commands included
`git status --short`, `rg`, upstream artifact inspection, `bash -n`, Python
syntax compilation without creating bytecode files, XML parsing, and whitespace
checks on all new files. Both dependency generators reproduced their checked-in
eclasses byte-for-byte. The downloaded Signal Debian package's SHA256 matched
the value in the upstream index:

```text
a43f6c86d3a460f91ea30dd96241610e05e295c38b82516eba661f1f1e405a4e
```

Manifests were generated and checked with:

```sh
pkgdev manifest -d /tmp/codex/net-im/signal-desktop-bin-8.33.0_beta1 net-im/signal-desktop-bin
pkgdev manifest -d /tmp/codex/dev-db/mongodb-compass-1.53.1/distfiles dev-db/mongodb-compass
pkgdev manifest -d /tmp/codex/sci-misc/jupyterlab-desktop-4.6.3_p1/distfiles sci-misc/jupyterlab-desktop
```

The final invocation for each returned `manifests are up to date` with exit
status 0. All three new Manifests are repository changes.

Package-scoped `pkgcheck scan` commands used `XDG_CACHE_HOME` inside the relevant
package workspace. Signal's final output was empty. Compass and JupyterLab
report `RequiredUseDefaults` and `RequiredUseUnsatisfiableInDev` for arm64 musl
profiles because their bundled Electron runtime requires glibc. These are
intentional profile exclusions, not claims of musl support.

With `pkgcheck scan --profiles default/linux/arm64/23.0 <category/package>`,
Compass and Signal returned exit status 0 with empty stdout and stderr.
JupyterLab returned exit status 0 and:

```text
sci-misc/jupyterlab-desktop
  OldPackageName: package uses old name which is source of pkgmove, rename into 'sci-misc/jupyterlab-desktop-bin'
```

The source package deliberately uses the base application name in this personal
overlay. Gentoo's historical move described its previous binary package; this
new application is compiled from source. The scan finding remains visible and
is not suppressed. All findings above are associated with the new packages;
no unrelated repository packages were changed.

**NOT VERIFIED.** No amd64 build was performed and no amd64 keyword is assigned.
Actual hardware-accelerated desktop rendering, Wayland, Signal account linking
and calls, MongoDB connections/SSH tunnels/encryption, and notebook execution
remain for the user to validate. Startup checks do not establish these workflows.
Compass's startup log includes Electron deprecation and packaged `NODE_OPTIONS`
warnings; JupyterLab's headless check reports a VA-API initialization warning.
These did not terminate the observed startup processes.

Final build, startup, native-load and ELF logs were copied back to the respective
`/tmp/codex/...` workspaces on `leonids-pc` as `arm64-final-build.log`,
`arm64-smoke.log`, `arm64-native-load.log` (Compass), and `arm64-elf-check.log`.
No Git commit, branch change, push, or pull request was performed.

## Review fixes: Mesa and the selected Python interpreter

This section supersedes the startup-only evidence above for Python server
launching. The changed files are the Compass and JupyterLab ebuilds,
`sci-misc/jupyterlab-desktop/files/jupyterlab-desktop-4.6.3_p1-selected-python.patch`,
and this report. Signal, the dependency eclasses, and dependency generators
were not changed. All three packages retain `KEYWORDS="~arm64"`.

**VERIFIED — Mesa dependency, `leonids-pc` and `gentoo`.** Both source ebuilds
now require `media-libs/mesa[opengl]`. The current
[`::gentoo` Mesa 26.2.5-r1 ebuild](https://github.com/gentoo/gentoo/blob/master/media-libs/mesa/mesa-26.2.5-r1.ebuild)
was inspected locally and through Gentoo's official GitHub mirror (file blob
`57f790458778e6d01aed912b5735c14abda2d6c0`). Its effective cached `IUSE` has
`+opengl` and no `gbm`; its configuration contains:

```text
$(meson_use opengl)
$(meson_feature opengl gbm)
```

The former `[gbm(+)]` constraint treated the missing flag as enabled under
[PMS USE-dependency default semantics](https://projects.gentoo.org/pms/9/pms.html),
so it did not require the real flag controlling GBM. Requiring `opengl` follows
Mesa's actual build configuration. On native arm64, the commands
`portageq has_version / 'media-libs/mesa[opengl]'` and `readelf -d` on both
new temporary-image application executables produced:

```text
installed Mesa[opengl] query exit: 0
 0x0000000000000001 (NEEDED)             Shared library: [libgbm.so.1]
 0x0000000000000001 (NEEDED)             Shared library: [libgbm.so.1]
```

**VERIFIED — exact-release launcher change.** The cached source was compared
byte-for-byte with `src/main/server.ts` inside the release distfile before
patching. The relevant release sources are
[`server.ts`](https://github.com/jupyterlab/jupyterlab-desktop/blob/v4.6.3-1/src/main/server.ts),
[`tokens.ts`](https://github.com/jupyterlab/jupyterlab-desktop/blob/v4.6.3-1/src/main/tokens.ts),
[`utils.ts`](https://github.com/jupyterlab/jupyterlab-desktop/blob/v4.6.3-1/src/main/utils.ts),
and [`env.ts`](https://github.com/jupyterlab/jupyterlab-desktop/blob/v4.6.3-1/src/main/env.ts).
`IPythonEnvironment.path` is the executable path. `getEnvironmentPath()` derives
the environment directory, which is `/usr` for `/usr/bin/python3.14`.
The old script sourced `/usr/bin/activate` and invoked bare `python`.

The release-specific patch is applied through `PATCHES` and `default` in
`src_prepare`. POSIX launch scripts now quote `environment.path` as one literal
shell argument, including embedded apostrophes, and use that executable for
`-m jupyterlab`. Activation scripts are sourced only if they exist. Existing
virtualenv activation, local conda activation, and base-conda shell setup plus
`conda activate` remain available. The conda environment and activation paths
are quoted too. The Windows branch is unchanged.

`patch --dry-run -p1 -i <patch>` against a freshly unpacked release returned:

```text
checking file src/main/server.ts
```

Its exit status was 0. `bash -n` returned 0 for both ebuilds. The patched
TypeScript was compiled by the release's normal `yarn build` during the native
build, and the final build log includes:

```text
 * Applying jupyterlab-desktop-4.6.3_p1-selected-python.patch ...
>>> Source compiled.
```

**VERIFIED — fresh non-merging builds on arm64 host `gentoo`.** Separate staged
repositories and build directories were created under these package workspaces:

```text
/tmp/codex/dev-db/mongodb-compass-1.53.1/review-fixes-zsobyh9m
/tmp/codex/sci-misc/jupyterlab-desktop-4.6.3_p1/review-fixes-phrirnpg
```

From each review directory, the commands actually run were:

```sh
PORTDIR_OVERLAY="$PWD/repo" \
  DISTDIR=/tmp/codex/dev-db/mongodb-compass-1.53.1/distfiles \
  PORTAGE_TMPDIR="$PWD/build" FEATURES="-userpriv" MAKEOPTS="-j4" \
  ebuild repo/dev-db/mongodb-compass/mongodb-compass-1.53.1.ebuild \
  clean unpack prepare configure compile install

PORTDIR_OVERLAY="$PWD/repo" \
  DISTDIR=/tmp/codex/sci-misc/jupyterlab-desktop-4.6.3_p1/distfiles \
  PORTAGE_TMPDIR="$PWD/build" FEATURES="-userpriv" MAKEOPTS="-j4" \
  ebuild repo/sci-misc/jupyterlab-desktop/jupyterlab-desktop-4.6.3_p1.ebuild \
  clean unpack prepare configure compile install
```

Both final commands exited 0, and the logs contain:

```text
>>> Completed installing dev-db/mongodb-compass-1.53.1 into /tmp/codex/dev-db/mongodb-compass-1.53.1/review-fixes-zsobyh9m/build/portage/dev-db/mongodb-compass-1.53.1/image
>>> Completed installing sci-misc/jupyterlab-desktop-4.6.3_p1 into /tmp/codex/sci-misc/jupyterlab-desktop-4.6.3_p1/review-fixes-phrirnpg/build/portage/sci-misc/jupyterlab-desktop-4.6.3_p1/image
```

The first Compass attempt failed during `npm ci` with `Disk quota exceeded`.
The earlier assistant-created Compass image was streamed back to
`review-fixes-zsobyh9m/previous-validation-image.tar.gz` on `leonids-pc`, and
Portage `clean` cleared only that previous temporary build. The failed-attempt
log was retained as `quota-failed-build.log`; the retry above exited 0.
No remote overlay checkout or live-system package was changed.

**VERIFIED — real JupyterLab server launch through the installed launcher.**
The first full GUI/CLI attempt did not create a Jupyter Server runtime record
within 55 seconds. That timeout was not counted as a successful server test.
The subsequent integration test loaded the installed, compiled `JupyterServer`
class under the matching upstream arm64 Electron 42.5.0 runtime. It called the
actual environment resolver and `JupyterServer.start()`; it did not replace the
launcher with a reimplementation. The commands were:

```sh
python3 /tmp/codex/sci-misc/jupyterlab-desktop-4.6.3_p1/review-fixes-phrirnpg/launcher-integration-test.py
node /tmp/codex/sci-misc/jupyterlab-desktop-4.6.3_p1/review-fixes-phrirnpg/launch-script-regressions.cjs
```

The Python integration script started Electron under isolated Xvfb with fresh
XDG, Jupyter, IPython and temporary directories. Its `sitecustomize.py` probe
recorded `sys.executable` and `sys.prefix` from the real `-m jupyterlab` process.
The probe PID was matched to Jupyter Server's runtime JSON and `/proc` command
line. Authenticated requests checked `/lab` for JupyterLab HTML and
`jupyter-config-data`, and `/api/status` for the server status JSON. The server
was shut down after each case.

For the no-activation system case, a temporary PATH entry named `python` was a
symlink to `/usr/bin/python3.13`. Native `readlink -f` returned exactly:

```text
/usr/bin/python3.13
```

`/usr/bin/activate` did not exist. The real server probe returned:

```json
{"pid": 119116, "executable": "/usr/bin/python3.14", "prefix": "/usr", "base_prefix": "/usr"}
```

A projection of the captured integration results printed:

```text
system-no-activate:
  selected=/usr/bin/python3.14
  activate_exists=False
  actual_server_executable=/usr/bin/python3.14
  actual_server_prefix=/usr
  lab_http=200
  api_status_http=200
  shell_substitution_marker_exists=False
```

The test also asserted that PATH inside that server process still resolved
`python` to 3.13. Thus the server used the selected interpreter independently
of PATH and without activation.

The real virtualenv case was created without installing packages:

```text
/usr/bin/python3.14 -m venv --without-pip --system-site-packages <temporary-venv-path>
```

It reused the existing system JupyterLab installation. Its directory was named:

```text
venv 'quoted' $literal `touch SHOULD_NOT_EXIST`
```

The selected executable was its `bin/python3.14`.
The result recorded `activate_exists=True`, the exact selected path as
`actual_server_executable`, that virtualenv directory as `actual_server_prefix`
and `VIRTUAL_ENV`, and `lab_http=200`, `api_status_http=200`,
`shell_substitution_marker_exists=False`. This tests real virtualenv activation
and quoting of spaces, apostrophes, dollar signs, and command-substitution
characters, not only server process startup. The host's existing Python 3.14
and 3.13 environments both had JupyterLab; no package installation was needed.

The separate Node script exercised the actual compiled launch-script generator
with controlled activation fixtures and executable paths. It ran `bash -n` and
executed each generated script, checking argv, activation markers, literal conda
arguments, absence of missing-source errors, and absence of command substitution:

```text
no-activate: PASS (bash syntax, selected executable, activation, literal shell paths)
venv: PASS (bash syntax, selected executable, activation, literal shell paths)
conda-local: PASS (bash syntax, selected executable, activation, literal shell paths)
conda-base: PASS (bash syntax, selected executable, activation, literal shell paths)
conda-missing: PASS (bash syntax, selected executable, activation, literal shell paths)
```

**VERIFIED — scoped scans and Manifests, `leonids-pc`.** The same two
`pkgdev manifest -d ... <category/package>` commands shown above were rerun;
both reported `manifests are up to date`. No distfile inputs changed, and this
repository uses thin Manifests. The new local patch therefore needs no new
`DIST` entry. Package-scoped `pkgcheck scan` was run for each changed package
with `XDG_CACHE_HOME` inside its review directory. The findings remained the
existing `RequiredUseDefaults` / `RequiredUseUnsatisfiableInDev` exclusions for
musl profiles and JupyterLab's existing `OldPackageName` finding. No QA finding
was suppressed, and neither unrelated packages nor Signal were changed.

**INFERRED.** The explicit `opengl` dependency prevents the prior resolver case
where Mesa without GBM satisfied a nonexistent flag's positive fallback. That
conclusion follows from the dependency semantics and current Mesa ebuild; no
Mesa installation with `-opengl` was created on the live system. Conda's real
activation behavior is expected to remain intact because the existing commands
were retained with existence guards and quoting; fixture tests cover those
script branches but are not an actual conda environment test.

**NOT VERIFIED.** No conda executable was available in PATH, and no conda
environment was found in the checked conventional prefixes, so no real conda
server launch was tested. The complete GUI/CLI workflow remains unverified
because of the timeout described above; the successful server tests establish
the installed launcher behavior, not the whole GUI flow. Notebook kernel
execution, accelerated rendering, Wayland and Windows were not tested here.
No amd64 build, live-system installation/merge, Git commit/push, branch change,
or pull request was performed. Native build and server-test logs/results were
copied to the matching review directories on `leonids-pc`; validation scripts
are also retained there.

The final glibc-profile scan commands were
`pkgcheck scan --profiles default/linux/arm64/23.0 dev-db/mongodb-compass`
and `pkgcheck scan --profiles default/linux/arm64/23.0 sci-misc/jupyterlab-desktop`.
Both returned exit status 0. Compass stdout was empty; JupyterLab stdout was:

```text
sci-misc/jupyterlab-desktop
  OldPackageName: package uses old name which is source of pkgmove, rename into 'sci-misc/jupyterlab-desktop-bin'
```


## Compass 1.53.1 Electron L10N selection (2026-10-26)

**Implementation.** Only the Compass source ebuild changed. `CHROMIUM_LANGS`
is defined before inheriting `chromium-2`; its 55 tags were derived from
`locales/*.pak` in the exact bundled
[Electron 45.0.0 Linux arm64 archive](https://github.com/electron/electron/releases/download/v45.0.0/electron-v45.0.0-linux-arm64.zip).
Its SHA512 is
`e18cdce5abd108a116a5a1fc35cd7d51d9ca31a548ea432de31d707b88d205d26ab6ccedf0c96a3ab97b79c9699f4ae8edf3107afb852d85dc8b935753bcad35`.
`src_install` calls `chromium_remove_language_paks` in the extracted Electron
`locales` directory, in a subshell so the existing installation directory does
not change. The source build, native addon compilation, runtime selection,
other packaging behavior, and `KEYWORDS="~arm64"` are preserved.
L10N selects Electron resource packs; it does not add Compass interface translations.

Sources inspected on `leonids-pc` were
`/var/db/repos/gentoo/eclass/chromium-2.eclass` (documentation and implementation),
`/var/db/repos/gentoo/eclass/linux-info.eclass`,
`/var/db/repos/gentoo/profiles/desc/l10n.desc`, and the current local-tree example
`/var/db/repos/gentoo/dev-db/mongodb-compass-bin/mongodb-compass-bin-1.50.0.ebuild`.
The [official chromium-2 reference](https://devmanual.gentoo.org/eclass-reference/chromium-2.eclass/index.html)
confirms the helper's current-directory contract and supported EAPIs 7 and 8;
this ebuild retains EAPI 8. The implementation generates L10N USE flags at
inheritance time, checks the declared list against available packs, and always
retains `en-US` as a fallback. The example's list was not used as the authority
for this release. All archive tags exist in the current Gentoo L10N registry.

**VERIFIED — static checks on `leonids-pc`.** Starting Git status was empty.
No applicable filesystem AGENTS.md was found; the supplied repository
instructions were followed. The workspace for this run, locally and on `gentoo`,
was `/tmp/codex/dev-db/mongodb-compass-1.53.1/l10n-0xprd572`.
Python `zipfile` enumerated archive members beginning `locales/` and ending
`.pak`, compared their stems with the ebuild's `CHROMIUM_LANGS`, and checked
uniqueness. Literal results:

```text
Archive/declaration equality: True (55 unique locale tags)
KEYWORDS="~arm64": True
Archive locale tags missing from ::gentoo L10N registry: []
```

Commands actually run from the overlay (cache paths were confined to this workspace):

```bash
bash -n dev-db/mongodb-compass/mongodb-compass-1.53.1.ebuild
pkgdev manifest -d /tmp/codex/dev-db/mongodb-compass-1.53.1/distfiles dev-db/mongodb-compass
XDG_CACHE_HOME=/tmp/codex/dev-db/mongodb-compass-1.53.1/l10n-0xprd572/cache pkgcheck scan dev-db/mongodb-compass
XDG_CACHE_HOME=/tmp/codex/dev-db/mongodb-compass-1.53.1/l10n-0xprd572/cache pkgcheck scan --profiles default/linux/arm64/23.0 dev-db/mongodb-compass
git diff --check
```

All returned exit status 0. `bash -n`, `git diff --check`, and the glibc-profile
scan emitted no output. Manifest generation printed `manifests are up to date`;
no Manifest content changed. The full package scan retained these existing
findings, with no new finding and no suppression:

```text
dev-db/mongodb-compass
  RequiredUseDefaults: version 1.53.1: profile: 'default/linux/arm64/23.0/musl' (3 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 1.53.1: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~arm64) dev profile (default/linux/arm64/23.0/musl) (3 total)
```

**VERIFIED — native arm64 build and image on `gentoo`.** `uname -m` returned
`aarch64`. A fresh validation subdirectory was created, and a tarball containing
the package, its dependency eclass, and minimal repository metadata was copied
there and extracted into `repo`. No remote overlay checkout was changed.
To free tmpfs space, only the previous assistant-created Compass review build
was cleaned using `ebuild ... clean`; its image and log had already been copied
back to `leonids-pc`. The new full build used this command from the fresh directory:

```bash
L10N="en-US he ru" \
PORTDIR_OVERLAY=/tmp/codex/dev-db/mongodb-compass-1.53.1/l10n-0xprd572/repo \
DISTDIR=/tmp/codex/dev-db/mongodb-compass-1.53.1/distfiles \
PORTAGE_TMPDIR=/tmp/codex/dev-db/mongodb-compass-1.53.1/l10n-0xprd572/build \
FEATURES="-userpriv" MAKEOPTS="-j4" \
ebuild repo/dev-db/mongodb-compass/mongodb-compass-1.53.1.ebuild clean unpack prepare configure compile install > build.log 2>&1
```

Exit status was 0. Relevant literal log lines (terminal color escapes omitted):

```text
   ✔  61/61 succeeded [0 read from cache]
>>> Source compiled.
>>> Completed installing dev-db/mongodb-compass-1.53.1 into /tmp/codex/dev-db/mongodb-compass-1.53.1/l10n-0xprd572/build/portage/dev-db/mongodb-compass-1.53.1/image
```

The build still emits Portage's large-environment warning (`A`, 77568 bytes),
the existing upstream patch mode warning
`warning: LIBRARY/float128/architecture.h has type 100755, expected 100644`,
and compiler warnings in Node headers and Kerberos (multiline comments,
function-pointer casts, and implicit `this` capture). No `QA Notice` or
`L10N warning` appeared. These were not suppressed; this locale-only change
does not modify their sources. The build's test phase was not enabled.

The staged inspection script was run as:

```bash
ssh gentoo 'python3 /tmp/codex/dev-db/mongodb-compass-1.53.1/l10n-0xprd572/inspect-image.py'
```

It returned exit status 0 and the following literal results:

```text
Archive locale count: 55
Declared locale count: 55
Missing from declaration: []
Extra declared locales: []
Effective L10N USE flags: l10n_en-US l10n_he l10n_ru
Installed locale packs: en-US.pak he.pak ru.pak
Unselected locale packs absent: 52
Unselected locale packs still present: []
Locale packs outside runtime locales directory: []
Selected packs byte-identical to archive: en-US.pak he.pak ru.pak
Bundled Electron version: 45.0.0
Expected native addons present and aarch64: 5
Compiled Compass main.js present: True
```

The script compared the original archive with the staged ebuild and complete
image, checked selected pack bytes, inspected ELF machine fields of the five
expected addons, and read the effective USE flags. `scp` copied `build.log`
(as `arm64-build.log`) and `image-inspection.log` back to the local workspace.
The image was also copied back with:

```bash
ssh gentoo 'tar -C /tmp/codex/dev-db/mongodb-compass-1.53.1/l10n-0xprd572/build/portage/dev-db/mongodb-compass-1.53.1/image -czf - .' > /tmp/codex/dev-db/mongodb-compass-1.53.1/l10n-0xprd572/arm64-validation-image.tar.gz
```

**INFERRED.** Other L10N selections follow the inspected eclass helper's
selection logic, including its mandatory `en-US` fallback; only the requested
three-language combination was built in this run.

**NOT VERIFIED.** Locale rendering in a running desktop, Compass interface
translations, and other locale combinations were not tested. Architecture
coverage is a real non-merging arm64 build through temporary-image installation
on `gentoo`; static packaging checks ran on amd64 `leonids-pc`, with no amd64
build. No live-system installation/merge, commit, push, branch change, or PR
was performed. Signal, JupyterLab Desktop, and unrelated files were untouched.


## Electron path.txt correction and fresh offline validation (2026-10-26)

**Historical validation correction.** The earlier reported successful Compass
validation did not establish reproducible offline behavior. Its reported success
conflicts with the subsequently observed failure in
`gentoo:/var/tmp/portage/dev-db/mongodb-compass-1.53.1/temp/build.log`.
No explanation for that earlier success has been established. The fresh run
below verifies the corrected ebuild offline; it resolves the current build
failure, but does not explain or retroactively validate the historical result.

**VERIFIED — cause and localized changes.** Starting Git status was empty;
applicable ancestor/package AGENTS.md paths were checked, and the supplied
repository instructions applied. The failed build directory was read using
`ssh gentoo 'sudo -n tail .../temp/build.log'` and read-only Python inspections.
It was not modified or cleaned. The retained failure log and remote log both
had SHA256 `cf4a95a3fb92b89a0e617165d7e279aad7f3c188a068f99b1e26c00bd9de882d`.
Literal failure evidence includes:

```text
Downloading Electron binary...
TypeError: fetch failed
Error: Electron failed to install correctly.
Failed loader matches locked npm artifact: True
Failed path.txt bytes: b'electron\n'
```

Compass's original release `package-lock.json` locks Electron 45.0.0;
JupyterLab's original release `yarn.lock` resolves `electron@^42.4.0` to
42.5.0. Both exact npm tarballs' SHA512 values were checked against the original
release locks, not just their package version strings. Sources:
[Electron 45 npm archive](https://registry.npmjs.org/electron/-/electron-45.0.0.tgz),
[Electron 42.5 npm archive](https://registry.npmjs.org/electron/-/electron-42.5.0.tgz),
[Compass release source](https://github.com/mongodb-js/compass/archive/refs/tags/v1.53.1.tar.gz),
and [JupyterLab Desktop release source](https://github.com/jupyterlab/jupyterlab-desktop/archive/refs/tags/v4.6.3-1.tar.gz).
The failed loader matched the locked Compass npm archive byte for byte.
Both loaders read `path.txt` without trimming, then test the resulting path.
Their installers write the filename without a newline. The equivalent
[45 loader](https://github.com/electron/electron/blob/v45.0.0/npm/index.js) and
[42.5 loader](https://github.com/electron/electron/blob/v42.5.0/npm/index.js)
were also consulted.

Both ebuilds now use exactly:

```bash
printf '%s' electron > node_modules/electron/path.txt || die
```

An overlay-wide `rg -n 'path.txt' --glob '*.ebuild' --glob '*.py' --glob '*.sh' .`
found only these two newline-producing writes. Nimbalyst's Python helper already
writes `"electron"` without a newline and was left untouched. Both changed
packages retain `KEYWORDS="~arm64"`; Compass's L10N declaration and pruning,
native addons, and runtime selection are unchanged.

**VERIFIED — download-path investigation.** The exact bootstrap lifecycle
scripts, webpack configuration, Electron `index.js`/`install.js`, and
`@electron/get` implementation were inspected. The loader can invoke
`install.js` on a missing executable; that installer has an independent download
path and does not honor the existing `ELECTRON_SKIP_BINARY_DOWNLOAD` setting.
`npm --offline` does not govern arbitrary JavaScript download code. No supported
offline environment switch was found in this exact downloader implementation.
The corrected filename makes the already-staged executable satisfy the loader;
no downloader override, network exception, or extra ebuild configuration was
needed for this exact bootstrap/build. Existing npm offline settings,
ignored dependency lifecycle scripts, and existing font/installer exclusions
were preserved. No other bootstrap download was observed in this fresh run.
Searches of bugs.gentoo.org for Compass/Electron path.txt and Yarn global-folder
failures returned no matching Gentoo bug; this is not a claim that the issue is new.

**VERIFIED — native arm64 validation on `gentoo`.** Fresh workspace roots,
also used to retain evidence on `leonids-pc`:

```text
Compass: /tmp/codex/dev-db/mongodb-compass-1.53.1/path-fix-ehf083l5
JupyterLab first attempt: /tmp/codex/sci-misc/jupyterlab-desktop-4.6.3_p1/path-fix-8f_s465i
JupyterLab successful retry: /tmp/codex/sci-misc/jupyterlab-desktop-4.6.3_p1/path-fix-8f_s465i-retry
```

Minimal repositories containing the exact changed packages and dependency
eclasses were staged under each workspace's `repo`; no remote overlay checkout
was edited. The only existing cache of build inputs consulted was
`/var/cache/distfiles`: 3230 Compass distfiles and two JupyterLab distfiles were
copied into isolated `distfiles` directories. Portage's explicit `fetch` phase
obtained the remaining 666 JupyterLab inputs there. The retry copied only those
668 declared distfiles from the first attempt, not its work or package caches.
The lists are retained as `staged-existing-distfiles.txt` and
`missing-distfiles.txt`. The retry script's copied-input status message still
labels its source `/var/cache/distfiles`; the actual source in its retained
script is the first attempt's staged `distfiles` directory.

The exact executed setup/build commands are retained in each
`run-validation.sh`. From each fresh workspace they exported:

```bash
export PORTDIR_OVERLAY="$PWD/repo" DISTDIR="$PWD/distfiles" PORTAGE_TMPDIR="$PWD/build"
export PORTAGE_LOGDIR="$PWD/logs" XDG_CACHE_HOME="$PWD/caches/xdg" electron_config_cache="$PWD/caches/electron"
export CCACHE_DIR="$PWD/caches/ccache" npm_config_userconfig="$PWD/caches/npm-userconfig" npm_config_globalconfig="$PWD/caches/npm-globalconfig"
export FEATURES="-userpriv -ccache network-sandbox sandbox" MAKEOPTS="-j4" L10N="en-US he ru"
unset ELECTRON_OVERRIDE_DIST_PATH ELECTRON_CUSTOM_VERSION ELECTRON_MIRROR ELECTRON_CUSTOM_DIR ELECTRON_CUSTOM_FILENAME NODE_OPTIONS NODE_PATH npm_config_cache
```

New empty npm configuration files and cache directories were created before the
commands. `ebuild <staged-ebuild> fetch > fetch.log 2>&1` was followed by:

```bash
ebuild repo/dev-db/mongodb-compass/mongodb-compass-1.53.1.ebuild clean unpack prepare configure compile install > build.log 2>&1
# Corresponding JupyterLab command in its separate workspace:
ebuild repo/sci-misc/jupyterlab-desktop/jupyterlab-desktop-4.6.3_p1.ebuild clean unpack prepare configure compile install > build.log 2>&1
```

Fetch and completed-build exit statuses were each 0, retained in `fetch.exit`
and `build.exit`. Compass's npm cache was freshly populated from staged
file-URL inputs under its new Portage `${T}/npm-cache`; Yarn used its new
`${T}/yarn-cache` and mirror of staged distfiles. Electron's explicitly selected
cache remained empty. Nx reported `0 read from cache`; ccache was disabled.
No previously populated npm, Yarn, Electron, or Nx cache was relied upon.
Portage filters inherited `XDG_CACHE_HOME`; the effective npm/Electron cache
settings and the ebuild's `${T}` Yarn settings, rather than that inherited
variable, establish the relevant cache isolation here.

The active Compass bootstrap process was inspected through `/proc`:

```text
bootstrap network namespace: net:[4026532700]
host network namespace: net:[4026531833]
```

Its effective FEATURES contained `network-sandbox` and `sandbox`, and its
`npm_config_offline` was `true`. Networking was not enabled for build phases.
The [Portage FEATURES documentation](https://dev.gentoo.org/~zmedico/portage/doc/man/make.conf.5.html)
was the reference for the network-sandbox setting.

JupyterLab's first attempt returned exit 1 due to Yarn's attempted
`mkdir /usr/local/share/.yarn`, denied by the filesystem sandbox. This was not
suppressed. After inspecting the bundled Yarn 1.22.22 implementation's `PREFIX`
handling, its fresh retry additionally exported:

```bash
export PREFIX="$PWD/caches/yarn-prefix" YARN_GLOBAL_FOLDER="$PWD/caches/yarn-global"
```

That retry completed through temporary-image installation with exit 0 and no
access-denied entry. No additional repository code was changed for this
validation-environment adjustment. Both attempts' logs are retained.

`inspect-loader.cjs` was run against each actual prepared source tree, replacing
`child_process.spawnSync` with a throwing guard before requiring Electron. It
returned exit 0 for both packages, with these literal results:

```text
path.txt bytes: "electron"
path.txt hex: 656c656374726f6e
Loader resolves existing staged executable: true
Electron installer invocations: 0
```

For JupyterLab, production dependency pruning removes the development Electron
npm module; its loader test therefore used a separate fresh `loader-build`
prepare run (exit 0), not a fabricated installed module. The exact command and
its log are retained in `loader-prepare-command.txt`, `loader-prepare.log`, and
`loader-prepare.exit`; it used the
same staged repo/distfiles, sandbox features, and temporary Yarn prefix.

`python3 inspect-native.py` inspected each completed temporary image and the
original locked artifacts. Both returned exit 0. Compass's literal results:

```text
Locked Electron npm version: 45.0.0
Locked Electron npm archive: mc-9a3d1dc73f7f6166.tgz
Npm archive SHA512 matches original release lock: True
Loader reads path.txt without trimming: True
Installer honors ELECTRON_SKIP_BINARY_DOWNLOAD: False
Build exit: 0
Electron download messages: 0
Electron cache file count: 0
Installed Electron version: 45.0.0
Compiled application build present: True
Declared locales match archive: True (55)
Installed locale packs: en-US.pak he.pak ru.pak
Unselected packs absent: 52
Selected packs byte-identical to original archive: True
Bootstrap: 61/61 succeeded [0 read from cache]
```

JupyterLab reported the corresponding locked version `42.5.0`, original-lock
SHA512 match, `Build exit: 0`, `Electron download messages: 0`,
`Electron cache file count: 0`, `Installed Electron version: 42.5.0`, and
`Compiled application build present: True`.

**VERIFIED — local packaging checks on `leonids-pc`.** The following commands
were run for each changed package; exact argv, literal stdout/stderr, and exit
statuses are retained in `local-validation.json` and `final-check-*.log` in
its initial local workspace:

```bash
bash -n dev-db/mongodb-compass/mongodb-compass-1.53.1.ebuild
bash -n sci-misc/jupyterlab-desktop/jupyterlab-desktop-4.6.3_p1.ebuild
pkgcheck scan dev-db/mongodb-compass
pkgcheck scan sci-misc/jupyterlab-desktop
pkgcheck scan --profiles default/linux/arm64/23.0 dev-db/mongodb-compass
pkgcheck scan --profiles default/linux/arm64/23.0 sci-misc/jupyterlab-desktop
pkgdev manifest -d /tmp/codex/dev-db/mongodb-compass-1.53.1/path-fix-ehf083l5/distfiles dev-db/mongodb-compass
pkgdev manifest -d /tmp/codex/sci-misc/jupyterlab-desktop-4.6.3_p1/path-fix-8f_s465i/distfiles sci-misc/jupyterlab-desktop
git diff --check
```

Each returned exit 0. Syntax and whitespace checks emitted no output. Both
Manifest commands printed `manifests are up to date`; no Manifest content
changed. Package-scoped scans retained the following existing findings:

```text
dev-db/mongodb-compass
  RequiredUseDefaults: version 1.53.1: profile: 'default/linux/arm64/23.0/musl' (3 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 1.53.1: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~arm64) dev profile (default/linux/arm64/23.0/musl) (3 total)
sci-misc/jupyterlab-desktop
  OldPackageName: package uses old name which is source of pkgmove, rename into 'sci-misc/jupyterlab-desktop-bin'
  RequiredUseDefaults: version 4.6.3_p1: profile: 'default/linux/arm64/23.0/musl' (3 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 4.6.3_p1: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~arm64) dev profile (default/linux/arm64/23.0/musl) (3 total)
```

The glibc-profile Compass scan emitted no output; JupyterLab retained only
`OldPackageName`. No QA finding was suppressed. Build logs retain the large
Portage environment warning, upstream libmongocrypt patch mode warning, and
Node/Kerberos compiler warnings for Compass; JupyterLab retains Yarn's existing
peer-dependency/workspace/engine warnings and Node's `url.parse()` deprecation
warning. No `QA Notice` or L10N warning occurred in the completed Compass run.

Native-tested repository copies, logs, scripts, exit statuses, and inspection
results were copied back as `native-evidence.tar.gz` and extracted into local
`native-results` directories. Both final images are retained locally as
`arm64-image.tar.gz`. Native-tested ebuilds were compared byte for byte with
the final overlay files; both comparisons returned True. All package files and
dependency eclasses also matched (five files per package), recorded in
`final-file-comparison.json`. Inspection of the entire retained Compass image
confirmed that the other 52 locale names occur nowhere in it, recorded in
`complete-image-locale-inspection.log`. The ebuild SHA256 values:

```text
Compass: 2ba86e66ea361ff392000f4e1a94d1542cd2317a9cf85c581a8dbfe455b05bb0
JupyterLab: 2b6679a3837fd6c6265b7f246861a8e0b648075c4068ae3fe1d90dc7540ac652
```

**INFERRED.** Removing the newline eliminates the verified invalid executable
lookup and its resulting Electron download branch. The fresh successful
sandboxed build establishes that no additional bootstrap offline configuration
is necessary for these exact staged inputs; it is not a guarantee for future
upstream releases or different build paths.

**NOT VERIFIED / limitations.** This run does not explain the earlier
conflicting success report. Desktop interaction, notebook execution, database
connections, and rendering were not tested. Build tests ran natively on arm64
`gentoo`, with `-userpriv` but filesystem and network sandboxing enabled;
ordinary userpriv builds were not repeated. Static packaging checks ran on
amd64 `leonids-pc`; no amd64 build was performed. No live-system installation,
merge, Git commit/push, branch change, or PR occurred. The failed `/var/tmp`
build and remote overlay checkout were untouched.

Staging deviation: the first Compass transfer briefly placed
`/tmp/validation.tar.gz` and `/tmp/run-validation.sh` directly under `/tmp`,
then moved them into the scoped workspace. All extraction, caches, builds, and
subsequent transfers used the required `/tmp/codex/<category>/<package>-<version>`
subdirectories. No validation files remain at those two initial transport paths.


## JupyterLab Desktop: self-contained Yarn paths (2026-10-26)

**VERIFIED — implementation and retained failure.** The initial working tree
already contained the Compass and JupyterLab Electron path.txt fixes and the
previous report additions; all were preserved. Applicable ancestor, repository,
package, and scripts AGENTS.md paths were checked; the supplied repository
instructions applied. This follow-up changes only two lines in the JupyterLab
ebuild's existing generated project `.yarnrc`, plus this report section:

```text
prefix "${T}/yarn-prefix"
global-folder "${T}/yarn-global"
```

The retained first-attempt log at
`/tmp/codex/sci-misc/jupyterlab-desktop-4.6.3_p1/path-fix-8f_s465i/native-results/build.log`
was inspected without altering it. Its literal sandbox evidence includes:

```text
F: mkdir
S: deny
P: /usr/local/share/.yarn
```

Both the outer `yarn --offline build` and nested `yarn bundle:preload` appeared
in that failure. The earlier successful retry exported `PREFIX` and
`YARN_GLOBAL_FOLDER` externally in `run-validation.sh`; it therefore did not
establish a self-contained ebuild fix. The new validation below uses the ebuild's
project configuration and removes those harness overrides.

The exact bundled `yarn-v1.22.22/lib/cli.js` was inspected, including
`getGlobalPrefix` and `this.globalFolder` initialization. Prefix selection checks
`config.getOption('prefix', true)` before the environment/fallback lookup;
global-folder initialization reads `config.getOption('global-folder', true)`.
The matching [Yarn 1.22.22 source](https://github.com/yarnpkg/yarn/blob/v1.22.22/src/cli/commands/global.js)
and [Yarn Classic .yarnrc documentation](https://classic.yarnpkg.com/lang/en/docs/yarnrc/)
were also consulted. Yarn reads project configuration up the directory tree,
so this existing `.yarnrc` covers prepare-time installation, compilation,
nested Yarn scripts, and production dependency pruning. No helper or exported
prefix variables are necessary. The implementation excerpts are retained as
`yarn-implementation.txt` and the generated configuration as `effective.yarnrc`.

The existing offline/frozen-lockfile/ignore-scripts options, `${T}/yarn-cache`,
production pruning, Electron newline correction, selected-Python patch, and
`KEYWORDS="~arm64"` are unchanged. No sandbox exception or suppression was added.

**VERIFIED — fresh arm64 build with normal userpriv on `gentoo`.** A new workspace
was created at
`/tmp/codex/sci-misc/jupyterlab-desktop-4.6.3_p1/yarn-paths-9_hzidep`.
The package and dependency eclass were staged in its minimal `repo`; the remote
overlay checkout and old failed builds were untouched. Its 668 declared
Portage distfiles were copied from the earlier retry's staged `distfiles`
directory, recorded in `staged-inputs.txt`; no earlier work, npm/Yarn/Electron
cache, or installed node_modules was reused. `ebuild ... fetch` checked the
staged distfiles and exited 0. Yarn populated a new `${T}/yarn-cache` from the
new mirror of explicitly staged distfiles. The Electron cache started and ended
empty. No npm installation command or existing npm cache was used.

The complete executed validation harness is retained locally as `validate.py`;
`commands.json` retains argv, working directories, and exit statuses, and
`harness-settings.json` retains its explicit settings and removed variables.
It removes inherited `PREFIX`, `YARN_*`, and relevant npm path overrides. It
exports no Yarn prefix/global/cache override. Its explicit settings were:

```text
PORTDIR_OVERLAY=<workspace>/repo
DISTDIR=<workspace>/distfiles
PORTAGE_TMPDIR=<workspace>/build
PORTAGE_LOGDIR=<workspace>/logs
FEATURES=userpriv usersandbox network-sandbox sandbox -ccache
MAKEOPTS=-j4
electron_config_cache=<workspace>/caches/electron
```

From the workspace, the actual non-merging Portage commands were:

```bash
ebuild repo/sci-misc/jupyterlab-desktop/jupyterlab-desktop-4.6.3_p1.ebuild fetch
ebuild repo/sci-misc/jupyterlab-desktop/jupyterlab-desktop-4.6.3_p1.ebuild clean unpack prepare
ebuild repo/sci-misc/jupyterlab-desktop/jupyterlab-desktop-4.6.3_p1.ebuild configure compile install
```

Each returned exit 0; separate `fetch.log`, `prepare.log`, and `build.log` and
corresponding `.exit` files are retained. Between prepare and compile, the
harness ran these read-only/configuration probes as the `portage` user from
the prepared source directory:

```text
runuser -u portage -- node <bundled-yarn>/bin/yarn.js --offline config get prefix
runuser -u portage -- node <bundled-yarn>/bin/yarn.js --offline config get global-folder
runuser -u portage -- node <bundled-yarn>/bin/yarn.js --offline config get cache-folder
runuser -u portage -- node <bundled-yarn>/bin/yarn.js --offline global bin
runuser -u portage -- node <workspace>/inspect-loader.cjs <prepared-source>
```

The path probes returned the actual absolute `${T}` directory under this new
workspace, ending respectively in `yarn-prefix`, `yarn-global`, `yarn-cache`,
and `yarn-prefix/bin`. All probe exit statuses were 0. The Electron probe
intercepts installer process spawning and reported:

```text
path.txt bytes: "electron"
path.txt hex: 656c656374726f6e
Loader resolves existing staged executable: true
Electron installer invocations: 0
```

A `/proc` monitor captured both the outer build and nested preload Yarn
processes running with all four UID fields equal to 250, the host's `portage`
UID. Both used `net:[4026532700]`, while the host namespace was
`net:[4026531833]`. This evidence is retained in `process-evidence.json`.
No root-only workaround was required for this build. The final native
`python3 inspect-result.py` check returned exit 0 with these literal results:

```text
Effective Yarn prefix: ${T}/yarn-prefix
Effective Yarn global-folder: ${T}/yarn-global
Effective Yarn cache-folder: ${T}/yarn-cache
Effective Yarn global bin: ${T}/yarn-prefix/bin
fetch exit: 0
prepare exit: 0
yarn-prefix exit: 0
yarn-global-folder exit: 0
yarn-cache-folder exit: 0
yarn-global-bin exit: 0
loader-inspection exit: 0
build exit: 0
/usr/local/share/.yarn log mentions: 0
Sandbox violation log: absent or empty
Electron cache entries: 0
Electron download messages: 0
--offline build: uid=250 (portage), separate network namespace
bundle:preload: uid=250 (portage), separate network namespace
Image: compiled server.js and aarch64 Electron 42.5.0 present
```

No `/usr/local/share/.yarn` write attempt was recorded: neither build log
contained that path or an access-denied entry, and the enabled filesystem
sandbox produced no nonempty violation log. Together with the effective prefix
and global paths, this verifies that the fallback responsible for the earlier
failure was avoided. This check is not a separate syscall trace of every path.

**VERIFIED — packaging checks on `leonids-pc`.** Exact argv/output/status records
are retained in `local-validation.json` and `check-*.log` in the local workspace.
Commands actually run:

```bash
bash -n sci-misc/jupyterlab-desktop/jupyterlab-desktop-4.6.3_p1.ebuild
pkgcheck scan sci-misc/jupyterlab-desktop
pkgdev manifest -d /tmp/codex/sci-misc/jupyterlab-desktop-4.6.3_p1/yarn-paths-9_hzidep/distfiles sci-misc/jupyterlab-desktop
git diff --check
```

All returned exit 0. Syntax and whitespace checks emitted no output. Manifest
generation printed `manifests are up to date`; no Manifest content changed.
The scoped pkgcheck output retained the same existing findings, with no new
finding and no suppression:

```text
sci-misc/jupyterlab-desktop
  OldPackageName: package uses old name which is source of pkgmove, rename into 'sci-misc/jupyterlab-desktop-bin'
  RequiredUseDefaults: version 4.6.3_p1: profile: 'default/linux/arm64/23.0/musl' (3 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 4.6.3_p1: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~arm64) dev profile (default/linux/arm64/23.0/musl) (3 total)
```

Build logs retain Yarn's peer-dependency/workspace/engine warnings and Node's
`url.parse()` deprecation warning; these were not suppressed.

The tested repository, logs, harness, command/status records, and process
observations were copied back to `leonids-pc` as `native-evidence.tar.gz` and
extracted into `native-results` in the matching local workspace. The final
inspection logs/scripts and generated configuration were also retained there;
`arm64-image.tar.gz` retains the temporary image. The native-tested ebuild was
compared byte for byte with the final repository file:

```text
Final ebuild matches native-tested copy: True
Only two Yarn configuration lines added to starting ebuild: True
Ebuild SHA256: b517436a1a9b871f9975688f3cc92df354deae9f6a62acc888630f2b54644e56
```

**INFERRED.** Project-local prefix/global-folder configuration will apply to
other Yarn commands run from this source tree or its children by the inspected
Yarn release. This is based on Yarn's configuration lookup; the installation,
build, nested preload, and pruning paths used here were actually exercised.

**NOT VERIFIED.** Desktop interaction, notebook execution, and server behavior
were not retested for this path-only packaging change. Native arm64 validation
ran on `gentoo`, including an ordinary userpriv build; static packaging checks
ran on amd64 `leonids-pc`, with no amd64 build. No live-system installation or
merge, commit, push, branch change, or PR was performed. Previous failed build
evidence and unrelated repository changes were preserved.


## JupyterLab Desktop 4.6.3_p1: Electron L10N selection (2026-10-26)

**VERIFIED — implementation and sources.** Starting Git status was empty.
Applicable ancestor/repository/package/scripts AGENTS.md paths were checked;
the supplied repository instructions applied. Only the JupyterLab ebuild and
this report section changed. Compass, Signal, and previous failed-build evidence
were preserved.

The 55 `CHROMIUM_LANGS` tags were independently derived with Python `zipfile`
from `locales/*.pak` in the exact bundled
[Electron 42.5.0 Linux arm64 archive](https://github.com/electron/electron/releases/download/v42.5.0/electron-v42.5.0-linux-arm64.zip).
The archive's SHA512 matched the existing package Manifest. The complete derived
list is retained as `archive-locales.txt`; it was compared with the declaration
and `/var/db/repos/gentoo/profiles/desc/l10n.desc`. Literal local results:

```text
Archive SHA512 matches package Manifest: True
Archive locale count: 55
Archive tags absent from Gentoo L10N registry: []
Declared locales match exact archive: True (55)
```

The current `/var/db/repos/gentoo/eclass/chromium-2.eclass` documentation and
implementation, inherited `linux-info.eclass`, and
[official eclass reference](https://devmanual.gentoo.org/eclass-reference/chromium-2.eclass/index.html)
were inspected. The helper operates on the current directory, validates the
language list, and always retains `en-US`. The eclass generates L10N USE flags
when inherited, so `CHROMIUM_LANGS` is defined first. EAPI 8 is retained within
the eclass's documented supported EAPIs 7 and 8. The reviewed local Compass
implementation and current
`/var/db/repos/gentoo/sci-misc/jupyterlab-desktop-bin/jupyterlab-desktop-bin-4.6.3.1.ebuild`
were inspected as examples; neither supplied the authoritative language list.

`src_install` now invokes `chromium_remove_language_paks` inside the extracted
Electron runtime's `locales` directory before installing the runtime. A subshell
preserves the existing working directory. Source compilation, production
pruning, selected-Python patch, newline-free Electron `path.txt`, project-local
Yarn prefix/global/cache settings, and `KEYWORDS="~arm64"` remain intact.
L10N selects Electron resource packs; it does not add JupyterLab interface
translations.

**VERIFIED — fresh native arm64 build on `gentoo`.** The fresh workspace was
`/tmp/codex/sci-misc/jupyterlab-desktop-4.6.3_p1/l10n-_sfpuqbf`, matching the local
evidence directory on `leonids-pc`. The staged `repo` contains the tested package
and dependency eclass. No remote overlay checkout was edited. The 668 declared
distfiles were explicitly copied from the previous `yarn-paths-9_hzidep/distfiles`
staging directory into a new `distfiles` directory; the exact list/source is in
`staged-inputs.txt`. Old work directories and package-manager caches were not
reused. Portage verified the staged inputs in its fetch phase. Yarn populated
a fresh `${T}/yarn-cache` from the new offline mirror. No npm installation or
existing npm cache was used. The explicit Electron cache remained empty.

The actual harness invocation was:

```bash
ssh gentoo 'cd /tmp/codex/sci-misc/jupyterlab-desktop-4.6.3_p1/l10n-_sfpuqbf; tar -xzf validation.tar.gz; sudo -n python3 validate.py'
```

`validate.py` and `harness-settings.json` retain its exact configuration. It
removed inherited Yarn/prefix overrides, exported no Yarn path overrides, and
set these build controls in addition to workspace-local Portage/distfile/log
paths:

```text
FEATURES=userpriv usersandbox network-sandbox sandbox -ccache
MAKEOPTS=-j4
L10N=en-US he ru
electron_config_cache=<workspace>/caches/electron
```

From that workspace, its actual Portage commands were:

```bash
ebuild repo/sci-misc/jupyterlab-desktop/jupyterlab-desktop-4.6.3_p1.ebuild fetch
ebuild repo/sci-misc/jupyterlab-desktop/jupyterlab-desktop-4.6.3_p1.ebuild clean unpack prepare
ebuild repo/sci-misc/jupyterlab-desktop/jupyterlab-desktop-4.6.3_p1.ebuild configure compile install
```

Each returned exit 0, recorded separately in `fetch.exit`, `prepare.exit`, and
`build.exit`, with corresponding complete logs. `commands.json` also records
exact argv/working directories/statuses for Yarn configuration and guarded
Electron-loader probes run as `portage` between prepare and compile.
`process-evidence.json` captures the outer and nested build commands running as
UID 250 (`portage`) in a network namespace separate from the host. Filesystem
and network sandboxing remained enabled, with normal userpriv and no exceptions.

The final native `python3 inspect-result.py` command returned exit 0 and these
literal results:

```text
Effective Yarn prefix: ${T}/yarn-prefix
Effective Yarn global-folder: ${T}/yarn-global
Effective Yarn cache-folder: ${T}/yarn-cache
Effective Yarn global bin: ${T}/yarn-prefix/bin
fetch exit: 0
prepare exit: 0
yarn-prefix exit: 0
yarn-global-folder exit: 0
yarn-cache-folder exit: 0
yarn-global-bin exit: 0
loader-inspection exit: 0
build exit: 0
/usr/local/share/.yarn log mentions: 0
Sandbox violation log: absent or empty
Electron cache entries: 0
Electron download messages: 0
--offline build: uid=250 (portage), separate network namespace
bundle:preload: uid=250 (portage), separate network namespace
Image: compiled server.js and aarch64 Electron 42.5.0 present
Archive locale count: 55
Declared locale count: 55
Missing from declaration: []
Extra declared locales: []
Tags absent from Gentoo L10N registry: []
Installed locale packs: en-US.pak he.pak ru.pak
Unselected locale packs absent: 52
Selected packs byte-identical to archive: True
Locale packs elsewhere in image: []
L10N QA warning messages: 0
```

The locale inspector compared the declaration against the full original archive,
checked selected pack bytes directly, and searched the whole image for locale
packs outside the runtime directory. Thus all 52 unselected packs are excluded
from the image, not just hidden in another installed directory. The compiled
`resources/app/build/out/main/server.js` exists, and the runtime executable's
ELF machine field is AArch64. The probe verified Electron's prepared npm loader
before production pruning removes that development dependency.

**VERIFIED — local checks and retained artifacts.** These commands ran on
`leonids-pc`, with pkgcheck's cache inside the local workspace:

```bash
bash -n sci-misc/jupyterlab-desktop/jupyterlab-desktop-4.6.3_p1.ebuild
pkgcheck scan sci-misc/jupyterlab-desktop
pkgdev manifest -d /tmp/codex/sci-misc/jupyterlab-desktop-4.6.3_p1/l10n-_sfpuqbf/distfiles sci-misc/jupyterlab-desktop
git diff --check
```

All returned exit 0. Syntax and whitespace checks emitted no output; Manifest
generation printed `manifests are up to date`, with no Manifest content change.
The existing scoped pkgcheck findings remain, without suppression:

```text
sci-misc/jupyterlab-desktop
  OldPackageName: package uses old name which is source of pkgmove, rename into 'sci-misc/jupyterlab-desktop-bin'
  RequiredUseDefaults: version 4.6.3_p1: profile: 'default/linux/arm64/23.0/musl' (3 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 4.6.3_p1: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~arm64) dev profile (default/linux/arm64/23.0/musl) (3 total)
```

The build also retains Yarn's existing peer/workspace/engine warnings and Node's
`url.parse()` deprecation warning; none was suppressed. There was no new L10N
warning. Exact local command/output/status records are in
`local-validation.json` and `check-*.log`.

The native-tested repository, harness, logs, statuses, and inspections were
copied back as `native-evidence.tar.gz` and extracted into `native-results` in
the local workspace. `arm64-image.tar.gz` retains the temporary image, and the
exact original Electron archive is retained locally for comparison.
`final-file-comparison.json` records byte-for-byte equality between all final
package files plus the dependency eclass and their native-tested copies:

```text
All final package files and dependency eclass match tested copies: 5
Compass and Signal files unchanged: True
Final ebuild SHA256: 300981958173043f6ce9334f20c8993521e16bd7162af033387c74b898f60eea
```

**INFERRED.** Other language combinations follow the inspected helper's logic,
including its mandatory `en-US` fallback. Only `L10N="en-US he ru"` was built
in this validation.

**NOT VERIFIED.** Locale rendering, desktop interaction, notebook/server
functionality, and other locale combinations were not tested in this run.
Architecture coverage is an actual native arm64 userpriv build through
temporary-image installation on `gentoo`; static packaging checks ran on amd64
`leonids-pc`, with no amd64 build. No live-system installation/merge, commit,
push, branch change, or PR occurred. Historical failure evidence was not modified
or removed, and the earlier report content was preserved.
