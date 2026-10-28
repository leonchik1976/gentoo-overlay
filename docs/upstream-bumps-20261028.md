# Upstream bumps — 2026-10-28

Thirty packages were updated, their superseded ebuilds removed, and their Manifests regenerated. The initial 33-package candidate list was refined after inspecting exact release artifacts: GPaste and Semgrep are blocked, and Brave has no newer suitable stable release. No branch, commit, push, live-system installation, merge, or qmerge was performed.

## Package decisions and architecture coverage

VERIFIED below means a native non-merging ebuild build reached the staged install phase with command exit 0. For binary packages this validates unpacking, preparation and image assembly; it does not claim recompilation of the upstream binary. NOT VERIFIED means no native build was run for that architecture. All three arm64-only packages keep arm64-only keywords; all other bumped packages keep their existing two keywords.

| Package | Old → new | Copy alone sufficient? | amd64 | arm64 | Exact release evidence |
| --- | --- | --- | --- | --- | --- |
| [app-admin/kiro-cli-bin](../app-admin/kiro-cli-bin/kiro-cli-bin-2.34.0.ebuild) | 2.33.1 → 2.34.0 | Yes: the existing phase logic, dependency constraints, USE behavior, patches and installed layout remain suitable; only versioned inputs/comments change. | VERIFIED: leonids-pc | NOT VERIFIED; user validation remains | [artifact](https://prod.download.cli.kiro.dev/stable/2.34.0/kirocli-x86_64-linux.tar.gz) |
| [app-editors/cursor](../app-editors/cursor/cursor-3.27.22.ebuild) | 3.27.12 → 3.27.22 | No: replace the upstream BUILD_ID; payload layout and Chromium notice texts remain compatible. | VERIFIED: leonids-pc | NOT VERIFIED; user validation remains | [artifact](https://downloads.cursor.com/production/b1aa50cb6db84fd3e8c808259cb172ea73425c1f/linux/x64/deb/amd64/deb/cursor_3.27.22_amd64.deb) |
| [app-misc/chatgpt-bin](../app-misc/chatgpt-bin/chatgpt-bin-26.1023.51421.ebuild) | 26.1021.22027 → 26.1023.51421 | Yes: the existing phase logic, dependency constraints, USE behavior, patches and installed layout remain suitable; only versioned inputs/comments change. | VERIFIED: leonids-pc | NOT VERIFIED; user validation remains | [artifact](https://persistent.oaistatic.com/codex-app-prod/linux/deb/pool/main/c/chatgpt/chatgpt_26.1023.51421_amd64.deb) |
| [app-misc/grok-bot-bin](../app-misc/grok-bot-bin/grok-bot-bin-0.77.0.ebuild) | 0.75.5 → 0.77.0 | No: replace MY_BUILD; retain the existing native payload handling and licenses. | VERIFIED: leonids-pc | NOT VERIFIED; user validation remains | [artifact](https://downloads.cursor.com/grokbot/stable/fe85646036572e2b9a531b337a0dcb56a32f9369/linux/x64/grok-bot_0.77.0_amd64.deb) |
| [app-misc/openclaw-bin](../app-misc/openclaw-bin/openclaw-bin-2026.10.8.ebuild) | 2026.10.7 → 2026.10.8 | No: regenerate the runtime lock, offline arrays, and compressed notice inventory; decompress notices before dodoc to avoid the compressed-document QA finding. | VERIFIED: leonids-pc | NOT VERIFIED; user validation remains | [artifact](https://registry.npmjs.org/openclaw/-/openclaw-2026.10.8.tgz) |
| [app-text/zettlr-bin](../app-text/zettlr-bin/zettlr-bin-4.9.0.ebuild) | 4.8.0 → 4.9.0 | Yes: the existing phase logic, dependency constraints, USE behavior, patches and installed layout remain suitable; only versioned inputs/comments change. | VERIFIED: leonids-pc | NOT VERIFIED; user validation remains | [artifact](https://github.com/Zettlr/Zettlr/releases/download/v4.9.0/Zettlr-4.9.0-x86_64.AppImage) |
| [dev-db/dbgate-bin](../dev-db/dbgate-bin/dbgate-bin-7.3.3.ebuild) | 7.3.2 → 7.3.3 | No: update Oracle to 26.0.0; select the new SQLite prebuild layout; remove foreign/musl addons at their new paths; account for absent EGL/GLES files and an architecture-specific sandbox helper; require glibc >=2.34. | VERIFIED: leonids-pc | VERIFIED: gentoo | [artifact](https://github.com/dbgate/dbgate/releases/download/v7.3.3/dbgate-7.3.3-linux_x86_64.AppImage) |
| [dev-db/mongodb-compass](../dev-db/mongodb-compass/mongodb-compass-1.53.2.ebuild) | 1.53.1 → 1.53.2 | No: regenerate the release-specific npm eclass; keep Electron 45.0.0, libmongocrypt 1.20.1, and C driver 2.3.3 after checking the new lock; add EPL-2.0 and MIT-0 for shipped npm code. | N/A: not keyworded | VERIFIED: gentoo | [artifact](https://github.com/mongodb-js/compass/archive/refs/tags/v1.53.2.tar.gz) |
| [dev-db/postgresql_anonymizer](../dev-db/postgresql_anonymizer/postgresql_anonymizer-3.3.0.ebuild) | 3.2.3 → 3.3.0 | No: regenerate 351 Cargo.lock entries and require cargo-pgrx 0.19.3. Upstream Cargo.toml still calls the release 3.3.0-dev, and the staged SQL filename follows that upstream version. | VERIFIED: leonids-pc | NOT VERIFIED; user validation remains | [artifact](https://gitlab.com/dalibo/postgresql_anonymizer/-/archive/3.3.0/postgresql_anonymizer-3.3.0.tar.bz2) |
| [dev-python/boto3-stubs](../dev-python/boto3-stubs/boto3-stubs-1.43.120.ebuild) | 1.43.118 → 1.43.120 | Yes: the existing phase logic, dependency constraints, USE behavior, patches and installed layout remain suitable; only versioned inputs/comments change. | VERIFIED: leonids-pc | NOT VERIFIED; user validation remains | [artifact](https://files.pythonhosted.org/packages/source/b/boto3-stubs/boto3_stubs-1.43.120.tar.gz) |
| [dev-python/botocore-stubs](../dev-python/botocore-stubs/botocore-stubs-1.43.120.ebuild) | 1.43.118 → 1.43.120 | Yes: the existing phase logic, dependency constraints, USE behavior, patches and installed layout remain suitable; only versioned inputs/comments change. | VERIFIED: leonids-pc | NOT VERIFIED; user validation remains | [artifact](https://files.pythonhosted.org/packages/source/b/botocore-stubs/botocore_stubs-1.43.120.tar.gz) |
| [dev-python/glances-api](../dev-python/glances-api/glances-api-0.11.0.ebuild) | 0.10.0 → 0.11.0 | Yes: the existing phase logic, dependency constraints, USE behavior, patches and installed layout remain suitable; only versioned inputs/comments change. | VERIFIED: leonids-pc | NOT VERIFIED; user validation remains | [artifact](https://github.com/home-assistant-ecosystem/python-glances-api/archive/0.11.0.tar.gz) |
| [dev-python/mypy-boto3-ecr](../dev-python/mypy-boto3-ecr/mypy-boto3-ecr-1.43.119.ebuild) | 1.43.73 → 1.43.119 | Yes: the existing phase logic, dependency constraints, USE behavior, patches and installed layout remain suitable; only versioned inputs/comments change. | VERIFIED: leonids-pc | NOT VERIFIED; user validation remains | [artifact](https://files.pythonhosted.org/packages/source/m/mypy-boto3-ecr/mypy_boto3_ecr-1.43.119.tar.gz) |
| [dev-python/pipx](../dev-python/pipx/pipx-1.18.6.ebuild) | 1.18.4 → 1.18.6 | No: add hatch-fancy-pypi-readme >=25.1 to BDEPEND for the new dynamic readme build hook. | VERIFIED: leonids-pc | NOT VERIFIED; user validation remains | [artifact](https://github.com/pypa/pipx/archive/1.18.6.tar.gz) |
| [dev-python/posthog](../dev-python/posthog/posthog-7.76.0.ebuild) | 7.75.11 → 7.76.0 | Yes: the existing phase logic, dependency constraints, USE behavior, patches and installed layout remain suitable; only versioned inputs/comments change. | VERIFIED: leonids-pc | NOT VERIFIED; user validation remains | [artifact](https://github.com/PostHog/posthog-python/archive/refs/tags/posthog-v7.76.0.tar.gz) |
| [dev-python/qh3](../dev-python/qh3/qh3-2.1.0.ebuild) | 2.0.4 → 2.1.0 | No: regenerate the 186-crate closure; Rust >=1.88 remains sufficient for its locked manifests. | VERIFIED: leonids-pc | NOT VERIFIED; user validation remains | [artifact](https://files.pythonhosted.org/packages/source/q/qh3/qh3-2.1.0.tar.gz) |
| [dev-python/urllib3-future](../dev-python/urllib3-future/urllib3-future-2.25.904.ebuild) | 2.25.903 → 2.25.904 | Yes: the existing phase logic, dependency constraints, USE behavior, patches and installed layout remain suitable; only versioned inputs/comments change. | VERIFIED: leonids-pc | NOT VERIFIED; user validation remains | [artifact](https://files.pythonhosted.org/packages/source/u/urllib3-future/urllib3_future-2.25.904.tar.gz) |
| [dev-util/github-copilot-bin](../dev-util/github-copilot-bin/github-copilot-bin-1.1.33.ebuild) | 1.1.32 → 1.1.33 | Yes: the existing phase logic, dependency constraints, USE behavior, patches and installed layout remain suitable; only versioned inputs/comments change. | VERIFIED: leonids-pc | NOT VERIFIED; user validation remains | [artifact](https://github.com/github/app/releases/download/v1.1.33/GitHub-Copilot-linux-x64.deb) |
| [dev-util/github-copilot-cli-bin](../dev-util/github-copilot-cli-bin/github-copilot-cli-bin-1.0.105.ebuild) | 1.0.103 → 1.0.105 | Yes: the existing phase logic, dependency constraints, USE behavior, patches and installed layout remain suitable; only versioned inputs/comments change. | VERIFIED: leonids-pc | NOT VERIFIED; user validation remains | [artifact](https://github.com/github/copilot-cli/releases/download/v1.0.105/copilot-linux-x64.tar.gz) |
| [dev-util/mise-bin](../dev-util/mise-bin/mise-bin-2026.10.21.ebuild) | 2026.10.18 → 2026.10.21 | Yes: the existing phase logic, dependency constraints, USE behavior, patches and installed layout remain suitable; only versioned inputs/comments change. | VERIFIED: leonids-pc | NOT VERIFIED; user validation remains | [artifact](https://github.com/jdx/mise/releases/download/v2026.10.21/mise-v2026.10.21-linux-x64.tar.gz) |
| [dev-util/postman-bin](../dev-util/postman-bin/postman-bin-12.34.2.ebuild) | 12.33.4 → 12.34.2 | Yes: the existing phase logic, dependency constraints, USE behavior, patches and installed layout remain suitable; only versioned inputs/comments change. | VERIFIED: leonids-pc | NOT VERIFIED; user validation remains | [artifact](https://dl.pstmn.io/download/version/12.34.2/linux64) |
| [dev-util/sonarscanner-bin](../dev-util/sonarscanner-bin/sonarscanner-bin-8.3.0.16463.ebuild) | 8.2.0.6438 → 8.3.0.16463 | Yes: the existing phase logic, dependency constraints, USE behavior, patches and installed layout remain suitable; only versioned inputs/comments change. | VERIFIED: leonids-pc | NOT VERIFIED; user validation remains | [artifact](https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-8.3.0.16463.zip) |
| [mail-client/betterbird-bin](../mail-client/betterbird-bin/betterbird-bin-153.6.0.ebuild) | 153.5.0 → 153.6.0 | No: change the upstream suffix to bb12; include GPL-2 and LGPL-2.1 from the bundled licensing information. | VERIFIED: leonids-pc | NOT VERIFIED; user validation remains | [artifact](https://www.betterbird.eu/downloads/LinuxArchive/betterbird-153.6.0esr-bb12.en-US.linux-x86_64.tar.xz) |
| [media-sound/plexamp](../media-sound/plexamp/plexamp-4.50.20.ebuild) | 4.50.19 → 4.50.20 | Yes: the existing phase logic, dependency constraints, USE behavior, patches and installed layout remain suitable; only versioned inputs/comments change. | VERIFIED: leonids-pc | NOT VERIFIED; user validation remains | [artifact](https://plexamp.plex.tv/desktop/Plexamp-4.50.20-x86_64.AppImage) |
| [media-video/aegisub](../media-video/aegisub/aegisub-3.5.1.ebuild) | 3.5.0 → 3.5.1 | No: stop applying the now-upstream Lua BOM patch. Keep the recovery and Lua error-unwind patches; both apply to the new source. | N/A: not keyworded | VERIFIED: gentoo | [artifact](https://github.com/TypesettingTools/Aegisub/releases/download/v3.5.1/aegisub-3.5.1.tar.xz) |
| [net-analyzer/gsa](../net-analyzer/gsa/gsa-28.7.0.ebuild) | 28.6.0 → 28.7.0 | No: update the arm64 Rolldown pin to 1.2.13 and SWC to 1.16.13 from the exact upstream lock; other native pins and build output remain unchanged. | N/A: not keyworded | VERIFIED: gentoo | [artifact](https://github.com/greenbone/gsa/archive/v28.7.0.tar.gz) |
| [net-im/claude-desktop-bin](../net-im/claude-desktop-bin/claude-desktop-bin-4.29.0.ebuild) | 3.6556.2 → 4.29.0 | Yes: the existing phase logic, dependency constraints, USE behavior, patches and installed layout remain suitable; only versioned inputs/comments change. | VERIFIED: leonids-pc | NOT VERIFIED; user validation remains | [artifact](https://downloads.claude.ai/claude-desktop/apt/stable/pool/main/c/claude-desktop/claude-desktop_4.29.0_amd64.deb) |
| [sys-cluster/egctl-bin](../sys-cluster/egctl-bin/egctl-bin-1.9.3.ebuild) | 1.9.2 → 1.9.3 | Yes: the existing phase logic, dependency constraints, USE behavior, patches and installed layout remain suitable; only versioned inputs/comments change. | VERIFIED: leonids-pc | NOT VERIFIED; user validation remains | [artifact](https://github.com/envoyproxy/gateway/releases/download/v1.9.3/egctl_v1.9.3_linux_amd64.tar.gz) |
| [sys-cluster/kubectl-convert](../sys-cluster/kubectl-convert/kubectl-convert-1.37.2.ebuild) | 1.37.1 → 1.37.2 | Yes: the existing phase logic, dependency constraints, USE behavior, patches and installed layout remain suitable; only versioned inputs/comments change. | VERIFIED: leonids-pc | NOT VERIFIED; user validation remains | [artifact](https://github.com/kubernetes/kubernetes/archive/v1.37.2.tar.gz) |
| [www-apps/open-webui-bin](../www-apps/open-webui-bin/open-webui-bin-0.12.4.ebuild) | 0.12.3 → 0.12.4 | No: regenerate both cp312 resolver reports and the private wheel closure, retain CPU-only PyTorch, and include GPL-2+ for the bundled x264/x265 code. | VERIFIED: leonids-pc | NOT VERIFIED; user validation remains | [artifact](https://files.pythonhosted.org/packages/d5/68/ba67840b98eb35636dbfb0685a6b4c3c02e26bd60e500f56d2e52216c13c/open_webui-0.12.4-py3-none-any.whl) |

No new USE flags or optional-runtime convenience dependencies were introduced. Existing USE choices were reviewed against the new build metadata; the builds do not cover every USE combination.

## Candidates retained unchanged

- **dev-util/semgrep-bin**: PyPI 1.182.1 changes semgrep-core, but upstream publishes only source tag v1.182.0. Exact v1.182.1 source and license/notice URLs return HTTP 404; retaining the current ebuild rather than substituting mismatched sources.
- **www-client/brave-bin**: No newer suitable stable release: v1.100.37 is explicitly Nightly, despite GitHub prerelease=false. Latest stable release and stable Debian assets remain v1.98.60.
- **x11-misc/gpaste**: Requires GLib >=2.90.0, GTK >=4.24.0 and libadwaita >=1.10.0; required versions are absent from the available Gentoo tree.

Semgrep evidence: [exact PyPI metadata](https://pypi.org/pypi/semgrep/1.182.1/json), [public tag query](https://api.github.com/repos/semgrep/semgrep/git/matching-refs/tags/v1.182), and the HTTP 404 responses for the requested v1.182.1 source and notice URLs. The amd64 wheel comparison found a changed `semgrep-core`, so substituting v1.182.0 source was rejected. The newer wheel also adds a certifi requirement, but the source/licensing prerequisite blocks the bump before changing its dependencies.

Brave evidence: [v1.100.37 release metadata](https://api.github.com/repos/brave/brave-browser/releases/tags/v1.100.37) names the release Nightly and supplies `brave-browser-nightly` artifacts; the stable v1.98.60 artifacts match the existing ebuild.

GPaste evidence: [v51.2 meson.build](https://github.com/Keruspe/GPaste/blob/v51.2/meson.build) requires GLib 2.90.0, GTK 4.24.0 and libadwaita 1.10.0. The available `::gentoo` paths contain GLib 2.88.2/2.88.3, GTK up to 4.22.5-r1, and libadwaita up to 1.9.4. The older GPaste ebuilds and their pre-existing dependency findings were preserved.

## License and source audit

VERIFIED source records are retained under each `/tmp/codex/<category>/<package>-<new-version>/` workspace. `audit.json` records artifact URLs and prior-art paths; `inspection/` contains archive inventories and extracted notice texts where applicable.

- The eight Python package source distributions were inspected for build backends, runtime bounds, extras and shipped primary license texts. The MIT texts for boto3-stubs, botocore-stubs, glances-api, mypy-boto3-ecr, pipx, posthog and urllib3-future match their cached previous source archives. qh3 retains its BSD grant and its dependent-crate license union. PostHog’s existing patches were dry-run checked and then applied by its actual build; one test-file hunk applies with an offset. No runtime dependency was added for upstream test-only or optional imports.
- qh3’s 186 and PostgreSQL anonymizer’s 351 crate archives were checked against their exact upstream Cargo.lock SHA256 values. Their crate manifests and license/notice inventories are recorded in `crate-license-audit.json`. The existing license unions cover the new locked expressions.
- Mise’s exact [release Cargo.lock](https://github.com/jdx/mise/blob/v2026.10.21/Cargo.lock) was checked against 1,145 crate archives and their shipped Cargo manifests; the existing license union covers the resulting expressions.
- egctl’s binary build information identified 261 exact module versions and hashes. `go mod download -json` returned matching module sums, and every module has root notices. Their Apache/BSD/ISC/MIT/MPL license families fit the existing union. See `binary-buildinfo.txt` and `go-module-license-audit.json` in its workspace.
- MongoDB Compass’s 3,224 distinct npm archives were checked against 4,672 source-lock references and their upstream integrity values. The shipped `elkjs` license text is EPL-2.0 and `@csstools/color-helpers` uses MIT-0, so those identifiers were added. Source: [exact release lock](https://github.com/mongodb-js/compass/blob/v1.53.2/package-lock.json). The source SSPL-1 grant and Electron/native dependency versions are unchanged.
- OpenClaw’s runtime-only npm lock was regenerated with `--package-lock-only --ignore-scripts --omit=dev`; no npm package installation or lifecycle scripts ran during resolution. The generated inventory contains 482 package license entries and 354 node_modules paths. The new published tarball retains its MIT license text.
- Open WebUI’s main wheel license texts match the previous wheel. Its newly resolved private environment was checked for top-level file collisions and for dependency metadata consistency by the build. Its PyAV wheel bundles libx264/libx265 separately from libavcodec’s reported LGPL-3+ license; GPL-2+ was added using the upstream [x264 header](https://code.videolan.org/videolan/x264/-/raw/stable/x264.h) and [x265 header](https://bitbucket.org/multicoreware/x265_git/raw/master/source/x265.h). CPU-only Torch remains selected on both architectures. See `wheel-license-metadata.json` and `ffmpeg-license-audit.json`.
- Betterbird’s shipped `omni.ja` licensing pages identify MPL application code and GPL/LGPL components. The declaration now includes GPL-2 and LGPL-2.1, consistent with the corresponding terms in those pages; `::gentoo` Thunderbird binary ebuilds were also inspected as practice, not as the authority for the grant.
- Cursor, Grok Bot and ChatGPT Chromium notice comparisons found no new distinct license texts against the cached previous amd64 artifacts (299, 299 and 262 distinct texts respectively). Their primary proprietary status is unchanged. Claude’s shipped copyright text is unchanged. GitHub Copilot CLI’s [exact release LICENSE.md](https://github.com/github/copilot-cli/blob/v1.0.105/LICENSE.md) and Kiro’s [upstream terms](https://kiro.dev/license/) were consulted; existing proprietary license identifiers were retained.
- SonarScanner’s old/new shaded jars contain the same license/notice paths and Java class-version range. The existing Java dependency and license choices were retained. Aegisub’s source BSD grant, GSA’s AGPL grant, Kubernetes’ Apache grant, and the other shipped top-level notices were checked in their exact new artifacts.

INFERRED: manifest/license metadata and source notice inventories support the retained dependency-license unions, but this is not an upstream attestation of every proprietary binary’s static link inputs. Semgrep’s existing incomplete attribution was not represented as resolved.

## Commands and literal validation evidence

All normal ebuild phases were run without network fetching; artifacts were fetched beforehand into package workspaces. All install phases below target Portage image directories, not the live root. Rootless namespaces were used where staged ownership or sandbox ptrace operations required them. The temporary cargo-pgrx 0.19.3 tool was built and staged separately for the anonymizer check; the live tool was not replaced.

Each row above has these retained logs: `manifest-final.log`, `pkgcheck-before.log`, `pkgcheck-final.log`, and `build-amd64.log` and/or `build-arm64.log` under its package workspace. The exact commands follow; flags shown were actually used.

```sh
pkgdev manifest -d /tmp/codex/app-admin/kiro-cli-bin-2.34.0/distfiles app-admin/kiro-cli-bin
pkgcheck scan --cache-dir /tmp/codex/app-admin/kiro-cli-bin-2.34.0/pkgcheck-cache --cache=-git app-admin/kiro-cli-bin
bash -n app-admin/kiro-cli-bin/kiro-cli-bin-2.34.0.ebuild
pkgdev manifest -d /tmp/codex/app-editors/cursor-3.27.22/distfiles app-editors/cursor
pkgcheck scan --cache-dir /tmp/codex/app-editors/cursor-3.27.22/pkgcheck-cache --cache=-git app-editors/cursor
bash -n app-editors/cursor/cursor-3.27.22.ebuild
pkgdev manifest -d /tmp/codex/app-misc/chatgpt-bin-26.1023.51421/distfiles app-misc/chatgpt-bin
pkgcheck scan --cache-dir /tmp/codex/app-misc/chatgpt-bin-26.1023.51421/pkgcheck-cache --cache=-git app-misc/chatgpt-bin
bash -n app-misc/chatgpt-bin/chatgpt-bin-26.1023.51421.ebuild
pkgdev manifest -d /tmp/codex/app-misc/grok-bot-bin-0.77.0/distfiles app-misc/grok-bot-bin
pkgcheck scan --cache-dir /tmp/codex/app-misc/grok-bot-bin-0.77.0/pkgcheck-cache --cache=-git app-misc/grok-bot-bin
bash -n app-misc/grok-bot-bin/grok-bot-bin-0.77.0.ebuild
pkgdev manifest -d /tmp/codex/app-misc/openclaw-bin-2026.10.8/distfiles app-misc/openclaw-bin
pkgcheck scan --cache-dir /tmp/codex/app-misc/openclaw-bin-2026.10.8/pkgcheck-cache --cache=-git app-misc/openclaw-bin
bash -n app-misc/openclaw-bin/openclaw-bin-2026.10.8.ebuild
pkgdev manifest -d /tmp/codex/app-text/zettlr-bin-4.9.0/distfiles app-text/zettlr-bin
pkgcheck scan --cache-dir /tmp/codex/app-text/zettlr-bin-4.9.0/pkgcheck-cache --cache=-git app-text/zettlr-bin
bash -n app-text/zettlr-bin/zettlr-bin-4.9.0.ebuild
pkgdev manifest -d /tmp/codex/dev-db/dbgate-bin-7.3.3/distfiles dev-db/dbgate-bin
pkgcheck scan --cache-dir /tmp/codex/dev-db/dbgate-bin-7.3.3/pkgcheck-cache --cache=-git dev-db/dbgate-bin
bash -n dev-db/dbgate-bin/dbgate-bin-7.3.3.ebuild
pkgdev manifest -d /tmp/codex/dev-db/mongodb-compass-1.53.2/distfiles dev-db/mongodb-compass
pkgcheck scan --cache-dir /tmp/codex/dev-db/mongodb-compass-1.53.2/pkgcheck-cache --cache=-git dev-db/mongodb-compass
bash -n dev-db/mongodb-compass/mongodb-compass-1.53.2.ebuild
pkgdev manifest -d /tmp/codex/dev-db/postgresql_anonymizer-3.3.0/distfiles dev-db/postgresql_anonymizer
pkgcheck scan --cache-dir /tmp/codex/dev-db/postgresql_anonymizer-3.3.0/pkgcheck-cache --cache=-git dev-db/postgresql_anonymizer
bash -n dev-db/postgresql_anonymizer/postgresql_anonymizer-3.3.0.ebuild
pkgdev manifest -d /tmp/codex/dev-python/boto3-stubs-1.43.120/distfiles dev-python/boto3-stubs
pkgcheck scan --cache-dir /tmp/codex/dev-python/boto3-stubs-1.43.120/pkgcheck-cache --cache=-git dev-python/boto3-stubs
bash -n dev-python/boto3-stubs/boto3-stubs-1.43.120.ebuild
pkgdev manifest -d /tmp/codex/dev-python/botocore-stubs-1.43.120/distfiles dev-python/botocore-stubs
pkgcheck scan --cache-dir /tmp/codex/dev-python/botocore-stubs-1.43.120/pkgcheck-cache --cache=-git dev-python/botocore-stubs
bash -n dev-python/botocore-stubs/botocore-stubs-1.43.120.ebuild
pkgdev manifest -d /tmp/codex/dev-python/glances-api-0.11.0/distfiles dev-python/glances-api
pkgcheck scan --cache-dir /tmp/codex/dev-python/glances-api-0.11.0/pkgcheck-cache --cache=-git dev-python/glances-api
bash -n dev-python/glances-api/glances-api-0.11.0.ebuild
pkgdev manifest -d /tmp/codex/dev-python/mypy-boto3-ecr-1.43.119/distfiles dev-python/mypy-boto3-ecr
pkgcheck scan --cache-dir /tmp/codex/dev-python/mypy-boto3-ecr-1.43.119/pkgcheck-cache --cache=-git dev-python/mypy-boto3-ecr
bash -n dev-python/mypy-boto3-ecr/mypy-boto3-ecr-1.43.119.ebuild
pkgdev manifest -d /tmp/codex/dev-python/pipx-1.18.6/distfiles dev-python/pipx
pkgcheck scan --cache-dir /tmp/codex/dev-python/pipx-1.18.6/pkgcheck-cache --cache=-git dev-python/pipx
bash -n dev-python/pipx/pipx-1.18.6.ebuild
pkgdev manifest -d /tmp/codex/dev-python/posthog-7.76.0/distfiles dev-python/posthog
pkgcheck scan --cache-dir /tmp/codex/dev-python/posthog-7.76.0/pkgcheck-cache --cache=-git dev-python/posthog
bash -n dev-python/posthog/posthog-7.76.0.ebuild
pkgdev manifest -d /tmp/codex/dev-python/qh3-2.1.0/distfiles dev-python/qh3
pkgcheck scan --cache-dir /tmp/codex/dev-python/qh3-2.1.0/pkgcheck-cache --cache=-git dev-python/qh3
bash -n dev-python/qh3/qh3-2.1.0.ebuild
pkgdev manifest -d /tmp/codex/dev-python/urllib3-future-2.25.904/distfiles dev-python/urllib3-future
pkgcheck scan --cache-dir /tmp/codex/dev-python/urllib3-future-2.25.904/pkgcheck-cache --cache=-git dev-python/urllib3-future
bash -n dev-python/urllib3-future/urllib3-future-2.25.904.ebuild
pkgdev manifest -d /tmp/codex/dev-util/github-copilot-bin-1.1.33/distfiles dev-util/github-copilot-bin
pkgcheck scan --cache-dir /tmp/codex/dev-util/github-copilot-bin-1.1.33/pkgcheck-cache --cache=-git dev-util/github-copilot-bin
bash -n dev-util/github-copilot-bin/github-copilot-bin-1.1.33.ebuild
pkgdev manifest -d /tmp/codex/dev-util/github-copilot-cli-bin-1.0.105/distfiles dev-util/github-copilot-cli-bin
pkgcheck scan --cache-dir /tmp/codex/dev-util/github-copilot-cli-bin-1.0.105/pkgcheck-cache --cache=-git dev-util/github-copilot-cli-bin
bash -n dev-util/github-copilot-cli-bin/github-copilot-cli-bin-1.0.105.ebuild
pkgdev manifest -d /tmp/codex/dev-util/mise-bin-2026.10.21/distfiles dev-util/mise-bin
pkgcheck scan --cache-dir /tmp/codex/dev-util/mise-bin-2026.10.21/pkgcheck-cache --cache=-git dev-util/mise-bin
bash -n dev-util/mise-bin/mise-bin-2026.10.21.ebuild
pkgdev manifest -d /tmp/codex/dev-util/postman-bin-12.34.2/distfiles dev-util/postman-bin
pkgcheck scan --cache-dir /tmp/codex/dev-util/postman-bin-12.34.2/pkgcheck-cache --cache=-git dev-util/postman-bin
bash -n dev-util/postman-bin/postman-bin-12.34.2.ebuild
pkgdev manifest -d /tmp/codex/dev-util/sonarscanner-bin-8.3.0.16463/distfiles dev-util/sonarscanner-bin
pkgcheck scan --cache-dir /tmp/codex/dev-util/sonarscanner-bin-8.3.0.16463/pkgcheck-cache --cache=-git dev-util/sonarscanner-bin
bash -n dev-util/sonarscanner-bin/sonarscanner-bin-8.3.0.16463.ebuild
pkgdev manifest -d /tmp/codex/mail-client/betterbird-bin-153.6.0/distfiles mail-client/betterbird-bin
pkgcheck scan --cache-dir /tmp/codex/mail-client/betterbird-bin-153.6.0/pkgcheck-cache --cache=-git mail-client/betterbird-bin
bash -n mail-client/betterbird-bin/betterbird-bin-153.6.0.ebuild
pkgdev manifest -d /tmp/codex/media-sound/plexamp-4.50.20/distfiles media-sound/plexamp
pkgcheck scan --cache-dir /tmp/codex/media-sound/plexamp-4.50.20/pkgcheck-cache --cache=-git media-sound/plexamp
bash -n media-sound/plexamp/plexamp-4.50.20.ebuild
pkgdev manifest -d /tmp/codex/media-video/aegisub-3.5.1/distfiles media-video/aegisub
pkgcheck scan --cache-dir /tmp/codex/media-video/aegisub-3.5.1/pkgcheck-cache --cache=-git media-video/aegisub
bash -n media-video/aegisub/aegisub-3.5.1.ebuild
pkgdev manifest -d /tmp/codex/net-analyzer/gsa-28.7.0/distfiles net-analyzer/gsa
pkgcheck scan --cache-dir /tmp/codex/net-analyzer/gsa-28.7.0/pkgcheck-cache --cache=-git net-analyzer/gsa
bash -n net-analyzer/gsa/gsa-28.7.0.ebuild
pkgdev manifest -d /tmp/codex/net-im/claude-desktop-bin-4.29.0/distfiles net-im/claude-desktop-bin
pkgcheck scan --cache-dir /tmp/codex/net-im/claude-desktop-bin-4.29.0/pkgcheck-cache --cache=-git net-im/claude-desktop-bin
bash -n net-im/claude-desktop-bin/claude-desktop-bin-4.29.0.ebuild
pkgdev manifest -d /tmp/codex/sys-cluster/egctl-bin-1.9.3/distfiles sys-cluster/egctl-bin
pkgcheck scan --cache-dir /tmp/codex/sys-cluster/egctl-bin-1.9.3/pkgcheck-cache --cache=-git sys-cluster/egctl-bin
bash -n sys-cluster/egctl-bin/egctl-bin-1.9.3.ebuild
pkgdev manifest -d /tmp/codex/sys-cluster/kubectl-convert-1.37.2/distfiles sys-cluster/kubectl-convert
pkgcheck scan --cache-dir /tmp/codex/sys-cluster/kubectl-convert-1.37.2/pkgcheck-cache --cache=-git sys-cluster/kubectl-convert
bash -n sys-cluster/kubectl-convert/kubectl-convert-1.37.2.ebuild
pkgdev manifest -d /tmp/codex/www-apps/open-webui-bin-0.12.4/distfiles www-apps/open-webui-bin
pkgcheck scan --cache-dir /tmp/codex/www-apps/open-webui-bin-0.12.4/pkgcheck-cache --cache=-git www-apps/open-webui-bin
bash -n www-apps/open-webui-bin/open-webui-bin-0.12.4.ebuild
```

Native build commands (successful final runs; earlier failures and their corrections remain in the workspace logs):

```sh
PORTAGE_CONFIGROOT=/tmp/codex/app-admin/kiro-cli-bin-2.34.0/config-rootless unshare --user --map-auto --map-root-user ebuild app-admin/kiro-cli-bin/kiro-cli-bin-2.34.0.ebuild clean unpack prepare configure compile install
PORTAGE_CONFIGROOT=/tmp/codex/app-editors/cursor-3.27.22/config ebuild app-editors/cursor/cursor-3.27.22.ebuild clean unpack prepare configure compile install
PORTAGE_CONFIGROOT=/tmp/codex/app-misc/chatgpt-bin-26.1023.51421/config ebuild app-misc/chatgpt-bin/chatgpt-bin-26.1023.51421.ebuild clean unpack prepare configure compile install
PORTAGE_CONFIGROOT=/tmp/codex/app-misc/grok-bot-bin-0.77.0/config ebuild app-misc/grok-bot-bin/grok-bot-bin-0.77.0.ebuild clean unpack prepare configure compile install
PORTAGE_CONFIGROOT=/tmp/codex/app-misc/openclaw-bin-2026.10.8/config-rootless unshare --user --map-auto --map-root-user ebuild app-misc/openclaw-bin/openclaw-bin-2026.10.8.ebuild clean unpack prepare configure compile install
PORTAGE_CONFIGROOT=/tmp/codex/app-text/zettlr-bin-4.9.0/config-rootless unshare --user --map-auto --map-root-user ebuild app-text/zettlr-bin/zettlr-bin-4.9.0.ebuild clean unpack prepare configure compile install
PORTAGE_CONFIGROOT=/tmp/codex/dev-db/dbgate-bin-7.3.3/config-rootless unshare --user --map-auto --map-root-user ebuild dev-db/dbgate-bin/dbgate-bin-7.3.3.ebuild clean unpack prepare configure compile install
# On gentoo, in its temporary staged repository:
PORTAGE_CONFIGROOT=/tmp/codex/dev-db/dbgate-bin-7.3.3/config unshare --user --map-auto --map-root-user ebuild /tmp/codex/dev-db/dbgate-bin-7.3.3/repo/dev-db/dbgate-bin/dbgate-bin-7.3.3.ebuild clean unpack prepare configure compile install
# On gentoo, in its temporary staged repository:
PORTAGE_CONFIGROOT=/tmp/codex/dev-db/mongodb-compass-1.53.2/config unshare --user --map-auto --map-root-user ebuild /tmp/codex/dev-db/mongodb-compass-1.53.2/repo/dev-db/mongodb-compass/mongodb-compass-1.53.2.ebuild clean unpack prepare configure compile install
PATH=/tmp/codex/dev-util/cargo-pgrx-0.19.3/portage/portage/dev-util/cargo-pgrx-0.19.3/image/usr/bin:$PATH PORTAGE_CONFIGROOT=/tmp/codex/dev-db/postgresql_anonymizer-3.3.0/config-rootless unshare --user --map-auto --map-root-user ebuild dev-db/postgresql_anonymizer/postgresql_anonymizer-3.3.0.ebuild clean unpack prepare configure compile install
PORTAGE_CONFIGROOT=/tmp/codex/dev-python/boto3-stubs-1.43.120/config ebuild dev-python/boto3-stubs/boto3-stubs-1.43.120.ebuild clean unpack prepare configure compile install
PORTAGE_CONFIGROOT=/tmp/codex/dev-python/botocore-stubs-1.43.120/config ebuild dev-python/botocore-stubs/botocore-stubs-1.43.120.ebuild clean unpack prepare configure compile install
PORTAGE_CONFIGROOT=/tmp/codex/dev-python/glances-api-0.11.0/config ebuild dev-python/glances-api/glances-api-0.11.0.ebuild clean unpack prepare configure compile install
PORTAGE_CONFIGROOT=/tmp/codex/dev-python/mypy-boto3-ecr-1.43.119/config ebuild dev-python/mypy-boto3-ecr/mypy-boto3-ecr-1.43.119.ebuild clean unpack prepare configure compile install
PORTAGE_CONFIGROOT=/tmp/codex/dev-python/pipx-1.18.6/config ebuild dev-python/pipx/pipx-1.18.6.ebuild clean unpack prepare configure compile install
PORTAGE_CONFIGROOT=/tmp/codex/dev-python/posthog-7.76.0/config ebuild dev-python/posthog/posthog-7.76.0.ebuild clean unpack prepare configure compile install
PORTAGE_CONFIGROOT=/tmp/codex/dev-python/qh3-2.1.0/config-rootless unshare --user --map-auto --map-root-user ebuild dev-python/qh3/qh3-2.1.0.ebuild clean unpack prepare configure compile install
PORTAGE_CONFIGROOT=/tmp/codex/dev-python/urllib3-future-2.25.904/config ebuild dev-python/urllib3-future/urllib3-future-2.25.904.ebuild clean unpack prepare configure compile install
PORTAGE_CONFIGROOT=/tmp/codex/dev-util/github-copilot-bin-1.1.33/config ebuild dev-util/github-copilot-bin/github-copilot-bin-1.1.33.ebuild clean unpack prepare configure compile install
PORTAGE_CONFIGROOT=/tmp/codex/dev-util/github-copilot-cli-bin-1.0.105/config-rootless unshare --user --map-auto --map-root-user ebuild dev-util/github-copilot-cli-bin/github-copilot-cli-bin-1.0.105.ebuild clean unpack prepare configure compile install
PORTAGE_CONFIGROOT=/tmp/codex/dev-util/mise-bin-2026.10.21/config-rootless unshare --user --map-auto --map-root-user ebuild dev-util/mise-bin/mise-bin-2026.10.21.ebuild clean unpack prepare configure compile install
PORTAGE_CONFIGROOT=/tmp/codex/dev-util/postman-bin-12.34.2/config ebuild dev-util/postman-bin/postman-bin-12.34.2.ebuild clean unpack prepare configure compile install
PORTAGE_CONFIGROOT=/tmp/codex/dev-util/sonarscanner-bin-8.3.0.16463/config-rootless unshare --user --map-auto --map-root-user ebuild dev-util/sonarscanner-bin/sonarscanner-bin-8.3.0.16463.ebuild clean unpack prepare configure compile install
PORTAGE_CONFIGROOT=/tmp/codex/mail-client/betterbird-bin-153.6.0/config ebuild mail-client/betterbird-bin/betterbird-bin-153.6.0.ebuild clean unpack prepare configure compile install
PORTAGE_CONFIGROOT=/tmp/codex/media-sound/plexamp-4.50.20/config-rootless unshare --user --map-auto --map-root-user ebuild media-sound/plexamp/plexamp-4.50.20.ebuild clean unpack prepare configure compile install
# On gentoo, in its temporary staged repository:
PORTAGE_CONFIGROOT=/tmp/codex/media-video/aegisub-3.5.1/config unshare --user --map-auto --map-root-user ebuild /tmp/codex/media-video/aegisub-3.5.1/repo/media-video/aegisub/aegisub-3.5.1.ebuild clean unpack prepare configure compile install
# On gentoo, in its temporary staged repository:
PORTAGE_CONFIGROOT=/tmp/codex/net-analyzer/gsa-28.7.0/config unshare --user --map-auto --map-root-user ebuild /tmp/codex/net-analyzer/gsa-28.7.0/repo/net-analyzer/gsa/gsa-28.7.0.ebuild clean unpack prepare configure compile install
PORTAGE_CONFIGROOT=/tmp/codex/net-im/claude-desktop-bin-4.29.0/config ebuild net-im/claude-desktop-bin/claude-desktop-bin-4.29.0.ebuild clean unpack prepare configure compile install
PORTAGE_CONFIGROOT=/tmp/codex/sys-cluster/egctl-bin-1.9.3/config-rootless unshare --user --map-auto --map-root-user ebuild sys-cluster/egctl-bin/egctl-bin-1.9.3.ebuild clean unpack prepare configure compile install
PORTAGE_CONFIGROOT=/tmp/codex/sys-cluster/kubectl-convert-1.37.2/config-rootless unshare --user --map-auto --map-root-user ebuild sys-cluster/kubectl-convert/kubectl-convert-1.37.2.ebuild clean unpack prepare configure compile install
PORTAGE_CONFIGROOT=/tmp/codex/www-apps/open-webui-bin-0.12.4/config-rootless unshare --user --map-auto --map-root-user ebuild www-apps/open-webui-bin/open-webui-bin-0.12.4.ebuild clean unpack prepare configure compile install
```

VERIFIED — all 30 final Manifest commands exited 0, with literal output in this form:

```text
 * generating manifest: dev-db/postgresql_anonymizer::local
```

VERIFIED — all 30 final scoped scans exited 0. Empty output is recorded for packages without findings. Existing findings remain; scan exit 0 is not described as a warning-free result. Representative literal findings:

```text
media-video/aegisub
  NonsolvableDepsInDev: version 3.5.1: nonsolvable depset(depend) keyword(~arm64) dev profile (default/linux/arm64/23.0/hardened) (9 total): solutions: [ >=media-libs/ffmpegsource-2.22:= ]
  NonsolvableDepsInDev: version 3.5.1: nonsolvable depset(rdepend) keyword(~arm64) dev profile (default/linux/arm64/23.0/hardened) (9 total): solutions: [ >=media-libs/ffmpegsource-2.22:= ]
  NonsolvableDepsInStable: version 3.5.1: nonsolvable depset(depend) keyword(~arm64) stable profile (default/linux/arm64/23.0) (12 total): solutions: [ >=media-libs/ffmpegsource-2.22:= ]
  NonsolvableDepsInStable: version 3.5.1: nonsolvable depset(rdepend) keyword(~arm64) stable profile (default/linux/arm64/23.0) (12 total): solutions: [ >=media-libs/ffmpegsource-2.22:= ]
dev-python/glances-api
  DeprecatedDep: version 0.11.0: BDEPEND: deprecated dependencies: <dev-python/httpx-1[python_targets_python3_13(-)?,python_targets_python3_14(-)?,python_targets_python3_15(-)?] >=dev-python/httpx-0.28[python_targets_python3_13(-)?,python_targets_python3_14(-)?,python_targets_python3_15(-)?]
  DeprecatedDep: version 0.11.0: RDEPEND: deprecated dependencies: <dev-python/httpx-1[python_targets_python3_13(-)?,python_targets_python3_14(-)?,python_targets_python3_15(-)?] >=dev-python/httpx-0.28[python_targets_python3_13(-)?,python_targets_python3_14(-)?,python_targets_python3_15(-)?]
dev-python/qh3
  PythonCompatUpdate: version 2.1.0: PYTHON_COMPAT update available: python3_15
dev-util/mise-bin
  NonsolvableDepsInDev: version 2026.10.21: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total): solutions: [ >=sys-libs/glibc-2.18 ]
  RequiredUseDefaults: version 2026.10.21: profile: 'default/linux/amd64/23.0/musl' (6 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 2026.10.21: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total)
```

The finding classes above also occur in the pre-change scans: Aegisub’s ffmpegsource keyword/dependency issue, glances-api’s deprecated httpx dependency, PythonCompatUpdate suggestions, and binary-package musl profile restrictions. They were not suppressed or fixed by changing unrelated packages.

VERIFIED — representative literal successful staged-build output:

```text
>>> Completed installing dev-db/postgresql_anonymizer-3.3.0 into /tmp/codex/dev-db/postgresql_anonymizer-3.3.0/portage/portage/dev-db/postgresql_anonymizer-3.3.0/image
>>> Completed installing dev-db/mongodb-compass-1.53.2 into /tmp/codex/dev-db/mongodb-compass-1.53.2/portage/portage/dev-db/mongodb-compass-1.53.2/image
>>> Completed installing media-video/aegisub-3.5.1 into /tmp/codex/media-video/aegisub-3.5.1/portage/portage/media-video/aegisub-3.5.1/image
>>> Completed installing net-analyzer/gsa-28.7.0 into /tmp/codex/net-analyzer/gsa-28.7.0/portage/portage/net-analyzer/gsa-28.7.0/image
>>> Completed installing dev-db/dbgate-bin-7.3.3 into /tmp/codex/dev-db/dbgate-bin-7.3.3/portage/portage/dev-db/dbgate-bin-7.3.3/image
>>> Completed installing www-apps/open-webui-bin-0.12.4 into /tmp/codex/www-apps/open-webui-bin-0.12.4/portage/portage/www-apps/open-webui-bin-0.12.4/image
>>> Completed installing dev-python/qh3-2.1.0 into /tmp/codex/dev-python/qh3-2.1.0/portage/portage/dev-python/qh3-2.1.0/image
private dependency metadata check: 242 distributions satisfied
qh3 staged Python and Rust-extension imports: 2.1.0
QUIC connection class: QuicConnection
Overlay dependency version atoms satisfied: 15
Keyword sets preserved: 30
```

Additional commands actually run included `readelf -h -d --version-info` on staged ELF objects; archive inventories and notice hash comparisons; `go version -m` on egctl; `go mod download -json` with private GOMODCACHE/GOCACHE/GOPATH; npm lock-only resolution; two pip `--dry-run --report` resolutions; both repository dependency generators; `patch -p1 --dry-run --batch` for Aegisub/PostHog; scoped shell syntax checks; and `git diff --check`. Full package-specific outputs remain under `/tmp/codex`.

VERIFIED — DBGate’s staged arm64 image contains only AArch64 ELF objects; both SQLite and Oracle arm64 addons remain installed. The maximum recorded glibc requirement is 2.34 on both tested architectures. No ABI or SONAME rewriting was used.

NOT VERIFIED — graphical startup, live service/API integrations, PostgreSQL database extension loading/migrations, full upstream test suites, every USE combination, and every supported Python/PostgreSQL slot. The anonymizer build used PostgreSQL 17; Python source builds used Python 3.14, and the bundled Open WebUI closure targets CPython 3.12. Twenty-six dual-keyword packages still need native arm64 build/runtime validation by the user; the three arm64-only packages do not claim amd64 validation. Source recompilation is not claimed for prebuilt application payloads.

## Official Gentoo references and repository changes

- [PMS index](https://projects.gentoo.org/pms/) and [EAPI 9 specification](https://projects.gentoo.org/pms/9/pms.html): EAPI 9 remains the latest published specification.
- [Devmanual dependencies](https://devmanual.gentoo.org/general-concepts/dependencies/) and [ebuild variables](https://devmanual.gentoo.org/ebuild-writing/variables/): dependency operators, phase variables and metadata semantics.
- Current eclass contracts/implementations under `/var/db/repos/gentoo/eclass/` were consulted, including distutils-r1, cargo, postgres, llvm-r2, go-module, meson, python-single-r1, python-any-r1, unpacker, chromium-2, xdg and java-pkg-2. Required eclasses that accept only EAPI 8 prevent converting those packages to EAPI 9. Existing EAPI 9 packages remain at 9.
- Current package examples were searched in `::gentoo` and `::guru` before editing. The relevant prior-art paths are recorded in each `audit.json`; no version, dependency bound or license was copied from an overlay without checking upstream inputs. Gentoo bug searches for the observed GPaste/Semgrep release issues found no matching result; no claim that these issues are new is made.

Changed files comprise the 30 new ebuilds and their 30 removed predecessors, 30 scoped Manifests, the new/replaced Compass dependency eclass and its generator, the new OpenClaw lock/notice inventory, two new Open WebUI resolver reports, removal of Aegisub’s upstreamed BOM patch, and a current-version note in the arm64 desktop README. Historical README evidence was preserved. Existing unrelated patches, older notice inventories, non-target ebuild versions and repository files remain untouched.

No package merge, qmerge, service restart, live-system installation, branch, commit, push or repository synchronization was performed.

## Open WebUI main-wheel URL correction and fresh-fetch check

The main-wheel `SRC_URI` retained the previous wheel’s content-addressed directory after its filename was bumped. The ebuild now uses the [exact 0.12.4 wheel URL](https://files.pythonhosted.org/packages/d5/68/ba67840b98eb35636dbfb0685a6b4c3c02e26bd60e500f56d2e52216c13c/open_webui-0.12.4-py3-none-any.whl), already correctly linked in the package table. The Manifest is unchanged. Earlier cached-distfile Manifest/build results did not establish that the ebuild’s main-wheel URL worked for a fresh fetch.

VERIFIED — `/tmp/codex/www-apps/open-webui-bin-0.12.4/fresh-wheel-fix-t2eg1e5s/download` was created empty and asserted empty immediately before downloading. No existing distfile or symlink was reused. Separate curl requests fetched the wheel and [fresh PyPI release JSON](https://pypi.org/pypi/open-webui/0.12.4/json). Python hashlib assertions checked the wheel’s SHA256 against the supplied value and fresh PyPI metadata, its URL against the JSON entry, and its size and all recorded digests against the Manifest.

```text
Fresh download SHA256: 02e9caba96234db3fa17a92e56163b3f7f2b8ca8227fa886b85c178d696483f6
PyPI SHA256: 02e9caba96234db3fa17a92e56163b3f7f2b8ca8227fa886b85c178d696483f6
Bytes: 106366595
Manifest checks matched: BLAKE2B, SHA512
Manifest SHA256 entry present: False
```

The Manifest has no SHA256 field: it records size, BLAKE2B and SHA512. Both recorded hashes and its size match the same fresh bytes whose SHA256 matches PyPI and the requested value. No Manifest regeneration or digest changes were needed.

Commands actually run:

```sh
curl --fail --location --silent --show-error --max-time 180 https://files.pythonhosted.org/packages/d5/68/ba67840b98eb35636dbfb0685a6b4c3c02e26bd60e500f56d2e52216c13c/open_webui-0.12.4-py3-none-any.whl --output /tmp/codex/www-apps/open-webui-bin-0.12.4/fresh-wheel-fix-t2eg1e5s/download/open_webui-0.12.4-py3-none-any.whl
curl --fail --location --silent --show-error --max-time 60 https://pypi.org/pypi/open-webui/0.12.4/json --output /tmp/codex/www-apps/open-webui-bin-0.12.4/fresh-wheel-fix-t2eg1e5s/pypi-fresh.json
bash -n www-apps/open-webui-bin/open-webui-bin-0.12.4.ebuild
pkgcheck scan --cache-dir /tmp/codex/www-apps/open-webui-bin-0.12.4/fresh-wheel-fix-t2eg1e5s/pkgcheck-cache --cache=-git www-apps/open-webui-bin
git diff --check
```

VERIFIED — bash syntax and git whitespace checks exited 0 with no output. Scoped pkgcheck exited 0 with the literal output below. It is byte-for-byte identical to the retained pre-fix scoped scan output.

```text
www-apps/open-webui-bin
  NonsolvableDepsInDev: version 0.12.4: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total): solutions: [ >=sys-libs/glibc-2.28 ]
  PythonCompatUpdate: version 0.12.4: PYTHON_COMPAT updates available: python3_13, python3_14, python3_15
  RequiredUseDefaults: version 0.12.4: profile: 'default/linux/amd64/23.0/musl' (6 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 0.12.4: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total)
```

Fresh-fetch evidence and command outputs are retained in `/tmp/codex/www-apps/open-webui-bin-0.12.4/fresh-wheel-fix-t2eg1e5s/verification.json` and `/tmp/codex/www-apps/open-webui-bin-0.12.4/fresh-wheel-fix-t2eg1e5s/checks.json`.

NOT VERIFIED — no new amd64 or arm64 build/runtime testing was performed for this URL-only correction. Earlier architecture results remain as recorded above. No package installation, merge, qmerge, commit or push was performed.
