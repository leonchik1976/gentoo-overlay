# Miabi CLI binary package audit

Investigated 2026-11-17. Scope: `app-admin/miabi-cli-bin-0.24.1`, the separate
API client and host stack manager, not the Miabi control-plane server.

## Sources and packaging decision

- Exact release: https://github.com/miabi-io/cli/releases/tag/v0.24.1
- Release API: https://api.github.com/repos/miabi-io/cli/releases/tags/v0.24.1
- Tagged source: https://github.com/miabi-io/cli/tree/v0.24.1
  (commit `13907c1d597380659b4e0a1c21bfbd4f8ae8cae8`).
- Build configuration: https://github.com/miabi-io/cli/blob/v0.24.1/.goreleaser.yaml
- Dependency declarations: https://github.com/miabi-io/cli/blob/v0.24.1/go.mod
- CLI license application: https://github.com/miabi-io/cli/blob/v0.24.1/main.go
- Installation requirements: https://docs.miabi.io/docs/getting-started/installation/
- Gentoo license guidance: https://devmanual.gentoo.org/general-concepts/licenses/
- Gentoo optional runtime dependencies, PG0001:
  https://projects.gentoo.org/qa/policy-guide/dependencies.html
- PMS: https://projects.gentoo.org/pms/9/pms.html
- EAPI guide: https://devmanual.gentoo.org/ebuild-writing/eapi/
- Eclass implementation read: `/var/db/repos/gentoo/eclass/shell-completion.eclass`
  (`SUPPORTED_EAPIS: 7 8 9`) and `go-module.eclass` (dependency tarball guidance).
- Prior practice inspected: `::gentoo/app-admin/awscli-bin/awscli-bin-2.36.34.ebuild`,
  `::guru/app-admin/terragrunt-bin/terragrunt-bin-0.96.1.ebuild`, and this overlay's
  Temporal and Argo CD CLI binary ebuilds. These are examples, not policy or
  authority for Miabi's licenses or dependency versions.

VERIFIED: local Portage reported `[(9, True), (10, False), (11, False)]`
for `portage.eapi_is_supported`. PMS 9 and the current eclass support EAPI 9;
no newer usable EAPI was identified. The ebuild uses EAPI 9.

A source build would require preparing and hosting a non-upstream Go dependency
tarball (the tagged archive has no vendor directory). The binary package follows
the requested personal-overlay preference and uses upstream archives for both
architectures. No Go compiler is required to package these binaries.

## Dependencies and USE flags

The ebuild declares:

- `RDEPEND="app-misc/ca-certificates"`: HTTPS trust for remote API and release/image
  operations. The binary uses Go's TLS stack and the host trust store; no dynamic
  libc or OpenSSL dependency was found.
- `BDEPEND="app-arch/xz-utils"`: decompress the bundled third-party license notices
  during `src_prepare`. Notices are compressed in FILESDIR to avoid unnecessarily
  large repository resources, then installed as ordinary documentation.
- No Go module packages as Portage runtime dependencies: those libraries are
  statically linked into the upstream executable.

No USE flags are proposed. In particular, a Docker flag would only pull in an
independent optional runtime service; it would not change the installed binary.
The CLI remains functional as a remote API client without Docker, so such a flag
would conflict with PG0001. The global/local flag registries do not need a new
entry because no flag is introduced.

For local stack management, upstream requires rootful Docker Engine 25 or newer.
The CLI talks to its API directly; neither the docker CLI nor Compose is needed
for this path. Users selecting local management should world-select
`>=app-containers/docker-25` themselves. PostgreSQL, Redis and Goma are provisioned
as containers by the user's explicit setup operation, not Portage dependencies.
The package does not provision containers, start daemons, create stack secrets,
or run upgrades in an ebuild phase.

Browser-based login may invoke `xdg-open`; config editing invokes the user's
editor. These optional conveniences do not justify mandatory GUI/editor
packages or convenience USE flags. Sources:
https://github.com/miabi-io/cli/blob/v0.24.1/internal/cmd/auth.go and
https://github.com/miabi-io/cli/blob/v0.24.1/internal/cmd/configs.go .

## License audit

Result: `LICENSE="AGPL-3+ Apache-2.0 BSD MIT"`.

VERIFIED: the CLI's per-file SPDX markers apply `AGPL-3.0-or-later`, not merely
AGPL-3.0-only. Linked module versions were read with `go version -m` from both
upstream binaries. `lichen` scanned 32 amd64 dependency modules and downloaded
their exact source archives into the package-specific temporary workspace.
Its automatic classifications were checked against the actual license texts.
The arm64 binary records the same dependency modules except `golang.org/x/sys`;
the union has the same license set.

Manual corrections to automated results:

1. `github.com/miabi-io/miabi` is classified AGPL at module root by lichen, but
   the CLI imports only its Apache-2.0 `pkg/` subtree. `go list -deps -json .`
   resolved these seven packages: `pkg/stack/docker`, `pkg/bundled`,
   `pkg/stack/saferollout`, `pkg/stack/selfcontainer`, `pkg/stack`, `pkg/sealed`,
   and `pkg/stack/stackcmd`. No Miabi `internal/` or Enterprise imports were found.
   Embedded `pkg/stack/assets/goma.yml` and `pkg/stack/document.go` are also
   covered by this subtree's license. Sources:
   https://github.com/miabi-io/miabi/blob/v1.10.28/LICENSING.md and
   https://github.com/miabi-io/miabi/blob/v1.10.28/pkg/LICENSE .
2. `github.com/opencontainers/go-digest` has a CC license for its README and
   contribution documentation. Those files are neither linked nor installed;
   its linked Go code is Apache-2.0. `LICENSE.docs` is consequently excluded from
   the installed notices and CC-BY-SA is excluded from the ebuild LICENSE.
   Source: https://github.com/opencontainers/go-digest/tree/v1.0.0 .
3. OpenTelemetry license files include both Apache-2.0 and BSD notices; both
   remain in the installed notices and LICENSE expression. Gentoo's `BSD`
   identifier represents the three-clause BSD license here.
4. yaml.v3's license applies MIT to its libyaml-derived files and Apache-2.0 to
   the remaining files. Both apply, rather than being alternative choices.
5. The Go standard-library license was fetched from the exact upstream toolchain
   tag: https://raw.githubusercontent.com/golang/go/go1.27.3/LICENSE .

The FILESDIR notice resource includes dependency LICENSE texts and top-level
NOTICE files, plus the Go standard-library license. The CLI's own LICENSE is
installed separately from the upstream binary archive. It is intentionally not
correct to describe the CLI as containing the control plane's Enterprise code
merely because both use a single Go module dependency.

INFERRED limit: both upstream executables record `vcs.modified=true` and
`v0.24.1+dirty`. The recorded revision matches the tag and module versions match
the declarations, but the exact uncommitted release-worktree changes cannot be
reconstructed from that metadata. No bit-for-bit reproducible source rebuild
was performed. A binary license audit is not proof of source/binary identity.

Exact dependency source archives and license classifications (before Gentoo
identifier normalization):

| Module | Version | Applicable license(s) | Exact source |
| --- | --- | --- | --- |
| `filippo.io/age` | `v1.3.2` | BSD-3-Clause | [source archive](https://proxy.golang.org/filippo.io/age/@v/v1.3.2.zip) |
| `filippo.io/hpke` | `v0.4.0` | BSD-3-Clause | [source archive](https://proxy.golang.org/filippo.io/hpke/@v/v0.4.0.zip) |
| `github.com/cespare/xxhash/v2` | `v2.3.0` | MIT | [source archive](https://proxy.golang.org/github.com/cespare/xxhash/v2/@v/v2.3.0.zip) |
| `github.com/containerd/errdefs` | `v1.0.0` | Apache-2.0 | [source archive](https://proxy.golang.org/github.com/containerd/errdefs/@v/v1.0.0.zip) |
| `github.com/containerd/errdefs/pkg` | `v0.3.0` | Apache-2.0 | [source archive](https://proxy.golang.org/github.com/containerd/errdefs/pkg/@v/v0.3.0.zip) |
| `github.com/distribution/reference` | `v0.6.0` | Apache-2.0 | [source archive](https://proxy.golang.org/github.com/distribution/reference/@v/v0.6.0.zip) |
| `github.com/docker/go-connections` | `v0.8.2` | Apache-2.0 | [source archive](https://proxy.golang.org/github.com/docker/go-connections/@v/v0.8.2.zip) |
| `github.com/docker/go-units` | `v0.5.0` | Apache-2.0 | [source archive](https://proxy.golang.org/github.com/docker/go-units/@v/v0.5.0.zip) |
| `github.com/felixge/httpsnoop` | `v1.1.0` | MIT | [source archive](https://proxy.golang.org/github.com/felixge/httpsnoop/@v/v1.1.0.zip) |
| `github.com/go-logr/logr` | `v1.4.4` | Apache-2.0 | [source archive](https://proxy.golang.org/github.com/go-logr/logr/@v/v1.4.4.zip) |
| `github.com/go-logr/stdr` | `v1.2.2` | Apache-2.0 | [source archive](https://proxy.golang.org/github.com/go-logr/stdr/@v/v1.2.2.zip) |
| `github.com/jkaninda/logger` | `v0.0.5` | MIT | [source archive](https://proxy.golang.org/github.com/jkaninda/logger/@v/v0.0.5.zip) |
| `github.com/jkaninda/okapi` | `v1.2.1` | MIT | [source archive](https://proxy.golang.org/github.com/jkaninda/okapi/@v/v1.2.1.zip) |
| `github.com/miabi-io/miabi` | `v1.10.28` | Apache-2.0 | [source archive](https://proxy.golang.org/github.com/miabi-io/miabi/@v/v1.10.28.zip) |
| `github.com/moby/docker-image-spec` | `v1.3.1` | Apache-2.0 | [source archive](https://proxy.golang.org/github.com/moby/docker-image-spec/@v/v1.3.1.zip) |
| `github.com/moby/moby/api` | `v1.56.1` | Apache-2.0 | [source archive](https://proxy.golang.org/github.com/moby/moby/api/@v/v1.56.1.zip) |
| `github.com/moby/moby/client` | `v0.6.2` | Apache-2.0 | [source archive](https://proxy.golang.org/github.com/moby/moby/client/@v/v0.6.2.zip) |
| `github.com/opencontainers/go-digest` | `v1.0.0` | Apache-2.0 | [source archive](https://proxy.golang.org/github.com/opencontainers/go-digest/@v/v1.0.0.zip) |
| `github.com/opencontainers/image-spec` | `v1.1.1` | Apache-2.0 | [source archive](https://proxy.golang.org/github.com/opencontainers/image-spec/@v/v1.1.1.zip) |
| `github.com/spf13/cobra` | `v1.10.2` | Apache-2.0 | [source archive](https://proxy.golang.org/github.com/spf13/cobra/@v/v1.10.2.zip) |
| `github.com/spf13/pflag` | `v1.1.0` | BSD-3-Clause | [source archive](https://proxy.golang.org/github.com/spf13/pflag/@v/v1.1.0.zip) |
| `go.opentelemetry.io/auto/sdk` | `v1.2.1` | Apache-2.0 | [source archive](https://proxy.golang.org/go.opentelemetry.io/auto/sdk/@v/v1.2.1.zip) |
| `go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp` | `v0.72.0` | Apache-2.0, BSD-3-Clause | [source archive](https://proxy.golang.org/go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp/@v/v0.72.0.zip) |
| `go.opentelemetry.io/otel` | `v1.47.0` | Apache-2.0, BSD-3-Clause | [source archive](https://proxy.golang.org/go.opentelemetry.io/otel/@v/v1.47.0.zip) |
| `go.opentelemetry.io/otel/log` | `v1.47.0` | Apache-2.0, BSD-3-Clause | [source archive](https://proxy.golang.org/go.opentelemetry.io/otel/log/@v/v1.47.0.zip) |
| `go.opentelemetry.io/otel/metric` | `v1.47.0` | Apache-2.0, BSD-3-Clause | [source archive](https://proxy.golang.org/go.opentelemetry.io/otel/metric/@v/v1.47.0.zip) |
| `go.opentelemetry.io/otel/trace` | `v1.47.0` | Apache-2.0, BSD-3-Clause | [source archive](https://proxy.golang.org/go.opentelemetry.io/otel/trace/@v/v1.47.0.zip) |
| `golang.org/x/crypto` | `v0.58.1-0.20261009181718-2f1f834330b2` | BSD-3-Clause | [source archive](https://proxy.golang.org/golang.org/x/crypto/@v/v0.58.1-0.20261009181718-2f1f834330b2.zip) |
| `golang.org/x/mod` | `v0.43.0` | BSD-3-Clause | [source archive](https://proxy.golang.org/golang.org/x/mod/@v/v0.43.0.zip) |
| `golang.org/x/sys` | `v0.49.0` | BSD-3-Clause | [source archive](https://proxy.golang.org/golang.org/x/sys/@v/v0.49.0.zip) |
| `gopkg.in/natefinch/lumberjack.v2` | `v2.2.1` | MIT | [source archive](https://proxy.golang.org/gopkg.in/natefinch/lumberjack.v2/@v/v2.2.1.zip) |
| `gopkg.in/yaml.v3` | `v3.0.1` | Apache-2.0, MIT | [source archive](https://proxy.golang.org/gopkg.in/yaml.v3/@v/v3.0.1.zip) |

## Initial investigation and checks

`git status --short` produced no output before editing. Local `rg --files`
searches found no existing Miabi package in ::gentoo or ::guru. Bugzilla query
`curl -fsSL 'https://bugs.gentoo.org/rest/bug?quicksearch=miabi'` returned
`{"bugs":[]}`; this establishes the query result, not absence of every possible
relevant bug under another name.

Archive checksum evidence (`sha256sum amd64.tar.gz arm64.tar.gz`, compared with
upstream https://github.com/miabi-io/cli/releases/download/v0.24.1/checksums.txt):

```text
855e20fde902a690c73962ad841ac1b965e5fc8e79c56eb0a2b98f548922c4c3  amd64.tar.gz
859727125d2b6864b7a3794186322ed29453b2b67442000ec1cc2472e2746728  arm64.tar.gz
```

`file binary/miabi` reported `statically linked` and `stripped`.
`readelf -d` on both architectures printed:

```text
There is no dynamic section in this file.
```

No binary editing or QA suppression was needed. `QA_PREBUILT` identifies the
single upstream executable; it is not an assertion of architecture validation.
The initial uncompressed license resource triggered SizeViolation and
TotalSizeViolation. Compressing the resource to 6.8 KiB addressed their cause.

## Final validation evidence

VERIFIED on amd64 (`leonids-pc`) and native arm64 (`gentoo`): the ebuild's
unpack, prepare, configure, compile, test and install-to-image phases returned
exit status 0. For this `-bin` package, compile generates shell completions;
it does **not** compile the application from source. No source build is claimed.
Both staged executables were also executed after Portage's stripping step.

Commands used on leonids-pc (workspace abbreviated as `$audit` below):

```bash
audit=/tmp/codex/app-admin/miabi-cli-bin-0.24.1/audit.rgIMPM
pkgdev manifest -d "$audit/distfiles" app-admin/miabi-cli-bin
env XDG_CACHE_HOME="$audit/cache" pkgcheck scan app-admin/miabi-cli-bin
bash -n app-admin/miabi-cli-bin/miabi-cli-bin-0.24.1.ebuild
git diff --check
env PORTAGE_TMPDIR="$audit/build-final" DISTDIR="$audit/distfiles" \
    PORT_LOGDIR="$audit/logs" PORTAGE_INST_UID=1000 PORTAGE_INST_GID=1000 \
    FEATURES='test -userpriv -usersandbox -buildpkg -ccache -distlocks' \
    ebuild app-admin/miabi-cli-bin/miabi-cli-bin-0.24.1.ebuild test install
"$audit/build-final/portage/app-admin/miabi-cli-bin-0.24.1/image/usr/bin/miabi" --version
```

`pkgdev manifest` initially printed:

```text
 * generating manifest: app-admin/miabi-cli-bin::local
```

The subsequent run printed:

```text
manifests are up to date
```

The final `pkgcheck scan` emitted no findings; the captured status was:

```text
pkgcheck exit status: 0
```

The first sandboxed scan could not write the default user cache; setting
XDG_CACHE_HOME to the package workspace resolved that. The first sandboxed
Portage invocation could not change its temporary directory group, so validation
ran outside that filesystem sandbox. An initial install-to-image invocation
without PORTAGE_INST_UID/GID failed to chown the staged executable to root.
The final invocation sets those test-environment variables to the invoking
user/group. The ebuild itself has no ownership override; normal Portage use
retains its standard installation ownership. No live installation was attempted.

The arm64 command, run over SSH with `-F /dev/null -o BatchMode=yes`, was:

```bash
cd /tmp/codex/app-admin/miabi-cli-bin-0.24.1/validation.kctK3h
env PORTAGE_TMPDIR="$PWD/build" DISTDIR="$PWD/distfiles" \
    PORT_LOGDIR="$PWD/logs" PORTAGE_INST_UID=1000 PORTAGE_INST_GID=1000 \
    FEATURES='test -userpriv -usersandbox -buildpkg -ccache -distlocks' \
    ebuild repo/app-admin/miabi-cli-bin/miabi-cli-bin-0.24.1.ebuild test install
build/portage/app-admin/miabi-cli-bin-0.24.1/image/usr/bin/miabi --version
cd repo
env XDG_CACHE_HOME=/tmp/codex/app-admin/miabi-cli-bin-0.24.1/validation.kctK3h/cache \
    pkgcheck scan app-admin/miabi-cli-bin
```

This used a temporary validation repository and copied distfiles; no remote
Git checkout was edited. The arm64 scan emitted no findings and returned 0.
The logs and staged image were copied back to
`$audit/arm64-results/` on leonids-pc.

Literal relevant output shared by both architecture logs:

```text
>>> Source prepared.
>>> Source configured.
>>> Source compiled.
>>> Test phase: app-admin/miabi-cli-bin-0.24.1
miabi version 0.24.1
>>> Completed testing app-admin/miabi-cli-bin-0.24.1
```

Literal installation completion lines:

```text
>>> Completed installing app-admin/miabi-cli-bin-0.24.1 into /tmp/codex/app-admin/miabi-cli-bin-0.24.1/audit.rgIMPM/build-final/portage/app-admin/miabi-cli-bin-0.24.1/image
>>> Completed installing app-admin/miabi-cli-bin-0.24.1 into /tmp/codex/app-admin/miabi-cli-bin-0.24.1/validation.kctK3h/build/portage/app-admin/miabi-cli-bin-0.24.1/image
```

Post-strip execution on each native host printed:

```text
miabi version 0.24.1
```

A Python comparison of both staged images with the FILESDIR notice resource
printed:

```text
amd64 and arm64 staged images: license notices match FILESDIR; all three completion files are nonempty
```

Additional audit commands actually run include `go version -m` for each binary,
`readelf -h` / `readelf -d`, `sha256sum`, `lichen --json`, and
`go list -deps -json .`. The latter two used package-local GOMODCACHE/GOCACHE
(and GOPATH for go list). Source-file SPDX inspection found only
`AGPL-3.0-or-later` and `Apache-2.0` explicit identifiers in selected non-standard
Go files; the additional BSD/MIT licenses come from license texts in dependencies
which do not uniformly use SPDX headers.

## Remaining validation

NOT VERIFIED: authenticated API operations, browser login, editor integration,
Docker stack provisioning, upgrades, backup/restore, or a running control-plane
server. These require an explicitly configured service environment and are left
for the administrator. No live-system merge, installation, service start, Docker
operation or container image download was performed on either host.

Files added: ebuild, metadata.xml, the two-distfile Manifest, compressed
third-party license notices, and this audit. No pre-existing package was changed.
