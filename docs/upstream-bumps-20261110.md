# Overlay upstream updates — 2026-11-10

99 packages updated; 99 superseded ebuilds removed after native staged-install validation. No branch, commit, push, merge, qmerge or live-system package installation was performed. `/tmp/report.txt` contains only the 99 eligible package names.

The dependency map covers all 347 ebuilds / 343 packages and 382 Portage-expanded local dependency atoms after the updates: [local dependency map](local-ebuild-dependencies-20261110.md). The review-corrected map uses `use_reduce(matchall=True)` to include all conditional branches; the previous 189-atom map did not. The current check returned `Selected-version/slot atom mismatches: 0`; it checks versions and slots, not all-profile USE solvability.

## Evidence and scope

**VERIFIED** means an actual command or exact artifact observation is quoted below or in the linked evidence files. **INFERRED** means a packaging judgment from those observations. **NOT VERIFIED** identifies remaining runtime, architecture, provenance or exhaustive bundled-license work. A successful source build and a successful prebuilt-payload staged installation are different results.

Exact release artifacts, API responses, old/new build metadata, notices and logs are retained in `/tmp/codex/<category>/<package>-<version>/`. Temporary evidence is not a permanent artifact store. [Evidence index](upstream-bumps-20261110-evidence.json) records the sources, license field and literal completed-install output per package.

## Dependency decisions made first

- `app-admin/aws-sam-cli`: inspected first with its dependency closure. The new release advances its builder pin to 1.68.0; both packages advance together. Existing local compatibility relaxations are documented in the ebuild and remain local choices. [Exact SAM metadata](https://pypi.org/pypi/aws-sam-cli/1.171.0/json).
- `dev-util/aws-cdk-local-3.1.0`: its local atoms require node-diff >=5,<6, node-semver >=7.7.4,<8 and aws-cdk >=2.1113.0,<3. The selected node-semver 7.8.6 and CDK 2.1148.0 fit those ranges. [Upstream package metadata](https://registry.npmjs.org/aws-cdk-local/3.1.0).
- `sci-ml/ollmcp-0.33.3`: retain the existing any-llm-sdk >=1.26,<1.27, mcp >=1.25,<2, prompt-toolkit >=3.0.53,<3.1, rich >=14.2,<15.1 and typer >=0.27,<0.28 ranges and its existing Rich compatibility patch. No incompatible dependency bump was introduced. [Upstream metadata](https://pypi.org/pypi/mcp-client-for-ollama/0.33.3/json).
- The five Elastic packages all advance from 9.5.5 to 9.5.6 together; their existing synchronized dependency relationships are preserved.

## Releases retained or excluded

- GPaste 51.3 is blocked: its exact Meson metadata requires GLib 2.90, GTK 4.24 and libadwaita 1.10, beyond available versions. Existing GPaste ebuilds remain. [Source](https://raw.githubusercontent.com/Keruspe/GPaste/v51.3/meson.build).
- Plexamp 4.50.21 is blocked: the new Linux artifact returned HTTP 403 while the prior 4.50.20 artifact returned HTTP 200. The existing version remains; an announcement alone was insufficient. [Vendor update endpoint](https://plexamp.plex.tv/desktop/latest-linux.yml).
- RT 6.0.4 is blocked: its exact `etc/cpanfile` says `requires 'Starlet', '>= 0.33';`; `::gentoo` has only `dev-perl/Starlet/Starlet-0.310.0-r1.ebuild`. The configure check literally reported `Starlet >= 0.33 ... MISSING (have 0.31)`. RT 6.0.3 remains. [Release artifact](https://download.bestpractical.com/pub/rt/release/rt-6.0.4.tar.gz).
- Async HTTP 0.91.0, IO Stream 0.11.1 and JSON 2.21.2 are the latest suitable releases for the existing dependency/Ruby/slot constraints, rather than the unrestricted latest releases. Their exact gem/API evidence is indexed below.
- No version availability check was performed for the seven explicitly excluded packages: dev-debug/sysdig, dev-util/intel-ocl-sdk, net-misc/rabbitmq-server, sci-geosciences/qgis, sci-ml/XNNPACK, sys-block/libfabric, sys-cluster/ceph.

## Packaging and architecture policy

EAPI 9 is the latest supported EAPI in this environment and the current PMS. Existing EAPI 9 ebuilds remain at 9. EAPI 8 is retained where required inherited eclasses document only EAPI 8 (including current Python, CMake, Ruby and desktop helpers); a version bump does not justify claiming unsupported eclass compatibility.

All keyword strings retain their original architecture coverage. VeraCrypt, Yubico Authenticator, Anki, Proton Mail and Signal remain arm64-only. Selenium IDE, Viber, ExpanDrive and Lens remain amd64-only after checking their published Linux artifacts; an arm64 artifact was not established. Existing dual-architecture packages keep both keywords. Keywords are local availability declarations, not proof of runtime or build testing on both architectures.

No new optional-integration USE flags were added. Existing flags and their install/build choices were inspected. In particular, PostHog metrics integrations and metric-learning optional imports do not become dependency-only USE flags. This follows [PG0001](https://projects.gentoo.org/qa/policy-guide/dependencies.html#pg0001).

Official references consulted: [PMS 9](https://projects.gentoo.org/pms/9/pms.html), [Devmanual dependencies](https://devmanual.gentoo.org/general-concepts/dependencies/), current `/var/db/repos/gentoo/eclass/*.eclass` documentation and implementations for inherited eclasses, and package-specific `::gentoo`/`::guru` examples recorded in each temporary audit JSON. Prior art was not used as license authority. Gentoo Bugzilla lookup for the observed Insomnia lockfile problem was access-limited; no claim that the issue is new is made.

## Commands and results

Commands actually run include `git status --short`, `git show HEAD:<ebuild>`, `git diff --check`, Portage `aux_get`/`use_reduce`/`match_from_list`, exact upstream API/artifact fetches and hash checks, `bash -n <ebuild>`, `pkgdev manifest -d <package-workspace>/distfiles <category/package>`, and scoped `pkgcheck scan --cache-dir <workspace>/final-scan-cache --cache=-git <99 packages>`.

Native staged checks used `unshare --user --map-auto --map-root-user ebuild <ebuild> clean unpack prepare configure compile install` (plus `test` for the Semgrep native-core check). Private package-local Portage configuration redirected distfiles, build trees, logs and staged images to `/tmp/codex`. Compiler caches were disabled. For server packages needing absent service accounts, an additional private mount namespace supplied temporary passwd/group mappings; live account databases were untouched. This validates staged ownership operations, not actual account-package installation.

**VERIFIED:** final Manifest generation returned `Final scoped Manifest generation: 100 packages; failures: 0` before RT was withdrawn; RT’s retained version and the six packages whose old ebuilds were subsequently removed were remanifested with exit 0. The original `git diff --check` checked only the worktree against the index. It did not validate the staged batch; review reproduced `git diff --cached --check` exit 2. See the review-correction section below for current index and worktree results. Final 99-package pkgcheck scan returned exit 0; its pre-review findings are retained as historical evidence in [QA output](upstream-bumps-20261110-qa.txt); current scoped findings are in [review QA](upstream-bumps-20261110-review-qa.txt). Exit 0 does not mean no QA findings.

**VERIFIED:** 94 amd64 staged installs completed on `leonids-pc`; five arm64 staged installs completed on `gentoo`. Source packages compiled where their ebuild defines compilation; binary packages were unpacked/prepared/staged rather than rebuilt from their upstream source. `src_install` wrote a temporary image only. No merge phase ran. Semgrep also emitted `>>> Completed testing dev-util/semgrep-bin-1.185.0` for its native-core startup/version test. Other complete upstream test suites were not run.

## QA findings and limits

The final scan contains 120 findings: 114 match original-version baseline findings after normalizing the version prefix. Six textual differences reflect new exact dependency ranges: OpenClaw’s Node range on x32, Async HTTP’s async-pool range on arm64 (four findings), and Open WebUI’s raised glibc minimum on musl. The underlying x32/keyword/libc limitations already existed. No UnknownManifest, missing Manifest, invalid dependency or newly introduced style finding remains in the final scan.

Existing unresolved findings include glibc-only packages on musl profiles, Node packages on x32, LMMS arm64 dependency keywords, async-pool lacking arm64 keywords, Anki’s deprecated orjson dependency, Python/Ruby compatibility suggestions, Keycloak’s provider selection requirement, and the existing Semgrep OpenTelemetry-threading dependency gap. They are shown verbatim in the QA log; this change does not certify all profiles as solvable.

**NOT VERIFIED:** runtime application/GUI/service behavior; full Python version matrices; non-default USE combinations; native arm64 builds for the dual-keyword packages tested only on amd64; amd64 builds for the five arm64-only packages. Neither virtualenv/wheel resolution nor a keyword is an architecture build test.

## License audit extent

Root license texts, release notices, build metadata and available bundled notices were inspected; hashes and exact source URLs are indexed below. Metric-learning’s new notices expand LICENSE, and Open WebUI’s newly shipped noVNC font license adds OFL-1.1. Existing root grants otherwise did not establish a need for a different root-license value. These statements do not certify every opaque bundled component.

Exact compiled Go module versions/checksums were inspected with `go version -m -json` and `go mod download -json` outside ebuild phases. New indexed verbatim notice archives were generated for CLIamp, Oh My Posh, Semaphore and Traefik; hashes were round-tripped by the existing notice generator. Source-module metadata was not treated as proof that an upstream binary corresponds exactly to that source. Some vendor binaries strip module metadata.

**NOT VERIFIED / remaining provenance uncertainty:** local `(devel)` Go replacements, missing or unclear license grants in infracost/go-proto, xlab/vorbis-go and portions of appdash-data; CLIamp libogg’s exact bundled version; complete source correspondence for static Semgrep/native/vendor binaries; all nested proprietary application ASAR payloads; every transitive native library inside Python wheels. No soname rewriting was used to hide ABI incompatibility. These limits require upstream provenance or further manual review, not a claim of an exhaustive third-party license certification.

Open WebUI inspection collected 420 notice files across available old/new wheel artifacts; its main shipped LICENSE hash is unchanged between versions. Rust registry metadata/notice inspection covered all 351 PostgreSQL Anonymizer archives and the 355 locally available Anki archives; Anki’s remaining crates were fetched/used by the native arm64 build but were not all independently notice-audited locally. The retained Anki license union already includes CDLA-Permissive-2.0, Unicode-3.0, MPL-2.0 and the other identified families.

## Per-package decisions and literal staged-install evidence

“Copy sufficient” concerns the ebuild body plus required package resources. A “yes” still requires the new release artifact, Manifest, metadata/license inspection and validation. All license values below are the resulting ebuild declarations; authoritative upstream evidence is linked separately. Judgments about unchanged packaging are **INFERRED** from those inspections.

### app-admin/argocd-cli-bin: 3.5.6 → 3.6.1

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="Apache-2.0 BSD BSD-2 CC-BY-SA-4.0 ISC imagemagick MIT MPL-2.0 Unlicense"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/argoproj/argo-cd/v3.6.1/LICENSE), [source 2](https://raw.githubusercontent.com/argoproj/argo-cd/v3.6.1/go.mod), [source 3](https://github.com/argoproj/argo-cd/releases/download/v3.6.1/argocd-linux-amd64), [source 4](https://github.com/argoproj/argo-cd/releases/download/v3.6.1/argocd-linux-arm64).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing app-admin/argocd-cli-bin-3.6.1 into /tmp/codex/app-admin/argocd-cli-bin-3.6.1/build/portage/app-admin/argocd-cli-bin-3.6.1/image`. Log: `/tmp/codex/app-admin/argocd-cli-bin-3.6.1/build.log`. Other architecture: **NOT VERIFIED**.

### app-admin/aws-sam-cli: 1.170.0 → 1.171.0

Copy sufficient: **no**. Builder dependency advances to ~1.68.0 with the new upstream release. Existing documented downstream compatibility relaxations remain; this build does not establish runtime compatibility for every relaxed upstream pin.

`LICENSE="Apache-2.0 BSD BSD-2 MIT"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://pypi.org/pypi/aws-sam-cli/1.171.0/json), [source 2](https://files.pythonhosted.org/packages/6a/ca/ac3979dd6dd415a093ff947d74ec35cb584f473533537d72c85015fc3b46/aws_sam_cli-1.171.0.tar.gz), [source 3](https://files.pythonhosted.org/packages/source/a/aws-sam-cli/aws_sam_cli-1.171.0.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing app-admin/aws-sam-cli-1.171.0 into /tmp/codex/app-admin/aws-sam-cli-1.171.0/build/portage/app-admin/aws-sam-cli-1.171.0/image`. Log: `/tmp/codex/app-admin/aws-sam-cli-1.171.0/build.log`. Other architecture: **NOT VERIFIED**.

### app-admin/aws-vault-bin: 7.17.2 → 7.17.7

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="MIT Apache-2.0 BSD BSD-2"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/ByteNess/aws-vault/v7.17.7/LICENSE), [source 2](https://raw.githubusercontent.com/ByteNess/aws-vault/v7.17.7/go.mod), [source 3](https://github.com/ByteNess/aws-vault/releases/download/v7.17.7/aws-vault-linux-amd64), [source 4](https://github.com/ByteNess/aws-vault/releases/download/v7.17.7/aws-vault-linux-arm64).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing app-admin/aws-vault-bin-7.17.7 into /tmp/codex/app-admin/aws-vault-bin-7.17.7/build/portage/app-admin/aws-vault-bin-7.17.7/image`. Log: `/tmp/codex/app-admin/aws-vault-bin-7.17.7/build.log`. Other architecture: **NOT VERIFIED**.

### app-admin/cockpit: 370 → 372

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="LGPL-2.1+ GPL-3+ MIT CC-BY-SA-3.0 BSD"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/cockpit-project/cockpit/372/package.json), [source 2](https://github.com/cockpit-project/cockpit/releases/download/372/cockpit-372.tar.xz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing app-admin/cockpit-372 into /tmp/codex/app-admin/cockpit-372/build/portage/app-admin/cockpit-372/image`. Log: `/tmp/codex/app-admin/cockpit-372/build.log`. Other architecture: **NOT VERIFIED**.

### app-admin/cockpit-files: 46 → 47

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="LGPL-2.1+ MIT"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/cockpit-project/cockpit-files/47/LICENSE), [source 2](https://raw.githubusercontent.com/cockpit-project/cockpit-files/47/package.json), [source 3](https://github.com/cockpit-project/cockpit-files/releases/download/47/cockpit-files-47.tar.xz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing app-admin/cockpit-files-47 into /tmp/codex/app-admin/cockpit-files-47/build/portage/app-admin/cockpit-files-47/image`. Log: `/tmp/codex/app-admin/cockpit-files-47/build.log`. Other architecture: **NOT VERIFIED**.

### app-admin/cockpit-machines: 359 → 360

Copy sufficient: **no**. The release manifest requires Cockpit >=215; the ebuild now records that minimum.

`LICENSE="LGPL-2.1+ MIT"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/cockpit-project/cockpit-machines/360/LICENSE), [source 2](https://raw.githubusercontent.com/cockpit-project/cockpit-machines/360/package.json), [source 3](https://github.com/cockpit-project/cockpit-machines/releases/download/360/cockpit-machines-360.tar.xz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing app-admin/cockpit-machines-360 into /tmp/codex/app-admin/cockpit-machines-360/build/portage/app-admin/cockpit-machines-360/image`. Log: `/tmp/codex/app-admin/cockpit-machines-360/build.log`. Other architecture: **NOT VERIFIED**.

### app-admin/cockpit-podman: 132 → 133

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="LGPL-2.1+ MIT"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/cockpit-project/cockpit-podman/133/LICENSE), [source 2](https://raw.githubusercontent.com/cockpit-project/cockpit-podman/133/package.json), [source 3](https://github.com/cockpit-project/cockpit-podman/releases/download/133/cockpit-podman-133.tar.xz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing app-admin/cockpit-podman-133 into /tmp/codex/app-admin/cockpit-podman-133/build/portage/app-admin/cockpit-podman-133/image`. Log: `/tmp/codex/app-admin/cockpit-podman-133/build.log`. Other architecture: **NOT VERIFIED**.

### app-admin/cockpit-sensors: 2.2.2 → 2.4.0

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="LGPL-2.1+ MIT CC0-1.0"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/ocristopfer/cockpit-sensors/2.4.0/LICENSE), [source 2](https://raw.githubusercontent.com/ocristopfer/cockpit-sensors/2.4.0/package.json), [source 3](https://github.com/ocristopfer/cockpit-sensors/releases/download/2.4.0/cockpit-sensors.tar.xz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing app-admin/cockpit-sensors-2.4.0 into /tmp/codex/app-admin/cockpit-sensors-2.4.0/build/portage/app-admin/cockpit-sensors-2.4.0/image`. Log: `/tmp/codex/app-admin/cockpit-sensors-2.4.0/build.log`. Other architecture: **NOT VERIFIED**.

### app-admin/filebeat-bin: 9.5.5 → 9.5.6

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="Apache-2.0 BSD BSD-2 CC0-1.0 Elastic EPL-2.0 GPL-2 ISC MIT MPL-2.0"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/elastic/beats/v9.5.6/LICENSE.txt), [source 2](https://raw.githubusercontent.com/elastic/beats/v9.5.6/go.mod), [source 3](https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-9.5.6-linux-x86_64.tar.gz), [source 4](https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-9.5.6-linux-arm64.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing app-admin/filebeat-bin-9.5.6 into /tmp/codex/app-admin/filebeat-bin-9.5.6/build/portage/app-admin/filebeat-bin-9.5.6/image`. Log: `/tmp/codex/app-admin/filebeat-bin-9.5.6/build.log`. Other architecture: **NOT VERIFIED**.

### app-admin/fluent-bit: 5.1.5 → 5.2.0

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="Apache-2.0 BSD BSD-2 MIT public-domain"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/fluent/fluent-bit/v5.2.0/LICENSE), [source 2](https://raw.githubusercontent.com/fluent/fluent-bit/v5.2.0/CMakeLists.txt), [source 3](https://github.com/fluent/fluent-bit/archive/refs/tags/v5.2.0.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing app-admin/fluent-bit-5.2.0 into /tmp/codex/app-admin/fluent-bit-5.2.0/build/portage/app-admin/fluent-bit-5.2.0/image`. Log: `/tmp/codex/app-admin/fluent-bit-5.2.0/build.log`. Other architecture: **NOT VERIFIED**.

### app-admin/infracost-bin: 2.18.2 → 2.18.3

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="Apache-2.0 BSD MIT MPL-2.0 Unicode-DFS-2016 Unlicense"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/infracost/cli/v2.18.3/LICENSE), [source 2](https://raw.githubusercontent.com/infracost/cli/v2.18.3/go.mod), [source 3](https://github.com/infracost/cli/releases/download/v2.18.3/infracost-linux-amd64.tar.gz), [source 4](https://github.com/infracost/cli/releases/download/v2.18.3/infracost-linux-arm64.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing app-admin/infracost-bin-2.18.3 into /tmp/codex/app-admin/infracost-bin-2.18.3/build/portage/app-admin/infracost-bin-2.18.3/image`. Log: `/tmp/codex/app-admin/infracost-bin-2.18.3/build.log`. Other architecture: **NOT VERIFIED**.

### app-admin/istioctl-bin: 1.31.3 → 1.32.0

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="Apache-2.0 BSD BSD-2 ISC MIT MPL-2.0"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/istio/istio/1.32.0/LICENSE), [source 2](https://raw.githubusercontent.com/istio/istio/1.32.0/go.mod), [source 3](https://github.com/istio/istio/releases/download/1.32.0/istioctl-1.32.0-linux-amd64.tar.gz), [source 4](https://github.com/istio/istio/releases/download/1.32.0/istioctl-1.32.0-linux-arm64.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing app-admin/istioctl-bin-1.32.0 into /tmp/codex/app-admin/istioctl-bin-1.32.0/build/portage/app-admin/istioctl-bin-1.32.0/image`. Log: `/tmp/codex/app-admin/istioctl-bin-1.32.0/build.log`. Other architecture: **NOT VERIFIED**.

### app-admin/kiro-cli-bin: 2.34.0 → 3.1.0

Copy sufficient: **no**. The release contains only bin/kiro-cli. Removed installation of the retired chat and terminal helpers.

`LICENSE="all-rights-reserved"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://prod.download.cli.kiro.dev/stable/3.1.0/kirocli-x86_64-linux.tar.gz), [source 2](https://prod.download.cli.kiro.dev/stable/3.1.0/kirocli-aarch64-linux.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing app-admin/kiro-cli-bin-3.1.0 into /tmp/codex/app-admin/kiro-cli-bin-3.1.0/build/portage/app-admin/kiro-cli-bin-3.1.0/image`. Log: `/tmp/codex/app-admin/kiro-cli-bin-3.1.0/build.log`. Other architecture: **NOT VERIFIED**.

### app-admin/logstash-bin: 9.5.5 → 9.5.6

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="Apache-2.0 BSD BSD-2 EPL-2.0 GPL-2 ISC LGPL-2.1+ MIT MPL-2.0 Ruby public-domain x-pack? ( Elastic )"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/elastic/logstash/v9.5.6/LICENSE.txt), [source 2](https://artifacts.elastic.co/downloads/logstash/logstash-9.5.6-linux-x86_64.tar.gz), [source 3](https://artifacts.elastic.co/downloads/logstash/logstash-9.5.6-linux-aarch64.tar.gz), [source 4](https://artifacts.elastic.co/downloads/logstash/logstash-oss-9.5.6-linux-x86_64.tar.gz), [source 5](https://artifacts.elastic.co/downloads/logstash/logstash-oss-9.5.6-linux-aarch64.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing app-admin/logstash-bin-9.5.6 into /tmp/codex/app-admin/logstash-bin-9.5.6/build/portage/app-admin/logstash-bin-9.5.6/image`. Log: `/tmp/codex/app-admin/logstash-bin-9.5.6/build.log`. Other architecture: **NOT VERIFIED**.

### app-admin/pulumi-bin: 3.272.0 → 3.274.1

Copy sufficient: **no**. Removed pulumi-watch from dobin because the new release no longer ships it.

`LICENSE="Apache-2.0 BSD BSD-2 ISC MIT MPL-2.0 Unicode-DFS-2016 Unlicense"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/pulumi/pulumi/v3.274.1/LICENSE), [source 2](https://github.com/pulumi/pulumi/releases/download/v3.274.1/pulumi-v3.274.1-linux-x64.tar.gz), [source 3](https://github.com/pulumi/pulumi/releases/download/v3.274.1/pulumi-v3.274.1-linux-arm64.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing app-admin/pulumi-bin-3.274.1 into /tmp/codex/app-admin/pulumi-bin-3.274.1/build/portage/app-admin/pulumi-bin-3.274.1/image`. Log: `/tmp/codex/app-admin/pulumi-bin-3.274.1/build.log`. Other architecture: **NOT VERIFIED**.

### app-admin/semaphore-bin: 2.19.17 → 2.20.23

Copy sufficient: **no**. Replaced the unavailable upstream third-party notice URL with a generated archive of verbatim notices from exact compiled Go module versions.

`LICENSE="Apache-2.0 BSD BSD-2 ISC MIT MPL-2.0"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/semaphoreui/semaphore/v2.20.23/LICENSE), [source 2](https://raw.githubusercontent.com/semaphoreui/semaphore/v2.20.23/go.mod), [source 3](https://github.com/semaphoreui/semaphore/releases/download/v2.20.23/semaphore_community_2.20.23_linux_amd64.tar.gz), [source 4](https://github.com/semaphoreui/semaphore/releases/download/v2.20.23/semaphore_community_2.20.23_linux_arm64.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing app-admin/semaphore-bin-2.20.23 into /tmp/codex/app-admin/semaphore-bin-2.20.23/build/portage/app-admin/semaphore-bin-2.20.23/image`. Log: `/tmp/codex/app-admin/semaphore-bin-2.20.23/build.log`. Other architecture: **NOT VERIFIED**.

### app-admin/serverless-bin: 4.45.0 → 4.46.0

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="Serverless-Customer-Agreement-20251201 MIT"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://install.serverless.com/archives/serverless-4.46.0.tgz), [source 2](https://raw.githubusercontent.com/serverless/serverless/sf-core@4.46.0/THIRD_PARTY_LICENSES).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing app-admin/serverless-bin-4.46.0 into /tmp/codex/app-admin/serverless-bin-4.46.0/build/portage/app-admin/serverless-bin-4.46.0/image`. Log: `/tmp/codex/app-admin/serverless-bin-4.46.0/build.log`. Other architecture: **NOT VERIFIED**.

### app-admin/temporal-cli-bin: 1.9.1 → 1.10.0

Copy sufficient: **no**. Generate bash, zsh and fish completions from the release binary instead of requiring absent version-specific FILESDIR completions.

`LICENSE="Apache-2.0 BSD BSD-2 ISC MIT MPL-2.0 imagemagick"`; `KEYWORDS="-* ~amd64 ~arm64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/temporalio/cli/v1.10.0/LICENSE), [source 2](https://raw.githubusercontent.com/temporalio/cli/v1.10.0/go.mod), [source 3](https://github.com/temporalio/cli/releases/download/v1.10.0/temporal_cli_1.10.0_linux_amd64.tar.gz), [source 4](https://github.com/temporalio/cli/releases/download/v1.10.0/temporal_cli_1.10.0_linux_arm64.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing app-admin/temporal-cli-bin-1.10.0 into /tmp/codex/app-admin/temporal-cli-bin-1.10.0/build/portage/app-admin/temporal-cli-bin-1.10.0/image`. Log: `/tmp/codex/app-admin/temporal-cli-bin-1.10.0/build.log`. Other architecture: **NOT VERIFIED**.

### app-admin/tflint-bin: 0.65.0 → 0.66.0

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="MPL-2.0 BUSL-1.1 Apache-2.0 BSD BSD-2 MIT Unicode-DFS-2016 Unlicense"`; `KEYWORDS="-* ~amd64 ~arm64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/terraform-linters/tflint/v0.66.0/LICENSE), [source 2](https://raw.githubusercontent.com/terraform-linters/tflint/v0.66.0/go.mod), [source 3](https://github.com/terraform-linters/tflint/releases/download/v0.66.0/tflint_linux_amd64.zip), [source 4](https://github.com/terraform-linters/tflint/releases/download/v0.66.0/tflint_linux_arm64.zip).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing app-admin/tflint-bin-0.66.0 into /tmp/codex/app-admin/tflint-bin-0.66.0/build/portage/app-admin/tflint-bin-0.66.0/image`. Log: `/tmp/codex/app-admin/tflint-bin-0.66.0/build.log`. Other architecture: **NOT VERIFIED**.

### app-admin/vector-bin: 0.60.0 → 0.61.0

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="0BSD Apache-2.0 BlueOak-1.0.0 Boost-1.0 BSD BSD-2 CC0-1.0 CDLA-Permissive-2.0 ISC MIT MIT-0 MPL-2.0 openssl Unicode-3.0 Unicode-DFS-2016 ZLIB"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/vectordotdev/vector/v0.61.0/LICENSE), [source 2](https://raw.githubusercontent.com/vectordotdev/vector/v0.61.0/Cargo.toml), [source 3](https://github.com/vectordotdev/vector/releases/download/v0.61.0/vector-0.61.0-x86_64-unknown-linux-gnu.tar.gz), [source 4](https://github.com/vectordotdev/vector/releases/download/v0.61.0/vector-0.61.0-aarch64-unknown-linux-gnu.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing app-admin/vector-bin-0.61.0 into /tmp/codex/app-admin/vector-bin-0.61.0/build/portage/app-admin/vector-bin-0.61.0/image`. Log: `/tmp/codex/app-admin/vector-bin-0.61.0/build.log`. Other architecture: **NOT VERIFIED**.

### app-containers/lstk-bin: 1.4.2 → 1.4.4

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="Apache-2.0 BSD BSD-2 MIT MPL-2.0 Unicode-DFS-2016"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/localstack/lstk/v1.4.4/LICENSE), [source 2](https://raw.githubusercontent.com/localstack/lstk/v1.4.4/go.mod), [source 3](https://github.com/localstack/lstk/releases/download/v1.4.4/lstk_1.4.4_linux_amd64.tar.gz), [source 4](https://github.com/localstack/lstk/releases/download/v1.4.4/lstk_1.4.4_linux_arm64.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing app-containers/lstk-bin-1.4.4 into /tmp/codex/app-containers/lstk-bin-1.4.4/build/portage/app-containers/lstk-bin-1.4.4/image`. Log: `/tmp/codex/app-containers/lstk-bin-1.4.4/build.log`. Other architecture: **NOT VERIFIED**.

### app-crypt/veracrypt: 1.26.30 → 1.26.31

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="Apache-2.0 BSD RSA truecrypt-3.0 || ( Apache-2.0 CC0-1.0 )"`; `KEYWORDS="~arm64"`.

Upstream evidence: [source 1](https://github.com/veracrypt/VeraCrypt/archive/VeraCrypt_1.26.31.tar.gz).

**VERIFIED**, arm64 on `gentoo`: `>>> Completed installing app-crypt/veracrypt-1.26.31 into /tmp/codex/app-crypt/veracrypt-1.26.31/build/portage/app-crypt/veracrypt-1.26.31/image`. Log: `/tmp/codex/app-crypt/veracrypt-1.26.31/arm64-build.log`. Other architecture: **NOT VERIFIED**.

### app-crypt/yubioath-flutter-bin: 7.5.0_pre20261012 → 7.5.0

Copy sufficient: **no**. Replace the prerelease CI ZIP with the official final arm64 tarball, remove nested-ZIP unpack logic and unzip dependency, and use the new source directory.

`LICENSE="Apache-2.0"`; `KEYWORDS="-* ~arm64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/Yubico/yubioath-flutter/7.5.0/LICENSE), [source 2](https://github.com/Yubico/yubioath-flutter/releases/download/7.5.0/yubico-authenticator-7.5.0-linux-arm64.tar.gz).

**VERIFIED**, arm64 on `gentoo`: `>>> Completed installing app-crypt/yubioath-flutter-bin-7.5.0 into /tmp/codex/app-crypt/yubioath-flutter-bin-7.5.0/build/portage/app-crypt/yubioath-flutter-bin-7.5.0/image`. Log: `/tmp/codex/app-crypt/yubioath-flutter-bin-7.5.0/arm64-build.log`. Other architecture: **NOT VERIFIED**.

### app-editors/cursor: 3.27.22 → 3.29.15

Copy sufficient: **no**. Update the vendor release build identifier as well as the version.

`LICENSE="all-rights-reserved Apache-2.0 BSD BSD-2 Boost-1.0 CC0-1.0 FFT2D FTL IJG ISC LGPL-2 LGPL-2.1 MIT MPL-2.0 OFL-1.1 PSF-2 Unicode-3.0 Unlicense ZLIB"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://downloads.cursor.com/production/86776fcb52ca505783155631089b65d646f9b03f/linux/x64/deb/amd64/deb/cursor_3.29.15_amd64.deb), [source 2](https://downloads.cursor.com/production/86776fcb52ca505783155631089b65d646f9b03f/linux/arm64/deb/arm64/deb/cursor_3.29.15_arm64.deb).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing app-editors/cursor-3.29.15 into /tmp/codex/app-editors/cursor-3.29.15/build/portage/app-editors/cursor-3.29.15/image`. Log: `/tmp/codex/app-editors/cursor-3.29.15/build.log`. Other architecture: **NOT VERIFIED**.

### app-editors/kiro: 1.4.26 → 1.4.154

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="all-rights-reserved Apache-2.0 BSD BSD-2 Boost-1.0 CC0-1.0 FFT2D FTL IJG ISC LGPL-2 LGPL-2.1 MIT MPL-2.0 OFL-1.1 PSF-2 Unicode-3.0 Unlicense ZLIB"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://prod.download.desktop.kiro.dev/releases/stable/linux-x64/signed/1.4.154/deb/kiro-ide-1.4.154-stable-linux-x64.deb), [source 2](https://prod.download.desktop.kiro.dev/releases/stable/linux-arm64/signed/1.4.154/deb/kiro-ide-1.4.154-stable-linux-arm64.deb).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing app-editors/kiro-1.4.154 into /tmp/codex/app-editors/kiro-1.4.154/build/portage/app-editors/kiro-1.4.154/image`. Log: `/tmp/codex/app-editors/kiro-1.4.154/build.log`. Other architecture: **NOT VERIFIED**.

### app-editors/nimbalyst: 0.82.1 → 0.83.0

Copy sufficient: **no**. Regenerate the exact pnpm dependency eclass; better-sqlite3 is now 13.0.3. Electron 43.7.0 and pnpm 12.9.1 remain. The existing 0.82.1 packaging patch applies to this release and is referenced explicitly.

`LICENSE="MIT Apache-2.0 BSD BSD-2 ISC BlueOak-1.0.0 CC0-1.0 Unlicense 0BSD EPL-2.0 LGPL-3 PYTHON all-rights-reserved Boost-1.0 CC-BY-SA-4.0 FFT2D FTL IJG LGPL-2 LGPL-2.1 MPL-2.0 OFL-1.1 PSF-2 Unicode-3.0 Unicode-DFS-2016 ZLIB"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://codeload.github.com/nimbalyst/nimbalyst/tar.gz/refs/tags/v0.83.0), [source 2](https://raw.githubusercontent.com/nimbalyst/nimbalyst/v0.83.0/LICENSE), [source 3](https://raw.githubusercontent.com/nimbalyst/nimbalyst/v0.83.0/package.json), [source 4](https://github.com/nimbalyst/nimbalyst/archive/refs/tags/v0.83.0.tar.gz), [source 5](https://artifacts.electronjs.org/headers/dist/v43.7.0/node-v43.7.0-headers.tar.gz), [source 6](https://github.com/electron/electron/releases/download/v43.7.0/electron-v43.7.0-linux-x64.zip), [source 7](https://github.com/microsoft/ripgrep-prebuilt/releases/download/v15.0.1/ripgrep-v15.0.1-x86_64-unknown-linux-musl.tar.gz), [source 8](https://github.com/electron/electron/releases/download/v43.7.0/electron-v43.7.0-linux-arm64.zip).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing app-editors/nimbalyst-0.83.0 into /tmp/codex/app-editors/nimbalyst-0.83.0/build/portage/app-editors/nimbalyst-0.83.0/image`. Log: `/tmp/codex/app-editors/nimbalyst-0.83.0/build.log`. Other architecture: **NOT VERIFIED**.

### app-metrics/metricbeat-bin: 9.5.5 → 9.5.6

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="Apache-2.0 BSD BSD-2 Elastic ISC MIT MPL-2.0"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/elastic/beats/v9.5.6/LICENSE.txt), [source 2](https://raw.githubusercontent.com/elastic/beats/v9.5.6/go.mod), [source 3](https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-9.5.6-linux-x86_64.tar.gz), [source 4](https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-9.5.6-linux-arm64.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing app-metrics/metricbeat-bin-9.5.6 into /tmp/codex/app-metrics/metricbeat-bin-9.5.6/build/portage/app-metrics/metricbeat-bin-9.5.6/image`. Log: `/tmp/codex/app-metrics/metricbeat-bin-9.5.6/build.log`. Other architecture: **NOT VERIFIED**.

### app-misc/anki: 26.09.3 → 26.09.4

Copy sufficient: **no**. Regenerate the Cargo crate list and Yarn dependency eclass from the exact release locks. Reuse the inspected 26.09.3 protobuf-stub patch explicitly. Other retained patches applied during native arm64 preparation.

`LICENSE="AGPL-3+ BSD public-domain 0BSD BlueOak-1.0.0 ISC PSF-2 gui? ( CC0-1.0 CC-BY-3.0 CC-BY-4.0 ) Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD-2 CC0-1.0 CDLA-Permissive-2.0 ISC MIT MPL-2.0 Unicode-3.0 Unlicense ZLIB openssl"`; `KEYWORDS="~arm64"`.

Upstream evidence: [source 1](https://codeload.github.com/ankitects/anki/tar.gz/refs/tags/26.09.4), [source 2](https://raw.githubusercontent.com/ankitects/anki/26.09.4/LICENSE), [source 3](https://raw.githubusercontent.com/ankitects/anki/26.09.4/Cargo.toml), [source 4](https://raw.githubusercontent.com/ankitects/anki/26.09.4/package.json), [source 5](https://static.crates.io/crates/addr2line/addr2line-0.24.2.crate), [source 6](https://static.crates.io/crates/adler2/adler2-2.0.1.crate), [source 7](https://static.crates.io/crates/aho-corasick/aho-corasick-1.1.3.crate), [source 8](https://static.crates.io/crates/ammonia/ammonia-4.1.4.crate).

**VERIFIED**, arm64 on `gentoo`: `>>> Completed installing app-misc/anki-26.09.4 into /tmp/codex/app-misc/anki-26.09.4/build/portage/app-misc/anki-26.09.4/image`. Log: `/tmp/codex/app-misc/anki-26.09.4/arm64-build.log`. Other architecture: **NOT VERIFIED**.

### app-misc/chatgpt-bin: 26.1023.51421 → 26.1103.60933

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="all-rights-reserved Apache-2.0 BSD BSD-2 Boost-1.0 CC0-1.0 FFT2D FTL IJG ISC LGPL-2 LGPL-2.1 MIT MPL-2.0 OFL-1.1 PSF-2 Unicode-3.0 Unlicense ZLIB"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://persistent.oaistatic.com/codex-app-prod/linux/deb/pool/main/c/chatgpt/chatgpt_26.1103.60933_amd64.deb), [source 2](https://persistent.oaistatic.com/codex-app-prod/linux/deb/pool/main/c/chatgpt/chatgpt_26.1103.60933_arm64.deb).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing app-misc/chatgpt-bin-26.1103.60933 into /tmp/codex/app-misc/chatgpt-bin-26.1103.60933/build/portage/app-misc/chatgpt-bin-26.1103.60933/image`. Log: `/tmp/codex/app-misc/chatgpt-bin-26.1103.60933/build.log`. Other architecture: **NOT VERIFIED**.

### app-misc/elasticsearch: 9.5.5 → 9.5.6

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="Apache-2.0 BSD-2 Elastic-2.0 LGPL-3 MIT public-domain"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/elastic/elasticsearch/v9.5.6/LICENSE.txt), [source 2](https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-9.5.6-linux-x86_64.tar.gz), [source 3](https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-9.5.6-linux-aarch64.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing app-misc/elasticsearch-9.5.6 into /tmp/codex/app-misc/elasticsearch-9.5.6/build/portage/app-misc/elasticsearch-9.5.6/image`. Log: `/tmp/codex/app-misc/elasticsearch-9.5.6/build.log`. Other architecture: **NOT VERIFIED**.

### app-misc/grok-bot-bin: 0.77.0 → 0.79.3

Copy sufficient: **no**. Update the vendor release build identifier.

`LICENSE="all-rights-reserved Apache-2.0 Apache-2.0-with-LLVM-exceptions APSL-2 Base64 Boost-1.0 BSD BSD-2 CC-BY-3.0 CC-BY-4.0 Clear-BSD FFT2D FTL IJG ISC LGPL-2 LGPL-2.1 LGPL-2.1+ libpng libtiff MIT MPL-1.1 MPL-2.0 Ms-PL openssl PSF-2 public-domain SGI-B-2.0 SSLeay SunSoft Unicode-3.0 Unicode-DFS-2015 Unlicense UoI-NCSA ZLIB"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://downloads.cursor.com/grokbot/stable/473941287261c3efa92c6b2a0bf7e1caad1a2ef2/linux/x64/grok-bot_0.79.3_amd64.deb), [source 2](https://downloads.cursor.com/grokbot/stable/473941287261c3efa92c6b2a0bf7e1caad1a2ef2/linux/arm64/grok-bot_0.79.3_arm64.deb).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing app-misc/grok-bot-bin-0.79.3 into /tmp/codex/app-misc/grok-bot-bin-0.79.3/build/portage/app-misc/grok-bot-bin-0.79.3/image`. Log: `/tmp/codex/app-misc/grok-bot-bin-0.79.3/build.log`. Other architecture: **NOT VERIFIED**.

### app-misc/openclaw-bin: 2026.10.8 → 2026.11.3

Copy sufficient: **no**. Resolve the new published runtime graph with peer checks enabled, excluding root development-only dependencies from the resolver copy. Regenerate the offline lock, archive list and license summary; recognize the new proc-safe/resvg native families. Remove Koffi pruning because Koffi is absent from the new runtime lock. Follow the new Node engine range >=24.16,<25 or >=26.1. No network is allowed in normal ebuild phases.

`LICENSE="MIT Apache-2.0 Artistic-2 BSD BSD-2 BlueOak-1.0.0 CC-BY-3.0 CC0-1.0 ISC MPL-2.0 0BSD Unlicense ZLIB || ( MIT GPL-3+ ) || ( MIT Apache-2.0 )"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://registry.npmjs.org/openclaw/-/openclaw-2026.11.3.tgz), [source 2](https://registry.npmjs.org/abort-controller/-/abort-controller-3.0.0.tgz), [source 3](https://registry.npmjs.org/accepts/-/accepts-2.0.0.tgz), [source 4](https://registry.npmjs.org/acorn/-/acorn-8.19.0.tgz), [source 5](https://registry.npmjs.org/agent-base/-/agent-base-7.1.4.tgz), [source 6](https://registry.npmjs.org/@agentclientprotocol/sdk/-/sdk-1.7.0.tgz), [source 7](https://registry.npmjs.org/ajv/-/ajv-8.20.0.tgz), [source 8](https://registry.npmjs.org/ajv-formats/-/ajv-formats-3.0.1.tgz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing app-misc/openclaw-bin-2026.11.3 into /tmp/codex/app-misc/openclaw-bin-2026.11.3/build/portage/app-misc/openclaw-bin-2026.11.3/image`. Log: `/tmp/codex/app-misc/openclaw-bin-2026.11.3/build.log`. Other architecture: **NOT VERIFIED**.

### app-shells/oh-my-posh-bin: 31.9.1 → 32.0.0

Copy sufficient: **no**. Replace stale per-module notice downloads with a generated exact-module notice archive and install its indexed verbatim texts.

`LICENSE="MIT Apache-2.0 BSD BSD-2"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/v32.0.0/COPYING), [source 2](https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/v32.0.0/posh-linux-amd64), [source 3](https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/v32.0.0/posh-linux-arm64), [source 4](https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/v32.0.0/themes.zip).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing app-shells/oh-my-posh-bin-32.0.0 into /tmp/codex/app-shells/oh-my-posh-bin-32.0.0/build/portage/app-shells/oh-my-posh-bin-32.0.0/image`. Log: `/tmp/codex/app-shells/oh-my-posh-bin-32.0.0/build.log`. Other architecture: **NOT VERIFIED**.

### app-text/koodo-reader-bin: 2.4.6 → 2.4.7

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="AGPL-3 0BSD AFL-2.1 APSL-2 Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD BSD-2 BSD-4 Boost-1.0 CC-BY-3.0 CC-BY-SA-3.0 FFT2D FTL GPL-2 IJG ISC LGPL-2 LGPL-2.1 MIT MPL-1.1 MPL-2.0 Ms-PL OFL-1.1 SGI-B-2.0 SSLeay SunSoft Unicode-3.0 Unicode-DFS-2015 Unlicense UoI-NCSA ZLIB all-rights-reserved android libpng libtiff openssl public-domain unRAR"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/koodo-reader/koodo-reader/v2.4.7/LICENSE), [source 2](https://raw.githubusercontent.com/koodo-reader/koodo-reader/v2.4.7/package.json), [source 3](https://github.com/koodo-reader/koodo-reader/releases/download/v2.4.7/Koodo-Reader-2.4.7-amd64.deb), [source 4](https://github.com/koodo-reader/koodo-reader/releases/download/v2.4.7/Koodo-Reader-2.4.7-arm64.deb).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing app-text/koodo-reader-bin-2.4.7 into /tmp/codex/app-text/koodo-reader-bin-2.4.7/build/portage/app-text/koodo-reader-bin-2.4.7/image`. Log: `/tmp/codex/app-text/koodo-reader-bin-2.4.7/build.log`. Other architecture: **NOT VERIFIED**.

### dev-db/beekeeper-studio-bin: 6.1.6 → 6.2.2

Copy sufficient: **no**. Remove pruning of a musl DuckDB binding that is no longer shipped. Remove chmod entries for libEGL.so/libGLESv2.so, absent in the new payload. Retain launcher sandbox handling and other native-module pruning.

`LICENSE="GPL-3+ Beekeeper-Studio-EULA-20260702"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/beekeeper-studio/beekeeper-studio/v6.2.2/LICENSE.md), [source 2](https://raw.githubusercontent.com/beekeeper-studio/beekeeper-studio/v6.2.2/package.json), [source 3](https://github.com/beekeeper-studio/beekeeper-studio/releases/download/v6.2.2/beekeeper-studio_6.2.2_amd64.deb), [source 4](https://github.com/beekeeper-studio/beekeeper-studio/releases/download/v6.2.2/beekeeper-studio_6.2.2_arm64.deb).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing dev-db/beekeeper-studio-bin-6.2.2 into /tmp/codex/dev-db/beekeeper-studio-bin-6.2.2/build/portage/dev-db/beekeeper-studio-bin-6.2.2/image`. Log: `/tmp/codex/dev-db/beekeeper-studio-bin-6.2.2/build.log`. Other architecture: **NOT VERIFIED**.

### dev-db/dbgate-bin: 7.3.3 → 7.3.4

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="GPL-3 Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD BSD-2 Base64 Boost-1.0 CC-BY-3.0 CC-BY-4.0 Clear-BSD FFT2D FTL IJG ISC LGPL-2 LGPL-2.1 MIT MPL-1.1 MPL-2.0 Ms-PL PSF-2 SGI-B-2.0 SSLeay SunSoft Unicode-3.0 Unicode-DFS-2015 Unlicense UoI-NCSA ZLIB libtiff openssl"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/dbgate/dbgate/v7.3.4/LICENSE), [source 2](https://raw.githubusercontent.com/dbgate/dbgate/v7.3.4/package.json), [source 3](https://github.com/dbgate/dbgate/releases/download/v7.3.4/dbgate-7.3.4-linux_x86_64.AppImage), [source 4](https://github.com/dbgate/dbgate/releases/download/v7.3.4/dbgate-7.3.4-linux_arm64.AppImage).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing dev-db/dbgate-bin-7.3.4 into /tmp/codex/dev-db/dbgate-bin-7.3.4/build/portage/dev-db/dbgate-bin-7.3.4/image`. Log: `/tmp/codex/dev-db/dbgate-bin-7.3.4/build.log`. Other architecture: **NOT VERIFIED**.

### dev-db/neo4j-bin: 2026.10.1 → 2026.10.2

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="Apache-2.0 BSD BSD-2 CDDL-1.1 EPL-1.0 EPL-2.0 GPL-2-with-classpath-exception GPL-3 MIT MPL-2.0"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/neo4j/neo4j/2026.10.2/LICENSE.txt), [source 2](https://dist.neo4j.org/neo4j-community-2026.10.2-unix.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing dev-db/neo4j-bin-2026.10.2 into /tmp/codex/dev-db/neo4j-bin-2026.10.2/build/portage/dev-db/neo4j-bin-2026.10.2/image`. Log: `/tmp/codex/dev-db/neo4j-bin-2026.10.2/build.log`. Other architecture: **NOT VERIFIED**.

### dev-db/postgresql_anonymizer: 3.3.0 → 3.3.2

Copy sufficient: **no**. Regenerate all 351 registry crate inputs from the release Cargo.lock. The inspected source LICENSE remains unchanged; compile and staged installation completed against the host PostgreSQL development environment.

`LICENSE="Apache-2.0 BSD BSD-2 ISC MIT POSTGRESQL UoI-NCSA Unicode-3.0 ZLIB"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://gitlab.com/dalibo/postgresql_anonymizer/-/archive/3.3.2/postgresql_anonymizer-3.3.2.tar.bz2), [source 2](https://static.crates.io/crates/adler2/adler2-2.0.1.crate), [source 3](https://static.crates.io/crates/aho-corasick/aho-corasick-1.1.5.crate), [source 4](https://static.crates.io/crates/aligned-vec/aligned-vec-0.6.4.crate), [source 5](https://static.crates.io/crates/aligned/aligned-0.4.3.crate), [source 6](https://static.crates.io/crates/android_system_properties/android_system_properties-0.1.6.crate), [source 7](https://static.crates.io/crates/anstyle/anstyle-1.0.14.crate), [source 8](https://static.crates.io/crates/anyhow/anyhow-1.0.104.crate).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing dev-db/postgresql_anonymizer-3.3.2 into /tmp/codex/dev-db/postgresql_anonymizer-3.3.2/build/portage/dev-db/postgresql_anonymizer-3.3.2/image`. Log: `/tmp/codex/dev-db/postgresql_anonymizer-3.3.2/build.log`. Other architecture: **NOT VERIFIED**.

### dev-libs/node-semver: 7.8.5 → 7.8.6

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="ISC"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://registry.npmjs.org/semver/-/semver-7.8.6.tgz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing dev-libs/node-semver-7.8.6 into /tmp/codex/dev-libs/node-semver-7.8.6/build/portage/dev-libs/node-semver-7.8.6/image`. Log: `/tmp/codex/dev-libs/node-semver-7.8.6/build.log`. Other architecture: **NOT VERIFIED**.

### dev-libs/tree-sitter-cmake: 0.7.5 → 0.7.6

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="MIT"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/uyha/tree-sitter-cmake/v0.7.6/LICENSE), [source 2](https://raw.githubusercontent.com/uyha/tree-sitter-cmake/v0.7.6/go.mod), [source 3](https://raw.githubusercontent.com/uyha/tree-sitter-cmake/v0.7.6/Cargo.toml), [source 4](https://raw.githubusercontent.com/uyha/tree-sitter-cmake/v0.7.6/package.json), [source 5](https://raw.githubusercontent.com/uyha/tree-sitter-cmake/v0.7.6/CMakeLists.txt), [source 6](https://github.com/uyha/tree-sitter-cmake/archive/v0.7.6.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing dev-libs/tree-sitter-cmake-0.7.6 into /tmp/codex/dev-libs/tree-sitter-cmake-0.7.6/build/portage/dev-libs/tree-sitter-cmake-0.7.6/image`. Log: `/tmp/codex/dev-libs/tree-sitter-cmake-0.7.6/build.log`. Other architecture: **NOT VERIFIED**.

### dev-php/ca-bundle: 1.6.0 → 1.6.1

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="MIT"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/composer/ca-bundle/1.6.1/LICENSE), [source 2](https://github.com/composer/ca-bundle/archive/1.6.1.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing dev-php/ca-bundle-1.6.1 into /tmp/codex/dev-php/ca-bundle-1.6.1/build/portage/dev-php/ca-bundle-1.6.1/image`. Log: `/tmp/codex/dev-php/ca-bundle-1.6.1/build.log`. Other architecture: **NOT VERIFIED**.

### dev-php/composer: 2.10.3 → 2.11.2

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="MIT"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/composer/composer/2.11.2/LICENSE), [source 2](https://getcomposer.org/download/2.11.2/composer.phar).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing dev-php/composer-2.11.2 into /tmp/codex/dev-php/composer-2.11.2/build/portage/dev-php/composer-2.11.2/image`. Log: `/tmp/codex/dev-php/composer-2.11.2/build.log`. Other architecture: **NOT VERIFIED**.

### dev-python/autobahn: 26.10.2 → 26.11.1

Copy sufficient: **no**. Update the documented optional Brotli integration minimum to 1.2.1, without adding a runtime integration USE flag.

`LICENSE="MIT"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://pypi.org/pypi/autobahn/26.11.1/json), [source 2](https://files.pythonhosted.org/packages/08/15/694ed91f8f28d8c74b424a8a80208d4f221c12ae5d2fbee4d5041cdf1d0d/autobahn-26.11.1.tar.gz), [source 3](https://files.pythonhosted.org/packages/source/a/autobahn/autobahn-26.11.1.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing dev-python/autobahn-26.11.1 into /tmp/codex/dev-python/autobahn-26.11.1/build/portage/dev-python/autobahn-26.11.1/image`. Log: `/tmp/codex/dev-python/autobahn-26.11.1/build.log`. Other architecture: **NOT VERIFIED**.

### dev-python/aws-lambda-builders: 1.67.0 → 1.68.0

Copy sufficient: **no**. Append to BDEPEND rather than replacing eclass-provided values. Remove the stale comment about the installed Python version.

`LICENSE="Apache-2.0"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://pypi.org/pypi/aws-lambda-builders/1.68.0/json), [source 2](https://files.pythonhosted.org/packages/0d/f5/747988e9df154282690d9fdb5d2c69f017d71cf3b5c59bce554d6791c804/aws_lambda_builders-1.68.0.tar.gz), [source 3](https://github.com/aws/aws-lambda-builders/archive/v1.68.0.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing dev-python/aws-lambda-builders-1.68.0 into /tmp/codex/dev-python/aws-lambda-builders-1.68.0/build/portage/dev-python/aws-lambda-builders-1.68.0/image`. Log: `/tmp/codex/dev-python/aws-lambda-builders-1.68.0/build.log`. Other architecture: **NOT VERIFIED**.

### dev-python/aws-lambda-powertools: 3.37.0 → 3.40.0

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="MIT-0 MIT Apache-2.0"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://pypi.org/pypi/aws-lambda-powertools/3.40.0/json), [source 2](https://files.pythonhosted.org/packages/8f/fc/ffe1ce4bc265f0a20da5833e53069ee48e98d86e24a5dbdd1a8cb8548091/aws_lambda_powertools-3.40.0.tar.gz), [source 3](https://files.pythonhosted.org/packages/source/a/aws-lambda-powertools/aws_lambda_powertools-3.40.0.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing dev-python/aws-lambda-powertools-3.40.0 into /tmp/codex/dev-python/aws-lambda-powertools-3.40.0/build/portage/dev-python/aws-lambda-powertools-3.40.0/image`. Log: `/tmp/codex/dev-python/aws-lambda-powertools-3.40.0/build.log`. Other architecture: **NOT VERIFIED**.

### dev-python/billiard: 4.3.1 → 4.3.2

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="BSD"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://pypi.org/pypi/billiard/4.3.2/json), [source 2](https://files.pythonhosted.org/packages/96/ba/4ee8c6d14b3e9b5ce89b5b070f1352e6cadefde3f6bc36afcfee5e7158a2/billiard-4.3.2.tar.gz), [source 3](https://files.pythonhosted.org/packages/source/b/billiard/billiard-4.3.2.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing dev-python/billiard-4.3.2 into /tmp/codex/dev-python/billiard-4.3.2/build/portage/dev-python/billiard-4.3.2/image`. Log: `/tmp/codex/dev-python/billiard-4.3.2/build.log`. Other architecture: **NOT VERIFIED**.

### dev-python/boto3-stubs: 1.43.120 → 1.43.127

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="MIT"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://pypi.org/pypi/boto3-stubs/1.43.127/json), [source 2](https://files.pythonhosted.org/packages/b9/4a/45e0979c2bbcee7f757cbebf1c92d85bc9fb69d79d6b2e04106637aea9e3/boto3_stubs-1.43.127.tar.gz), [source 3](https://files.pythonhosted.org/packages/source/b/boto3-stubs/boto3_stubs-1.43.127.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing dev-python/boto3-stubs-1.43.127 into /tmp/codex/dev-python/boto3-stubs-1.43.127/build/portage/dev-python/boto3-stubs-1.43.127/image`. Log: `/tmp/codex/dev-python/boto3-stubs-1.43.127/build.log`. Other architecture: **NOT VERIFIED**.

### dev-python/botocore-stubs: 1.43.120 → 1.43.126

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="MIT"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://pypi.org/pypi/botocore-stubs/1.43.126/json), [source 2](https://files.pythonhosted.org/packages/8c/7a/717e3dec2e4721f76621ddb397b4035ec1aff0c174b80f5c439512a352e9/botocore_stubs-1.43.126.tar.gz), [source 3](https://files.pythonhosted.org/packages/source/b/botocore-stubs/botocore_stubs-1.43.126.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing dev-python/botocore-stubs-1.43.126 into /tmp/codex/dev-python/botocore-stubs-1.43.126/build/portage/dev-python/botocore-stubs-1.43.126/image`. Log: `/tmp/codex/dev-python/botocore-stubs-1.43.126/build.log`. Other architecture: **NOT VERIFIED**.

### dev-python/dateparser: 1.4.3 → 1.5.0

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="BSD"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://pypi.org/pypi/dateparser/1.5.0/json), [source 2](https://files.pythonhosted.org/packages/da/c6/8bb3f0584e7affe13f092906b42fac0a22b6375bf80ed3896bb31fdcb497/dateparser-1.5.0.tar.gz), [source 3](https://files.pythonhosted.org/packages/source/d/dateparser/dateparser-1.5.0.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing dev-python/dateparser-1.5.0 into /tmp/codex/dev-python/dateparser-1.5.0/build/portage/dev-python/dateparser-1.5.0/image`. Log: `/tmp/codex/dev-python/dateparser-1.5.0/build.log`. Other architecture: **NOT VERIFIED**.

### dev-python/jellyfin-apiclient-python: 1.20.2 → 1.21.0

Copy sufficient: **no**. Record certifi >=2026.10.19. The existing backend patch still applies to the new Git/source layout.

`LICENSE="GPL-3"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://pypi.org/pypi/jellyfin-apiclient-python/1.21.0/json), [source 2](https://files.pythonhosted.org/packages/1a/b1/2637d80f74c70ea745bb023131611f193248f6fffa56482afbf736d2b6f6/jellyfin_apiclient_python-1.21.0.tar.gz), [source 3](https://files.pythonhosted.org/packages/source/j/jellyfin-apiclient-python/jellyfin_apiclient_python-1.21.0.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing dev-python/jellyfin-apiclient-python-1.21.0 into /tmp/codex/dev-python/jellyfin-apiclient-python-1.21.0/build/portage/dev-python/jellyfin-apiclient-python-1.21.0/image`. Log: `/tmp/codex/dev-python/jellyfin-apiclient-python-1.21.0/build.log`. Other architecture: **NOT VERIFIED**.

### dev-python/kubernetes: 37.0.1 → 37.0.2

Copy sufficient: **no**. Follow new aiohttp >=3.14.5,<4, aiohttp-retry >=2.9.1, certifi/dateutil/pydantic minima and setuptools >=84.2.1 build requirement from the release metadata.

`LICENSE="Apache-2.0"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://pypi.org/pypi/kubernetes/37.0.2/json), [source 2](https://files.pythonhosted.org/packages/3d/cc/6ef3531e14169d15905fb50730aac5bba53539ec9f21ecdc40be7a059196/kubernetes-37.0.2.tar.gz), [source 3](https://github.com/kubernetes-client/python/archive/refs/tags/v37.0.2.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing dev-python/kubernetes-37.0.2 into /tmp/codex/dev-python/kubernetes-37.0.2/build/portage/dev-python/kubernetes-37.0.2/image`. Log: `/tmp/codex/dev-python/kubernetes-37.0.2/build.log`. Other architecture: **NOT VERIFIED**.

### dev-python/mypy-boto3-lambda: 1.43.118 → 1.43.123

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="MIT"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://pypi.org/pypi/mypy-boto3-lambda/1.43.123/json), [source 2](https://files.pythonhosted.org/packages/25/4f/d8a62e5e0915df3331ef54a2441423704754491998d1ea28d42f0e2b2686/mypy_boto3_lambda-1.43.123.tar.gz), [source 3](https://files.pythonhosted.org/packages/source/m/mypy-boto3-lambda/mypy_boto3_lambda-1.43.123.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing dev-python/mypy-boto3-lambda-1.43.123 into /tmp/codex/dev-python/mypy-boto3-lambda-1.43.123/build/portage/dev-python/mypy-boto3-lambda-1.43.123/image`. Log: `/tmp/codex/dev-python/mypy-boto3-lambda-1.43.123/build.log`. Other architecture: **NOT VERIFIED**.

### dev-python/niquests: 3.21.2 → 3.21.3

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="Apache-2.0"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://pypi.org/pypi/niquests/3.21.3/json), [source 2](https://files.pythonhosted.org/packages/0b/e1/e73e2cdb3374e7b442d708de6f87555f00faa4fdb3e347d5ae6df66d472a/niquests-3.21.3.tar.gz), [source 3](https://files.pythonhosted.org/packages/source/n/niquests/niquests-3.21.3.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing dev-python/niquests-3.21.3 into /tmp/codex/dev-python/niquests-3.21.3/build/portage/dev-python/niquests-3.21.3/image`. Log: `/tmp/codex/dev-python/niquests-3.21.3/build.log`. Other architecture: **NOT VERIFIED**.

### dev-python/pipx: 1.18.6 → 1.18.16

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="MIT"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://pypi.org/pypi/pipx/1.18.16/json), [source 2](https://files.pythonhosted.org/packages/b4/a6/3bfb09e7b4ce1f0602474ce7a4158d2c649e8f9151d8b93138ad27134579/pipx-1.18.16.tar.gz), [source 3](https://github.com/pypa/pipx/archive/1.18.16.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing dev-python/pipx-1.18.16 into /tmp/codex/dev-python/pipx-1.18.16/build/portage/dev-python/pipx-1.18.16/image`. Log: `/tmp/codex/dev-python/pipx-1.18.16/build.log`. Other architecture: **NOT VERIFIED**.

### dev-python/posthog: 7.76.0 → 7.86.6

Copy sufficient: **no**. Add the new packaged request-instrumentation test dependency. The new metrics-autocapture test module needs an unpackaged system-metrics instrumentor and is explicitly excluded. Existing compatibility patches apply. Optional metrics integrations remain optional; no dependency-only USE flag was introduced.

`LICENSE="MIT"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://pypi.org/pypi/posthog/7.86.6/json), [source 2](https://files.pythonhosted.org/packages/e5/ed/ace897f5b58a8e5a4051478b3a534eb9218af6df0f0be6c5dee8dd81d6f4/posthog-7.86.6.tar.gz), [source 3](https://github.com/PostHog/posthog-python/archive/refs/tags/posthog-v7.86.6.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing dev-python/posthog-7.86.6 into /tmp/codex/dev-python/posthog-7.86.6/build/portage/dev-python/posthog-7.86.6/image`. Log: `/tmp/codex/dev-python/posthog-7.86.6/build.log`. Other architecture: **NOT VERIFIED**.

### dev-python/python-hcl2: 8.1.4 → 8.2.0

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="MIT"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://pypi.org/pypi/python-hcl2/8.2.0/json), [source 2](https://files.pythonhosted.org/packages/b0/c1/f1da88976116f93865429c07758febb8a0e9c66830c3107f5ba6f029253d/python_hcl2-8.2.0.tar.gz), [source 3](https://github.com/amplify-education/python-hcl2/archive/v8.2.0.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing dev-python/python-hcl2-8.2.0 into /tmp/codex/dev-python/python-hcl2-8.2.0/build/portage/dev-python/python-hcl2-8.2.0/image`. Log: `/tmp/codex/dev-python/python-hcl2-8.2.0/build.log`. Other architecture: **NOT VERIFIED**.

### dev-python/slack-sdk: 3.45.0 → 3.46.0

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="MIT"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://pypi.org/pypi/slack-sdk/3.46.0/json), [source 2](https://files.pythonhosted.org/packages/7a/43/9eb4f5172ec64d8c25f9fa397d3ca283782d356a60809e4b68ade81fde1a/slack_sdk-3.46.0.tar.gz), [source 3](https://files.pythonhosted.org/packages/source/s/slack-sdk/slack_sdk-3.46.0.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing dev-python/slack-sdk-3.46.0 into /tmp/codex/dev-python/slack-sdk-3.46.0/build/portage/dev-python/slack-sdk-3.46.0/image`. Log: `/tmp/codex/dev-python/slack-sdk-3.46.0/build.log`. Other architecture: **NOT VERIFIED**.

### dev-python/urllib3-future: 2.25.904 → 2.25.906

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="MIT"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://pypi.org/pypi/urllib3-future/2.25.906/json), [source 2](https://files.pythonhosted.org/packages/40/ba/65b899cde6b07d23f8a59fc97fbd2dd479eebcc396671c854a13acd41247/urllib3_future-2.25.906.tar.gz), [source 3](https://files.pythonhosted.org/packages/source/u/urllib3-future/urllib3_future-2.25.906.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing dev-python/urllib3-future-2.25.906 into /tmp/codex/dev-python/urllib3-future-2.25.906/build/portage/dev-python/urllib3-future-2.25.906/image`. Log: `/tmp/codex/dev-python/urllib3-future-2.25.906/build.log`. Other architecture: **NOT VERIFIED**.

### dev-ruby/async-http: 0.86.0 → 0.91.0

Copy sufficient: **no**. Choose 0.91.0 as the latest suitable release. Newer releases need unavailable protocol-url or newer dependency versions. Express the exact gem dependency lower bounds and pessimistic upper bounds. Preserve Ruby 3.3 and 3.4.

`LICENSE="MIT"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://rubygems.org/api/v2/rubygems/async-http/versions/0.91.0.json), [source 2](https://rubygems.org/gems/async-http-0.91.0.gem).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing dev-ruby/async-http-0.91.0 into /tmp/codex/dev-ruby/async-http-0.91.0/build/portage/dev-ruby/async-http-0.91.0/image`. Log: `/tmp/codex/dev-ruby/async-http-0.91.0/build.log`. Other architecture: **NOT VERIFIED**.

### dev-ruby/io-stream: 0.6.1 → 0.11.1 (review corrected)

Copy sufficient: **yes** for the packaging logic; the new ebuild adds a compatibility comment. The prior choice of 0.13.2 was incorrect: its exact gemspec requires OpenSSL >=3.3, incompatible with Ruby 3.3's bundled 3.2.4. Version 0.13.1 omits that dependency but fails a Ruby 3.3 TLS operation; source inspection shows that 0.12+ removes SSLSocket compatibility shims. Version 0.11.1 retains those shims, declares Ruby >=3.2 and no runtime gem dependencies, and passed fresh staged activation, plain buffered I/O, forced-wait TLS I/O and async-http loading on both declared implementations. No upstream gemspec requirement was modified.

`LICENSE="MIT"`; `KEYWORDS="~amd64 ~arm64"`; `USE_RUBY="ruby33 ruby34"` are preserved. The exact shipped `license.md` remains the MIT grant (SHA256 `7fdef642f306221ae884948eaa8e96006e3516db75e966db7114cdf6716c5dd0`).

Upstream evidence: [0.11.1 metadata](https://rubygems.org/api/v2/rubygems/io-stream/versions/0.11.1.json), [exact 0.11.1 gem](https://rubygems.org/gems/io-stream-0.11.1.gem), [rejected 0.13.2 metadata](https://rubygems.org/api/v2/rubygems/io-stream/versions/0.13.2.json), [0.12.0 metadata](https://rubygems.org/api/v2/rubygems/io-stream/versions/0.12.0.json). Exact candidate gem contents and API responses are retained under their package workspaces.

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing dev-ruby/io-stream-0.11.1 into /tmp/codex/dev-ruby/io-stream-0.11.1/build/portage/dev-ruby/io-stream-0.11.1/image`. Ruby 3.3.13/OpenSSL 3.2.4 and Ruby 3.4.12/OpenSSL 3.3.3 both completed runtime smoke checks; literal output and commands are recorded in the evidence index. **NOT VERIFIED:** arm64 build/runtime behavior and the full upstream test suite.

### dev-ruby/json: 2.21.0 → 2.21.2

Copy sufficient: **yes**. Keep the latest suitable 2.x release in slot 2 for the existing fluentd consumer; the newer 3.x release does not satisfy that slot dependency.

`LICENSE="|| ( BSD-2 Ruby )"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/ruby/json/v2.21.2/COPYING), [source 2](https://github.com/ruby/json/archive/v2.21.2.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing dev-ruby/json-2.21.2 into /tmp/codex/dev-ruby/json-2.21.2/build/portage/dev-ruby/json-2.21.2/image`. Log: `/tmp/codex/dev-ruby/json-2.21.2/build.log`. Other architecture: **NOT VERIFIED**.

### dev-util/aws-cdk: 2.1146.1 → 2.1148.0

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="0BSD Apache-2.0 BSD BSD-2 ISC MIT"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://registry.npmjs.org/aws-cdk/-/aws-cdk-2.1148.0.tgz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing dev-util/aws-cdk-2.1148.0 into /tmp/codex/dev-util/aws-cdk-2.1148.0/build/portage/dev-util/aws-cdk-2.1148.0/image`. Log: `/tmp/codex/dev-util/aws-cdk-2.1148.0/build.log`. Other architecture: **NOT VERIFIED**.

### dev-util/cursor-agent: 2026.10.22 → 2026.11.05

Copy sufficient: **no**. Update the release suffix and executable permissions for newly shipped SEA workers. The bundled Node executable reports 24.22.1.

`LICENSE="all-rights-reserved Apache-2.0 BlueOak-1.0.0 BSD BSD-2 ISC MIT Unicode-3.0 ZLIB"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/nodejs/node/v24.22.1/LICENSE), [source 2](https://downloads.cursor.com/lab/2026.11.05-86047df/linux/x64/agent-cli-package.tar.gz), [source 3](https://downloads.cursor.com/lab/2026.11.05-86047df/linux/arm64/agent-cli-package.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing dev-util/cursor-agent-2026.11.05 into /tmp/codex/dev-util/cursor-agent-2026.11.05/build/portage/dev-util/cursor-agent-2026.11.05/image`. Log: `/tmp/codex/dev-util/cursor-agent-2026.11.05/build.log`. Other architecture: **NOT VERIFIED**.

### dev-util/github-copilot-bin: 1.1.33 → 1.1.35

Copy sufficient: **no**. Remove the RPATH correction for Microsoft.AI.Foundry.Local.Core.so and its patchelf dependency because that library is absent from the new payload. No SONAME or dependency is rewritten.

`LICENSE="all-rights-reserved BSD BSD-2 ISC MIT"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://github.com/github/app/releases/download/v1.1.35/GitHub-Copilot-linux-x64.deb), [source 2](https://github.com/github/app/releases/download/v1.1.35/GitHub-Copilot-linux-arm64.deb).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing dev-util/github-copilot-bin-1.1.35 into /tmp/codex/dev-util/github-copilot-bin-1.1.35/build/portage/dev-util/github-copilot-bin-1.1.35/image`. Log: `/tmp/codex/dev-util/github-copilot-bin-1.1.35/build.log`. Other architecture: **NOT VERIFIED**.

### dev-util/github-copilot-cli-bin: 1.0.105 → 1.0.109

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="GitHub-Copilot-CLI"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/github/copilot-cli/v1.0.109/LICENSE.md), [source 2](https://github.com/github/copilot-cli/releases/download/v1.0.109/copilot-linux-x64.tar.gz), [source 3](https://github.com/github/copilot-cli/releases/download/v1.0.109/copilot-linux-arm64.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing dev-util/github-copilot-cli-bin-1.0.109 into /tmp/codex/dev-util/github-copilot-cli-bin-1.0.109/build/portage/dev-util/github-copilot-cli-bin-1.0.109/image`. Log: `/tmp/codex/dev-util/github-copilot-cli-bin-1.0.109/build.log`. Other architecture: **NOT VERIFIED**.

### dev-util/insomnia: 13.3.1 → 13.4.0

Copy sufficient: **no**. Rebase the release lockfile-completeness patch, verify added versions and integrity values against npm, and include three additional entries missing immutable URLs. Regenerate 1699 archive inputs. Follow grpc-reflection-js commit e0b00b8b76f5d58135abadf70a23d6c2022f05ad; parameterize the shared helper while retaining its old default. Electron remains 43.2.0. The existing Node 26 patch applies. Offline preparation, build and staged installation completed.

`LICENSE="Apache-2.0 Apache-2.0-with-LLVM-exceptions MIT MIT-0 BSD BSD-2 0BSD ISC BlueOak-1.0.0 Boost-1.0 CC-BY-3.0 CC-BY-4.0 CC0-1.0 MPL-1.1 MPL-2.0 Ms-PL PSF-2 Unlicense GPL-2 LGPL-2 LGPL-2.1 LGPL-3 FFT2D FTL IJG SGI-B-2.0 SunSoft UoI-NCSA ZLIB libpng2 libtiff Unicode-3.0 Unicode-DFS-2015 OFL-1.1 GSAP-Standard all-rights-reserved"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://codeload.github.com/Kong/insomnia/tar.gz/refs/tags/core@13.4.0), [source 2](https://raw.githubusercontent.com/Kong/insomnia/core@13.4.0/LICENSE), [source 3](https://raw.githubusercontent.com/Kong/insomnia/core@13.4.0/package.json), [source 4](https://github.com/Kong/insomnia/archive/refs/tags/core@13.4.0.tar.gz), [source 5](https://github.com/Kong/grpc-reflection-js/archive/e0b00b8b76f5d58135abadf70a23d6c2022f05ad.tar.gz), [source 6](https://artifacts.electronjs.org/headers/dist/v43.2.0/node-v43.2.0-headers.tar.gz), [source 7](https://github.com/electron/electron/releases/download/v43.2.0/electron-v43.2.0-linux-x64.zip), [source 8](https://github.com/electron/electron/releases/download/v43.2.0/electron-v43.2.0-linux-arm64.zip).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing dev-util/insomnia-13.4.0 into /tmp/codex/dev-util/insomnia-13.4.0/build/portage/dev-util/insomnia-13.4.0/image`. Log: `/tmp/codex/dev-util/insomnia-13.4.0/build.log`. Other architecture: **NOT VERIFIED**.

### dev-util/mise-bin: 2026.10.21 → 2026.11.6

Copy sufficient: **no**. Update the independent upstream npm-schema version used by the release.

`LICENSE="MIT 0BSD Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD BSD-1 BSD-2 BZIP2 Boost-1.0 CC0-1.0 CDLA-Permissive-2.0 GPL-2 ISC LGPL-2.1 LGPL-3 MIT-0 MPL-2.0 Unicode-3.0 Unlicense ZLIB openssl"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/jdx/mise/v2026.11.6/LICENSE), [source 2](https://raw.githubusercontent.com/jdx/mise/v2026.11.6/Cargo.toml), [source 3](https://raw.githubusercontent.com/jdx/mise/v2026.11.6/package.json), [source 4](https://github.com/jdx/mise/releases/download/v2026.11.6/mise-v2026.11.6-linux-x64.tar.gz), [source 5](https://github.com/jdx/mise/releases/download/v2026.11.6/mise-v2026.11.6-linux-arm64.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing dev-util/mise-bin-2026.11.6 into /tmp/codex/dev-util/mise-bin-2026.11.6/build/portage/dev-util/mise-bin-2026.11.6/image`. Log: `/tmp/codex/dev-util/mise-bin-2026.11.6/build.log`. Other architecture: **NOT VERIFIED**.

### dev-util/postman-bin: 12.34.2 → 12.36.1

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="all-rights-reserved"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://dl.pstmn.io/download/version/12.36.1/linux64), [source 2](https://dl.pstmn.io/download/version/12.36.1/linux_arm64).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing dev-util/postman-bin-12.36.1 into /tmp/codex/dev-util/postman-bin-12.36.1/build/portage/dev-util/postman-bin-12.36.1/image`. Log: `/tmp/codex/dev-util/postman-bin-12.36.1/build.log`. Other architecture: **NOT VERIFIED**.

### dev-util/selenium-ide-bin: 4.0.1_beta14 → 4.1.0_beta3

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD BSD-2 Base64 Boost-1.0 CC-BY-3.0 CC-BY-4.0 Clear-BSD FFT2D FTL IJG ISC LGPL-2 LGPL-2.1 MIT MPL-1.1 MPL-2.0 Ms-PL PSF-2 SGI-B-2.0 SSLeay SunSoft Unicode-3.0 Unicode-DFS-2015 Unlicense UoI-NCSA ZLIB libtiff openssl"`; `KEYWORDS="-* ~amd64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/SeleniumHQ/selenium-ide/v4.1.0-beta.3/LICENSE), [source 2](https://raw.githubusercontent.com/SeleniumHQ/selenium-ide/v4.1.0-beta.3/package.json), [source 3](https://github.com/SeleniumHQ/selenium-ide/releases/download/v4.1.0-beta.3/Selenium-IDE-4.1.0-beta.3.AppImage).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing dev-util/selenium-ide-bin-4.1.0_beta3 into /tmp/codex/dev-util/selenium-ide-bin-4.1.0_beta3/build/portage/dev-util/selenium-ide-bin-4.1.0_beta3/image`. Log: `/tmp/codex/dev-util/selenium-ide-bin-4.1.0_beta3/build.log`. Other architecture: **NOT VERIFIED**.

### dev-util/semgrep-bin: 1.182.0 → 1.185.0

Copy sufficient: **no**. Update immutable PyPI wheel URLs and corresponding license resources; retain the documented local Click/jsonschema/OpenTelemetry compatibility adaptations. Add the version-specific audit document. The native core startup/version test completed. The pre-existing missing OpenTelemetry threading package remains a dependency-resolution limitation.

`LICENSE="LGPL-2.1+ BZIP2 CC0-1.0 HPND ISC LGPL-2+ LGPL-2-with-linking-exception LGPL-3-with-linking-exception Apache-2.0 BSD curl || ( GPL-2+ LGPL-3+ ) || ( BSD GPL-2+ ) || ( libgcc libstdc++ gcc-runtime-library-exception-3.1 ) || ( LGPL-3+ GPL-2+ ) MIT LGPL-2.1 public-domain ZLIB"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://pypi.org/pypi/semgrep/1.185.0/json), [source 2](https://files.pythonhosted.org/packages/f2/13/0d4dc8d124794105f300082c46e3d8ad45eac7af63113b57a5966629b5a3/semgrep-1.185.0-cp310.cp311.cp312.cp313.cp314.py310.py311.py312.py313.py314-none-manylinux_2_34_x86_64.whl), [source 3](https://files.pythonhosted.org/packages/ba/4e/cae05468e1b8c33a18bafb25539f845d6f35e6e58973ebdd2aafa6b387ed/semgrep-1.185.0-cp310.cp311.cp312.cp313.cp314.py310.py311.py312.py313.py314-none-manylinux_2_34_aarch64.whl), [source 4](https://raw.githubusercontent.com/semgrep/semgrep/v1.185.0/LICENSE), [source 5](https://raw.githubusercontent.com/semgrep/semgrep/v1.185.0/cli/src/semdep/external/parsy/LICENSE), [source 6](https://raw.githubusercontent.com/semgrep/semgrep/v1.185.0/cli/src/semdep/external/packaging/LICENSE), [source 7](https://raw.githubusercontent.com/semgrep/semgrep/v1.185.0/cli/src/semdep/external/packaging/LICENSE.APACHE), [source 8](https://raw.githubusercontent.com/semgrep/semgrep/v1.185.0/cli/src/semdep/external/packaging/LICENSE.BSD).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing dev-util/semgrep-bin-1.185.0 into /tmp/codex/dev-util/semgrep-bin-1.185.0/build/portage/dev-util/semgrep-bin-1.185.0/image`. Log: `/tmp/codex/dev-util/semgrep-bin-1.185.0/build.log`. Other architecture: **NOT VERIFIED**.

### dev-util/sonarqube-bin: 26.10.0.133078 → 26.11.0.134175

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="LGPL-3 Sonar-Source-Available-1.0.1 Elastic-2.0 SonarSource-SVNKit-SQLJet 0BSD Apache-2.0 BSD BSD-2 CDDL EPL-1.0 EPL-2.0 GPL-2-with-classpath-exception LGPL-2.1 MIT MPL-1.1 MPL-2.0 public-domain W3C WTFPL-2"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/SonarSource/sonarqube/26.11.0.134175/LICENSE.txt), [source 2](https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-26.11.0.134175.zip).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing dev-util/sonarqube-bin-26.11.0.134175 into /tmp/codex/dev-util/sonarqube-bin-26.11.0.134175/build/portage/dev-util/sonarqube-bin-26.11.0.134175/image`. Log: `/tmp/codex/dev-util/sonarqube-bin-26.11.0.134175/build.log`. Other architecture: **NOT VERIFIED**.

### dev-util/sonarscanner-bin: 8.3.0.16463 → 8.4.0.16527

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="LGPL-3 Apache-2.0 BSD MIT || ( EPL-1.0 LGPL-2.1 )"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/SonarSource/sonar-scanner-cli/8.4.0.16527/LICENSE.txt), [source 2](https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-8.4.0.16527.zip).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing dev-util/sonarscanner-bin-8.4.0.16527 into /tmp/codex/dev-util/sonarscanner-bin-8.4.0.16527/build/portage/dev-util/sonarscanner-bin-8.4.0.16527/image`. Log: `/tmp/codex/dev-util/sonarscanner-bin-8.4.0.16527/build.log`. Other architecture: **NOT VERIFIED**.

### dev-util/trivy: 0.76.1 → 0.76.2

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="Apache-2.0 BSD BSD-2 ISC MIT MPL-2.0 Unicode-DFS-2016 Unlicense public-domain"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/aquasecurity/trivy/v0.76.2/LICENSE), [source 2](https://raw.githubusercontent.com/aquasecurity/trivy/v0.76.2/go.mod), [source 3](https://github.com/aquasecurity/trivy/releases/download/v0.76.2/trivy_0.76.2_Linux-64bit.tar.gz), [source 4](https://github.com/aquasecurity/trivy/releases/download/v0.76.2/trivy_0.76.2_Linux-ARM64.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing dev-util/trivy-0.76.2 into /tmp/codex/dev-util/trivy-0.76.2/build/portage/dev-util/trivy-0.76.2/image`. Log: `/tmp/codex/dev-util/trivy-0.76.2/build.log`. Other architecture: **NOT VERIFIED**.

### dev-vcs/sublime-merge: 2132 → 2136

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="SublimeHQ-EULA"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://download.sublimetext.com/sublime_merge_build_2136_x64.tar.xz), [source 2](https://download.sublimetext.com/sublime_merge_build_2136_arm64.tar.xz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing dev-vcs/sublime-merge-2136 into /tmp/codex/dev-vcs/sublime-merge-2136/build/portage/dev-vcs/sublime-merge-2136/image`. Log: `/tmp/codex/dev-vcs/sublime-merge-2136/build.log`. Other architecture: **NOT VERIFIED**.

### games-engines/trx: 1.11.1 → 1.12

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="GPL-3 LGPL-2.1+ ZLIB"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://github.com/LostArtefacts/TRX/archive/refs/tags/trx-1.12.tar.gz), [source 2](https://github.com/LostArtefacts/TRX/releases/download/trx-1.12/TRX-1.12-Linux.zip).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing games-engines/trx-1.12 into /tmp/codex/games-engines/trx-1.12/build/portage/games-engines/trx-1.12/image`. Log: `/tmp/codex/games-engines/trx-1.12/build.log`. Other architecture: **NOT VERIFIED**.

### games-misc/tui-battleship: 0.1.1 → 0.2.0

Copy sufficient: **no**. The ebuild body can be reused, but its version-specific XDG patch must be rebased. Separate installed assets from XDG config/state paths while preserving the new terminal cursor cleanup.

`LICENSE="GPL-2"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://gitlab.com/christosangel/tui-battleship/-/archive/0.2.0/tui-battleship-0.2.0.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing games-misc/tui-battleship-0.2.0 into /tmp/codex/games-misc/tui-battleship-0.2.0/build/portage/games-misc/tui-battleship-0.2.0/image`. Log: `/tmp/codex/games-misc/tui-battleship-0.2.0/build.log`. Other architecture: **NOT VERIFIED**.

### mail-client/proton-mail: 1.15.1_p20261023 → 1.16.1

Copy sufficient: **no**. Use exact release commit a2e93b9af665f9dcef254d2f182dfd732f592325, update Electron to 43.8.6, and regenerate the filtered 1829-package pnpm closure. Preserve arm64-only keywords. Native arm64 source build completed.

`LICENSE="Apache-2.0 BSD BSD-2 GPL-3 ISC LGPL-2.1+ MIT MPL-2.0 ZLIB"`; `KEYWORDS="~arm64"`.

Upstream evidence: [source 1](https://codeload.github.com/ProtonMail/WebClients/tar.gz/a2e93b9af665f9dcef254d2f182dfd732f592325), [source 2](https://github.com/ProtonMail/WebClients/archive/a2e93b9af665f9dcef254d2f182dfd732f592325.tar.gz), [source 3](https://github.com/electron/electron/releases/download/v43.8.6/electron-v43.8.6-linux-arm64.zip), [source 4](https://registry.npmjs.org/@pnpm/exe.linux-arm64/-/exe.linux-arm64-12.13.0.tgz), [source 5](https://codeload.github.com/electron/node-gyp/tar.gz/06b29aafb7708acef8b3669835c8a7857ebc92d2), [source 6](https://registry.npmjs.org/@adobe/css-tools/-/css-tools-4.4.0.tgz), [source 7](https://registry.npmjs.org/@asamuzakjp/css-color/-/css-color-3.2.0.tgz), [source 8](https://registry.npmjs.org/@babel/code-frame/-/code-frame-7.29.7.tgz).

**VERIFIED**, arm64 on `gentoo`: `>>> Completed installing mail-client/proton-mail-1.16.1 into /tmp/codex/mail-client/proton-mail-1.16.1/build/portage/mail-client/proton-mail-1.16.1/image`. Log: `/tmp/codex/mail-client/proton-mail-1.16.1/arm64-build.log`. Other architecture: **NOT VERIFIED**.

### media-sound/cliamp-bin: 2.3.0 → 2.4.0

Copy sufficient: **no**. Regenerate Go module notices. Retain the older codec notice resource only for the codec versions identified in the new binary; libogg provenance remains a documented limitation. Adapt notice unpacking explicitly.

`LICENSE="MIT Apache-2.0 BSD BSD-2 ISC GPL-3 Unlicense LGPL-2.1 all-rights-reserved"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/bjarneo/cliamp/v2.4.0/LICENSE), [source 2](https://raw.githubusercontent.com/bjarneo/cliamp/v2.4.0/go.mod), [source 3](https://github.com/bjarneo/cliamp/releases/download/v2.4.0/cliamp-linux-amd64), [source 4](https://github.com/bjarneo/cliamp/releases/download/v2.4.0/cliamp-linux-arm64), [source 5](https://github.com/bjarneo/cliamp/archive/refs/tags/v2.4.0.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing media-sound/cliamp-bin-2.4.0 into /tmp/codex/media-sound/cliamp-bin-2.4.0/build/portage/media-sound/cliamp-bin-2.4.0/image`. Log: `/tmp/codex/media-sound/cliamp-bin-2.4.0/build.log`. Other architecture: **NOT VERIFIED**.

### media-sound/lmms: 1.3.0_pre20261019 → 1.3.0_pre20261108

Copy sufficient: **no**. Advance the development snapshot to commit 382ba0117fa604abc06957ab9c0cc27b0772a777. Top-level CMake build metadata is unchanged. Retain pinned submodule inputs and existing license resources; native compilation completed.

`LICENSE="GPL-2+ LGPL-2.1 LGPL-2.1+ MIT WTFPL GPL-3+"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://codeload.github.com/LMMS/lmms/tar.gz/382ba0117fa604abc06957ab9c0cc27b0772a777), [source 2](https://raw.githubusercontent.com/LMMS/lmms/382ba0117fa604abc06957ab9c0cc27b0772a777/LICENSE.txt), [source 3](https://raw.githubusercontent.com/LMMS/lmms/382ba0117fa604abc06957ab9c0cc27b0772a777/CMakeLists.txt), [source 4](https://github.com/LMMS/lmms/archive/382ba0117fa604abc06957ab9c0cc27b0772a777.tar.gz), [source 5](https://github.com/libgme/game-music-emu/archive/21a064ea66a5cdf71910e207c4756095c266814f.tar.gz), [source 6](https://github.com/adplug/adplug/archive/3ed6617ec00022dfab574c27710d9071a6032c87.tar.gz), [source 7](https://github.com/ArashPartow/exprtk/archive/a4b17d543f072d2e3ba564e4bc5c3a0d2b05c338.tar.gz), [source 8](https://github.com/portsmf/portsmf/archive/8856236f97bf3086e76b726f82e91a4b9e086ac1.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing media-sound/lmms-1.3.0_pre20261108 into /tmp/codex/media-sound/lmms-1.3.0_pre20261108/build/portage/media-sound/lmms-1.3.0_pre20261108/image`. Log: `/tmp/codex/media-sound/lmms-1.3.0_pre20261108/build.log`. Other architecture: **NOT VERIFIED**.

### net-im/claude-desktop-bin: 4.29.0 → 4.23118.1

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="all-rights-reserved Apache-2.0 BSD Boost-1.0 FFT2D FTL IJG ISC LGPL-2 LGPL-2.1 MIT MPL-2.0 OFL-1.1 Unicode-3.0 Unicode-DFS-2016 Unlicense ZLIB"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://downloads.claude.ai/claude-desktop/apt/stable/pool/main/c/claude-desktop/claude-desktop_4.23118.1_amd64.deb), [source 2](https://downloads.claude.ai/claude-desktop/apt/stable/pool/main/c/claude-desktop/claude-desktop_4.23118.1_arm64.deb).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing net-im/claude-desktop-bin-4.23118.1 into /tmp/codex/net-im/claude-desktop-bin-4.23118.1/build/portage/net-im/claude-desktop-bin-4.23118.1/image`. Log: `/tmp/codex/net-im/claude-desktop-bin-4.23118.1/build.log`. Other architecture: **NOT VERIFIED**.

### net-im/signal-desktop-bin: 8.33.0_beta1 → 8.35.0_beta1

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="AGPL-3 Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD BSD-2 Base64 Boost-1.0 CC-BY-3.0 CC-BY-4.0 Clear-BSD FFT2D FTL IJG ISC LGPL-2 LGPL-2.1 MIT MPL-1.1 MPL-2.0 Ms-PL PSF-2 SGI-B-2.0 SSLeay SunSoft Unicode-3.0 Unicode-DFS-2015 Unlicense UoI-NCSA ZLIB libtiff openssl Apache-1.1 BlueOak-1.0.0"`; `KEYWORDS="~arm64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/signalapp/Signal-Desktop/v8.35.0-beta.1/LICENSE), [source 2](https://raw.githubusercontent.com/signalapp/Signal-Desktop/v8.35.0-beta.1/package.json), [source 3](https://updates.signal.org/desktop/apt-arm64/pool/s/signal-desktop-beta/signal-desktop-beta_8.35.0-beta.1_arm64.deb).

**VERIFIED**, arm64 on `gentoo`: `>>> Completed installing net-im/signal-desktop-bin-8.35.0_beta1 into /tmp/codex/net-im/signal-desktop-bin-8.35.0_beta1/build/portage/net-im/signal-desktop-bin-8.35.0_beta1/image`. Log: `/tmp/codex/net-im/signal-desktop-bin-8.35.0_beta1/arm64-build.log`. Other architecture: **NOT VERIFIED**.

### net-im/viber: 27.3.0.2 → 29.4.0.7

Copy sufficient: **no**. The new payload no longer needs the old libtiff/JBIG workaround. Remove the libjbig SONAME rewrite and its patchelf/jbigkit dependencies. No ABI mismatch is hidden.

`LICENSE="all-rights-reserved"`; `KEYWORDS="-* ~amd64"`.

Upstream evidence: [source 1](https://download.cdn.viber.com/cdn/desktop/Linux/viber.deb).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing net-im/viber-29.4.0.7 into /tmp/codex/net-im/viber-29.4.0.7/build/portage/net-im/viber-29.4.0.7/image`. Log: `/tmp/codex/net-im/viber-29.4.0.7/build.log`. Other architecture: **NOT VERIFIED**.

### net-misc/expandrive: 2026.10.2_p902 → 2026.11.6_p916

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="all-rights-reserved"`; `KEYWORDS="-* ~amd64"`.

Upstream evidence: [source 1](https://www.expandrive.com/api/download/expandrive?platform=linux&ext=deb).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing net-misc/expandrive-2026.11.6_p916 into /tmp/codex/net-misc/expandrive-2026.11.6_p916/build/portage/net-misc/expandrive-2026.11.6_p916/image`. Log: `/tmp/codex/net-misc/expandrive-2026.11.6_p916/build.log`. Other architecture: **NOT VERIFIED**.

### net-proxy/traefik-bin: 3.7.16 → 3.7.18

Copy sufficient: **no**. The ebuild body is reusable, but regenerate the version-specific notice archive from 358 exact compiled module records.

`LICENSE="MIT Apache-2.0 BSD BSD-2 ISC MPL-2.0"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/traefik/traefik/v3.7.18/LICENSE.md), [source 2](https://raw.githubusercontent.com/traefik/traefik/v3.7.18/go.mod), [source 3](https://github.com/traefik/traefik/releases/download/v3.7.18/traefik_v3.7.18_linux_amd64.tar.gz), [source 4](https://github.com/traefik/traefik/releases/download/v3.7.18/traefik_v3.7.18_linux_arm64.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing net-proxy/traefik-bin-3.7.18 into /tmp/codex/net-proxy/traefik-bin-3.7.18/build/portage/net-proxy/traefik-bin-3.7.18/image`. Log: `/tmp/codex/net-proxy/traefik-bin-3.7.18/build.log`. Other architecture: **NOT VERIFIED**.

### sci-ml/lm-studio-bin: 0.4.26_p4 → 0.4.28_p2

Copy sufficient: **no**. Update the vendor build suffix to 0.4.28-2. Staged validation used cpu_flags_x86_avx2.

`LICENSE="all-rights-reserved"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://installers.lmstudio.ai/linux/x64/0.4.28-2/LM-Studio-0.4.28-2-x64.AppImage), [source 2](https://installers.lmstudio.ai/linux/arm64/0.4.28-2/LM-Studio-0.4.28-2-arm64.AppImage).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing sci-ml/lm-studio-bin-0.4.28_p2 into /tmp/codex/sci-ml/lm-studio-bin-0.4.28_p2/build/portage/sci-ml/lm-studio-bin-0.4.28_p2/image`. Log: `/tmp/codex/sci-ml/lm-studio-bin-0.4.28_p2/build.log`. Other architecture: **NOT VERIFIED**.

### sci-ml/pytorch-metric-learning: 2.9.0 → 3.0.2

Copy sufficient: **no**. Use the new pyproject build backend and underscore-normalized sdist. Remove the obsolete setup.py patch. Follow numpy >=2.5.3 and torch >=2.14, retain optional imports as optional, and install the new THIRD_PARTY_NOTICES. Expand LICENSE to Apache-2.0 BSD BSD-2 MIT from the shipped texts.

`LICENSE="Apache-2.0 BSD BSD-2 MIT"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://pypi.org/pypi/pytorch-metric-learning/3.0.2/json), [source 2](https://files.pythonhosted.org/packages/cf/96/84a70ae0b5c17afe41ab085ec0118cc215b97bb42d2babc6025b44944447/pytorch_metric_learning-3.0.2.tar.gz), [source 3](https://files.pythonhosted.org/packages/source/p/pytorch-metric-learning/pytorch_metric_learning-3.0.2.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing sci-ml/pytorch-metric-learning-3.0.2 into /tmp/codex/sci-ml/pytorch-metric-learning-3.0.2/build/portage/sci-ml/pytorch-metric-learning-3.0.2/image`. Log: `/tmp/codex/sci-ml/pytorch-metric-learning-3.0.2/build.log`. Other architecture: **NOT VERIFIED**.

### sci-visualization/visidata: 3.4 → 3.5

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="GPL-3"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://pypi.org/pypi/visidata/3.5/json), [source 2](https://files.pythonhosted.org/packages/d9/1c/df4179d28dd544646e643e1608cb1dd54ffed6cb00259880e65617452273/visidata-3.5.tar.gz), [source 3](https://files.pythonhosted.org/packages/source/v/visidata/visidata-3.5.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing sci-visualization/visidata-3.5 into /tmp/codex/sci-visualization/visidata-3.5/build/portage/sci-visualization/visidata-3.5/image`. Log: `/tmp/codex/sci-visualization/visidata-3.5/build.log`. Other architecture: **NOT VERIFIED**.

### sys-auth/keycloak-bin: 26.8.1 → 26.8.2

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="Apache-2.0 BSD CC0-1.0 EPL-2.0 MIT POSTGRESQL"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/keycloak/keycloak/26.8.2/LICENSE.txt), [source 2](https://github.com/keycloak/keycloak/releases/download/26.8.2/keycloak-26.8.2.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing sys-auth/keycloak-bin-26.8.2 into /tmp/codex/sys-auth/keycloak-bin-26.8.2/build/portage/sys-auth/keycloak-bin-26.8.2/image`. Log: `/tmp/codex/sys-auth/keycloak-bin-26.8.2/build.log`. Other architecture: **NOT VERIFIED**.

### sys-cluster/egctl-bin: 1.9.3 → 1.10.0

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="Apache-2.0 BSD BSD-2 ISC MIT MPL-2.0"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/envoyproxy/gateway/v1.10.0/LICENSE), [source 2](https://raw.githubusercontent.com/envoyproxy/gateway/v1.10.0/go.mod), [source 3](https://github.com/envoyproxy/gateway/releases/download/v1.10.0/egctl_v1.10.0_linux_amd64.tar.gz), [source 4](https://github.com/envoyproxy/gateway/releases/download/v1.10.0/egctl_v1.10.0_linux_arm64.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing sys-cluster/egctl-bin-1.10.0 into /tmp/codex/sys-cluster/egctl-bin-1.10.0/build/portage/sys-cluster/egctl-bin-1.10.0/image`. Log: `/tmp/codex/sys-cluster/egctl-bin-1.10.0/build.log`. Other architecture: **NOT VERIFIED**.

### sys-cluster/k3s-bin: 1.37.1_p1 → 1.37.2_p1

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="Apache-2.0 BSD MIT BSD BSD-2 CC-BY-SA-4.0 ISC MIT MPL-2.0 POSTGRESQL GPL-2 GPL-3 LGPL-2.1 LGPL-3 ZLIB"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/k3s-io/k3s/v1.37.2+k3s1/LICENSE), [source 2](https://raw.githubusercontent.com/k3s-io/k3s/v1.37.2+k3s1/go.mod), [source 3](https://github.com/k3s-io/k3s/releases/download/v1.37.2+k3s1/k3s), [source 4](https://github.com/k3s-io/k3s/releases/download/v1.37.2+k3s1/k3s-arm64).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing sys-cluster/k3s-bin-1.37.2_p1 into /tmp/codex/sys-cluster/k3s-bin-1.37.2_p1/build/portage/sys-cluster/k3s-bin-1.37.2_p1/image`. Log: `/tmp/codex/sys-cluster/k3s-bin-1.37.2_p1/build.log`. Other architecture: **NOT VERIFIED**.

### sys-cluster/kubescape-bin: 4.0.16 → 4.0.20

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="0BSD Apache-2.0 BSD BSD-2 CC0-1.0 ISC MIT MPL-2.0 Unicode-DFS-2016 Unlicense public-domain"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/kubescape/kubescape/v4.0.20/LICENSE), [source 2](https://raw.githubusercontent.com/kubescape/kubescape/v4.0.20/go.mod), [source 3](https://github.com/kubescape/kubescape/releases/download/v4.0.20/kubescape_4.0.20_linux_amd64.tar.gz), [source 4](https://github.com/kubescape/kubescape/releases/download/v4.0.20/kubescape_4.0.20_linux_arm64.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing sys-cluster/kubescape-bin-4.0.20 into /tmp/codex/sys-cluster/kubescape-bin-4.0.20/build/portage/sys-cluster/kubescape-bin-4.0.20/image`. Log: `/tmp/codex/sys-cluster/kubescape-bin-4.0.20/build.log`. Other architecture: **NOT VERIFIED**.

### sys-cluster/lens-bin: 2026.10.121159 → 2026.11.91422

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="0BSD BlueOak-1.0.0 APSL-2 Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD BSD-2 Base64 Boost-1.0 CC-BY-3.0 CC-BY-4.0 Clear-BSD FFT2D FTL IJG ISC LGPL-2 LGPL-2.1 MIT MPL-1.1 MPL-2.0 Ms-PL PSF-2 SGI-B-2.0 SSLeay SunSoft Unicode-3.0 Unicode-DFS-2015 Unity-Companion-1.3 Unlicense UoI-NCSA ZLIB all-rights-reserved android libtiff openssl unRAR"`; `KEYWORDS="~amd64"`.

Upstream evidence: [source 1](https://downloads.k8slens.dev/ide/Lens-2026.11.91422-latest.amd64.deb).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing sys-cluster/lens-bin-2026.11.91422 into /tmp/codex/sys-cluster/lens-bin-2026.11.91422/build/portage/sys-cluster/lens-bin-2026.11.91422/image`. Log: `/tmp/codex/sys-cluster/lens-bin-2026.11.91422/build.log`. Other architecture: **NOT VERIFIED**.

### sys-process/falco-bin: 0.45.1 → 0.45.2

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="Apache-2.0 BSD BSD-1 BSD-2 curl GPL-2 ISC MIT MPL-2.0 public-domain Unlicense ZLIB || ( public-domain MIT ) || ( LGPL-2.1 BSD-2 ) || ( GPL-2 MIT )"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/falcosecurity/falco/0.45.2/LICENSE), [source 2](https://raw.githubusercontent.com/falcosecurity/falco/0.45.2/COPYING), [source 3](https://raw.githubusercontent.com/falcosecurity/falco/0.45.2/CMakeLists.txt), [source 4](https://download.falco.org/packages/bin/x86_64/falco-0.45.2-x86_64.tar.gz), [source 5](https://download.falco.org/packages/bin/aarch64/falco-0.45.2-aarch64.tar.gz), [source 6](https://raw.githubusercontent.com/falcosecurity/libs/cea7e1d4fa6f64d3855a8e37d784088ae4846891/NOTICES), [source 7](https://raw.githubusercontent.com/falcosecurity/libs/cea7e1d4fa6f64d3855a8e37d784088ae4846891/driver/GPL2.txt), [source 8](https://raw.githubusercontent.com/falcosecurity/libs/cea7e1d4fa6f64d3855a8e37d784088ae4846891/driver/MIT.txt).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing sys-process/falco-bin-0.45.2 into /tmp/codex/sys-process/falco-bin-0.45.2/build/portage/sys-process/falco-bin-0.45.2/image`. Log: `/tmp/codex/sys-process/falco-bin-0.45.2/build.log`. Other architecture: **NOT VERIFIED**.

### www-apps/draw-io: 32.6.1 → 32.6.10

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="Apache-2.0 MIT BSD ZLIB EPL-2.0 LGPL-2.1 CC-BY-4.0 OFL-1.1 drawio-icons"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/jgraph/drawio/v32.6.10/LICENSE), [source 2](https://github.com/jgraph/drawio/archive/refs/tags/v32.6.10.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing www-apps/draw-io-32.6.10 into /tmp/codex/www-apps/draw-io-32.6.10/build/portage/www-apps/draw-io-32.6.10/image`. Log: `/tmp/codex/www-apps/draw-io-32.6.10/build.log`. Other architecture: **NOT VERIFIED**.

### www-apps/kibana-bin: 9.5.5 → 9.5.6

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="0BSD Apache-2.0 Artistic-2 BSD BSD-2 BlueOak-1.0.0 CC-BY-SA-4.0 Elastic-2.0 ISC MIT MPL-2.0 PYTHON Unlicense WTFPL-2 ZLIB icu public-domain"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/elastic/kibana/v9.5.6/LICENSE.txt), [source 2](https://raw.githubusercontent.com/elastic/kibana/v9.5.6/package.json), [source 3](https://artifacts.elastic.co/downloads/kibana/kibana-9.5.6-linux-x86_64.tar.gz), [source 4](https://artifacts.elastic.co/downloads/kibana/kibana-9.5.6-linux-aarch64.tar.gz).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing www-apps/kibana-bin-9.5.6 into /tmp/codex/www-apps/kibana-bin-9.5.6/build/portage/www-apps/kibana-bin-9.5.6/image`. Log: `/tmp/codex/www-apps/kibana-bin-9.5.6/build.log`. Other architecture: **NOT VERIFIED**.

### www-apps/open-webui-bin: 0.12.4 → 0.13.3

Copy sufficient: **no**. Regenerate both architecture wheel reports and 306 immutable distfiles for the private Python 3.12 environment, retaining CPU-only torch 2.10.0. Canonicalize mirror URLs only after exact-byte SHA256 equality checks. New wheels require glibc >=2.34. The new noVNC font license text requires OFL-1.1. The main Open WebUI license text is unchanged except for trailing newline relative to the repository copy.

`LICENSE="Open-WebUI GPL-2+ CC0-1.0 CNRI MIT-0 ZLIB 0BSD Apache-2.0 BSD BSD-2 HPND ISC LGPL-2.1 LGPL-3 LGPL-3+ MIT MPL-2.0 OFL-1.1 PSF-2 Unlicense ZPL || ( Apache-2.0 BSD ) || ( Apache-2.0 BSD-2 ) || ( Apache-2.0 MIT ) || ( BSD Apache-2.0 ) || ( MPL-2.0 MIT )"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://pypi.org/pypi/open-webui/0.13.3/json), [source 2](https://files.pythonhosted.org/packages/b5/b0/67bef782e65b5a6ce5c14cbfc6d264498027044c60e9380e087f8b234a7b/open_webui-0.13.3-py3-none-any.whl), [source 3](https://files.pythonhosted.org/packages/fb/95/adcb68e20c34162e9135f370d6e31737719c2b6f94bc953fe7ed1f10fe21/authlib-1.7.2-py2.py3-none-any.whl), [source 4](https://files.pythonhosted.org/packages/25/ed/e47dec0626edd468c84c04d97769e7ab4ea6457b7f54dcb3f72b17fcd876/Events-0.5-py3-none-any.whl), [source 5](https://files.pythonhosted.org/packages/62/a1/3d680cbfd5f4b8f15abc1d571870c5fc3e594bb582bc3b64ea099db13e56/jinja2-3.1.6-py3-none-any.whl), [source 6](https://files.pythonhosted.org/packages/6d/a0/053d6af3e8f871e0073b4a36732d9e65be77a72e5434c31b94f6af78a6bb/mako-1.4.3-py3-none-any.whl), [source 7](https://files.pythonhosted.org/packages/de/1f/77fa3081e4f66ca3576c896ae5d31c3002ac6607f9747d2e3aa49227e464/markdown-3.10.2-py3-none-any.whl), [source 8](https://files.pythonhosted.org/packages/a3/5e/ecf12fdb62546d64385c158514e9b2b671f7832108ef2ecd2020ce0af2d1/pyjwt-2.13.0-py3-none-any.whl).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing www-apps/open-webui-bin-0.13.3 into /tmp/codex/www-apps/open-webui-bin-0.13.3/build/portage/www-apps/open-webui-bin-0.13.3/image`. Log: `/tmp/codex/www-apps/open-webui-bin-0.13.3/build.log`. Other architecture: **NOT VERIFIED**.

### www-apps/owncloud: 11.0.1 → 11.1.0

Copy sufficient: **yes**. The exact release lib/base.php still requires PHP >=8.3 and <8.6, matching the existing ebuild. The shipped COPYING remains AGPL-3; existing install layout is sufficient.

`LICENSE="AGPL-3 GPL-2"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/owncloud/core/v11.1.0/COPYING), [source 2](https://github.com/owncloud/core/releases/download/v11.1.0/owncloud-11.1.0.tar.bz2).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing www-apps/owncloud-11.1.0 into /tmp/codex/www-apps/owncloud-11.1.0/build/portage/www-apps/owncloud-11.1.0/image`. Log: `/tmp/codex/www-apps/owncloud-11.1.0/build.log`. Other architecture: **NOT VERIFIED**.

### www-apps/selenium-server-bin: 4.51.0 → 4.52.0

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="Apache-2.0 BSD BSD-2 BZIP2 CDLA-Permissive-2.0 ISC MIT MIT-0 MPL-2.0 Unicode-3.0 ZLIB"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://github.com/SeleniumHQ/selenium/releases/download/selenium-4.52.0/selenium-server-4.52.0.jar).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing www-apps/selenium-server-bin-4.52.0 into /tmp/codex/www-apps/selenium-server-bin-4.52.0/build/portage/www-apps/selenium-server-bin-4.52.0/image`. Log: `/tmp/codex/www-apps/selenium-server-bin-4.52.0/build.log`. Other architecture: **NOT VERIFIED**.

### www-client/brave-bin: 1.98.60 → 1.99.56

Copy sufficient: **yes**. Existing ebuild body retained after exact-release metadata and payload inspection; the native staged install completed. No new USE flag or patch was needed.

`LICENSE="Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD BSD-2 Base64 Boost-1.0 CC-BY-3.0 CC-BY-4.0 Clear-BSD FFT2D FTL IJG ISC LGPL-2 LGPL-2.1 MIT MPL-1.1 MPL-2.0 Ms-PL PSF-2 SGI-B-2.0 SSLeay SunSoft Unicode-3.0 Unicode-DFS-2015 Unlicense UoI-NCSA ZLIB libtiff openssl"`; `KEYWORDS="~amd64 ~arm64"`.

Upstream evidence: [source 1](https://raw.githubusercontent.com/brave/brave-browser/v1.99.56/LICENSE), [source 2](https://raw.githubusercontent.com/brave/brave-browser/v1.99.56/package.json), [source 3](https://github.com/brave/brave-browser/releases/download/v1.99.56/brave-browser_1.99.56_amd64.deb), [source 4](https://github.com/brave/brave-browser/releases/download/v1.99.56/brave-browser_1.99.56_arm64.deb).

**VERIFIED**, amd64 on `leonids-pc`: `>>> Completed installing www-client/brave-bin-1.99.56 into /tmp/codex/www-client/brave-bin-1.99.56/build/portage/www-client/brave-bin-1.99.56/image`. Log: `/tmp/codex/www-client/brave-bin-1.99.56/build.log`. Other architecture: **NOT VERIFIED**.

## Changed files

For each package above: added the new versioned ebuild, removed its superseded ebuild, and updated its Manifest where distfiles changed. Only changed-package files and directly related maintenance/reporting resources were edited. Existing historical patch/notice resources and unrelated versions were retained.

Additional resources and maintenance files:

- `dev-util/insomnia/files/insomnia-build.py`
- `scripts/generate-insomnia-npm-deps.py`
- `scripts/generate-openclaw-npm-deps.py`
- `app-admin/semaphore-bin/files/semaphore-bin-2.20.23-third-party-notices.tar.xz`
- `app-misc/openclaw-bin/files/openclaw-bin-2026.11.3-third-party-licenses.txt.gz`
- `app-shells/oh-my-posh-bin/files/oh-my-posh-bin-32.0.0-third-party-notices.tar.xz`
- `dev-util/insomnia/files/insomnia-13.4.0-lockfile.patch`
- `dev-util/semgrep-bin/files/semgrep-1.185.0-license-audit.md`
- `dev-util/semgrep-bin/files/semgrep-1.185.0-notice-index.json`
- `docs/local-ebuild-dependencies-20261110.md`
- `docs/upstream-bumps-20261110-qa.txt`
- `eclass/anki-npm-deps-26.09.4.eclass`
- `eclass/insomnia-npm-deps-13.4.0.eclass`
- `eclass/nimbalyst-npm-deps-0.83.0.eclass`
- `games-misc/tui-battleship/files/tui-battleship-0.2.0-xdg-paths.patch`
- `media-sound/cliamp-bin/files/cliamp-2.4.0-go-notices.tar.xz`
- `net-proxy/traefik-bin/files/traefik-bin-3.7.18-third-party-notices.tar.xz`
- `scripts/audit-go-binary.py`
- `scripts/locks/open-webui-bin-0.13.3-report-aarch64.json`
- `scripts/locks/open-webui-bin-0.13.3-report-x86_64.json`
- `scripts/locks/openclaw-bin-2026.11.3-package-lock.json`
- `scripts/validate-ebuild.py`

Final static command output: `Final static validation: 99 ebuilds, 3 generated eclasses, 5 Python helpers; errors: []`; `Keyword strings unchanged: 99`; `Superseded target ebuilds remaining: 0`. Python helpers were parsed with `ast.parse`; ebuilds/eclasses were checked with `bash -n`.

This report and `docs/upstream-bumps-20261110-evidence.json` are also new reporting files. Cache cleanup is recorded below after the final checks.

**VERIFIED — cache cleanup:** `Removed __pycache__ directories: 2`; `Remaining __pycache__ directories: 0`. Cleanup was confined to this repository and did not follow directory symlinks.

## Review corrections on leonids-pc

The existing staged batch was based on `HEAD cec8578`; repository and ancestor `AGENTS.md` searches found no on-disk file, so the supplied AGENTS.md instructions apply. Initial worktree/index status was recorded before editing. Only the following review paths changed relative to that index: the io-stream versioned ebuild and Manifest; Nimbalyst's generated eclass and generator; the TUI Battleship XDG patch; this report, its evidence index and dependency map; and the new scoped QA output. All unrelated index entries remained byte-for-byte unchanged (`Unrelated index entries changed: 0`). No live package installation or host configuration change occurred.

### Runtime correction

**VERIFIED:** the exact rejected 0.13.2 gemspec requires `openssl >=3.3`; the API and exact gem agree. Ruby 3.3.13 bundles OpenSSL gem 3.2.4 and Ruby 3.4.12 bundles 3.3.3. The old audit's claim that 0.13.2 avoided that requirement was incorrect and has been corrected in `/tmp/codex/dev-ruby/io-stream-0.13.2/audit.json` and this report's evidence index.

**INFERRED from exact source plus VERIFIED tests:** select 0.11.1 as the newest suitable release for both implementations. It retains the SSLSocket timeout/wait compatibility methods removed in 0.12+. An additional 0.13.1 trial activated successfully but failed Ruby 3.3 TLS reads with `undefined method 'timeout' for an instance of OpenSSL::SSL::SSLSocket`; omitting a gemspec dependency alone was insufficient evidence of compatibility. No upstream version requirement was weakened or removed. Existing USE choices, architecture keywords and MIT license remain; EAPI 8 follows the current [ruby-fakegem contract](https://devmanual.gentoo.org/eclass-reference/ruby-fakegem.eclass/index.html).

Fresh non-merging commands used `python scripts/validate-ebuild.py dev-ruby/io-stream/io-stream-0.11.1.ebuild --manifest --build`, which ran `unshare --user --map-auto --map-root-user ebuild <ebuild> clean unpack prepare configure compile install`, exit 0. Sixteen supporting packages, including async-http 0.91.0, were also built into temporary images using unmodified ebuild/package-file copies under a temporary validation repository; no packages were added to this overlay for that closure.

The runtime driver `/tmp/codex/dev-ruby/io-stream-0.11.1/run-runtime-smoke.py` ran each Ruby in the same UID namespace with explicit `GEM_PATH` entries for the 17 staged images and that implementation's bundled gems, an empty temporary `GEM_HOME`, `GEMRC=/dev/null` and empty `RUBYOPT`. It asserts the selected io-stream/async-http versions came from staged images. The complete commands, test source, loaded gem versions/paths and outputs are retained in the evidence JSON. Literal results:

```text
ruby33 exit 0
PASS ruby3.3.13 io-stream=0.11.1 staged activation + buffered read/write/flush/EOF; openssl=3.2.4
PASS ruby3.3.13 io-stream TLS socket-pair read/write with bundled openssl=3.2.4
PASS ruby3.3.13 async-http=0.91.0 client/endpoint load + Async scheduler with staged dependency closure
ruby34 exit 0
PASS ruby3.4.12 io-stream=0.11.1 staged activation + buffered read/write/flush/EOF; openssl=3.3.3
PASS ruby3.4.12 io-stream TLS socket-pair read/write with bundled openssl=3.3.3
PASS ruby3.4.12 async-http=0.91.0 client/endpoint load + Async scheduler with staged dependency closure
```

TLS testing used an in-memory certificate and local socket pair, with a delayed response to force the nonblocking wait path. No external service or network connection was needed.

### Whitespace correction

Nimbalyst's generator now emits `SRC_URI+="` followed by a newline, without a trailing space. Regenerating the eclass returned `{'common': 1578, 'arm64': 17, 'amd64': 17}`; `cmp` against the corrected eclass returned exit 0. Sourcing old/new eclasses and comparing expanded SRC_URI tokens returned `src_uri_tokens_unchanged: True`, `src_uri_token_count: 4843`. No Nimbalyst distfile or build behavior changed, so its full source build was not repeated.

The TUI Battleship patch was regenerated as valid unified diff with zero context; single-space blank context lines were not stripped. Both old and new patches applied to the exact pristine 0.2.0 source with `patch --batch --fuzz=0 -p1`, exit 0. The patched outputs were byte-identical, SHA256 `9eb5418b09e7be64927d752c980ce9adf823e74e502d098af8c04707b3fe12ae`. `bash -n` returned exit 0, followed by another non-merging staged build/install, exit 0. No patch whitespace exception or Git whitespace configuration change is needed.

Manifests were regenerated with `pkgdev manifest` for io-stream, Nimbalyst and TUI Battleship, all exit 0. Nimbalyst/TUI distfile sets remained unchanged; io-stream now records only the selected 0.11.1 gem. The regenerated local dependency map includes all conditional branches (`matchall=True`), correcting the previous omission: `Mapped 347 ebuilds / 343 packages / 382 local dependency atoms (all conditional branches).` The version/slot check returned `Selected-version/slot atom mismatches: 0`.

### Current validation states

The initial full staged whitespace check returned exit 2 with five findings, while the worktree-only check returned exit 0. Current full checks were run separately, with no path exclusions or whitespace exceptions:

```text
git diff --cached --check   exit 0, output ''   (index versus HEAD)
git diff --check            exit 0, output ''   (worktree versus index)
git diff HEAD --check       exit 0, output ''   (combined final content versus HEAD)
```

Scoped `pkgcheck scan` ran against worktree contents for io-stream, async-http, Nimbalyst and TUI Battleship, exit 0. Package inputs in the final index were checked for equality with those validated worktree inputs. [Literal scoped QA output](upstream-bumps-20261110-review-qa.txt) contains ten findings: all ten match the pre-review baseline after version-prefix normalization; `introduced_findings: []`. These are the existing async-pool arm64 keyword limitation, compatibility suggestions, Nimbalyst x32/musl findings and TUI archive-compression suggestion. Exit 0 is not a claim of no findings.

The actual Portage pretend resolver, using isolated config/cache paths and `emerge --pretend --verbose --autounmask=n --backtrack=0 =dev-ruby/io-stream-0.11.1 =dev-ruby/async-http-0.91.0`, returned exit 0 and `Total: 16 packages (16 new), Size of downloads: 4,317 KiB`. This is a proposed dependency plan only. No merge command was run.

**NOT VERIFIED:** native arm64 build/runtime coverage for this correction; full upstream test suites; every async-http protocol/feature or interactive TUI behavior. All new Ruby runtime tests ran on amd64 `leonids-pc`; arm64 keywords remain unchanged. Nimbalyst received regeneration, syntax and URI-equivalence validation rather than another full build.
