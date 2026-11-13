# BuildKit and calicoctl packaging — 2026-11-13

## Changes and rationale

Added `app-containers/buildkit-0.35.0` (source) and
`net-misc/calicoctl-bin-3.33.0` (upstream binaries), each with metadata.xml and
Manifest. Added BuildKit's OpenRC init script and Calico's compressed linked-module
license notices in their respective `files/` directories. Both use
`KEYWORDS="~amd64 ~arm64"` and the requested maintainer identity.

BuildKit's exact release archive contains `vendor/`; its Dockerfile supplies the
pure-Go build tags used here. The ebuild builds buildctl and buildkitd directly,
without Docker or dependency downloads, and installs OpenRC and upstream systemd
service/socket files. The service path is adjusted to /usr/bin. Its default OCI
worker uses app-containers/runc; the optional containerd backend does not require
an extra convenience USE flag. No new USE flags were added.

Calico's source archive does not contain vendored Go dependencies. Under this
overlay's dependency-tarball rule it is packaged as -bin. The source archive is
also fetched for license documentation. The installed executable is calicoctl.
Choose the release matching the cluster; cluster operations were not exercised.

## Sources and classification

- Release versions/artifacts: [BuildKit release API](https://api.github.com/repos/moby/buildkit/releases/latest)
  returned v0.35.0; [Calico release API](https://api.github.com/repos/projectcalico/calico/releases/latest)
  returned v3.33.0. Exact releases: [BuildKit](https://github.com/moby/buildkit/releases/tag/v0.35.0),
  [Calico](https://github.com/projectcalico/calico/releases/tag/v3.33.0).
- Exact inspected source archives:
  https://github.com/moby/buildkit/archive/refs/tags/v0.35.0.tar.gz and
  https://github.com/projectcalico/calico/archive/refs/tags/v3.33.0.tar.gz.
- Upstream requirements: [BuildKit go.mod](https://github.com/moby/buildkit/blob/v0.35.0/go.mod)
  specifies `go 1.26.8`; this determines the appended Go build dependency.
  [Dockerfile](https://github.com/moby/buildkit/blob/v0.35.0/Dockerfile) determines
  build tags; [README](https://github.com/moby/buildkit/blob/v0.35.0/README.md)
  documents the OCI and containerd workers and runtime requirements.
- Upstream binary installation/configuration guidance:
  https://docs.tigera.io/calico/latest/operations/calicoctl/install.
  The certificate dependency supplies the system trust pool for HTTPS access.
- Licenses were inspected from those exact source archives, rather than inferred
  from another overlay. BuildKit's LICENSE and vendor license texts establish
  Apache-2.0, BSD, BSD-2, ISC, MIT and MPL-2.0. Examples include
  vendor/github.com/pkg/errors/LICENSE (BSD-2),
  vendor/github.com/hashicorp/go-cleanhttp/LICENSE (MPL-2.0), and
  vendor/github.com/cyphar/filepath-securejoin/LICENSE.MPL-2.0. Vendor license
  and NOTICE files are installed with their directory structure; separate
  vendor documentation licenses ending in `.docs` are excluded.
- Calico's [LICENSE.md](https://github.com/projectcalico/calico/blob/v3.33.0/LICENSE.md)
  establishes Apache-2.0. `go version -m` plus lichen inspected the actual binary's
  linked dependencies. Their texts establish Apache-2.0, BSD, BSD-2, ISC and MIT.
  amd64 and arm64 binary dependency lists were compared and are identical.
  The complete module license texts are installed from the compressed resource.
  Lichen exited 1 because github.com/termie/go-shutil has a nonstandard license
  statement; manual inspection of its exact module LICENSE explicitly offers
  MIT as a fallback:
  https://github.com/termie/go-shutil/blob/bcacb06fecae/LICENSE.
  Lichen also labeled sigs.k8s.io/yaml's combined LICENSE as ImageMagick; direct
  inspection shows MIT, BSD-3-Clause and Apache-2.0 texts, so that automated label
  was not adopted. Source: https://github.com/kubernetes-sigs/yaml/blob/v1.6.0/LICENSE.
- PMS semantics: https://projects.gentoo.org/pms/9/pms.html.
  The [PMS index](https://projects.gentoo.org/pms/) lists EAPI 9 as the latest.
  General packaging guidance: https://devmanual.gentoo.org/ebuild-writing/.
- Eclass contracts inspected locally in `/var/db/repos/gentoo/eclass/`:
  go-module.eclass and go-env.eclass support 7, 8, 9; systemd.eclass supports
  only 7, 8. Therefore BuildKit uses EAPI 8 and Calico uses EAPI 9.
  go-module documents offline vendoring and accounting for statically linked
  dependency licenses. BDEPEND is appended to preserve inherited dependencies.
- Prior practice: searched ::gentoo and ::guru for both package names; no
  existing packages found. Inspected ::gentoo/app-containers/containerd/
  containerd-2.4.2.ebuild and docker-compose/docker-compose-5.7.0.ebuild as
  examples only. These examples are not policy.
- Gentoo bug REST queries for each name returned literal `{"bugs":[]}`:
  https://bugs.gentoo.org/rest/bug?quicksearch=buildkit&include_fields=id,summary,status,resolution
  and https://bugs.gentoo.org/rest/bug?quicksearch=calicoctl&include_fields=id,summary,status,resolution.

## VERIFIED — commands and literal evidence

Initial `git status --short` produced no output. Investigation used `find`, `rg`,
`tar`, upstream `curl` downloads, `go version -m`, `lichen --json`, and direct
license-text inspection. Temporary files remain under the two package workspaces:

- /tmp/codex/app-containers/buildkit-0.35.0
- /tmp/codex/net-misc/calicoctl-3.33.0

Manifest commands:

```sh
pkgdev manifest -d /tmp/codex/app-containers/buildkit-0.35.0/distfiles app-containers/buildkit
pkgdev manifest -d /tmp/codex/net-misc/calicoctl-3.33.0/distfiles net-misc/calicoctl-bin
```

Initial generation reported `* generating manifest:` for each package. The final
repeat reported `manifests are up to date` for each. Both new Manifests are
repository changes. An earlier attempt with only DISTDIR in the environment was
ineffective for pkgdev; the documented -d option above was used instead.

```sh
XDG_CACHE_HOME=/tmp/codex/app-containers/buildkit-0.35.0/cache \
  pkgcheck scan app-containers/buildkit net-misc/calicoctl-bin
```

Final output: no findings; separately printed `pkgcheck exit: 0`.
The initial scan identified an indirect go-env inherit and long URI lines; both
were corrected. `bash -n` on the ebuilds and `sh -n` on the OpenRC script produced
no output. `git diff --check` produced no output.

Both hosts ran `ebuild <package.ebuild> clean unpack prepare compile install`,
with PORTAGE_TMPDIR and DISTDIR set to the respective package workspace,
FEATURES="-userpriv -usersandbox -ipc-sandbox -pid-sandbox", and sudo for image
ownership. Only install was repeated after the license-installation adjustment,
by clearing the temporary `.installed` marker. These are temporary package-image
install phases, never a merge into the live root.

On gentoo, package copies were staged in `validation-overlay/` under the matching
/tmp/codex workspace and passed via PORTDIR_OVERLAY. No remote overlay git checkout
was edited. Remote logs were copied back to leonids-pc.

| Package | amd64, leonids-pc | arm64, gentoo |
| --- | --- | --- |
| BuildKit | Native source compilation and image staging | Native source compilation and image staging |
| calicoctl-bin | Upstream binary image staging, no compilation | Upstream binary image staging, no compilation |

Literal final install evidence, obtained on each host:

```text
>>> Completed installing app-containers/buildkit-0.35.0 into /tmp/codex/app-containers/buildkit-0.35.0/portage/app-containers/buildkit-0.35.0/image
>>> Completed installing net-misc/calicoctl-bin-3.33.0 into /tmp/codex/net-misc/calicoctl-3.33.0/portage/net-misc/calicoctl-bin-3.33.0/image
```

Offline smoke tests executed the staged programs using --version / version
--client. Both architectures printed:

```text
buildctl github.com/moby/buildkit v0.35.0
buildkitd github.com/moby/buildkit v0.35.0
Client Version:    v3.33.0
Git commit:        d2060a8417a60c37946901f1beb951011ea24557
```

`readelf -d` on both Calico binaries printed:

```text
There is no dynamic section in this file.
```

On amd64 BuildKit, `readelf -d` showed a PIE dynamic section with no NEEDED entries.
Final license staging on arm64 included:

```text
/tmp/codex/app-containers/buildkit-0.35.0/portage/app-containers/buildkit-0.35.0/image/usr/share/doc/buildkit-0.35.0/third-party-licenses/vendor/github.com/cyphar/filepath-securejoin/LICENSE.MPL-2.0.bz2
```

## INFERRED / NOT VERIFIED

INFERRED: the upstream Go-only build configuration and supplied dependencies
provide the default OCI worker; smoke checks alone do not validate container builds.
NOT VERIFIED: privileged upstream BuildKit integration tests, starting either
init service, rootless/containerd integrations, and live Calico cluster operations.
BuildKit's integration suite is RESTRICT=test because it requires running
containers/privileged workers. Those operational checks remain for the user.
The explicit two-architecture keyword policy is local overlay policy.

No package was merged, installed, upgraded, or removed on a live system. No git
commit, push, branch change, or pull request was made.


## Runtime dependency correction — 2026-11-13, leonids-pc

Only BuildKit's RDEPEND declaration and this report were changed in this
follow-up. RDEPEND retains app-containers/runc and adds dev-vcs/git,
net-misc/openssh, and app-misc/ca-certificates. No Manifest inputs changed, so no
Manifest regeneration was needed. The initial inspection used
`git status --short --untracked-files=all`; both packages and this report were
already staged additions, rather than untracked. Existing staging was preserved.

### VERIFIED — source and atom checks

Read-only inspection used `ls` on all four ::gentoo package directories and `rg`
/ `sed` on the previously downloaded exact BuildKit v0.35.0 source archive.
All four atoms exist in /var/db/repos/gentoo. Exact local ebuilds selected by the
resolver, also serving as atom evidence:

- /var/db/repos/gentoo/app-containers/runc/runc-1.5.2.ebuild
- /var/db/repos/gentoo/dev-vcs/git/git-2.56.1.ebuild
- /var/db/repos/gentoo/net-misc/openssh/openssh-10.6_p2.ebuild
- /var/db/repos/gentoo/app-misc/ca-certificates/ca-certificates-20260816.3.131.1-r1.ebuild

The upstream source establishes the external runtime requirements:

- Git contexts: [source/git/source.go, line 78](https://github.com/moby/buildkit/blob/v0.35.0/source/git/source.go#L78)
  executes `git version`, and [util/gitutil/git_cli.go, lines 162–178](https://github.com/moby/buildkit/blob/v0.35.0/util/gitutil/git_cli.go#L162)
  executes the external git binary. dev-vcs/git supplies it.
- SSH Git contexts: [git_cli.go, line 234](https://github.com/moby/buildkit/blob/v0.35.0/util/gitutil/git_cli.go#L234)
  sets GIT_SSH_COMMAND using getGitSSHCommand; [lines 363–371](https://github.com/moby/buildkit/blob/v0.35.0/util/gitutil/git_cli.go#L363)
  construct `ssh -F /dev/null`. net-misc/openssh supplies the ssh client.
  Authentication keys/agent forwarding and host configuration remain operational
  prerequisites, rather than additional package atoms.
- HTTPS registries: [util/resolver/resolver.go](https://github.com/moby/buildkit/blob/v0.35.0/util/resolver/resolver.go)
  attaches a tls.Config to the HTTPS transport and calls x509.SystemCertPool
  when extending system trust with custom registry CAs. Without custom roots,
  RootCAs remains nil and Go uses the host roots. Local Go source inspection
  of /usr/lib/go/src/crypto/x509/verify.go and root_linux.go confirms this default
  and includes `/etc/ssl/certs/ca-certificates.crt` as the Debian/Ubuntu/Gentoo
  certificate-bundle path. app-misc/ca-certificates supplies the system CA trust
  material. Private registries may still need administrator-provided CAs.

These conclusions come from exact-release code and local package inspection;
no network Git fetch or registry TLS handshake was performed. Git's HTTP(S)
transport is controlled by its curl USE flag, enabled in the tested resolution;
the unqualified dev-vcs/git atom used at this earlier step did not force that flag when an
administrator explicitly disables it. This does not affect Git's SSH transport
or BuildKit's own Go HTTPS registry transport.

### VERIFIED — syntax and QA

Commands actually run:

```sh
bash -n app-containers/buildkit/buildkit-0.35.0.ebuild net-misc/calicoctl-bin/calicoctl-bin-3.33.0.ebuild
XDG_CACHE_HOME=/tmp/codex/app-containers/buildkit-0.35.0/cache \
  pkgcheck scan app-containers/buildkit net-misc/calicoctl-bin
```

Both commands produced no diagnostics. Their separately printed statuses were:

```text
bash -n exit: 0
pkgcheck exit: 0
```

The QA log is /tmp/codex/app-containers/buildkit-0.35.0/runtime-deps-pkgcheck.log.
`git diff --check` also produced no output.

### VERIFIED — pretend runtime dependency closure

Created a unique workspace with Python tempfile.mkdtemp under the existing
package workspace; no existing temporary files were overwritten:

```text
/tmp/codex/app-containers/buildkit-0.35.0/runtime-deps-cn1p6je9
```

The temporary config uses the local default/linux/amd64/23.0 profile, ARCH=amd64,
CHOST=x86_64-pc-linux-gnu, ACCEPT_KEYWORDS="amd64 ~amd64", ACCEPT_LICENSE="*", and
workspace-local cache, distfile and Portage temporary paths. Its repos.conf
contains only ::gentoo, ::guru, and ::local; ::local points directly at
/home/leonid/GitHub/leonchik1976/gentoo-overlay with priority 100 and masters
gentoo guru. No package copies or stale mirrored overlay were used for this
resolution. The target root/var/db/pkg was created empty.

The final command actually run was:

```sh
validation_workspace=$(cat /tmp/codex/app-containers/buildkit-0.35.0/runtime-deps-workspace.txt)
emerge --pretend --verbose --color=n --nospinner --package-moves=n \
  --sysroot="${validation_workspace}/root" \
  --root="${validation_workspace}/root" \
  --config-root="${validation_workspace}/config" \
  --root-deps=rdeps --with-bdeps=n --usepkg=n --autounmask=n \
  '=app-containers/buildkit-0.35.0::local'
```

Output was redirected to `${validation_workspace}/emerge-pretend-closure.log`.
Literal result:

```text
pretend closure exit: 0
Total: 170 packages (170 new), Size of downloads: 726,670 KiB
```

The following are literal package/slot/repository fields extracted from the
`[ebuild  N     ]` lines in that log; all target the temporary root:

```text
app-misc/ca-certificates-20260816.3.131.1-r1::gentoo
app-containers/runc-1.5.2::gentoo
net-misc/openssh-10.6_p2::gentoo
dev-vcs/git-2.56.1::gentoo
app-containers/buildkit-0.35.0::local
```

After resolution, Python counted installed CONTENTS files and immediate entries
under the target root/var/db/pkg:

```text
Target package database entries: 0
Target database directories: 0
```

Earlier attempts and adjustments, retained in workspace logs:

1. The first command omitted --sysroot and --package-moves=n. The second added
   --sysroot. Both exited 1 before dependency resolution because Portage also
   attempted running-root package moves and encountered
   `ReadOnlyFileSystem: [Errno 30] Read-only file system: '/var/db/.pkg.portage_lockfile'`.
   No escalation was used; --package-moves=n disables that update path.
2. With package moves disabled, the empty-root resolution exited 1 on a Perl
   feature mismatch involving dev-perl/Authen-SASL and dev-lang/perl. Its literal
   diagnostic included `Change USE: +perl_features_ithreads +perl_features_quadmath`.
   Added only `USE="perl_features_ithreads perl_features_quadmath"` to temporary
   make.conf, then repeated the same pretend command. That is the exit-0 run
   above. No live USE configuration was changed and autounmask remained disabled.
3. Portage reported `7 news items need reading for repository 'gentoo'`; no news
   state was changed. The download-size output is a plan, not downloaded files.

### INFERRED / NOT VERIFIED — limits of this follow-up

VERIFIED: native amd64 syntax, scoped QA for both packages, exact-source runtime
requirements, and runtime dependency resolution against an empty target database
on leonids-pc. Build-time dependency closure was deliberately excluded with
--with-bdeps=n / --root-deps=rdeps; the running host remains available for build
context, so this is not a full bootstrap proof or a full build dependency audit.
ACCEPT_LICENSE="*" is a temporary resolver setting, not a license acceptance
recommendation. Results depend on the recorded profile and temporary USE settings.

NOT VERIFIED in this follow-up: a new source build, native arm64 dependency
resolution, actual Git/SSH transfers, HTTPS certificate validation against a live
registry, service startup, or container/cluster operations. The earlier native
build/staging results above remain historical evidence; they do not constitute
fresh build validation of this metadata change. No new build was necessary for
this dependency-only correction. amd64 and arm64 operational integration checks
remain for the user. No package merge, service startup, cluster operation,
commit, push, branch change, or live configuration/package-database update was
performed. Only the BuildKit ebuild and this report were edited in the repository.


## Require Git HTTP(S) transport — 2026-11-13, leonids-pc

Changed only BuildKit's Git dependency from `dev-vcs/git` to
`dev-vcs/git[curl]`, retaining runc, OpenSSH and CA certificates. This supersedes
the earlier unqualified-atom limitation above. The local authoritative ebuild
`/var/db/repos/gentoo/dev-vcs/git/git-2.56.1.ebuild` declares `+curl`, adds
net-misc/curl conditionally, and passes `$(meson_feature curl)` to Git's build.
Thus the USE dependency requires the Git HTTP(S) transport even when an
administrator has otherwise disabled curl for Git. This is a dependency USE
requirement, not a new BuildKit USE flag. No Manifest inputs changed.

### VERIFIED — commands and actual results

Working-tree inspection included staged and untracked files using
`git status --short --untracked-files=all`. Existing staging was preserved.

```sh
bash -n app-containers/buildkit/buildkit-0.35.0.ebuild net-misc/calicoctl-bin/calicoctl-bin-3.33.0.ebuild
XDG_CACHE_HOME=/tmp/codex/app-containers/buildkit-0.35.0/cache \
  pkgcheck scan app-containers/buildkit net-misc/calicoctl-bin
```

No diagnostics from either command; separately printed statuses:

```text
bash -n exit: 0
pkgcheck exit: 0
```

QA output is retained in
`/tmp/codex/app-containers/buildkit-0.35.0/git-curl-pkgcheck.log`.
The existing empty-target amd64 configuration, profile, temporary Perl USE
settings and repository selection described above were reused:

```sh
validation_workspace=$(cat /tmp/codex/app-containers/buildkit-0.35.0/runtime-deps-workspace.txt)
emerge --pretend --verbose --color=n --nospinner --package-moves=n \
  --sysroot="${validation_workspace}/root" \
  --root="${validation_workspace}/root" \
  --config-root="${validation_workspace}/config" \
  --root-deps=rdeps --with-bdeps=n --usepkg=n --autounmask=n \
  '=app-containers/buildkit-0.35.0::local'
```

Output was redirected to `${validation_workspace}/emerge-git-curl.log`.
Literal result:

```text
curl enabled resolution exit: 0
Total: 170 packages (170 new), Size of downloads: 726,670 KiB
```

The selected Git line contained `dev-vcs/git-2.56.1::gentoo` and
`USE="curl gpg iconv nls pcre perl rust safe-directory webdav` (followed by disabled
flags). This resolves the working overlay's changed BuildKit ebuild.

For the negative check, Python tempfile.mkdtemp created
`${validation_workspace}/git-no-curl-6eulmk_y`; shutil.copytree copied the existing
config there with symlinks preserved. Only that new copy gained
`etc/portage/package.use` containing exactly:

```text
dev-vcs/git -curl
```

The repeated command was identical except for:

```sh
negative_workspace=$(cat "${validation_workspace}/git-no-curl-workspace.txt")
# In the emerge command above, replace its --config-root argument with:
# --config-root="${negative_workspace}/config"
```

Output was redirected to `${negative_workspace}/emerge-git-no-curl.log`.
Literal result (the diagnostic's target-root suffix omitted here):

```text
curl disabled resolution exit: 1
emerge: there are no ebuilds built with USE flags to satisfy "dev-vcs/git[curl]"
- dev-vcs/git-2.56.1::gentoo (Change USE: +curl)
(dependency required by "app-containers/buildkit-0.35.0::local" [ebuild])
```

The exit-1 result is the expected negative check: Portage rejects Git without
curl rather than silently resolving BuildKit with missing HTTPS Git transport.
Autounmask remained disabled, and no live configuration was changed. After both
runs, counting immediate entries under the temporary root/var/db/pkg printed:

```text
Target database entries: 0
```

Both runs also printed the existing seven-unread-news notice. `git diff --check`
produced no output. Only the BuildKit ebuild and this report changed.

### NOT VERIFIED — limits

These checks ran on amd64 leonids-pc only. They validate syntax, scoped QA and
runtime dependency resolution, including enforcement of Git's curl USE flag;
they do not perform a fresh source build, arm64 resolution or an actual HTTPS
Git fetch. The earlier build results remain historical. Build dependencies were
excluded as in the preceding runtime-resolution check. No merge, live-system
installation, service startup, cluster operation, commit or push was performed.
