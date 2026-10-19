# Autobahn and aiohttp-retry correction and validation

Changes: raise Autobahn’s zope-interface floor from 5.2.0 to 6.2; correct aiohttp-retry’s tagged setup.py version before building. Only these two ebuilds and their validation documentation changed during this follow-up. Existing unrelated checkout changes were preserved by SHA256 comparison.

## Primary sources and rationale

Autobahn’s Twisted extra requires zope-interface>=6.2; this overlay includes that extra unconditionally. See pyproject.toml in the [exact release sdist](https://files.pythonhosted.org/packages/source/a/autobahn/autobahn-26.10.1.tar.gz) and generated wheel metadata below.

The aiohttp-retry v2.9.1 tag declares version 2.9.0 in [setup.py](https://raw.githubusercontent.com/inyutin/aiohttp_retry/v2.9.1/setup.py); the [PyPI release](https://pypi.org/pypi/aiohttp-retry/2.9.1/json) declares 2.9.1. The ebuild corrects setup.py in python_prepare_all before building and verifies the resulting version line. The complete tag is retained for its test-server fixture. Earlier staging exit codes did not establish correct wheel version metadata: the fresh checks here supersede that coverage for these two packages.

Consulted current local distutils-r1.eclass documentation/implementation, [official eclass reference](https://devmanual.gentoo.org/eclass-reference/distutils-r1.eclass/index.html), and [PyPA wheel specification](https://packaging.python.org/en/latest/specifications/binary-distribution-format/). The prepare override calls distutils-r1_python_prepare_all. No ebuild for either package was found in the local Gentoo/Guru trees. A Gentoo Bugzilla REST summary search for aiohttp-retry returned an empty bugs list; the query URL and response are retained in the aiohttp-retry workspace. This search does not establish absence of issues under other names.

## VERIFIED: isolated commands and results

Fresh local workspaces are listed below. Portage temporary directories, caches, logs, distfiles, package outputs and test helpers were confined to these workspaces. Missing declared test helpers were supplied through SHA256-checked upstream wheels extracted into temporary PYTHONPATH directories. Nothing was installed on the live system.

On leonids-pc (amd64), ran ebuild unpack prepare configure compile; inspected generated wheels; ran ebuild test; then sudo env with explicit temporary Portage paths ebuild install into the temporary image. Logs and amd64 wheel artifacts were retained before cleaning the build workdir. The unprivileged image inventory helper returned zero files; that count is not treated as package-content evidence. Completed image sizes are recorded in stage-amd64.log.

On gentoo (native aarch64), staged an isolated temporary repository under /tmp/codex/category/package-version/validation-nonce and ran ebuild clean unpack prepare configure compile; inspected generated wheels; then ran ebuild test install. Logs, complete wheel metadata and image inventories were returned locally before removing only the unique remote staging directory. The remote overlay checkout was never edited.

After builds, reran pkgdev manifest -d WORKSPACE/distfiles PACKAGE; pkgcheck scan --cache-dir WORKSPACE/pkgcheck-cache PACKAGE; and bash -n EBUILD. Both Manifests remained byte-identical to their pre-follow-up content; no source distfile changed.

| Package | amd64 build/test/stage exit | arm64 build/test/stage exit | Manifest / pkgcheck / syntax exit |
|---|---|---|---|
| dev-python/autobahn | 0 | 0 | 0 / 0 / 0 |
| dev-python/aiohttp-retry | 0 | 0 | 0 / 0 / 0 |

## VERIFIED: generated wheel metadata

Each generated wheel was opened as a ZIP and its actual METADATA parsed before tests. Checks assert normalized Name, exact Version, matching dist-info version, matching wheel filename version and the relevant Requires-Dist. Autobahn platform tags were also checked against each host. Full METADATA and SHA256 records are retained in wheel-metadata-amd64.json and wheel-metadata-arm64.json in each workspace. Local wheel files are retained under wheel-artifacts-amd64.

### dev-python/autobahn

Evidence workspace: /tmp/codex/dev-python/autobahn-26.10.1/metadata-followup-1792432833844173001

amd64:

    Wheel: autobahn-26.10.1-cp312-cp312-linux_x86_64.whl
    Metadata entry: autobahn-26.10.1.dist-info/METADATA
    Name: autobahn
    Version: 26.10.1
    Requires-Dist: zope-interface>=6.2; extra == 'all'
    Requires-Dist: zope-interface>=6.2; extra == 'twisted'

    Wheel: autobahn-26.10.1-cp313-cp313-linux_x86_64.whl
    Metadata entry: autobahn-26.10.1.dist-info/METADATA
    Name: autobahn
    Version: 26.10.1
    Requires-Dist: zope-interface>=6.2; extra == 'all'
    Requires-Dist: zope-interface>=6.2; extra == 'twisted'

    Wheel: autobahn-26.10.1-cp314-cp314-linux_x86_64.whl
    Metadata entry: autobahn-26.10.1.dist-info/METADATA
    Name: autobahn
    Version: 26.10.1
    Requires-Dist: zope-interface>=6.2; extra == 'all'
    Requires-Dist: zope-interface>=6.2; extra == 'twisted'

arm64:

    Wheel: autobahn-26.10.1-cp312-cp312-linux_aarch64.whl
    Metadata entry: autobahn-26.10.1.dist-info/METADATA
    Name: autobahn
    Version: 26.10.1
    Requires-Dist: zope-interface>=6.2; extra == 'all'
    Requires-Dist: zope-interface>=6.2; extra == 'twisted'

    Wheel: autobahn-26.10.1-cp313-cp313-linux_aarch64.whl
    Metadata entry: autobahn-26.10.1.dist-info/METADATA
    Name: autobahn
    Version: 26.10.1
    Requires-Dist: zope-interface>=6.2; extra == 'all'
    Requires-Dist: zope-interface>=6.2; extra == 'twisted'

    Wheel: autobahn-26.10.1-cp314-cp314-linux_aarch64.whl
    Metadata entry: autobahn-26.10.1.dist-info/METADATA
    Name: autobahn
    Version: 26.10.1
    Requires-Dist: zope-interface>=6.2; extra == 'all'
    Requires-Dist: zope-interface>=6.2; extra == 'twisted'

### dev-python/aiohttp-retry

Evidence workspace: /tmp/codex/dev-python/aiohttp-retry-2.9.1/metadata-followup-1792432833844173001

amd64:

    Wheel: aiohttp_retry-2.9.1-py3-none-any.whl
    Metadata entry: aiohttp_retry-2.9.1.dist-info/METADATA
    Name: aiohttp_retry
    Version: 2.9.1
    Requires-Dist: aiohttp

arm64:

    Wheel: aiohttp_retry-2.9.1-py3-none-any.whl
    Metadata entry: aiohttp_retry-2.9.1.dist-info/METADATA
    Name: aiohttp_retry
    Version: 2.9.1
    Requires-Dist: aiohttp

## VERIFIED: literal test and QA output

### dev-python/autobahn

amd64:

    Ran 370 tests in 2.441s
    PASSED (skips=29, successes=341)
    ======================== 35 passed, 1 warning in 1.77s =========================
    Ran 370 tests in 2.407s
    PASSED (skips=29, successes=341)
    ======================== 35 passed, 1 warning in 1.75s =========================
    Ran 370 tests in 2.437s
    PASSED (skips=29, successes=341)
    ============================== 35 passed in 1.76s ==============================

arm64:

    Ran 370 tests in 4.015s
    PASSED (skips=29, successes=341)
    ======================== 35 passed, 1 warning in 1.82s =========================
    Ran 370 tests in 4.381s
    PASSED (skips=29, successes=341)
    ======================== 35 passed, 1 warning in 1.79s =========================
    Ran 370 tests in 4.158s
    PASSED (skips=29, successes=341)
    ============================== 35 passed in 1.81s ==============================

Scoped pkgcheck exit 0; stdout/stderr was empty.

pkgdev manifest exit 0; bash -n exit 0; syntax stdout/stderr was empty.

### dev-python/aiohttp-retry

amd64:

    ======================= 42 passed, 3 warnings in 16.98s ========================
    ======================= 42 passed, 3 warnings in 17.11s ========================
    ======================= 42 passed, 3 warnings in 17.24s ========================

arm64:

    ======================= 42 passed, 3 warnings in 17.30s ========================
    ======================= 42 passed, 3 warnings in 17.28s ========================
    ======================= 42 passed, 3 warnings in 17.36s ========================

Scoped pkgcheck exit 0; literal output:

    dev-python/aiohttp-retry
      PythonCompatUpdate: version 2.9.1: PYTHON_COMPAT update available: python3_15

pkgdev manifest exit 0; bash -n exit 0; syntax stdout/stderr was empty.

## INFERRED / NOT VERIFIED

The dependency floor now agrees with upstream metadata. The hosts’ installed zope-interface was used; integration with exactly 6.2 was not tested. Existing Autobahn test exclusions and unprovided optional cryptobox integration are unchanged. Python 3.12, 3.13 and 3.14 were tested on both hosts; Autobahn’s declared 3.11 and the aiohttp-retry PythonCompatUpdate suggestion of 3.15 were not tested. aiohttp-retry was built and tested natively on both hosts; its any wheel tag was not treated as architecture validation.

No live-system merge/installation, commit, push, branch change or pull request was performed. No unrelated package, patch or lockfile was edited.

## aiohttp-retry license-classifier QA follow-up

This narrowly scoped follow-up changes only the aiohttp-retry ebuild and this document. In python_prepare_all(), an anchored sed expression removes exactly the obsolete classifier entry:

    sed -e '/^[[:space:]]*"License :: OSI Approved :: MIT License",$/d' -i setup.py || die

Entry removed:

    "License :: OSI Approved :: MIT License",

The existing correction from upstream 2.9.0 to the ebuild PV and its verification are unchanged. setup.py retains license="MIT", the ebuild retains LICENSE="MIT" and the setuptools backend, and distutils-r1_python_prepare_all is still called. No warning suppression was added and the source archive was not modified.

Primary sources consulted: [v2.9.1 setup.py](https://raw.githubusercontent.com/inyutin/aiohttp_retry/v2.9.1/setup.py), current [Setuptools license migration guidance](https://setuptools.pypa.io/en/stable/userguide/license_migration.html), [PyPA core metadata](https://packaging.python.org/en/latest/specifications/core-metadata/), and the current local distutils-r1.eclass prepare-hook implementation. These sources explain the deprecated classifier; only the requested entry was removed.

### VERIFIED: commands and isolation

Fresh local workspace:

    /tmp/codex/dev-python/aiohttp-retry-2.9.1/license-classifier-1792433766684902612

Host commands returned hostname leonids-pc and uname -m x86_64. Portage environment settings were:

    PORTAGE_TMPDIR=/tmp/codex/dev-python/aiohttp-retry-2.9.1/license-classifier-1792433766684902612/build
    PORTAGE_DEPCACHEDIR=/tmp/codex/dev-python/aiohttp-retry-2.9.1/license-classifier-1792433766684902612/dep-cache
    PORT_LOGDIR=/tmp/codex/dev-python/aiohttp-retry-2.9.1/license-classifier-1792433766684902612/logs
    DISTDIR=/tmp/codex/dev-python/aiohttp-retry-2.9.1/license-classifier-1792433766684902612/distfiles
    PKGDIR=/tmp/codex/dev-python/aiohttp-retry-2.9.1/license-classifier-1792433766684902612/packages
    XDG_CACHE_HOME=/tmp/codex/dev-python/aiohttp-retry-2.9.1/license-classifier-1792433766684902612/cache
    PYTHONPATH=/tmp/codex/dev-python/aiohttp-retry-2.9.1/license-classifier-1792433766684902612/testdeps
    FEATURES="-userpriv -usersandbox -buildpkg -ccache -distcc"
    MAKEOPTS="-j2"
    NINJAOPTS="-j2"

PORTAGE_REPOSITORIES selected the local checkout with the installed Gentoo/Guru masters. Declared test helpers were supplied through SHA256-checked upstream wheels extracted into the temporary PYTHONPATH; no live dependencies were installed. Commands with those settings:

    ebuild /home/leonid/GitHub/leonchik1976/gentoo-overlay/dev-python/aiohttp-retry/aiohttp-retry-2.9.1.ebuild unpack prepare configure compile
    ebuild /home/leonid/GitHub/leonchik1976/gentoo-overlay/dev-python/aiohttp-retry/aiohttp-retry-2.9.1.ebuild test
    sudo -n env <the explicit temporary settings above> ebuild /home/leonid/GitHub/leonchik1976/gentoo-overlay/dev-python/aiohttp-retry/aiohttp-retry-2.9.1.ebuild install

Prepared setup.py and generated wheels were inspected between compile and test. Logs and local wheel artifacts were retained before cleaning the build workdir. The remote run asserted native aarch64 on gentoo and used this unique temporary repository/workspace:

    /tmp/codex/dev-python/aiohttp-retry-2.9.1/validation-1792433880496331469

Actual remote phase commands:

    ebuild /tmp/codex/dev-python/aiohttp-retry-2.9.1/validation-1792433880496331469/repo/dev-python/aiohttp-retry/aiohttp-retry-2.9.1.ebuild clean unpack prepare configure compile
    ebuild /tmp/codex/dev-python/aiohttp-retry-2.9.1/validation-1792433880496331469/repo/dev-python/aiohttp-retry/aiohttp-retry-2.9.1.ebuild test install

Remote Portage paths and test helpers were likewise confined under that workspace, with FEATURES="-buildpkg -ccache -distcc" and two build jobs. Logs, prepared-source checks, full wheel metadata and image inventories were returned locally before removing only the unique temporary staging directory. The remote checkout was never modified.

Post-build scoped local commands:

    pkgdev manifest -d /tmp/codex/dev-python/aiohttp-retry-2.9.1/license-classifier-1792433766684902612/distfiles dev-python/aiohttp-retry
    pkgcheck scan --cache-dir /tmp/codex/dev-python/aiohttp-retry-2.9.1/license-classifier-1792433766684902612/pkgcheck-cache dev-python/aiohttp-retry
    bash -n /home/leonid/GitHub/leonchik1976/gentoo-overlay/dev-python/aiohttp-retry/aiohttp-retry-2.9.1.ebuild

### VERIFIED: prepared source, metadata, warning and tests

Both architectures completed build, tests and temporary image staging with exit 0. The prepared setup.py was compared byte-for-byte against the original archive with exactly the pre-existing version correction and this single classifier removal applied. AST checks confirmed version, license and the complete remaining classifier list. Wheel filename versions were parsed independently of METADATA; both agree on 2.9.1.

amd64:

    Wheel: aiohttp_retry-2.9.1-py3-none-any.whl
    Metadata entry: aiohttp_retry-2.9.1.dist-info/METADATA
    Name: aiohttp_retry
    Version: 2.9.1
    License: MIT
    Classifier: Programming Language :: Python :: 3
    Classifier: Operating System :: OS Independent
    License-classifier warning matches in complete build/staging logs: 0
    ======================= 42 passed, 3 warnings in 17.23s ========================
    ======================= 42 passed, 3 warnings in 17.27s ========================
    ======================= 42 passed, 3 warnings in 17.23s ========================

Remaining test warning messages:

    DeprecationWarning: BasicAuth is deprecated and will be removed in aiohttp 4.0; use aiohttp.encode_basic_auth() with headers={'Authorization': ...} instead
    DeprecationWarning: The 'auth' parameter is deprecated and will be removed in v4; pass headers={'Authorization': aiohttp.encode_basic_auth(login, password)} instead
    PytestAssertRewriteWarning: Module already imported so cannot be rewritten; asyncio

arm64:

    Wheel: aiohttp_retry-2.9.1-py3-none-any.whl
    Metadata entry: aiohttp_retry-2.9.1.dist-info/METADATA
    Name: aiohttp_retry
    Version: 2.9.1
    License: MIT
    Classifier: Programming Language :: Python :: 3
    Classifier: Operating System :: OS Independent
    License-classifier warning matches in complete build/staging logs: 0
    ======================= 42 passed, 3 warnings in 17.27s ========================
    ======================= 42 passed, 3 warnings in 17.31s ========================
    ======================= 42 passed, 3 warnings in 17.30s ========================

Remaining test warning messages:

    DeprecationWarning: BasicAuth is deprecated and will be removed in aiohttp 4.0; use aiohttp.encode_basic_auth() with headers={'Authorization': ...} instead
    DeprecationWarning: The 'auth' parameter is deprecated and will be removed in v4; pass headers={'Authorization': aiohttp.encode_basic_auth(login, password)} instead
    PytestAssertRewriteWarning: Module already imported so cannot be rewritten; asyncio

The earlier amd64 build log provides the literal positive control:

    SetuptoolsDeprecationWarning: License classifiers are deprecated.

The unchanged source archive SHA256 is:

    873fc4f7c5dde1206d7016d4d9889f0f6ea03bf5b6bafcb889bd407f0d97f84e

Full evidence remains in prepared-source-amd64.json, prepared-source-arm64.json, wheel-metadata-amd64.json, wheel-metadata-arm64.json, build-amd64.log, stage-amd64.log, build-arm64.log, validation-arm64.json and classifier-validation-checks.json under the fresh workspace. Local wheel files are retained under wheel-artifacts-amd64.

Scoped pkgcheck exit 0; literal remaining output:

    dev-python/aiohttp-retry
      PythonCompatUpdate: version 2.9.1: PYTHON_COMPAT update available: python3_15

pkgdev manifest exit 0; bash -n exit 0 with empty stdout/stderr. The Manifest is byte-identical to the pre-fix snapshot.

### NOT VERIFIED / limits

Python 3.12, 3.13 and 3.14 were built and tested on both hosts. Python 3.15 remains untested; the existing PythonCompatUpdate suggestion is reported rather than suppressed. The remaining pytest/plugin and aiohttp-auth deprecation warnings are quoted above. Temporary image staging is not live-system integration testing. No live-system installation/merge, branch creation/switch, commit, push or PR was performed. Unrelated checkout files were preserved.
