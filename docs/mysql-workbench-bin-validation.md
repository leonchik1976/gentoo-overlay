# MySQL Workbench 26.7.0 packaging investigation

Repository: `/home/leonid/GitHub/leonchik1976/gentoo-overlay`.
Date: 2026-10-07. Initial working tree had no changes.

## Result and changed files

Created `dev-db/mysql-workbench-bin/mysql-workbench-bin-26.7.0.ebuild`,
`metadata.xml` with Leonid Kopylov's maintainer identity, and `Manifest` with
both architecture archives and their detached signatures. No existing versions,
patches or Manifest entries were removed. No Git commit, push or branch action
was performed.

The upstream binary archives are installed under `/opt/mysql-workbench`, with
`/usr/bin/mysql-workbench` and a desktop entry/icon. The ebuild uses a weak blocker
on `dev-db/mysql-workbench` because the application command collides with the
older package. No old package was removed during this work.

## Sources and packaging rationale

- Exact upstream artifacts: [amd64 ZIP](https://cdn.mysql.com/Downloads/MySQLGUITools/mysql-workbench-26.7.0-linux-glibc2.28-x86_64.zip),
  [arm64 ZIP](https://cdn.mysql.com/Downloads/MySQLGUITools/mysql-workbench-26.7.0-linux-glibc2.28-aarch64.zip),
  and [source TAR](https://cdn.mysql.com/Downloads/MySQLGUITools/mysql-workbench-26.7.0-src.tar.gz).
  Dependency and ABI claims below come from these exact artifacts, not another overlay.
- [Oracle's announcement](https://blogs.oracle.com/mysql/introducing-mysql-workbench-26)
  explains the replacement of the old C++ application with Electron/MySQL Shell.
- [PMS 9](https://projects.gentoo.org/pms/9/pms.html) establishes EAPI and blocker
  semantics. EAPI 9 is the latest defined EAPI checked here. The inherited
  `/var/db/repos/gentoo/eclass/chromium-2.eclass` and `xdg.eclass` explicitly
  support EAPIs 7 and 8 only. Consequently this ebuild uses EAPI 8. The documented
  `make_desktop_entry --eapi9` interface is supported in EAPI 8 and is used here.
- [Devmanual USE guidance](https://devmanual.gentoo.org/general-concepts/use-flags/),
  [PG0001](https://projects.gentoo.org/qa/policy-guide/dependencies.html), and
  [license guidance](https://devmanual.gentoo.org/general-concepts/licenses/)
  were consulted.
- Current eclass implementation/documentation inspected: `chromium-2`, `desktop`,
  `xdg`, `optfeature`, `verify-sig`, `wrapper`, and `unpacker` under
  `/var/db/repos/gentoo/eclass/`.
- Prior art inspected: `::gentoo/dev-db/mysql-workbench/mysql-workbench-8.0.46.ebuild`,
  `::gentoo/dev-db/mongodb-compass-bin/mongodb-compass-bin-1.50.0.ebuild`, current
  `::gentoo/app-editors/vscode` and `::gentoo/net-im/discord` ebuilds, and
  `::guru/dev-util/insomnia-bin/insomnia-bin-2023.5.8.ebuild`.
  Their choices were treated as examples, not policy or upstream requirements.
- Gentoo bug searches for the new release were attempted. The bug site was
  inaccessible through the browsing tool; no current relevant bug status was
  established. Old Workbench's compiler/LTO workarounds were not carried over.

The `-bin` name reflects installation of prebuilt binaries and follows the local
repository instruction. The source artifact's `gui/WORKBENCH_DEV.md`,
`gui/electron/developer.md`, and package metadata describe npm dependency
installation, Electron packaging and a staged MySQL Shell runtime. A reproducible
offline source build would require a separate dependency/build workflow; it was
not implemented or shown impossible by this investigation.

## Dependencies, licenses and USE choices

VERIFIED: `readelf -d`, `readelf -V`, `readelf -h`, `lddtree`, and `qfile` were used.
Per-file static evidence is in `amd64-elf.json` and `arm64-elf.json` in this directory.
The installed native images were additionally checked with `lddtree` on each host.

Both architectures ship Electron, Shell, Python, OpenSSL, libssh, ANTLR, protobuf,
Abseil and Python packages. External dependencies include the desktop libraries,
CUPS, ALSA, D-Bus, udev, keyutils, bzip2, libyaml, ncurses/tinfo and libcrypt.
Dependencies in the ebuild were mapped to providers in the local Gentoo tree.
ABI-specific constraints include glibc >=2.28, libcrypt.so.1, ncurses ABI 6,
libudev.so.1 and libz.so.1. Both archives' version requirements extend through
GLIBC_2.28, GLIBCXX_3.4.22 and CXXABI_1.3.11.

Only amd64 ships `_gdbm` and `_dbm` Python extensions requiring libgdbm.so.6 and
libgdbm_compat.so.4, hence `amd64? ( sys-libs/gdbm:0/6[berkdb] )`. The arm64
archive lacks those extensions. Current provider contracts were inspected in
`::gentoo/sys-libs/gdbm/gdbm-1.26.ebuild`,
`::gentoo/sys-libs/libxcrypt/libxcrypt-4.5.2.ebuild`,
`::gentoo/sys-libs/ncurses/ncurses-6.6_p20260912.ebuild`, and
`::gentoo/virtual/libudev/libudev-257.ebuild`.

The license value comes from the exact archives' `LICENSE.txt`,
`LICENSE.electron.txt`, `LICENSES.chromium.html`,
`resources/app/shell/share/mysqlsh/LICENSE`, Python's `LICENSE.txt`, and bundled
Python package license files/metadata. The primary application license is GPL-2;
the ebuild also records the bundled components' license terms. The full upstream
notices remain installed. OCI's shipped dual UPL/Apache terms permit the Apache-2.0
choice already included in the expression.

The only selectable installation/build choices are:

- Chromium `L10N` flags, generated by the eclass, remove unselected `.pak` files.
  This is an install-time file selection, not a promise that the application UI
  itself has been translated. It follows the eclass contract and official-tree
  packaging practice. Available locales were checked against both archives.
- The eclass-provided `verify-sig` flag verifies detached upstream signatures
  during unpacking. Existing eclass dependencies are preserved by `BDEPEND+=`.

No `alsa`, `cups`, `dbus`, `X`, `wayland`, `ssl`, `ssh`, `kerberos`, cloud,
`gnome-keyring`, `doc`, or `debug` feature flags were added. Directly linked
libraries cannot be disabled by dropping their dependencies. Runtime backend
selection and already installed optional integrations do not justify dependency-
only flags under PG0001. No overlay convenience exceptions were requested.
Global/local registries were checked in `::gentoo/profiles/use.desc` and
`use.local.desc`; no new local flag requires a metadata description.

`strings` on the shipped `mysql-secret-store-secret-service` executable confirms
that it invokes `secret-tool`. Optional post-install guidance therefore names
both `app-crypt/libsecret[crypt]` and `virtual/secret-service`, not one specific
desktop's provider. Notification-library and local Enterprise Backup bootstrap
Python requirements are also optional guidance. The latter remains dependent on
administrator configuration and upstream Enterprise Backup prerequisites.
[Shell password-store documentation](https://dev.mysql.com/doc/mysql-shell/26.7/en/mysql-shell-pluggable-password-store.html)
confirms that password storage is optional.

## Validation evidence

VERIFIED: real non-merging Portage packaging tests were performed on **server01
(amd64)** and **gentoo (native arm64)**. These are packaging builds of upstream
binaries, not compilation of Workbench/Electron/Shell source. `ebuild ... clean
install` ran the unpack, prepare, configure, compile (default/no compilation),
and install phases, placing files only in temporary images.

The final commands used the following environment assignments and paths:

```sh
sudo -n env \
  PORTAGE_TMPDIR=/tmp/codex/dev-db/mysql-workbench-26.7.0/build-amd64 \
  DISTDIR=/tmp/codex/dev-db/mysql-workbench-26.7.0 \
  PORT_LOGDIR=/tmp/codex/dev-db/mysql-workbench-26.7.0/build-amd64/logs \
  ebuild dev-db/mysql-workbench-bin/mysql-workbench-bin-26.7.0.ebuild clean install
```

On `gentoo`, the corresponding command used `build-arm64` and the temporary
`validation-repo/dev-db/mysql-workbench-bin/mysql-workbench-bin-26.7.0.ebuild`,
with `PORTDIR_OVERLAY` set to that temporary repository. No remote Git checkout
was edited. Remote build/runtime/QA logs were copied back to this directory.

Literal final build output includes, on each respective host:

```text
>>> Completed installing dev-db/mysql-workbench-bin-26.7.0 into /tmp/codex/dev-db/mysql-workbench-26.7.0/build-amd64/portage/dev-db/mysql-workbench-bin-26.7.0/image
>>> Completed installing dev-db/mysql-workbench-bin-26.7.0 into /tmp/codex/dev-db/mysql-workbench-26.7.0/build-arm64/portage/dev-db/mysql-workbench-bin-26.7.0/image
```

`validate-runtime.py` performed native ELF resolution, checked root ownership
and mode 4711 of chrome-sandbox, resolved the command symlink, ran
`desktop-file-validate`, and executed the bundled Shell/Python with `--no-defaults`
and temporary configuration/login-file paths. Actual output:

```text
x86_64: inspected 231 non-symlink ELF files; dependency resolution issues: 0
aarch64: inspected 229 non-symlink ELF files; dependency resolution issues: 0
Sandbox root ownership/mode, command symlink and desktop entry: OK
Installed Chromium locales: en-US he ru
Bundled Python imports: OK
```

Both packaged Shell executables identify themselves as **26.7.1**, while the
Workbench package is **26.7.0**; these are distinct upstream component versions.
The exact archives' embedded Shell license and executable output establish this.
Additional direct smoke checks produced:

```text
amd64 GUI backend import: OK
amd64 Electron runtime: 43.2.0
arm64 GUI backend import: OK
arm64 Electron runtime: 43.2.0
```

These used bundled `mysqlsh --no-defaults --disable-plugins --py -e 'import
gui_plugin; ...'` and `ELECTRON_RUN_AS_NODE=1 mysql-workbench -e ...`; no GUI or
database connection was opened.

Both detached ZIP signatures were checked with GnuPG in a temporary keyring
using [Oracle's published signing key](https://repo.mysql.com/RPM-GPG-KEY-mysql-2025).
Both returned:

```text
gpg: Good signature from "MySQL Release Engineering <mysql-build@oss.oracle.com>" [unknown]
```

The fingerprint is BCA43417C3B485DD128EC6D4B7B3B788A8D3785C, matching the current
`::gentoo/sec-keys/openpgp-keys-mysql/openpgp-keys-mysql-20250120.ebuild` declaration.
The normal GnuPG trust-certification warning was present. The initial packaging tests did not enable `verify-sig`. The additional
2026-10-07 validation below exercises the actual eclass unpack path on both hosts.

Final check commands and literal output are in `manifest.log`,
`pkgcheck-glibc.log`, `pkgcheck-full.log`, `bash-syntax.log`, and `diff-check.log`.
`pkgdev manifest --distdir ... dev-db/mysql-workbench-bin` reports
`manifests are up to date`. The target glibc-profile `pkgcheck scan` returns exit
0 with no output. Native arm64's scoped scan also returned exit 0 with no output.
The unfiltered scan reports the unsupported musl-profile dependency/REQUIRED_USE
findings; they were not suppressed or described as a clean scan.

Earlier attempts encountered sandbox cache/ownership restrictions; reruns with
the appropriate access and temporary-cache locations completed. An early smoke
test read host MySQL defaults; it was corrected to use `--no-defaults` and
temporary login/config paths. An inspection-script false positive treating a
shared library's absent ELF interpreter as a missing dependency was corrected,
and both native scans were repeated with the corrected helper.

## Remaining validation

NOT VERIFIED: operation in a physical desktop session, hardware GPU acceleration,
Wayland, password storage/retrieval through a live Secret Service, desktop
notifications, Enterprise Backup, SSH tunnelling, remote-server/TLS scenarios,
and behavior on other profiles/libc implementations. Xvfb GUI operation, local
TCP database authentication, and SQL execution were validated separately on both
architectures as described below. No source compilation was
performed. Optional guidance and license metadata were finalized after the
packaging tests; those edits do not change unpack/prepare/install behavior.

No live-system package merge, installation, upgrade, removal or service change
was performed on any host. No package's pkg_postinst was invoked on a live
system. Architecture keywords are unstable `~amd64 ~arm64` as required locally.


## Additional validation: verify-sig and GUI/database (2026-10-07)

VERIFIED on amd64 (`server01`) and native arm64 (`gentoo`). A directory-permission repair was identified during GUI validation and applied:
`cp -a .` propagates the private WORKDIR mode 0700 to the application directory;
`fperms 0755 /opt/mysql-workbench` now restores normal user access. The report is retained in `docs/mysql-workbench-bin-validation.md`;
raw evidence and harness scripts reside under
`/tmp/codex/dev-db/mysql-workbench-26.7.0` on server01. Remote evidence was copied
back; the remote overlay checkout was not modified.

### Actual verify-sig unpack path

Executed locally:

```sh
sudo -n unshare --mount --propagation private python3 /tmp/codex/dev-db/mysql-workbench-26.7.0/verify-isolated.py /tmp/codex/dev-db/mysql-workbench-26.7.0 /home/leonid/GitHub/leonchik1976/gentoo-overlay/dev-db/mysql-workbench-bin/mysql-workbench-bin-26.7.0.ebuild amd64
```

The same command ran via `ssh gentoo`, using the staged ebuild at
`/tmp/codex/dev-db/mysql-workbench-26.7.0/validation-repo/dev-db/mysql-workbench-bin/mysql-workbench-bin-26.7.0.ebuild`
and the `arm64` argument. The helper bind-mounted the temporary signing-key
directory over `/usr/share/openpgp-keys` **inside the private mount namespace**,
then invoked `ebuild ... clean unpack` with `USE=verify-sig`, and temporary
`DISTDIR`, `PORTAGE_TMPDIR`, and `PORT_LOGDIR`. No signing-key package was installed;
the original ebuild key path and its inherited unpack implementation were used.
This does not test installation/resolution of the key package by Portage.

Both logs contain:

```text
- status: OpenPGPSignatureStatus.GOOD
- valid: True, trusted: True
- primary key: BCA43417C3B485DD128EC6D4B7B3B788A8D3785C
verify-sig unpack exit: 0
```

Evidence: `verify-sig-amd64.log` and
`validation-20261007/verify-sig-arm64.log`. After namespace exit,
`test ! -e /usr/share/openpgp-keys/mysql.asc` succeeded on each host and printed
`Host MySQL signing key remains absent`.

### Native GUI and authenticated SQL workflow

Commands actually run:

```sh
python3 -u /tmp/codex/dev-db/mysql-workbench-26.7.0/gui-environment.py /tmp/codex/dev-db/mysql-workbench-26.7.0/g5 /tmp/codex/dev-db/mysql-workbench-26.7.0/validation-20261007/gui-app-amd64
node /tmp/codex/dev-db/mysql-workbench-26.7.0/gui-test.mjs /tmp/codex/dev-db/mysql-workbench-26.7.0/g5
```

Native arm64 ran both commands via `ssh gentoo`, replacing `g5` with `a5` and
`gui-app-amd64` with `gui-app-arm64`. Each application tree was copied from its
previous non-merging Portage install image. The initial image top-level directory had mode 0700 and required mode 0755 for
unprivileged execution. This exposed the packaging issue fixed above. GUI
validation used the corrected directory mode and otherwise unchanged installed
files; subsequent non-merging packaging tests checked the final ebuild.
The tests used a private Xvfb display, private D-Bus session, fresh Electron
profile, XDG directories and login file, and `--disable-gpu`. Existing HOME was
not reassigned. No `--no-sandbox` launch argument was supplied; upstream itself
launches its renderer with `--no-sandbox`, so this is **not** a claim of renderer
sandbox enforcement.

The harness initialized a distinct temporary MySQL server with
`mysqld --no-defaults --initialize-insecure`, then launched it on an ephemeral
127.0.0.1 TCP port with a private data directory/socket, MySQL X disabled and
binary logging disabled. Initialization returned exit 0 on each architecture.
A synthetic database/table and a dedicated account with SELECT permission were
created using only that server's private socket. The observed server result was:

```text
server01: 8.4.11  32961  /tmp/codex/dev-db/mysql-workbench-26.7.0/g5/db/
gentoo:   8.4.11  50891  /tmp/codex/dev-db/mysql-workbench-26.7.0/a5/db/
```

These server versions are command output, not package dependency requirements.
See [upstream initialization documentation](https://dev.mysql.com/doc/refman/8.4/en/data-directory-initialization.html).

The unmodified GUI was automated through
[Electron remote debugging](https://www.electronjs.org/docs/latest/api/command-line-switches#--remote-debugging-portport)
and [CDP Runtime](https://chromedevtools.github.io/devtools-protocol/tot/Runtime/).
The selectors and main-process native-menu interception follow the exact source
artifact's `gui/electron/tests/e2e/helpers/ElectronWorkbench.ts`. The harness
created a connection through the GUI, opened a SQL script, entered the password,
executed `SELECT id, label FROM codex_validation.probe;`, and asserted the result
in the rendered page. It did not substitute a direct Shell query for GUI testing.

Both architecture logs contain:

```text
GUI welcome and connection browser: OK
GUI connection saved in private profile: OK
GUI authenticated database connection and SQL editor: OK
GUI SQL result: 42 | codex-gui-connection-ok
GUI and database connection validation: OK
```

Screenshots were captured and visually inspected separately:
`g5/gui-result.png` (amd64) and `validation-20261007/gui-result.png` (arm64).
Logs: `gui-amd64.log`, `validation-20261007/gui-arm64.log`.

Initial harness attempts exposed three validation-environment issues: copied
application directory traversal permission, Chromium's Unix socket path-length
limit, and host MySQL defaults initiating a connection as the host user before
the backend command ran. The final harness uses a shorter workspace and the
upstream `ELECTRON_MYSQLSH_RUNTIME_DIR` override with a wrapper that execs the
original bundled Shell with `--no-defaults` **first**, before the GUI arguments.
Appending it using `MYSQLSH_GUI_EXTRA_ARGS` is too late for Shell option parsing
and was rejected. No packaged executable or application source was modified.
The helper is explicitly `login-path` with `--save-passwords=never` and a private
`MYSQL_TEST_LOGIN_FILE`. Live keyring integration remains untested. Startup logs
include portal/PipeWire and private-keyring warnings; successful query evidence
does not establish those integrations work.

Both environment drivers exited 0 after STOP requests and printed:

```text
Temporary GUI, Xvfb and MySQL processes stopped
```

`python3 .../cleanup-gui.py` was run on both hosts, terminating only remaining
session helpers tagged by the private XDG runtime path. Both returned exit 0:

```text
Remaining processes tagged with the private validation runtime: []
```

### musl findings retained

The previously recorded unfiltered `pkgcheck scan` returned exit 0 but reported
these three findings across six unsupported musl profiles:

```text
NonsolvableDepsInDev: >=sys-libs/glibc-2.28
RequiredUseDefaults: failed REQUIRED_USE: elibc_glibc
RequiredUseUnsatisfiableInDev: REQUIRED_USE can't be satisfied due to masked/forced USE flags
```

The full literal output remains in `pkgcheck-full.log`. These findings were not
suppressed. INFERRED: they follow from packaging the upstream glibc binaries,
requiring `elibc_glibc`, and retaining the locally mandated unstable architecture
keywords. NOT VERIFIED: musl operation; no musl support is claimed. The ebuild gained the application directory permission fix; the Manifest did
not change. No live-system
package merge, installation or service configuration change was performed.


### Final permission repair validation

VERIFIED: repeated `ebuild ... clean install` on server01 and gentoo, with the
same temporary DISTDIR/PORTAGE_TMPDIR/PORT_LOGDIR settings described above. Both
returned exit 0; logs are `build-amd64-permissions.log` and
`validation-20261007/build-arm64-permissions.log`. Both contain:

```text
>>> Completed installing dev-db/mysql-workbench-bin-26.7.0 into .../image
```

This is a non-merging binary packaging test, not source compilation or a live
installation. `sudo -n stat -c '%a %U:%G %n'` against the final application
directory and sandbox on each host returned respectively:

```text
755 root:root .../image/opt/mysql-workbench
4711 root:root .../image/opt/mysql-workbench/chrome-sandbox
```

The GUI workflow above exercised exactly these modes. The signature test
preceded this src_install-only repair; its unpack code is unchanged.

Repeated `pkgdev manifest --distdir /tmp/codex/dev-db/mysql-workbench-26.7.0
dev-db/mysql-workbench-bin` returned exit 0 with `manifests are up to date`.
Repeated `pkgcheck scan --cache-dir /tmp/codex/dev-db/mysql-workbench-26.7.0/pkgcheck-cache
--profiles default/linux/amd64/23.0,default/linux/arm64/23.0 dev-db/mysql-workbench-bin`
returned exit 0 with no output. `bash -n` returned exit 0. Per-file
`git diff --no-index --check /dev/null ...` emitted no whitespace diagnostics
(exit 1 denotes the new-file difference). The broader musl findings above remain
applicable and are explicitly retained.
