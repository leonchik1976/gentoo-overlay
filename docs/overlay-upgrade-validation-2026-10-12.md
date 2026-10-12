# Overlay upgrade validation — 2026-10-12

All 14 eligible packages were bumped. After successful non-merging package-image builds on both architectures, 18 superseded ebuilds and their metadata caches were removed. Manifests were regenerated. `/tmp/report.txt` remains a package-name-only list.

## Versions and authoritative release sources

| Package | Previous latest | New | Source |
|---|---|---|---|
| app-admin/argocd-cli-bin | 3.5.4 | 3.5.5 | [Upstream](https://github.com/argoproj/argo-cd/releases/tag/v3.5.5) |
| app-editors/cursor | 3.24.9 | 3.24.12 | [Upstream](https://api2.cursor.sh/updates/api/download/stable/linux-x64/cursor) |
| app-misc/grok-bot-bin | 0.68.1 | 0.70.2 | [Upstream](https://api2.cursor.sh/updates/api/download/stable/linux-x64/sand) |
| app-misc/openclaw-bin | 2026.9.9 | 2026.10.2 | [Upstream](https://registry.npmjs.org/openclaw/latest) |
| app-shells/oh-my-posh-bin | 31.7.0 | 31.8.0 | [Upstream](https://github.com/JanDeDobbeleer/oh-my-posh/releases/tag/v31.8.0) |
| dev-db/clickhouse-bin | 26.9.14.10 | 26.9.16.11 | [Upstream](https://github.com/ClickHouse/ClickHouse/releases/tag/v26.9.16.11-stable) |
| dev-db/clickhouse-client-bin | 26.9.14.10 | 26.9.16.11 | [Upstream](https://github.com/ClickHouse/ClickHouse/releases/tag/v26.9.16.11-stable) |
| dev-db/clickhouse-common-static-bin | 26.9.14.10 | 26.9.16.11 | [Upstream](https://github.com/ClickHouse/ClickHouse/releases/tag/v26.9.16.11-stable) |
| dev-python/pipx | 1.17.12 | 1.17.14 | [Upstream](https://pypi.org/pypi/pipx/1.17.14/json) |
| dev-python/posthog | 7.67.0 | 7.68.0 | [Upstream](https://pypi.org/pypi/posthog/7.68.0/json) |
| dev-util/mise-bin | 2026.10.7 | 2026.10.8 | [Upstream](https://github.com/jdx/mise/releases/tag/v2026.10.8) |
| dev-util/postman-bin | 12.31.7 | 12.32.0 | [Upstream](https://dl.pstmn.io/api/version/latest?platform=linux64&channel=stable) |
| dev-util/sonarqube-bin | 26.9.0.129388 | 26.10.0.133078 | [Upstream](https://github.com/SonarSource/sonarqube/releases/tag/26.10.0.133078) |
| www-apps/open-webui-bin | 0.11.4 | 0.12.0 | [Upstream](https://pypi.org/pypi/open-webui/0.12.0/json) |

## Packaging changes

The three ClickHouse packages retain identical versions and their dependency relationships. Cursor and Grok release build identifiers were updated. Openclaw’s runtime npm lock and bundled dependency/license inventories were regenerated from the exact release; its new license inventory is compressed. Oh My Posh’s embedded Go module inventory and x/sys dependency were updated. Pipx and Posthog retain EAPI 8 because distutils-r1 supports EAPI 8; other inherited eclasses similarly restrict several binary recipes. Existing Posthog patches remain, including the older-named HTTPX patch still used by the new recipe.

Open WebUI 0.12.0 has regenerated architecture-specific, CPU-only Python wheel closures and retained resolver reports. The wheel generator adds an explicit --resolved-only mode because this release resolves OmegaConf and headless OpenCV directly; obsolete Antlr compilation and RapidOCR metadata rewriting were removed. The resulting private environment contains 242 distributions. Existing generator behavior remains the default.

Changed files comprise the 14 new ebuilds and Manifests, their generated md5 caches, removed superseded ebuilds/caches, the new Openclaw npm lock and compressed license inventory, the new Oh My Posh notice, the Open WebUI generator and two resolver reports, and this report. Superseded Openclaw 2026.9.9 lock/license resources and Oh My Posh 31.6.0/31.7.0 notices were removed. Older historical orphan resources were left alone. The six excluded packages and synchronized Elastic packages were not changed.

## VERIFIED: builds and commands

Each package ran `ebuild <new-ebuild> unpack prepare configure compile install` inside a network-isolated bubblewrap sandbox with a read-only live root, writable package-specific /tmp/codex workspace, and DISTDIR pointing to previously downloaded artifacts. Argo CD also ran its test phase. Some recipes required `sudo -n bwrap` for ownership in their temporary package images. No merge or installation phase was run.

| Package | amd64 host server01 | native arm64 host gentoo |
|---|---|---|
| app-admin/argocd-cli-bin-3.5.5 | completed install, exit 0 | completed install, exit 0 |
| app-editors/cursor-3.24.12 | completed install, exit 0 | completed install, exit 0 |
| app-misc/grok-bot-bin-0.70.2 | completed install, exit 0 | completed install, exit 0 |
| app-misc/openclaw-bin-2026.10.2 | completed install, exit 0 | completed install, exit 0 |
| app-shells/oh-my-posh-bin-31.8.0 | completed install, exit 0 | completed install, exit 0 |
| dev-db/clickhouse-bin-26.9.16.11 | completed install, exit 0 | completed install, exit 0 |
| dev-db/clickhouse-client-bin-26.9.16.11 | completed install, exit 0 | completed install, exit 0 |
| dev-db/clickhouse-common-static-bin-26.9.16.11 | completed install, exit 0 | completed install, exit 0 |
| dev-python/pipx-1.17.14 | completed install, exit 0 | completed install, exit 0 |
| dev-python/posthog-7.68.0 | completed install, exit 0 | completed install, exit 0 |
| dev-util/mise-bin-2026.10.8 | completed install, exit 0 | completed install, exit 0 |
| dev-util/postman-bin-12.32.0 | completed install, exit 0 | completed install, exit 0 |
| dev-util/sonarqube-bin-26.10.0.133078 | completed install, exit 0 | completed install, exit 0 |
| www-apps/open-webui-bin-0.12.0 | completed install, exit 0 | completed install, exit 0 |

Native arm64 builds used staging directories `/tmp/codex/<category>/<package>-<version>/bump-20261012-arm64` on gentoo. The remote overlay checkout was not edited. Logs and exit files were copied back into each local `/tmp/codex/<category>/<package>-<version>/bump-20261012` directory as `build-arm64.log` and `build-arm64.exit`; local logs are `build-amd64.log`. The native arm64 orchestration output was:

```
SUMMARY [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
```

Open WebUI’s build printed:

```
private dependency metadata check: 242 distributions satisfied
```

For each package, `pkgdev manifest -d <workspace>/distfiles <category/package>` returned exit 0 after cleanup. Scoped `egencache --update --repo local --jobs 4 --cache-dir <temporary-cache> --repositories-configuration <explicit-dev-repo-config> <14 package atoms>` returned exit 0 inside sudo bubblewrap, writing only the development repository’s metadata cache and temporary workspace. Initial unprivileged attempts failed on Portage’s group ownership requirements; those were not successful validation.

`pkgcheck scan --cache-dir /tmp/codex/dev-python/pipx-1.17.14/bump-20261012/pkgcheck-cache <14 package atoms>` returned exit 0. Its output is retained at `/tmp/codex/dev-python/pipx-1.17.14/bump-20261012/cleanup-pkgcheck.log`; it is not empty:

```
dev-db/clickhouse-common-static-bin
  NonsolvableDepsInDev: version 26.9.16.11: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total): solutions: [ >=sys-libs/glibc-2.17 ]
  RequiredUseDefaults: version 26.9.16.11: profile: 'default/linux/amd64/23.0/musl' (6 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 26.9.16.11: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total)

dev-util/mise-bin
  RequiredUseDefaults: version 2026.10.8: profile: 'default/linux/amd64/23.0/musl' (6 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 2026.10.8: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total)

dev-util/sonarqube-bin
  NonsolvableDepsInDev: version 26.10.0.133078: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total): solutions: [ sys-libs/glibc ]
  RequiredUseDefaults: version 26.10.0.133078: profile: 'default/linux/amd64/23.0/musl' (6 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 26.10.0.133078: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total)

app-misc/grok-bot-bin
  NonsolvableDepsInDev: version 0.70.2: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total): solutions: [ >=sys-libs/glibc-2.38 ]

dev-util/postman-bin
  NonsolvableDepsInDev: version 12.32.0: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total): solutions: [ >=sys-libs/glibc-2.34 ]

app-editors/cursor
  NonsolvableDepsInDev: version 3.24.12: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total): solutions: [ >=sys-libs/glibc-2.28 ]

app-misc/openclaw-bin
  NonsolvableDepsInDev: version 2026.10.2: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total): solutions: [ sys-libs/glibc ]
  NonsolvableDepsInDev: version 2026.10.2: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/x32): solutions: [ <net-libs/nodejs-25, >=net-libs/nodejs-24.16.0, >=net-libs/nodejs-26.1.0 ]
  RequiredUseDefaults: version 2026.10.2: profile: 'default/linux/amd64/23.0/musl' (6 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 2026.10.2: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total)

www-apps/open-webui-bin
  PythonCompatUpdate: version 0.12.0: PYTHON_COMPAT updates available: python3_13, python3_14, python3_15
```

## INFERRED and NOT VERIFIED

The musl/x32 findings correspond to limitations already present in the previous recipes. WebUI retains Python 3.12 because its exact upstream metadata requires Python >=3.11,<3.13.0a1; the scanner’s suggested later Python versions are not eligible. No interactive GUI or production service tests were performed. Non-merging builds validate recipe phases and package-image creation, not deployment.

Posthog’s separate test attempt could not start because the host lacks the pytest-asyncio distribution; its literal error was `importlib.metadata.PackageNotFoundError: No package metadata was found for pytest-asyncio`. No live dependency was installed to remedy this. Pipx’s existing offline test restriction was retained; [Gentoo bug 971387](https://bugs.gentoo.org/971387) is RESOLVED FIXED and concerns removal, so it should not be described as an unresolved test bug. Full Python test suites and interactive/runtime integration validation remain for the user.

Both amd64 and arm64 received real non-merging build validation on server01 and gentoo respectively. Binary packages unpack and construct images during these phases; this is not compilation of their upstream native binaries. Source Python packages ran their build phases. Openclaw and WebUI installed bundled dependencies only into temporary images.

## Official references consulted

- [PMS](https://projects.gentoo.org/pms/): EAPI and ebuild semantics; EAPI 9 is current, while installed inherited eclasses require EAPI 8 for these recipes.
- [Devmanual dependency variables](https://devmanual.gentoo.org/ebuild-writing/variables/): dependency declarations.
- [Gentoo eclass reference](https://devmanual.gentoo.org/eclass-reference/): current inherited eclass contracts, supplemented by /var/db/repos/gentoo/eclass implementations.
- Exact upstream release URLs in the table, source archives, Python pyproject/PKG-INFO metadata and license text, npm package metadata/lock, embedded Go build metadata, and Cargo.lock.
- ::gentoo and ::guru searches provided prior-art investigation; upstream artifacts remain the authority for version/dependency/license changes.

No live-system merge or installation, commit, push, branch operation, or ::local sync was performed.

