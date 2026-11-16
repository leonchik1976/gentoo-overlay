# Compass 1.53.2-r1: remove the unnecessary OpenSSL 3 dependency

The source package no longer requests an OpenSSL downgrade. Its build does not
consume system OpenSSL headers or link directly to system OpenSSL. Remove the
OpenSSL atom from `DEPEND` and the OpenSSL runtime alternative from `RDEPEND`.
Keep `DEPEND="virtual/krb5"`, all phase functions, EAPI, and `KEYWORDS="~arm64"`.
No Manifest content changed. No other package was modified.

This does **not** make the package usable on amd64: it deliberately still bundles
only arm64 Electron. On `leonids-pc`, the exact final ebuild's private pretend
resolution schedules no OpenSSL change, but returns 1 because installed
`dev-db/mongodb-compass-bin` is a weak blocker. Temporary keyword acceptance was
necessary even to perform that dependency experiment. No live configuration was
changed, and the blocker was not removed.

## Sources and build paths inspected

The exact [Compass release artifact](https://github.com/mongodb-js/compass/archive/refs/tags/v1.53.2.tar.gz)
and its [release lockfile](https://github.com/mongodb-js/compass/blob/v1.53.2/package-lock.json)
were inspected locally. The lock fixes these relevant inputs:

| Input | Locked version | Treatment in this ebuild |
| --- | --- | --- |
| Electron | 45.0.0 | Bundled upstream arm64 runtime and matching headers |
| mongodb-client-encryption | 7.2.1 | Native addon compiled locally |
| kerberos | 7.0.0 | Native addon compiled locally; loads Kerberos libraries dynamically |
| interruptor | 2.0.1 | Native addon compiled locally |
| os-dns-native | 2.1.3 | Native addon compiled locally |
| @mongodb-js/native-machine-id | 1.0.4 | Native addon compiled locally |
| ssh2 | 1.17.0 | JavaScript crypto fallback; optional native accelerator not built |
| node-gyp | 12.2.0 | Build tool from the lock |

The encryption archive's `package.json` field `mongodb:libmongocrypt` pins
[libmongocrypt 1.20.1](https://registry.npmjs.org/mongodb-client-encryption/7.2.1).
Its [FetchMongoC.cmake](https://github.com/mongodb/libmongocrypt/blob/1.20.1/cmake/FetchMongoC.cmake)
pins the bundled C driver to 2.3.3. Both exact archives were inspected.

* [Encryption binding.gyp](https://github.com/mongodb-js/mongodb-client-encryption/blob/v7.2.1/binding.gyp)
  sets `MONGOCRYPT_AVOID_OPENSSL_CRYPTO` when `built_with_electron==1`; the ebuild
  already passes that argument. Its compiled `openssl-crypto.cc` therefore uses
  the non-OpenSSL branch. Its ordinary native OpenSSL hook implementation does
  contain a `[3.0.0, 4.0.0)` runtime check, but that branch is **not used here**.
* libmongocrypt's [CMakeLists.txt](https://github.com/mongodb/libmongocrypt/blob/1.20.1/CMakeLists.txt)
  selects `MONGOCRYPT_CRYPTO=none` with the existing `DISABLE_NATIVE_CRYPTO=ON`.
  The corresponding [kms-message build](https://github.com/mongodb/libmongocrypt/blob/1.20.1/kms-message/CMakeLists.txt)
  also disables native crypto. The addon supplies Node crypto callbacks instead.
* The other four rebuilt addons have no direct OpenSSL link requirement. The
  actual dependency records contain no included OpenSSL headers. node-gyp's
  generic `-I.../deps/openssl/...` arguments are include search paths, not evidence
  of using those headers. Compiler and linker command records were retained.
* C-driver configuration detects the installed OpenSSL 4, but only its libbson
  targets are built for this package. The compiler dependency records for those
  targets contain no OpenSSL headers either.
* No system `openssl` command requirement was found in the ebuild phases or
  Compass scripts they invoke. Upstream install scripts are disabled during
  `npm ci`; native addons are rebuilt explicitly. The `openssl` command used
  below to create a test certificate belongs to the validation harness only.
* The final image has six Electron ELF files and five locally built addon ELF
  files. No other prebuilt npm addon is in the installed runtime closure.

Official packaging references consulted: [PMS 9](https://projects.gentoo.org/pms/9/pms.html),
[Devmanual dependencies](https://devmanual.gentoo.org/general-concepts/dependencies/),
and [Devmanual subslots](https://devmanual.gentoo.org/general-concepts/slotting/).
No OpenSSL `:=` binding is appropriate without a direct OpenSSL ABI dependency.
Transitive system-library dependencies belong to their owning packages.
The inherited eclasses' local implementations were inspected; EAPI is unchanged.

Prior art: `::gentoo/dev-db/mongodb-compass-bin/mongodb-compass-bin-1.53.2.ebuild`
has an OpenSSL 3 runtime alternative, but packages upstream application binaries,
not this rebuilt native runtime. Its dependency is not evidence that this source
build needs OpenSSL 3. The local `::gentoo` and `::guru` searches found no matching
source ebuild. Indexed searches of bugs.gentoo.org for Compass/OpenSSL did not
return a relevant bug; direct access was blocked by robots.txt. Bug absence is
not established.

## VERIFIED: native arm64 build and staged runtime on gentoo

Workspace (all helper scripts and temporary artifacts reside here):

```text
/tmp/codex/dev-db/mongodb-compass-1.53.2/openssl-audit-EgK8Vv
```

Host `gentoo` reported `aarch64` and:

```text
OpenSSL 4.1.0 23 Oct 2026 (Library: OpenSSL 4.1.0 23 Oct 2026)
```

The private candidate removed the build pin before building. After the complete
image audit, the final ebuild also removed the unused runtime alternative and
added explanatory comments. All build functions are byte-identical between the
built candidate and final ebuild; both snapshots and their comparison are retained.

Actual non-merging build command, with output redirected to `build-retry.log`:

```sh
PORTAGE_CONFIGROOT=/tmp/codex/dev-db/mongodb-compass-1.53.2/openssl-audit-EgK8Vv/config \
  unshare --user --map-auto --map-root-user ebuild \
  /tmp/codex/dev-db/mongodb-compass-1.53.2/openssl-audit-EgK8Vv/repo/dev-db/mongodb-compass/mongodb-compass-1.53.2-r1.ebuild \
  unpack prepare configure compile install
```

This command returned 0 and printed:

```text
>>> Completed installing dev-db/mongodb-compass-1.53.2-r1 into /tmp/codex/dev-db/mongodb-compass-1.53.2/openssl-audit-EgK8Vv/build/portage/dev-db/mongodb-compass-1.53.2-r1/image
```

This is installation **into the temporary image**, not a live installation.
The first attempt encountered namespace/fetch permission errors. The retry used
private namespace-compatible FEATURES, retained `network-sandbox`, disabled
ccache, and used only existing Manifest-checked distfiles. npm remained offline.
The build retains npm/peer/compiler/bundler warnings; it is not warning-free.

`audit.py` invoked `readelf -h -d` on every staged ELF and inspected generated
compiler dependency files. `staged-audit.json` records paths, architecture,
SHA256 values, all `DT_NEEDED` entries, OpenSSL SONAME strings, included headers,
and 23 node-gyp compiler/linker command records. Literal audit output includes:

```text
Staged ELF files: 11
Recorded node-gyp compiler/linker commands: 23
```

All 11 are AArch64. Every `needed` list excludes `libssl` and `libcrypto`, every
`openssl_soname_strings` list is empty, and every `included_openssl_headers` list
is empty. In particular, `mongocrypt.node` needs only libstdc++, libm, libgcc_s,
libc and the platform loader.

The actual staged smoke command was:

```sh
ELECTRON_RUN_AS_NODE=1 unshare --user --map-auto --map-root-user timeout 30 \
  /tmp/codex/dev-db/mongodb-compass-1.53.2/openssl-audit-EgK8Vv/build/portage/dev-db/mongodb-compass-1.53.2-r1/image/opt/mongodb-compass/mongodb-compass \
  /tmp/codex/dev-db/mongodb-compass-1.53.2/openssl-audit-EgK8Vv/smoke.cjs \
  /tmp/codex/dev-db/mongodb-compass-1.53.2/openssl-audit-EgK8Vv/build/portage/dev-db/mongodb-compass-1.53.2-r1/image/opt/mongodb-compass/resources/app
```

It returned 0. `smoke-staged.log` includes:

```text
Native addons loaded: interruptor, kerberos, os-dns-native, @mongodb-js/native-machine-id, mongodb-client-encryption
Local key generation and authenticated encryption/decryption: PASS; cryptoHooksProvider=js
KMS native request/signing + driver TLS + certificate verification + native response parsing: PASS; TLSv1.3
KMS untrusted certificate rejected: PASS
Loaded system OpenSSL libraries: [ '/usr/lib64/libcrypto.so.4', '/usr/lib64/libssl.so.4' ]
SMOKE PASS
```

The harness uses an in-memory key vault, fake AWS credentials, and a loopback TLS
server with a temporary trusted certificate. It exercises native local key
generation, authenticated encryption/decryption, native AWS request signing,
the locked driver's real KMS TLS transport, native parsing of a controlled KMS
error response, and a negative certificate-trust test. It contacts no real AWS
or MongoDB service. `/proc/self/maps` is retained in `smoke-library-maps.log`.
System OpenSSL 4 is loaded transitively; no OpenSSL 3 library is mapped.

Earlier harness attempts and logs are retained. They exposed an unrelated locked
driver timeout path: enabling `timeoutMS` waits for the timeout promise even
after a response. The final test uses the default timeout behavior and external
`timeout 30`; it does not establish correctness of the `timeoutMS` path. The
loopback IP endpoint also emits Node's TLS ServerName deprecation warning.

## VERIFIED: dependency resolution on amd64 leonids-pc

Remote workspace:
`/tmp/codex/dev-db/mongodb-compass-1.53.2/openssl-audit-kukGzh`.
Only private staged files were written; the remote overlay checkout was untouched.
The host reported `x86_64` and the same OpenSSL 4.1.0 version string.

A private configuration accepts `~amd64 ~arm64` solely for this experiment. The
exact final ebuild was copied from this checkout and tested with:

```sh
PORTAGE_CONFIGROOT=/tmp/codex/dev-db/mongodb-compass-1.53.2/openssl-audit-kukGzh/config \
  emerge --pretend --verbose --oneshot --autounmask=n \
  =dev-db/mongodb-compass-1.53.2-r1::compass-openssl-audit
```

`pretend-final.log` schedules only Compass and reports:

```text
Total: 1 package (1 new), Size of downloads: 966,112 KiB
Conflict: 1 block (1 unsatisfied)
```

The exit status is 1, due to installed `mongodb-compass-bin`, not an OpenSSL
requirement. No OpenSSL replacement is scheduled, and `openssl version` still
reports OpenSSL 4.1.0. The original dependency's comparison log contains
`dev-libs/openssl:0/3 required by ...mongodb-compass-1.53.2-r1...` and fails amid
host dependency conflicts. Those unrelated installed-package constraints were
not altered. Logs were copied back to `leonids-pc-results/` on `gentoo`.

## VERIFIED: scoped packaging checks; remaining limits

Actual commands on `gentoo`:

```sh
pkgdev manifest -d /tmp/codex/dev-db/mongodb-compass-1.53.2/openssl-audit-EgK8Vv/distfiles dev-db/mongodb-compass
pkgcheck scan --cache-dir /tmp/codex/dev-db/mongodb-compass-1.53.2/openssl-audit-EgK8Vv/pkgcheck-cache --cache=-git dev-db/mongodb-compass
bash -n dev-db/mongodb-compass/mongodb-compass-1.53.2-r1.ebuild
git diff --check
```

Manifest output is `manifests are up to date`; its content is unchanged.
Syntax and whitespace checks each returned 0 with empty stdout/stderr.
The scan printed the same two findings as the pre-existing remote QA log:

```text
dev-db/mongodb-compass
  RequiredUseDefaults: version 1.53.2-r1: profile: 'default/linux/arm64/23.0/musl' (3 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 1.53.2-r1: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~arm64) dev profile (default/linux/arm64/23.0/musl) (3 total)
```

Final ebuild SHA256:
`2907d5b176c23a857125e469596060adbdbbe226aa5d3b613619cbb976f34622`.

**INFERRED:** the direct OpenSSL dependency is unnecessary for this unchanged
build configuration; the measured compiled inputs, staged linkage and tested
crypto/TLS paths support removing it. No private OpenSSL 3 development tree,
header/library mixing, SONAME rewriting, or upstream source patch is needed.

**NOT VERIFIED:** amd64 build/runtime (excluded by the retained arm64-only
package), full GUI operation, real MongoDB/AWS integration, Kerberos
authentication, and all application TLS configurations. Arm64 on `gentoo` has an
actual offline staged build and crypto/TLS smoke test; amd64 on `leonids-pc` has
pretend dependency validation only. A normal amd64 emerge remains unavailable
under the user's explicit arm64-only constraint, independently of the resolved
OpenSSL pin. No live install, merge, qmerge, package removal, host configuration
change, branch, commit, push, or pull request was performed.
