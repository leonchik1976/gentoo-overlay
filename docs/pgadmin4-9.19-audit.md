# pgAdmin 4 9.19 desktop packaging audit

## Sources and packaging decision

Upstream's `pgadmin4-desktop` is the standalone desktop edition. The Debian 13 package metadata reports `Package: pgadmin4-desktop` and `Depends: pgadmin4-server (= 9.19)`. The latter supplies the Python backend. Upstream publishes its Linux DEBs and RPMs for x86-64. The upstream Linux package therefore cannot serve as a native binary input for both target architectures. [APT installation](https://www.pgadmin.org/download/pgadmin-4-apt/) · [RPM installation](https://www.pgadmin.org/download/pgadmin-4-rpm/) · [Desktop deployment](https://www.pgadmin.org/docs/pgadmin4/9.19/desktop_deployment.html)

The ebuild uses the same pgAdmin sources on both architectures. It runs the release's webpack configuration and compiles gettext translations. The launcher uses the release's desktop code and production JavaScript dependencies. The exact runtime lock selects Electron 44.7.0. The ebuild stages the matching native Electron binary for each architecture and extracts offline help from the official 9.19 wheel. The wheel's application code and Python dependencies are excluded. [9.19 source artifact](https://ftp.postgresql.org/pub/pgadmin/pgadmin4/v9.19/source/pgadmin4-9.19.tar.gz) · [9.19 wheel](https://ftp.postgresql.org/pub/pgadmin/pgadmin4/v9.19/pip/pgadmin4-9.19-py3-none-any.whl) · [Electron 44.7.0](https://github.com/electron/electron/releases/tag/v44.7.0)

The source tarball pins Yarn 4.15.0 in both `package.json` files. The overlay's cache generator fills both Linux architecture caches before the build. It also captures the exact packed react-data-grid git dependency. The ebuild consumes the Manifest-checked cache and uses Yarn's offline, immutable-cache mode. A second generation of the archive matched byte for byte with SHA-256 `9a9fe6be42a0dbab02aae48505910baa8206ba4cf1c363e529250b65cffe1bc9`. [Yarn 4.15.0](https://registry.npmjs.org/@yarnpkg/cli-dist/4.15.0) · [react-data-grid source](https://github.com/pgadmin-org/react-data-grid/tree/d9dccda1ff4bfc155b6893d0c0ff7585cf0bc101)

EAPI 9 is current. The locally synced `python-single-r1`, `distutils-r1`, `pypi` and `xdg` eclasses require EAPI 8 for these recipes. There are no package-specific USE flags. The package always builds the desktop interface. Upstream 9.19 gates the LDAP, OAuth2 and GSSAPI authentication providers behind server mode, so their Python libraries are excluded from the desktop dependency set. [PMS 9](https://projects.gentoo.org/pms/9/pms.html) · [EAPI Devmanual](https://devmanual.gentoo.org/ebuild-writing/eapi/index.html) · [PG0001](https://projects.gentoo.org/qa/policy-guide/dependencies.html) · [9.19 release notes](https://www.pgadmin.org/docs/pgadmin4/9.19/release_notes_9_19.html)

Gentoo removed the old 4.29 and 4.30 ebuilds on June 19, 2022. Bugs 836282, 774348 and 817350 are RESOLVED FIXED and were closed by that commit. They concerned Flask upgrade blocking, Flask-Security startup and the old psycopg2 query path. The new recipe uses the current Flask stack, the 9.19 Flask-Security-Too 5.8.3 minimum and Psycopg 3 with native extensions. The Gentoo sshtunnel ebuild patches compatibility with newer Paramiko, so the desktop uses Gentoo's Paramiko instead of importing 9.19's old 3.5.1 pin. [Gentoo treeclean commit](https://gitweb.gentoo.org/repo/gentoo.git/commit/?id=8b0fa104cddcbb9dd7bca9351c2de58703939fcf) · [Bug 836282](https://bugs.gentoo.org/836282) · [Bug 774348](https://bugs.gentoo.org/774348) · [Bug 817350](https://bugs.gentoo.org/817350) · [Gentoo sshtunnel ebuild](https://gitweb.gentoo.org/repo/gentoo.git/tree/dev-python/sshtunnel/sshtunnel-0.4.0-r2.ebuild)

## Dependency status

The Python dependency baseline is `requirements.txt` in the exact release tarball. Separately packaged libraries keep their own license metadata. Gentoo's certifi uses system trust. The overlay already supplies `dev-python/user-agents`. GURU supplies `flask-socketio-5.7.0` and `msrest-0.7.1`, and Gentoo supplies `portalocker`. On arm64, the existing amd64-only Python dependencies are accepted as existing ebuilds per the overlay owner's instruction. Portage will still require local keyword acceptance for them. The glibc constraint comes from the Electron runtime. Both builds' ELF version requirements reach GLIBC_2.25. [Flask-SocketIO in GURU](https://gitweb.gentoo.org/repo/proj/guru.git/tree/dev-python/flask-socketio/flask-socketio-5.7.0.ebuild) · [msrest in GURU](https://gitweb.gentoo.org/repo/proj/guru.git/tree/dev-python/msrest/msrest-0.7.1.ebuild) · [Portalocker in Gentoo](https://gitweb.gentoo.org/repo/gentoo.git/tree/dev-python/portalocker/portalocker-4.4.2.ebuild)

The new Python recipes cover the following release sources. The Azure Core recipe supplies the minimum API generation required by `azure-identity` and `azure-mgmt-core` since GURU's Azure Core stops at 1.28.0. The recipe versions, build backends and dependency bounds come from the release sources and metadata.

| Recipe | Gentoo license | Upstream metadata |
| --- | --- | --- |
| `azure-common-1.1.28` | `MIT` | [PyPI release JSON](https://pypi.org/pypi/azure-common/1.1.28/json) |
| `azure-core-1.41.0` | `MIT` | [PyPI release JSON](https://pypi.org/pypi/azure-core/1.41.0/json) |
| `azure-identity-1.26.0` | `MIT` | [PyPI release JSON](https://pypi.org/pypi/azure-identity/1.26.0/json) |
| `azure-mgmt-core-1.6.0` | `MIT` | [PyPI release JSON](https://pypi.org/pypi/azure-mgmt-core/1.6.0/json) |
| `azure-mgmt-rdbms-10.1.1` | `MIT` | [PyPI release JSON](https://pypi.org/pypi/azure-mgmt-rdbms/10.1.1/json) |
| `azure-mgmt-resource-24.0.0` | `MIT` | [PyPI release JSON](https://pypi.org/pypi/azure-mgmt-resource/24.0.0/json) |
| `azure-mgmt-subscription-3.1.1` | `MIT` | [PyPI release JSON](https://pypi.org/pypi/azure-mgmt-subscription/3.1.1/json) |
| `flask-mail-0.10.0` | `BSD` | [PyPI release JSON](https://pypi.org/pypi/Flask-Mail/0.10.0/json) |
| `flask-migrate-4.1.0` | `MIT` | [PyPI release JSON](https://pypi.org/pypi/Flask-Migrate/4.1.0/json) |
| `flask-principal-0.4.0` | `MIT` | [PyPI release JSON](https://pypi.org/pypi/Flask-Principal/0.4.0/json) |
| `flask-security-too-5.8.3` | `MIT` | [PyPI release JSON](https://pypi.org/pypi/Flask-Security-Too/5.8.3/json) |
| `flask-sqlalchemy-3.1.1` | `BSD` | [PyPI release JSON](https://pypi.org/pypi/Flask-SQLAlchemy/3.1.1/json) |
| `flask-wtf-1.3.0` | `BSD` | [PyPI release JSON](https://pypi.org/pypi/Flask-WTF/1.3.0/json) |
| `jsonformatter-0.3.4` | `BSD-2` | [PyPI release JSON](https://pypi.org/pypi/jsonformatter/0.3.4/json) |
| `libgravatar-1.0.4` | `GPL-3` | [PyPI release JSON](https://pypi.org/pypi/libgravatar/1.0.4/json) |
| `msal-1.39.0` | `MIT` | [PyPI release JSON](https://pypi.org/pypi/msal/1.39.0/json) |
| `msal-extensions-1.3.1` | `MIT` | [PyPI release JSON](https://pypi.org/pypi/msal-extensions/1.3.1/json) |

## License inventory

- pgAdmin source and documentation use the PostgreSQL License, confirmed in the 9.19 source tarball's `LICENSE`. The embedded Sphinx help assets use BSD terms recorded in the wheel's generated HTML support files. [Source archive](https://ftp.postgresql.org/pub/pgadmin/pgadmin4/v9.19/source/pgadmin4-9.19.tar.gz) · [Wheel archive](https://ftp.postgresql.org/pub/pgadmin/pgadmin4/v9.19/pip/pgadmin4-9.19-py3-none-any.whl)
- Open Sans and Roboto use Apache-2.0. Source Code Pro uses OFL-1.1. This comes from the exact TTF name-table license records in `web/pgadmin/static/fonts`. The vendored RequireJS 2.3.6 records MIT in its source header. Font Awesome records CC BY 4.0 for icons, OFL-1.1 for fonts and MIT for code. [Source archive](https://ftp.postgresql.org/pub/pgadmin/pgadmin4/v9.19/source/pgadmin4-9.19.tar.gz) · [Font Awesome Free](https://fontawesome.com/license/free)
- Webpack chunk statistics identify 268 distinct browser dependency releases. The production desktop installation contains 76 distinct npm releases. The accompanying `pgadmin4-9.19-browser-notices.txt.xz` and `pgadmin4-9.19-desktop-notices.txt.xz` record each release and its bundled root notice or manifest declaration. React Leaflet 4.2.1 and its core 2.1.0 carry the Hippocratic License 2.1. The older heap 0.2.5 and pathfinding 0.4.18 document PSF 2 and MIT respectively in their shipped README files. The browser audit uses emitted chunks, so build-time-only tooling licenses are excluded from the application metadata. [React Leaflet 4.2.1](https://registry.npmjs.org/react-leaflet/4.2.1) · [React Leaflet Core 2.1.0](https://registry.npmjs.org/@react-leaflet%2Fcore/2.1.0) · [heap 0.2.5](https://registry.npmjs.org/heap/0.2.5) · [pathfinding 0.4.18](https://registry.npmjs.org/pathfinding/0.4.18)
- Both Electron ZIPs carry the Electron MIT notice and 779 Chromium credits entries. The two `LICENSES.chromium.html` files compare byte for byte and are installed intact. The credits include FFmpeg LGPL-2.1-or-later, the LLVM exception for LLVM runtime components, FreeType terms, ICU/Unicode notices and bundled JavaScript notices. Chromium credits also include cross-platform and optional components. A per-component comparison against the compiled Electron binary's link map remains unverified. The package is restricted from binary redistribution. [Electron release](https://github.com/electron/electron/releases/tag/v44.7.0)
- The npm report identifies packages whose published tarball had no root license file. The notices include three exact upstream commit texts and additional terms recovered from shipped README files and source headers. Several packages provide a license declaration without a complete standalone attribution text. The audit records the available source without assuming that it covers copyright terms omitted by the publisher. The audit also leaves external EDB binary tools and additional runtime plugins outside the package scope.

## Build and launch evidence

**VERIFIED.** `pkgdev manifest -d /tmp/codex/dev-db/pgadmin4-9.19` generated the application and 17 Python Manifests. The repeated scoped run reported `manifests are up to date`. The offline cache was checked against the Manifest on both hosts.

**VERIFIED.** With Python 3.13 selected, `ebuild ... clean unpack prepare compile install` reached `>>> Source compiled.` and `>>> Completed installing dev-db/pgadmin4-9.19` on amd64 (`leonids-pc`) and native arm64 (`gentoo`). Webpack on both hosts reported `webpack 5.112.0 compiled with 3 warnings`, covering asset size and performance recommendations. All 17 new Python ebuilds reached their staged install phase on both hosts. The test used a single bytecode worker because the long amd64 staging path exceeded the AF_UNIX path limit with parallel Python bytecode compilation.

**VERIFIED.** `desktop-file-validate`, `readelf -h`, and Xvfb desktop startup checks ran against staged images. `xwininfo` showed a `"pgAdmin 4"` main window at `1024x768` on both hosts. Each loopback check reported `Help HTTP 200` and `JavaScript HTTP 200`. The smoke tests used isolated user directories, the staged Python builds and a temporary directory for missing pre-existing Python modules. Electron used its namespace sandbox in these tests, since its setuid helper was staged without root ownership.

**VERIFIED.** The staged SDKs reported `azure-core 1.41.0` and `Azure SDK imports completed` on both hosts. On amd64, Portalocker 4.4.2 acquired and released a temporary MSAL cache lock. This exercises the cache API used by the package even though MSAL Extensions 1.3.1 declares a narrower range for its optional Portalocker extra. [MSAL Extensions release JSON](https://pypi.org/pypi/msal-extensions/1.3.1/json) · [Portalocker release JSON](https://pypi.org/pypi/portalocker/4.4.2/json)

**VERIFIED.** Scoped `pkgcheck scan` reports `NonsolvableDepsInDev` and `NonsolvableDepsInStable` for the amd64-only Python dependencies on ordinary arm64 profiles. This is the expected keyword-acceptance issue for `flask-socketio`, `msrest`, and `portalocker`. It also reports unsupported musl/x32 profiles and offers `PythonCompatUpdate` for some standalone libraries. The recipes target the verified development stack across both architectures on glibc.

**NOT VERIFIED.** A live Portage merge, Python 3.14 runtime, actual PostgreSQL backup/restore, SSH tunnel connections and external cloud authentication were outside these staging checks. No live-system merge or installation was performed.

## Cache for future builds

Use the existing `pgadmin4-9.19-yarn-cache.tar` from `/tmp/codex/dev-db/pgadmin4-9.19`, or regenerate it from the exact source archive:

```sh
scripts/generate-pgadmin4-yarn-cache.sh /path/to/pgadmin4-9.19.tar.gz
```

Place that archive in Portage's `DISTDIR` for each build host. The repository stores its hash in the Manifest. The generator is the only step that resolves the Yarn inputs over the network.

## leonids-pc resolver follow-up

**Python targets.** The host-wide settings reported by `portageq envvar PYTHON_SINGLE_TARGET PYTHON_TARGETS` were `python3_15` and `python3_14 python3_12 python3_13 python3_14t python3_15 python3_15t` respectively. With pgAdmin on 3.14 and the original Azure Core ebuild, Portage reported `Change USE: -python_targets_python3_15` for `msrest-0.7.1::guru`. msrest enables every compatible target selected by the host, so its Azure Core USE dependency includes 3.15 even though pgAdmin runs under 3.14. The Azure Core ebuild now includes the regular CPython 3.15 target. The exact release declares `Requires-Python: >=3.10` and lists classifiers through 3.14. The new target is based on local testing. [Azure Core 1.41.0 metadata](https://pypi.org/pypi/azure-core/1.41.0/json) · [GURU msrest ebuild](https://gitweb.gentoo.org/repo/proj/guru.git/tree/dev-python/msrest/msrest-0.7.1.ebuild)

**VERIFIED.** Before the checkout edit, a scratch Azure Core ebuild completed `ebuild ... clean unpack prepare compile install` with `PYTHON_TARGETS=python3_15`. Python 3.15 imported Azure Core 1.41.0 from that staged image. Selected upstream paging, pipeline, REST request and utility tests ran with `python3.15 -m pytest --noconftest` against the staged image and reported `119 passed, 18 deselected, 2 warnings`. The selection bypassed the loopback fixture, excluded async and fixture-dependent cases, and left out the serialization module because the release archive lacks its `modeltypes` fixture. The two warnings were unknown async test marks with external pytest plugins disabled. The updated checkout build subsequently reported `Verifying compiled files for python3.13`, `python3.14` and `python3.15`. Portage still reports that the recipe has no automatic test phase.

**Dateutil.** The 9.19 source pins `python-dateutil==2.*`. All three pgAdmin modules that import it use the general `parser.parse` entry point. The major-version changes most relevant to review are stricter numeric fields in 4.0's `isoparse` and the 3.0 rewrite of `tzfile` and time zone database selection. The pgAdmin calls supply no `tzinfos` and do not use `isoparse`, the changed time zone database interface, or removed Python 2 helpers. The overlay now caps the dependency at `<dev-python/python-dateutil-5`, leaving the next major version outside the checked range. [pgAdmin 9.19 source archive](https://ftp.postgresql.org/pub/pgadmin/pgadmin4/v9.19/source/pgadmin4-9.19.tar.gz) · [dateutil 4.0.0 release](https://github.com/dateutil/dateutil/releases/tag/4.0.0) · [dateutil changelog at 4.0.0](https://github.com/dateutil/dateutil/blob/4.0.0/NEWS)

**VERIFIED.** A focused Python 3.14 harness executed the exact release's `RoleView._validate_rolvaliduntil`, `_Preference.get` and `set`, and `BatchProcess.status` and `list` with mocked database and process boundaries. It checked the upstream role fixture's +05:30 offset, UTC and date-only inputs, null/empty/invalid values, date and datetime preference round trips and invalid fallback, and active/finished process durations with offsets and microseconds. The Python 3.14 runs reported `dateutil 2.9.0.post0 all focused checks completed` and `dateutil 4.0.0 all focused checks completed`. The 4.0.0 run also completed on Python 3.13.

**Temporary configuration.** The test copied the host settings into a writable `PORTAGE_CONFIGROOT`, resolved its profile symlink, and pointed the `local` repository entry to this checkout. The only Python USE override was:

```text
# package.use/zz-pgadmin-test
=dev-db/pgadmin4-9.19::local -python_single_target_python3_15 python_single_target_python3_14
# package.unmask/zz-pgadmin-test
=dev-python/msrest-0.7.1::guru
```

The copied host configuration already accepted Flask-SocketIO. The added `package.accept_keywords/zz-pgadmin-test` contained the following entries.
```text
=dev-db/pgadmin4-9.19::local ~amd64
=dev-python/azure-common-1.1.28::local ~amd64
=dev-python/azure-core-1.41.0::local ~amd64
=dev-python/azure-identity-1.26.0::local ~amd64
=dev-python/azure-mgmt-core-1.6.0::local ~amd64
=dev-python/azure-mgmt-rdbms-10.1.1::local ~amd64
=dev-python/azure-mgmt-resource-24.0.0::local ~amd64
=dev-python/azure-mgmt-subscription-3.1.1::local ~amd64
=dev-python/flask-mail-0.10.0::local ~amd64
=dev-python/flask-migrate-4.1.0::local ~amd64
=dev-python/flask-principal-0.4.0::local ~amd64
=dev-python/flask-security-too-5.8.3::local ~amd64
=dev-python/flask-sqlalchemy-3.1.1::local ~amd64
=dev-python/flask-wtf-1.3.0::local ~amd64
=dev-python/jsonformatter-0.3.4::local ~amd64
=dev-python/libgravatar-1.0.4::local ~amd64
=dev-python/msal-1.39.0::local ~amd64
=dev-python/msal-extensions-1.3.1::local ~amd64
=dev-python/msrest-0.7.1::guru ~amd64
```

**VERIFIED.** The following command used the installed VDB and exited zero with `Total: 28 packages (28 new)`. The tree selected pgAdmin on `python3_14`, and both msrest and Azure Core on `python3_13 python3_14 python3_15`. `portageq best_version / dev-python/python-dateutil` reported `dev-python/python-dateutil-4.0.0` and the tree contained no dateutil transaction. Host-wide targets in the temporary configuration matched the live defaults. `Fetch Restriction: 1 package` describes pgAdmin's manual cache input. The ebuild's unpack phase verified the cache against the Manifest.

```sh
FEATURES=-news PORTAGE_CONFIGROOT="$test_config" DISTDIR=/tmp/codex/dev-db/pgadmin4-9.19 \
  emerge --pretend --verbose --tree --autounmask=n '=dev-db/pgadmin4-9.19::local'
```

**VERIFIED.** With the same temporary configuration, `ebuild dev-db/pgadmin4/pgadmin4-9.19.ebuild clean unpack prepare compile install` reported `webpack 5.112.0 compiled with 3 warnings` and `>>> Completed installing dev-db/pgadmin4-9.19` into the staging image. The launcher interpreter symlink resolved within the image layout to `/usr/bin/python3.14`. Scoped `pkgdev manifest` reported `manifests are up to date`.

The scoped `pkgcheck scan dev-db/pgadmin4 dev-python/azure-core` reported the existing pgAdmin arm64 dependency keyword and musl/x32 profile findings. No changes were made to `/etc/portage` or GURU ebuilds. The follow-up ran on amd64 on `leonids-pc`. The earlier native arm64 results above cover the original recipes. The updated recipes have not been rebuilt on arm64. No package was merged.

## QA and offline tests on leonids-pc

**Verified.** The release archives were inspected for tests. Portage ran `ebuild ... clean unpack prepare compile test install` on all 18 recipes on amd64. The pgAdmin builds used temporary 3.13 and 3.14 selections and the existing Manifest-checked Yarn cache. The Python recipes ran their declared 3.13/3.14 targets, with 3.15 also run for Azure Core. Validation used Portage's network sandbox. The focused reruns also enabled filesystem sandboxing. Missing already-packaged Python test imports were supplied from temporary staging directories. No packages were merged. [Gentoo Python test guide](https://projects.gentoo.org/python/guide/test.html) · [Gentoo pytest recipes](https://projects.gentoo.org/python/guide/pytest.html)

The table quotes test counts per interpreter selection where the suite ran.

| Package | Tests and exclusions | Metadata and staging result |
| --- | --- | --- |
| pgAdmin 4 | Offline Jest, `179 passed` suites and `1159 passed` tests for both selections. The Python regression and browser feature suites need configured PostgreSQL servers and browser drivers. | Both images reached `Completed installing`. Existing webpack size/performance warnings remain. |
| Azure Common | No tests in the sdist. Import verified from both staged images. | Removed the universal wheel option and legacy MIT classifier. Both staging builds completed. |
| Azure Core | `119 passed, 18 deselected` on each of 3.13, 3.14 and 3.15. Uses the previously verified paging, pipeline, REST request and utility selection. Excludes the global server fixture, cases requiring it, async cases in this selection and serialization with omitted model fixtures. | Staging completed for all three targets. |
| Azure Identity | `97 passed, 5 deselected` on each target. Runs independent mock-based unit modules outside the recording proxy conftest. Excludes omitted certificate fixtures and live multitenant cases. | Staging completed. |
| Azure Management Core | `14 passed, 1 deselected` on each target. Uses offline endpoint, polling, policy, exception and utility tests. The older serialized poller token fixture is incompatible with current Azure Core. The credential-based and async integration modules are outside this selection. | Removed the legacy license classifier and switched the two HTTP policy tests from deprecated HTTPretty to requests-mock. Staging completed. |
| Azure Management RDBMS | `1 passed` on each target. Invokes the shipped import test by filename. The other disabled tests create Azure database servers. | Staging completed. |
| Azure Management Resource | `2 passed` on each target. Runs the independent import-boundary tests. Generated operation tests require the Azure recording proxy. | Removed the legacy license classifier. Staging completed. |
| Azure Management Subscription | `RESTRICT="test"` with a source-specific comment. The sole suite uses the Azure recording proxy and SDK test harness. | Removed the legacy license classifier. Staging completed. |
| Flask-Mail | No tests in the sdist. | Recipe required no edit. Staging completed. |
| Flask-Migrate | `7 passed` on each target. The test subprocess wrapper uses the selected interpreter for the Flask CLI. SQLite migration tests run offline. | Migrated the TOML license to MIT SPDX metadata with a setuptools 77.0.3 minimum. Staging completed. |
| Flask-Principal | No tests in the sdist. | Removed the legacy MIT classifier and obsolete Nose setup options. Staging completed. |
| Flask-Security-Too | `659 passed, 138 skipped, 47 deselected` on each target. Excludes MongoDB fixtures, a deliverability case that queries DNS and one shared-form order-dependent assertion. Optional backend and WebAuthn cases skip in the staged environment. | Staging completed with usual pytest warnings. |
| Flask-SQLAlchemy | `296 passed, 156 deselected` on each target. The installed SQLAlchemy 2.1 rejects the release's dataclass fixture patterns. The test command confines warning exceptions to the old UTC and unclosed SQLite fixture warnings. | Staging completed. The runtime dependency is unchanged. |
| Flask-WTF | `83 passed, 2 skipped` on each target. The two optional Flask-Uploads cases skip upstream. | Staging completed. |
| jsonformatter | `22 passed, 1 deselected` on each target. Excludes the missing logger configuration fixture and uses the non-Windows suite. | Migrated to BSD-2-Clause SPDX metadata, preserved the license file and removed the duplicate setup.py license. Staging completed. |
| libgravatar | No tests in the sdist. | Removed the universal wheel option and legacy classifier. Wheel metadata records the GPLv3-or-later grant in the shipped source. The Gentoo LICENSE value is preserved. Staging completed. |
| MSAL | `17 passed` on each target. Runs cache, Cloud Shell scope parsing and mocked certificate-thumbprint tests. Other modules rely on omitted test helpers or external endpoints. | Removed the legacy classifier and universal-wheel option. Staging completed. |
| MSAL Extensions | `3 passed, 4 skipped, 2 deselected` on each target. Runs portable file persistence and lock tests. Other modules need omitted helpers, platform-specific backends or a desktop Secret Service. | Removed the legacy classifier, universal-wheel option and obsolete setuptools test option. Staging completed. |

**Verified.** The baseline Azure Common build reproduced `License classifiers are deprecated.` and `bdist_wheel.universal is deprecated`. The patched wheel reported `License: MIT`, `License-File: LICENSE` and `Tag: py3-none-any` under host setuptools 84.2.1 and a separate wheel build with setuptools 77.0.3. `azure.common` imported from both Portage images. The patched recipes' final phase logs contained no setuptools deprecation or unenabled-test QA notices. The upstream terms and Gentoo LICENSE values were retained. [Setuptools license migration guide](https://setuptools.pypa.io/en/latest/userguide/pyproject_config.html)

**Verified.** Scoped `pkgdev manifest` reported `manifests are up to date`. Scoped `pkgcheck scan` over the 18 packages continued to report the established profile/keyword findings and Python compatibility suggestions. The temporary-config `emerge --pretend --verbose --tree --autounmask=n '=dev-db/pgadmin4-9.19::local'` exited zero with `Total: 18 packages (18 new)`. Installed dateutil was `dev-python/python-dateutil-4.0.0` and the tree contained no dateutil transaction. A second pretend run with per-package `test` enabled also exited zero and reported `Total: 21 packages (21 new)`.

**Not verified.** These QA changes were staged on amd64 only. Native arm64 tests and builds, and the explicitly excluded external-service and optional-backend tests, remain unverified. The GURU recipes, live Portage configuration and Yarn cache workflow were left intact.
