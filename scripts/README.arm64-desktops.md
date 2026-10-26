# arm64 desktop packages

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
